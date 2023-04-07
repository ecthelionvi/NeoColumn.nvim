if vim.g.loaded_neocolumn then
  return
end

require('NeoColumn').setup()

vim.g.loaded_neocolumn = true
