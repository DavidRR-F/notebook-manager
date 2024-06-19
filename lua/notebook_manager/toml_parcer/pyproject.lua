local toml = require("notebook_manager.toml_parcer.toml")
local PackageManagerFactory = require("notebook_manager.package_manager.factory")

PyProject = {}
PyProject.__index = PyProject

local mt = {
  __index = function(tbl, key)
    if key == "name" then
      return tbl.manager:get_project_name()
    elseif key == "description" then
      return tbl.manager:get_project_description()
    elseif key == "author" then
      return tbl.manager:get_project_author()
    elseif key == "python_version" then
      return tbl.manager:get_project_version()
    else
      return rawget(tbl, key) or PyProject[key]
    end
  end
}

function PyProject:new(file_path)
  local instance = setmetatable({}, mt)
  instance.found = true
  instance.file_path = file_path or "pyproject.toml"
  instance.manager = PackageManagerFactory:createManager(instance:load(file_path))
  return instance
end

function PyProject:load()
  local file = io.open(self.file_path, "r")
  if not file then
    return nil
  end
  local contents = file:read("*all")
  file:close()
  return toml.parse(contents)
end

return PyProject