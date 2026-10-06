local source = debug.getinfo(1, 'S').source:sub(2)
local root = vim.fn.fnamemodify(source, ':p:h:h')
local parser_dir = root .. '/parser'
local os_name = vim.uv.os_uname().sysname
local extension = os_name == 'Windows_NT' and 'dll' or (os_name == 'Darwin' and 'dylib' or 'so')
local output = parser_dir .. '/mux.' .. extension
local compiler = vim.env.CC

if compiler == nil or compiler == '' then
  compiler = 'cc'
end

vim.fn.mkdir(parser_dir, 'p')
local query_dir = root .. '/queries/mux'
vim.fn.mkdir(query_dir, 'p')

local args = { compiler, '-O2' }
if os_name == 'Darwin' then
  vim.list_extend(args, { '-dynamiclib', '-fPIC' })
elseif os_name == 'Windows_NT' then
  vim.list_extend(args, { '-shared' })
else
  vim.list_extend(args, { '-shared', '-fPIC' })
end
vim.list_extend(args, {
  '-I' .. root .. '/src',
  root .. '/src/parser.c',
  '-o',
  output,
})

local result = vim.system(args, { cwd = root, text = true }):wait()
if result.code ~= 0 then
  io.stderr:write(result.stderr or 'C compiler failed to build the Mux parser\n')
  vim.cmd('cquit ' .. tostring(math.max(result.code, 1)))
end

print('Built Mux Tree-sitter parser: ' .. output)
vim.fn.writefile(
  vim.fn.readfile(root .. '/queries/highlights.scm'),
  query_dir .. '/highlights.scm'
)
print('Installed Mux Neovim highlight query: ' .. query_dir .. '/highlights.scm')
