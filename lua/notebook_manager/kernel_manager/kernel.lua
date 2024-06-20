local config = require('notebook_manager.config')

local KernelManager = {}
KernelManager.__index = KernelManager

function KernelManager:new()
  local instance = setmetatable({}, KernelManager)
  instance.path = config.options.kernel_dir
  return instance
end

function KernelManager:create_kernel(name, manager)
  local cmd
  local tool

  if self.path == "default" then
    tool = "jupyter kernelspec install --user --name="
  else
    tool = "jupyter kernelspec install " .. self.path .. " --user --name="
  end

  -- Add manager if it exists
  if manager then
    cmd = manager .. " run " .. tool .. name
  else
    cmd = tool .. name
  end

  -- Run the command
  local output = vim.fn.systemlist(cmd)
  local exit_code = vim.v.shell_error

  -- Check if the command was successful
  if exit_code ~= 0 then
    -- Command failed, print an error message
    print("Error running command: " .. cmd)
    for _, line in ipairs(output) do
      print(line)
    end
  else
    -- Command succeeded, print the output
    for _, line in ipairs(output) do
      print(line)
    end
  end
end

function KernelManager:delete_kernel(name, manager)
  local cmd = "jupyter kernelspec remove " .. name

  if manager then
    cmd = manager .. " run " .. cmd
  end

  -- Run the command
  local output = vim.fn.systemlist(cmd)
  local exit_code = vim.v.shell_error

  -- Check if the command was successful
  if exit_code ~= 0 then
    -- Command failed, print an error message
    print("Error running command: " .. cmd)
    for _, line in ipairs(output) do
      print(line)
    end
  else
    -- Command succeeded, print the output
    for _, line in ipairs(output) do
      print(line)
    end
  end
end

return KernelManager
