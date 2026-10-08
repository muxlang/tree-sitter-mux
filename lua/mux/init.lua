local M = {}
local setup_done = false

local function plugin_root()
  local source = debug.getinfo(1, 'S').source:sub(2)
  return vim.fn.fnamemodify(source, ':p:h:h:h')
end

local function parser_library_extension()
  local platform = dofile(plugin_root() .. '/lua/mux/platform.lua')
  return platform.library_extension(vim.uv.os_uname().sysname)
end

function M.setup(opts)
  if setup_done then
    return
  end

  opts = opts or {}
  vim.filetype.add({ extension = { mux = 'mux' } })

  if vim.fn.has('nvim-0.11') ~= 1 then
    error('tree-sitter-mux requires Neovim 0.11 or newer')
  end

  local parser = plugin_root() .. '/parser/mux.' .. parser_library_extension()
  if vim.uv.fs_stat(parser) == nil then
    error('Mux parser is not built. Run nvim --headless --clean -l scripts/build-nvim-parser.lua from the plugin directory.')
  end
  vim.treesitter.language.add('mux', { path = parser })

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('MuxEditorSupport', { clear = true }),
    pattern = 'mux',
    callback = function(args)
      vim.treesitter.start(args.buf, 'mux')
    end,
  })

  local lsp_opts = opts.lsp == false and {} or (opts.lsp or {})
  vim.lsp.config('mux', vim.tbl_extend('force', {
    cmd = { 'mux', 'lsp' },
    filetypes = { 'mux' },
    root_markers = { 'mux-project.json', '.git' },
    workspace_required = false,
  }, lsp_opts))

  if opts.lsp ~= false then
    vim.lsp.enable('mux')
  end

  setup_done = true
end

return M
