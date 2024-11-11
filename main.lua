local turbo = require("turbo")
local handlers = require("handlers")

local app = turbo.web.Application({
  {"^/todo$", handlers.TodoHandler},
  {"^/show$", handlers.ShowHandler},
  {"^/add$", handlers.AddHandler},
  {"^/update$", handlers.UpdateHandler},
  {"^/remove$", handlers.RemoveHandler},
  {"^/style.css$", turbo.web.StaticFileHandler, "./static/style.css"},
  {"^/$", turbo.web.RedirectHandler, "/todo"},
  {"^.*$", handlers.ErrorHandler}
})

print("Listening on port 8888")
app:listen(8888)
turbo.ioloop.instance():start()
