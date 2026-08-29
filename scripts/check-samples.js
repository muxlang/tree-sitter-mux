#!/usr/bin/env node

const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const root = path.resolve(__dirname, '..');
const samples = ['test.mux', 'validation.mux'];
const cacheRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'tree-sitter-mux-cache-'));

function run(args) {
  return spawnSync('tree-sitter', args, {
    cwd: root,
    encoding: 'utf8',
    env: { ...process.env, XDG_CACHE_HOME: cacheRoot },
  });
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

try {
  for (const sample of samples) {
    const parse = run(['parse', '--quiet', sample]);
    assert(parse.status === 0, `${sample} could not be parsed: ${parse.stderr.trim()}`);
    assert(!/\b(?:ERROR|MISSING)\b/.test(parse.stdout), `${sample} contains a parse error`);

    const highlight = run(['highlight', '--scope', 'source.mux', '--quiet', sample]);
    const diagnostic = `${highlight.stdout}\n${highlight.stderr}`;
    assert(highlight.status === 0, `${sample} could not be highlighted: ${diagnostic.trim()}`);
    assert(highlight.stdout.trim().length > 0, `${sample} produced no highlight output`);
    assert(!/No language found/i.test(diagnostic), `${sample} was not loaded as Mux`);
  }

  console.log(`Tree-sitter sample checks passed (${samples.length} samples).`);
} finally {
  fs.rmSync(cacheRoot, { recursive: true, force: true });
}
