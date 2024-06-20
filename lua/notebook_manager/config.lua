local M = {}

M.options = {
  notebook_dir = "./notebooks",
  kernel_dir = "~/.local/share/jupyter/kernels",
}

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
end

return M
