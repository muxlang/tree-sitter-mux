<div align="center">

<img src="https://mux-lang.dev/img/mux-logo.png" alt="Mux Logo" width="120">

# tree-sitter-mux

**Tree-sitter grammar for [Mux](https://github.com/muxlang) (Neovim, Helix, Emacs)**

[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](LICENSE)
[![Sonar Quality Gate](https://sonarcloud.io/api/project_badges/measure?project=muxlang_tree-sitter-mux&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=muxlang_tree-sitter-mux)

</div>

[Tree-sitter](https://tree-sitter.github.io/tree-sitter/) grammar for the Mux
programming language. Powers parser-based editor tooling: Neovim
(nvim-treesitter), Helix, and Emacs. `grammar.js` lives at the repo root, as the
tree-sitter ecosystem expects.

---

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

---

## Development

```bash
npm install -g tree-sitter-cli@0.26.8
tree-sitter generate grammar.js   # regenerates src/parser.c (committed - commit it)
tree-sitter test                  # run corpus tests
tree-sitter parse <file.mux>      # parse a file
```

CI runs `tree-sitter generate` + `tree-sitter test` plus a SonarQube scan.

---

## Editor installation

See [INTEGRATION.md](INTEGRATION.md) for copy-pasteable setup. In short:

- **No prerequisite.** The generated parser is committed, so editors compile it
  directly and none of them need the tree-sitter CLI.
- **Neovim (nvim-treesitter):** register `mux` as a custom parser, add the `.mux`
  filetype, then `:TSInstall mux`.
- **Helix:** add the `[[language]]` and `[[grammar]]` blocks, then
  `hx --grammar fetch && hx --grammar build`, and copy `queries/highlights.scm`
  into the Helix runtime.
- **Emacs:** `treesit-install-language-grammar` pointing at this repo.

A zero-config install (nvim-treesitter registry + Helix upstream) is planned
follow-up, tracked in [mux-context](https://github.com/muxlang/mux-context).

---

## Compatibility

Grammar revisions track the Mux language; nvim-treesitter consumers pin a specific
commit SHA. See `COMPATIBILITY` notes in
[mux-syntax-highlighting](https://github.com/muxlang/mux-syntax-highlighting) for
language-version mapping.

---

## Related repositories

| Repo | What it is |
|------|------------|
| [mux-syntax-highlighting](https://github.com/muxlang/mux-syntax-highlighting) | Canonical syntax spec (vendored here) + TextMate/VSCode tooling |
| [mux-compiler](https://github.com/muxlang/mux-compiler) | The language, compiler, and CLI |
| [mux-website](https://github.com/muxlang/mux-website) | Docs site (mux-lang.dev) and playground |
| [mux-context](https://github.com/muxlang/mux-context) | Cross-repo architecture, design rationale, glossary, releases |

---

## License

[MIT](LICENSE) - Maintained by [Derek Corniello](https://github.com/DerekCorniello)
