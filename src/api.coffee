Router  = require 'koa-router'
api = new Router

api.get "/hello/:name", ->
  @body = "hello #{@params.name}"
  yield return

module.exports = api
