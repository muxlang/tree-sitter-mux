# Editor integration

Wiring the Mux tree-sitter grammar into parser-based editors (Neovim, Helix,
Emacs).

The generated parser (`src/parser.c`) is committed, so editors can compile it
without installing the Tree-sitter CLI. Upstream Neovim and Helix integrations
are being prepared; until they ship, use the manual setup below.

## Neovim (nvim-treesitter)

Neovim does not yet recognize `.mux` files. Register the filetype until the
Neovim core change is available:

```lua
vim.filetype.add({ extension = { mux = "mux" } })
```

### nvim-treesitter `main` branch

```lua
require("nvim-treesitter.parsers").mux = {
  install_info = {
    url = "https://github.com/muxlang/tree-sitter-mux",
    revision = "9d89fb021c15b70b967ef8574c7e28d640d2b705",
  },
  maintainers = { "@DerekCorniello" },
  tier = 2,
}
```

### nvim-treesitter `master` branch (classic)

```lua
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.mux = {
  install_info = {
    url = "https://github.com/muxlang/tree-sitter-mux",
    files = { "src/parser.c" },
    branch = "main",
  },
  filetype = "mux",
}
```

Then `:TSInstall mux`, and on the classic branch `:TSBufEnable highlight`.

The highlight queries live in `queries/highlights.scm` and nvim-treesitter picks
them up from the installed parser. If you manage queries by hand, copy that file
to `queries/mux/highlights.scm` on your runtimepath.

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

The language-server block requires a compiler release that includes `mux lsp`.
Until that release is available, remove the `[language-server.mux]` section and
omit `language-servers = ["mux"]`.

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
into your own major-mode setup as needed.

## Validation

- `tree-sitter test` - corpus tests.
- `tree-sitter generate` must leave `src/` unchanged; CI fails if the committed
  parser has drifted from `grammar.js`.
