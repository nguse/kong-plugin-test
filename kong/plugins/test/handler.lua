local BasePlugin = require "kong.plugins.base_plugin"

local TestHandler = BasePlugin:extend()

function TestHandler:new()
  TestHandler.super.new(self, "test")
end

function TestHandler:access(conf)
  ngx.req.set_uri("/request/bar")

  -- error(ngx.var.uri)
end

TestHandler.PRIORITY = 800

return TestHandler
