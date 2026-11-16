local script = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fn.fnamemodify(script, ':p:h:h')
vim.opt.runtimepath:prepend(root)

require('mux').setup({ lsp = false })

local platform = dofile(root .. '/lua/mux/platform.lua')
assert(platform.library_extension('Windows_NT') == 'dll', 'Windows parser extension is incorrect')
assert(platform.library_extension('Darwin') == 'dylib', 'macOS parser extension is incorrect')
assert(platform.library_extension('Linux') == 'so', 'Linux parser extension is incorrect')

local sample = root .. '/test.mux'
vim.cmd.edit(vim.fn.fnameescape(sample))
assert(vim.bo.filetype == 'mux', 'Neovim did not detect the .mux filetype')
assert(
  vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil,
  'Neovim did not attach an active Tree-sitter highlighter to the Mux buffer'
)

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

local comment_source = [[
/// documentation line
// ordinary line
/** documentation block */
/* ordinary block */
]]
local comment_tree = vim.treesitter.get_string_parser(comment_source, 'mux'):parse()[1]
local comment_kinds = {}
for capture_id, node in query:iter_captures(comment_tree:root(), comment_source) do
  local text = vim.treesitter.get_node_text(node, comment_source)
  if text:match('^///') or text:match('^/%*%*') then
    comment_kinds[text] = comment_kinds[text] or {}
    comment_kinds[text][query.captures[capture_id]] = true
  elseif text:match('^//') or text:match('^/%*') then
    assert(query.captures[capture_id] ~= 'comment.documentation', 'ordinary comments must not be documentation comments')
  end
end
assert(comment_kinds['/// documentation line']['comment.documentation'], 'line MuxDoc capture missing')
assert(comment_kinds['/** documentation block */']['comment.documentation'], 'block MuxDoc capture missing')

local match_source = [[match some(15) {
    some(value) { print(value) }
    none { print("none") }
}]]
local match_tree = vim.treesitter.get_string_parser(match_source, 'mux'):parse()[1]
local some_constant_count = 0
for capture_id, node in query:iter_captures(match_tree:root(), match_source) do
  local text = vim.treesitter.get_node_text(node, match_source)
  if text == 'some' then
    local capture = query.captures[capture_id]
    assert(capture ~= 'function.call', 'some should not be highlighted as a function call')
    assert(capture ~= 'constructor', 'some should match the constant style of none')
    if capture == 'constant' or capture == 'constant.language' then
      some_constant_count = some_constant_count + 1
    end
  end
end
assert(some_constant_count == 4, 'both some occurrences should use the constant captures used by none')

local lsp = vim.lsp.config.mux
assert(lsp ~= nil and lsp.cmd[1] == 'mux' and lsp.cmd[2] == 'lsp', 'Mux LSP defaults were not configured')

print('Neovim Mux integration checks passed.')
vim.cmd.qa({ bang = true })
