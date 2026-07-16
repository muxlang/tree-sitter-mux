# Editor support

Drop-in configuration for the tree-sitter editors. These live here, next to the
grammar they configure, rather than in `mux-syntax-highlighting` - that repo owns
the canonical spec and the regex-based (TextMate) highlighters for VSCode,
Sublime and JetBrains.

- `helix/languages.toml` - language + grammar entry for Helix.

Neovim and Emacs need no file from here; see [INTEGRATION.md](../INTEGRATION.md)
for their setup. The highlight queries for every tree-sitter editor are
`queries/highlights.scm` at the repo root.
