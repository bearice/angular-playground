Router  = require 'koa-router'
{Service} = require './model'

api = new Router
api.get "/hello/:name", ->
  @body = "hello #{@params.name}"
  yield return

api.get "/env", ->
  @body = yield Service.aggregate().group(
    _id: "$env"
    count: $sum: 1
  ).exec()

api.get "/env/:env", ->
  @body = yield Service.find {env: @params.env}
  @status=404 if @body is null

api.get "/env/:env/:app", ->
  @body = yield Service.findOne
    env: @params.env
    app: @params.app
  @status=404 if @body is null

module.exports = api
