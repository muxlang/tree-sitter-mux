local M = {}

function M.library_extension(system_name)
  if system_name == 'Windows_NT' then
    return 'dll'
  end
  if system_name == 'Darwin' then
    return 'dylib'
  end
  return 'so'
end

return M
