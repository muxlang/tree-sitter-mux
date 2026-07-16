# Editor integration

Wiring the Mux tree-sitter grammar into parser-based editors (Neovim, Helix,
Emacs). This is the manual path; a zero-config install (nvim-treesitter registry
+ Helix upstream) is planned follow-up, tracked in
[muxlang/mux-context](https://github.com/muxlang/mux-context).

## Prerequisite: the tree-sitter CLI

This repo does NOT commit the generated parser (`src/parser.c`,
`src/grammar.json`, and `src/node-types.json` are gitignored). Every editor below
therefore regenerates the parser from `grammar.js` at install time, which needs
the tree-sitter CLI on your `PATH`:

```bash
npm install -g tree-sitter-cli@0.26.8
```

Pin `0.26.8` - it matches the version that generated the committed
`queries/highlights.scm`.

## Neovim (nvim-treesitter)

Neovim does not recognize the `.mux` extension on its own, so register the
filetype regardless of which branch of nvim-treesitter you run:

```lua
vim.filetype.add({ extension = { mux = "mux" } })
```

### nvim-treesitter `main` branch (recommended)

```lua
require("nvim-treesitter.parsers").mux = {
  install_info = {
    url = "https://github.com/muxlang/tree-sitter-mux",
    branch = "main",
    -- parser.c is not committed; regenerate from grammar.js on install.
    generate = true,
    queries = "queries",
  },
}
```

Then `:TSInstall mux`.

### nvim-treesitter `master` branch (classic)

```lua
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.mux = {
  install_info = {
    url = "https://github.com/muxlang/tree-sitter-mux",
    files = { "src/parser.c" },
    branch = "main",
    -- parser.c is not committed; run `tree-sitter generate` during install.
    requires_generate_from_grammar = true,
  },
  filetype = "mux",
}
```

Then `:TSInstall mux` followed by `:TSBufEnable highlight`.

The highlight queries live in `queries/highlights.scm`; nvim-treesitter picks
them up from the installed parser. If you manage queries by hand, copy
`queries/highlights.scm` to `queries/mux/highlights.scm` on your runtimepath.

## Helix

Helix builds grammars from source but does not run `tree-sitter generate`, so you
generate the parser and hand Helix the built grammar plus the queries.

1. Build the grammar:

```bash
git clone https://github.com/muxlang/tree-sitter-mux
cd tree-sitter-mux
tree-sitter generate
cc -shared -fPIC -I src src/parser.c -o mux.so
mkdir -p ~/.config/helix/runtime/grammars
cp mux.so ~/.config/helix/runtime/grammars/mux.so
```

2. Install the queries:

```bash
mkdir -p ~/.config/helix/runtime/queries/mux
cp queries/highlights.scm ~/.config/helix/runtime/queries/mux/highlights.scm
```

3. Register the language in `~/.config/helix/languages.toml`. A ready-to-copy
   block lives in
   [mux-syntax-highlighting `editor-support/helix/languages.toml`](https://github.com/muxlang/mux-syntax-highlighting/blob/main/editor-support/helix/languages.toml):

```toml
[[language]]
name = "mux"
scope = "source.mux"
injection-regex = "mux"
file-types = ["mux"]
comment-token = "//"
block-comment-tokens = { start = "/*", end = "*/" }
grammar = "mux"

[[grammar]]
name = "mux"
source = { git = "https://github.com/muxlang/tree-sitter-mux", rev = "main" }
```

Run `hx --health mux` to confirm the grammar and queries are found.

## Emacs (treesit)

```elisp
(add-to-list
 'treesit-language-source-alist
 '(mux "https://github.com/muxlang/tree-sitter-mux"))
(treesit-install-language-grammar 'mux)
```

`treesit-install-language-grammar` runs the tree-sitter CLI to generate and
compile the parser, so the CLI prerequisite above applies here too.

## Validation

- `tree-sitter test` in this repo (corpus tests).
- `node ../scripts/check-parity.js` from a checkout that also has
  `mux-syntax-highlighting` (verifies the vendored spec matches canonical).
