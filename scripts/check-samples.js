#!/usr/bin/env node

const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const root = path.resolve(__dirname, '..');
const samples = ['test.mux', 'validation.mux'];
const cacheRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'tree-sitter-mux-cache-'));
const treeSitterBinary = process.env.TREE_SITTER_BIN;

if (!treeSitterBinary || !path.isAbsolute(treeSitterBinary)) {
  throw new Error('TREE_SITTER_BIN must be an absolute path to the pinned tree-sitter executable');
}

function run(args) {
  const previousCache = process.env.XDG_CACHE_HOME;
  process.env.XDG_CACHE_HOME = cacheRoot;
  try {
    return spawnSync(treeSitterBinary, args, {
      cwd: root,
      encoding: 'utf8',
    });
  } finally {
    if (previousCache === undefined) {
      delete process.env.XDG_CACHE_HOME;
    } else {
      process.env.XDG_CACHE_HOME = previousCache;
    }
  }
}

function diagnostic(result) {
  const stdout = result.stdout ?? '';
  const stderr = result.stderr ?? '';
  const spawnError = result.error ? ` (${result.error.message})` : '';
  return `${stdout}\n${stderr}${spawnError}`.trim();
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

try {
  for (const sample of samples) {
    const parse = run(['parse', '--quiet', sample]);
    assert(parse.status === 0, `${sample} could not be parsed: ${diagnostic(parse)}`);
    assert(!/\b(?:ERROR|MISSING)\b/.test(parse.stdout ?? ''), `${sample} contains a parse error`);

    const highlight = run(['highlight', '--scope', 'source.mux', '--quiet', sample]);
    const highlightDiagnostic = diagnostic(highlight);
    assert(highlight.status === 0, `${sample} could not be highlighted: ${highlightDiagnostic}`);
    assert((highlight.stdout ?? '').trim().length > 0, `${sample} produced no highlight output`);
    assert(!/No language found/i.test(highlightDiagnostic), `${sample} was not loaded as Mux`);
  }

  console.log(`Tree-sitter sample checks passed (${samples.length} samples).`);
} finally {
  fs.rmSync(cacheRoot, { recursive: true, force: true });
}
