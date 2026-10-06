# Editor integration

Mux maintains the Neovim integration in this grammar repository. The generated
parser is committed, so setup does not need the Tree-sitter CLI. A C compiler
builds the small Neovim parser library during plugin installation.

## Neovim

Requires Neovim 0.11 or newer, a C compiler, and the Mux 0.13.0 or newer
compiler on `PATH`.

With lazy.nvim:

```lua
{
  "muxlang/tree-sitter-mux",
  lazy = false,
  build = "nvim --headless --clean -l scripts/build-nvim-parser.lua",
  config = function()
    require("mux").setup()
  end,
}
```

The plugin detects `.mux` files, builds and loads the committed parser,
highlights them with Neovim's built-in Tree-sitter support, and starts `mux lsp`.
For a custom compiler path, pass it to setup:

```lua
require("mux").setup({ lsp = { cmd = { "/path/to/mux", "lsp" } } })
```

Use `require("mux").setup({ lsp = false })` to disable automatic LSP startup.
For a manual package install, build the parser from the repository directory
and call setup from `init.lua`:

```sh
nvim --headless --clean -l scripts/build-nvim-parser.lua
```

```lua
require("mux").setup()
```

The compiler v0.13.0 release includes the Mux language server. On Neovim 0.11 or
newer, configure it after registering the `.mux` filetype:

```lua
vim.lsp.config('mux', {
  cmd = { 'mux', 'lsp' },
  filetypes = { 'mux' },
  root_markers = { 'mux-project.json', '.git' },
})
vim.lsp.enable('mux')
```

Keep the compiler executable on Neovim's `PATH`. This manual configuration is
needed until Mux is added to nvim-lspconfig; Tree-sitter parser distribution
and language-server installation are separate.

## Helix

Add the language and grammar to `~/.config/helix/languages.toml`, then let Helix
fetch and build it:

```toml
[[language]]
name = "mux"
scope = "source.mux"
injection-regex = "mux"
file-types = ["mux"]
comment-token = "//"
block-comment-tokens = { start = "/*", end = "*/" }
grammar = "mux"
language-servers = ["mux"]

[[grammar]]
name = "mux"
source = { git = "https://github.com/muxlang/tree-sitter-mux", rev = "9d89fb021c15b70b967ef8574c7e28d640d2b705" }

[language-server.mux]
command = "mux"
args = ["lsp"]
```

The Mux v0.13.0 compiler release includes `mux lsp`, so the language-server
block works when `mux` is on Helix's `PATH`. Helix's native Mux definition is
still pending upstream; keep this manual config until that change ships.

```bash
hx --grammar fetch
hx --grammar build
```

Helix does not read `queries/` from the grammar repo, so install the highlights
into its runtime:

```bash
mkdir -p ~/.config/helix/runtime/queries/mux
curl -fsSL https://raw.githubusercontent.com/muxlang/tree-sitter-mux/9d89fb021c15b70b967ef8574c7e28d640d2b705/queries/highlights.scm \
  -o ~/.config/helix/runtime/queries/mux/highlights.scm
```

Run `hx --health mux` to confirm the grammar and queries are found.

## Emacs (treesit)

```elisp
(add-to-list
 'treesit-language-source-alist
 '(mux "https://github.com/muxlang/tree-sitter-mux"))
(treesit-install-language-grammar 'mux)
```

Confirm it loaded with `(treesit-ready-p 'mux)`. Copy `queries/highlights.scm`
into your major-mode setup as needed.

## Validation

- `nvim --headless --clean -l scripts/build-nvim-parser.lua` builds the local
  parser library.
- `nvim --headless --clean -l scripts/test-neovim.lua` checks filetype
  detection, parser loading, highlight queries, and default LSP settings.
- `tree-sitter test` - corpus tests.
- `tree-sitter generate` must leave `src/` unchanged; CI fails if the committed
  parser has drifted from `grammar.js`.
