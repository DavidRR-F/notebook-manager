local config = require('notebook_manager.config')
local Job = require('plenary.job')

local KernelManager = {}
KernelManager.__index = KernelManager

function KernelManager:new()
  local instance = setmetatable({}, KernelManager)
  instance.path = config.options.kernel_dir
  return instance
end

function KernelManager:create_kernel(name, manager)
  local cmd
  local tool = "python -m ipykernel install --user --name="

  if manager then
    cmd = manager .. " run " .. tool .. name
  else
    cmd = tool .. name
  end

  local output = vim.fn.systemlist(cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 then
    print("Error running command: " .. cmd)
    for _, line in ipairs(output) do
      print(line)
    end
  else
    for _, line in ipairs(output) do
      print(line)
    end
  end
end

function KernelManager:delete_kernel(name, manager, on_exit)
  local cmd
  local args
  local std_fn = function(err, data)
    if err then
      vim.notify(err)
    elseif data then
      vim.notify(data)
    end
  end

  if manager then
    cmd = manager
    args = { "run", "jupyter", "kernelspec", "remove", name, "-y" }
  else
    cmd = "jupyter"
    args = { "kernelspec", "remove", name, "-y" }
  end

  Job:new({
    command = cmd,
    args = args,
    on_stdout = std_fn,
    on_exit = on_exit
  }):sync()
end

function KernelManager:get_kernels(manager)
  local results = {}
  local command
  local args

  if manager then
    command = manager
    args = { "run", "jupyter", "kernelspec", "list" }
  else
    command = "jupyter"
    args = { "kernelspec", "list" }
  end

  Job:new({
    command = command,
    args = args,
    on_exit = function(j, return_val)
      if return_val == 0 then
        for _, line in ipairs(j:result()) do
          if line:match('%*') then -- Skip the header
            goto continue
          end
          local name = line:match('(%S+)')
          if name then
            table.insert(results, name)
          end
          ::continue::
        end
      end
    end,
  }):sync()
  table.remove(results, 1)
  return results
end

return KernelManager