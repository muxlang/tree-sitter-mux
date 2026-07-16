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

Helix's `hx --grammar build` compiles `src/parser.c` from the grammar source; it
does not run `tree-sitter generate`. Because this repo does not commit
`src/parser.c`, the automatic path cannot work here - build the grammar yourself
and hand Helix the result.

1. Build the grammar and install it into Helix's runtime:

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

3. Register the language in `~/.config/helix/languages.toml`. Note there is no
   `[[grammar]]` block: Helix resolves `grammar = "mux"` to the `mux.so` you just
   placed in `runtime/grammars/`. Adding a `[[grammar]]` source here would opt
   into `hx --grammar build`, which would re-clone and overwrite that file - and
   then fail, since there is no committed `src/parser.c` to compile.

```toml
[[language]]
name = "mux"
scope = "source.mux"
injection-regex = "mux"
file-types = ["mux"]
comment-token = "//"
block-comment-tokens = { start = "/*", end = "*/" }
grammar = "mux"
```

Run `hx --health mux` to confirm the grammar and queries are found.

Re-run step 1 to pick up grammar updates; pin to a specific commit
(`git checkout <sha>`) if you want a reproducible setup rather than whatever is
on `main`.

## Emacs (treesit)

`treesit-install-language-grammar` clones the repo and compiles `src/parser.c`
directly - it never invokes the tree-sitter CLI. With no committed `src/parser.c`
it fails, so build the library yourself and drop it where Emacs looks for
grammars:

```bash
git clone https://github.com/muxlang/tree-sitter-mux
cd tree-sitter-mux
tree-sitter generate
cc -shared -fPIC -I src src/parser.c -o libtree-sitter-mux.so
mkdir -p ~/.emacs.d/tree-sitter
cp libtree-sitter-mux.so ~/.emacs.d/tree-sitter/
```

Emacs searches `treesit-extra-load-path`, then `~/.emacs.d/tree-sitter/`, for a
`libtree-sitter-<lang>` library. Confirm it loaded with:

```elisp
(treesit-ready-p 'mux)
```

Copy `queries/highlights.scm` into your own major-mode setup as needed.

## Validation

- `tree-sitter test` in this repo (corpus tests).
- `node ../scripts/check-parity.js` from a checkout that also has
  `mux-syntax-highlighting` (verifies the vendored spec matches canonical).
