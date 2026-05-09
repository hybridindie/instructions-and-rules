#!/usr/bin/env python3
"""
Generate Copilot instruction mirrors from Claude rules.

Reads every .claude/rules/**/*.md file, extracts the frontmatter paths,
and writes a corresponding .github/instructions/*.instructions.md file
with Copilot-style frontmatter (description + applyTo).

workflow.md is skipped per primitive-drift policy.
"""

import os
import re
import sys


def extract_frontmatter_and_body(text):
    m = re.match(r'^---\n(.*?)\n---\n(.*)', text, re.DOTALL)
    if not m:
        return None, text
    return m.group(1), m.group(2)


def extract_paths(fm_text):
    lines = fm_text.split('\n')
    in_paths = False
    paths = []
    for line in lines:
        if line.strip().startswith('paths:'):
            in_paths = True
            continue
        if in_paths:
            stripped = line.strip()
            if stripped.startswith('- '):
                path = stripped[2:].strip().strip('"').strip("'")
                paths.append(path)
            elif stripped and not line.startswith(' '):
                break
    return paths


def generate_mirror(claude_file, out_dir):
    with open(claude_file, 'r', encoding='utf-8') as f:
        text = f.read()

    fm, body = extract_frontmatter_and_body(text)
    if fm is None:
        # No frontmatter — write mirror without applyTo
        copilot_fm = '---\n---\n'
    else:
        paths = extract_paths(fm)
        title_match = re.search(r'^# (.+)$', body, re.MULTILINE)
        description = title_match.group(1).strip() if title_match else "Project rule"
        # Escape quotes in description
        description = description.replace('"', '\\"')

        copilot_fm = f'---\ndescription: "{description}"\n'
        if paths:
            apply_to = ', '.join(paths)
            copilot_fm += f'applyTo: "{apply_to}"\n'
        copilot_fm += '---\n'

    rel = os.path.relpath(claude_file, start=os.path.join(out_dir, '.claude', 'rules'))
    base = rel.replace(os.sep, '-').replace('.md', '.instructions.md')
    out_file = os.path.join(out_dir, '.github', 'instructions', base)

    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    with open(out_file, 'w', encoding='utf-8') as f:
        f.write(copilot_fm + body)

    print(f"  Mirrored: .claude/rules/{rel} -> .github/instructions/{base}")


def main():
    if len(sys.argv) < 2:
        print("Usage: python generate-copilot-mirrors.py <output_dir>")
        sys.exit(1)

    out_dir = sys.argv[1]
    rules_dir = os.path.join(out_dir, '.claude', 'rules')

    if not os.path.isdir(rules_dir):
        print(f"Rules directory not found: {rules_dir}")
        sys.exit(1)

    for root, _dirs, files in os.walk(rules_dir):
        for fname in files:
            if not fname.endswith('.md'):
                continue
            rel = os.path.relpath(os.path.join(root, fname), start=rules_dir)
            # workflow.md has no Copilot mirror per primitive-drift policy
            if rel == 'workflow.md':
                print(f"  Skipped:  .claude/rules/{rel} (no Copilot mirror)")
                continue
            generate_mirror(os.path.join(root, fname), out_dir)


if __name__ == '__main__':
    main()
