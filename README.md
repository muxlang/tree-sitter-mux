# tree-sitter-mux

[Tree-sitter](https://tree-sitter.github.io/tree-sitter/) grammar for the
[Mux programming language](https://github.com/muxlang). Powers parser-based editor
tooling: Neovim (nvim-treesitter), Helix, and Emacs.

`grammar.js` lives at the repo root, as the tree-sitter ecosystem expects.

## Layout

- `grammar.js` - the grammar definition (the source of truth for the parser).
- `syntax-matrix.json` - vendored copy of the canonical syntax spec; `grammar.js`
  reads it. The canonical spec is maintained in
  [mux-syntax-highlighting](https://github.com/muxlang/mux-syntax-highlighting);
  keep this copy in sync with it. CI verifies the vendored copy against canonical
  on every push/PR and fails on drift; run `./scripts/sync-matrix.sh` to refresh
  it in one command (then commit the updated `syntax-matrix.json`).
- `queries/highlights.scm` - highlight queries (generated from the spec, vendored).
- `test/` - corpus tests run by `tree-sitter test`.

## Development

```bash
npm install -g tree-sitter-cli@0.26.8
tree-sitter generate grammar.js   # produces src/parser.c (gitignored)
tree-sitter test                  # run corpus tests
tree-sitter parse <file.mux>      # parse a file
```

CI runs `tree-sitter generate` + `tree-sitter test` plus a SonarQube scan.

## Editor installation

- **Neovim (nvim-treesitter):** register this repo as the `mux` parser source and
  `:TSInstall mux`.
- **Helix:** add a grammar entry with `source = { git = "https://github.com/muxlang/tree-sitter-mux", rev = "..." }` and the queries.
- **Emacs:** install via `treesit-install-language-grammar` pointing at this repo.

## Compatibility

Grammar revisions track the Mux language; nvim-treesitter consumers pin a specific
commit SHA. See `COMPATIBILITY` notes in
[mux-syntax-highlighting](https://github.com/muxlang/mux-syntax-highlighting) for
language-version mapping.

## Related repositories

- [mux-syntax-highlighting](https://github.com/muxlang/mux-syntax-highlighting) - canonical syntax spec (vendored here) + TextMate/VSCode tooling
- [mux-compiler](https://github.com/muxlang/mux-compiler) - the language/compiler
- [mux-context](https://github.com/muxlang/mux-context) - cross-repo architecture, design notes, glossary, releases

## License

[MIT](LICENSE)
