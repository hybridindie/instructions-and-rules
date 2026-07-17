# Warns when editing harness pointer files instead of .agents/.
# Windows/PowerShell equivalent of warn-pointer-edit.sh.
# Input arrives on stdin as JSON with tool_input.file_path.
# Print a warning to stderr; exit 0 so normal flow continues.

$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }
try { $file = ($raw | ConvertFrom-Json).tool_input.file_path } catch { exit 0 }
if (-not $file) { exit 0 }

$lower = $file.ToLower().Replace('\', '/')
$patterns = @(
  '/.opencode/', '/.claude/', '/.github/copilot-instructions.md',
  '/.github/skills/'
)
foreach ($p in $patterns) {
  if ($lower.Contains($p)) {
    [Console]::Error.WriteLine("Reminder: editable content lives in .agents/. The file you are editing is a harness pointer. If you are changing canonical content, edit the corresponding file in .agents/ instead.")
    break
  }
}
exit 0
