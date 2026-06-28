# tree-sitter-mux: AI Agent Guidelines

Tree-sitter grammar for the Mux language (Neovim/Helix/Emacs). `grammar.js` is at
the repo root, as the tree-sitter ecosystem requires. Part of the multi-repo
[muxlang](https://github.com/muxlang) ecosystem.

## Critical Rules

- **No special characters** - avoid em-dashes, emojis, or other non-ASCII in code,
  comments, or commit messages.
- **`grammar.js` MUST stay at the root** and self-contained (no `../` requires) -
  nvim-treesitter and others run `tree-sitter generate` against it directly.
- **Understand existing code first**; follow existing grammar patterns.
- Pin tree-sitter-cli to **0.26.8** (matches what generated the committed queries).

## The vendored spec (important)

`grammar.js` reads `./syntax-matrix.json`, a VENDORED copy of the canonical syntax
spec that lives in `mux-syntax-highlighting`. When the canonical spec changes, this
copy must be updated to match. A cross-repo CI parity check (vendored vs canonical)
is planned as part of the spec-consolidation work; until it lands, keep them in
sync by hand. Do not let this copy drift.

## Generated artifacts

`tree-sitter generate` produces `src/parser.c`, `src/grammar.json`,
`src/node-types.json` - these are gitignored and regenerated; do not commit them.
`queries/highlights.scm` is a vendored generated artifact (committed).

## Development

```bash
npm install -g tree-sitter-cli@0.26.8
tree-sitter generate grammar.js
tree-sitter test
```

CI runs generate + test + a SonarQube scan.

## Related repos

- `mux-syntax-highlighting` - canonical syntax spec + TextMate-family highlighting.
- `mux-compiler` - the language/compiler.

**Add to this document as you learn vital information.**
