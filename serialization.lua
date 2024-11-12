serialization = {}

function serialization.load(filename)
  local file = io.open(filename, "r")
  local todos = {}
  if file then
    for line in file:lines() do
      local task, category = line:match("^(.*)|(.+)$")
      if task and category then
        table.insert(todos, {
          task = task,
          category = category
        })
      end
    end
    file:close()
  end
  return todos
end

function serialization.save(filename, todos)
  local file = io.open(filename, "w")
  if file then
    for _, todo in ipairs(todos) do
      file:write(todo.task .. "|" .. todo.category .. "\n")
    end
    file:close()
  end
end

return serialization
