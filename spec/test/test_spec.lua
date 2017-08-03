local helpers = require "spec.helpers"

describe("test (access)", function()
  local client

  setup(function()
    local api1 = assert(helpers.dao.apis:insert { 
        name = "api-1", 
        hosts = { "test1.com" }, 
        upstream_url = "http://mockbin.com",
    })

    assert(helpers.dao.plugins:insert {
      api_id = api1.id,
      name = "test",
    })

    -- start kong, while setting the config item `custom_plugins` to make sure our
    -- plugin gets loaded
    assert(helpers.start_kong {custom_plugins = "test"})
  end)

  teardown(function()
    helpers.stop_kong()
  end)

  before_each(function()
    client = helpers.proxy_client()
  end)

  after_each(function()
    if client then client:close() end
  end)

  describe("request", function()
    it("rewrite foo to bar", function()
      local r = assert(client:send {
        method = "GET",
        path = "/request/foo",  -- makes mockbin return the entire request
        headers = {
          host = "test1.com"
        }
      })

      assert.response(r).has.status(200)
      
      local json = assert.response(r).has.jsonbody()
      -- error(json)
      assert.equal("http://mockbin.com/request/bar", json.url)
    end)
  end)

end)
