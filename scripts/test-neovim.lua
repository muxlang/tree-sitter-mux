local script = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fn.fnamemodify(script, ':p:h:h')
vim.opt.runtimepath:prepend(root)

require('mux').setup({ lsp = false })

local sample = root .. '/test.mux'
vim.cmd.edit(vim.fn.fnameescape(sample))
assert(vim.bo.filetype == 'mux', 'Neovim did not detect the .mux filetype')

local parser = vim.treesitter.get_parser(0, 'mux')
local tree = parser:parse()[1]
local query = vim.treesitter.query.get('mux', 'highlights')
assert(query ~= nil, 'Neovim could not load the Mux highlight query')

local captures = {}
for capture_id in query:iter_captures(tree:root(), 0) do
  captures[query.captures[capture_id]] = true
end
assert(captures.keyword, 'Mux keyword was not highlighted')
assert(captures['function.call'], 'Mux function call was not highlighted')
assert(captures.number, 'Mux numeric literal was not highlighted')

local lsp = vim.lsp.config.mux
assert(lsp ~= nil and lsp.cmd[1] == 'mux' and lsp.cmd[2] == 'lsp', 'Mux LSP defaults were not configured')

print('Neovim Mux integration checks passed.')
vim.cmd.qa({ bang = true })
