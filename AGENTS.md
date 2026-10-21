# tree-sitter-mux

`tree-sitter-mux` is the parser grammar and editor query package used by
Neovim, Helix, and Emacs.

Cross-repository architecture and release facts live in
[`mux-context`](https://github.com/muxlang/mux-context). Read its canonical
[`SKILL.md`](https://github.com/muxlang/mux-context/blob/main/SKILL.md) before
changing syntax or a generated consumer.

## Invariants

- Keep `grammar.js` at the repository root and self-contained.
- `syntax-matrix.json` is vendored from `mux-syntax-highlighting`; update it
  deliberately and verify parity when the canonical spec changes.
- `src/parser.c`, `src/grammar.json`, and `src/node-types.json` are committed
  generated artifacts. Regenerate them with every grammar change and reject
  generated drift.

## Quality gate

Run `tree-sitter generate grammar.js`, `tree-sitter test`, and the repository's
parity/check scripts before committing grammar changes. The pre-commit hook
runs generation and corpus checks for grammar changes. CI also checks parser
ABI compatibility on supported platforms and runs the Neovim integration
checks.

## Documentation

See [`README.md`](README.md) and the canonical syntax specification in
`mux-syntax-highlighting`. See the
[cross-repo testing policy](https://github.com/muxlang/mux-context/blob/main/docs/testing-policy.md)
for the distinction between grammar, editor, and compiler tests.
