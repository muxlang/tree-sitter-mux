-- Test Tree-sitter highlighting for Mux in Neovim
-- Run with: nvim --headless -c "set filetype=mux" -c "TSBufEnable highlight" -c "redir! > /tmp/ts-highlights.txt" -c "echo 'test'" -c "q" test.mux

-- This script checks if Tree-sitter is highlighting correctly
local buf = vim.api.nvim_get_current_buf()
local ok, parser = pcall(vim.treesitter.get_parser, buf)

if not ok or not parser then
  error("Failed to load the Mux parser")
end

print("Parser loaded successfully: " .. parser:lang())
local trees = parser:parse()
if not trees or not trees[1] then
  error("Mux parser returned no parse tree")
end
print("Parse tree root: " .. trees[1]:root():type())
