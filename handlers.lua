local turbo = require("turbo")
local serialization = require("serialization")
local util = require("util")

local urlencode = util.urlencode
local urldecode = util.urldecode

local todos_file = "todos.txt"
local todos = serialization.load(todos_file) or {}

local TodoHandler = class("TodoHandler", turbo.web.RequestHandler)
local ShowHandler = class("ShowHandler", turbo.web.RequestHandler)
local AddHandler = class("AddHandler", turbo.web.RequestHandler)
local UpdateHandler = class("UpdateHandler", turbo.web.RequestHandler)
local RemoveHandler = class("RemoveHandler", turbo.web.RequestHandler)

function TodoHandler:get()
  local category = urldecode(self:get_argument("category", ""))
  local default_category = ""
  local categories = {}
  local list_items = ""

  for _, todo in ipairs(todos) do
    categories[todo.category] = true
    if not category:match("%S") then category = todo.category end
  end

  if category:match("%S") then
    default_category = category
  end

  for i, todo in ipairs(todos) do
    if todo.category == category then
      list_items = list_items .. string.format(
        [[<li>
  <span><a href="/show?index=%d">%s</a></span>
  <form class="delete-form" action="/remove?index=%d&category=%s" method="POST"
    onsubmit="return confirm('Are you sure you want to delete this task?');">
    <button type="submit">Delete</button>
  </form>
</li>]],
        i, turbo.escape.html_escape(todo.task), i, urlencode(category)
      )
    end
  end

  if list_items == "" then
    for cat in pairs(categories) do
      self:redirect("/todo?category=" .. urlencode(cat))
      return
    end
    list_items = '<li>No items to display!</li>'
  end

  local category_list = {}
  for cat in pairs(categories) do
    table.insert(category_list, cat)
  end
  table.sort(category_list)

  local tags = ""
  for _, cat in ipairs(category_list) do
    tags = tags .. string.format("<a class='tag' href='/todo?category=%s'>%s</a>", urlencode(cat), cat)
  end

  local html_form_template = [[<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tasks</title>
  <link rel="stylesheet" href="/style.css">
</head>
<body>
  <h1>Tasks</h1>
  <div class="container">
    <div style="overflow-x: auto; white-space: nowrap; padding: 1rem;">%s</div>
    <ul>%s</ul>
    <form action="/add" method="POST">
      <input type="text" name="task" placeholder="New task" autofocus required>
      <input type="text" name="category" placeholder="Category" value="%s" required>
      <button type="submit">Add Task</button>
    </form>
  </div>
</body>
</html>]]

  self:write(html_form_template:format(tags, list_items, turbo.escape.html_escape(default_category)))
end

function ShowHandler:get()
  local index = urldecode(self:get_argument("index", 1))

  local categories = {}

  for _, todo in ipairs(todos) do
    categories[todo.category] = true
  end

  local category_list = {}
  for cat in pairs(categories) do
    table.insert(category_list, cat)
  end
  table.sort(category_list)

  local tags = ""
  for _, cat in ipairs(category_list) do
    tags = tags .. string.format("<a class='tag' href='/todo?category=%s'>%s</a>", urlencode(cat), cat)
  end

  local html_form_template = [[<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Tasks</title>
  <link rel="stylesheet" href="/style.css">
</head>
<body>
  <h1>Tasks</h1>
  <div class="container">
    <div class="tagbar">%s</div>
    <form action="/update" method="POST">
      <input type="text" name="task" placeholder="Task Name" value="%s" autofocus required><br>
      <input type="text" name="category" placeholder="Category" value="%s" required><br>
      <input type="number" name="index" value="%d" hidden>
      <button type="submit">Update Task</button>
    </form>
  </div>
</body>
</html>]]

  local todo = todos[tonumber(index)]
  self:write(html_form_template:format(
      tags,
      todo.task,
      todo.category,
      index
    ))
end

function AddHandler:post()
  local task = self:get_argument("task")
  local category = self:get_argument("category")

  if task and category then
    table.insert(todos, {task = task, category = category})
    serialization.save(todos_file, todos)
    self:redirect("/todo?category=" .. urlencode(category))
  else
    self:set_status(400)
    self:write({error = "Invalid task or category"})
  end
end

function UpdateHandler:post()
  local task = self:get_argument("task")
  local category = self:get_argument("category")
  local index = self:get_argument("index")

  if task and category and index then
    todos[tonumber(index)].task = task
    todos[tonumber(index)].category = category
    serialization.save(todos_file, todos)
    self:redirect("/todo?category=" .. urlencode(category))
  else
    self:set_status(400)
    self:write({error = "Invalid task or category"})
  end
end

function RemoveHandler:post()
  local index = tonumber(self:get_argument("index"))
  local category = urldecode(self:get_argument("category") or "")

  if index and todos[index] then
    table.remove(todos, index)
    serialization.save(todos_file, todos)
    self:redirect("/todo?category=" .. urlencode(category))
  else
    self:set_status(400)
    self:write({error = "Invalid task"})
  end
end

function ErrorHandler:get()
  self:set_status(404)
  self:write("404 - Page Not Found")
end

return {
  TodoHandler = TodoHandler,
  ShowHandler = ShowHandler,
  AddHandler = AddHandler,
  UpdateHandler = UpdateHandler,
  RemoveHandler = RemoveHandler,
}
