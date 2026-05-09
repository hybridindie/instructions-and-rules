// Opencode graphify plugin
// Identical functionality to Claude Code /graphify command
// Usage: /graphify <path> [--update]

const { execSync } = require('child_process');
const path = require('path');

module.exports = {
  name: 'graphify',
  description: 'Build or update knowledge graph for backend or frontend source',
  arguments: [
    { name: 'sourcePath', description: 'Path to source directory (e.g., backend/src)', required: true },
    { name: 'update', description: 'Incremental update only', required: false }
  ],
  execute(args) {
    const src = args.sourcePath || 'backend/src';
    const updateFlag = args.update ? '--update' : '';
    try {
      const output = execSync(`npx graphify ${src} ${updateFlag}`, { encoding: 'utf-8', cwd: process.cwd() });
      return output;
    } catch (e) {
      return `Graphify failed: ${e.stderr || e.message}`;
    }
  }
};
