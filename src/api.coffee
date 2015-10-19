Router  = require 'koa-router'
{Service} = require './model'

api = new Router

api.get "/service", ->
  @body = yield Service.aggregate().group(
    _id: "$env"
    count: $sum: 1
    apps: $push: '$app'
  ).exec()

api.get "/service/:env", ->
  @body = yield Service.find {env: @params.env}
  @status=404 if @body is null

api.get "/service/:env/:app", ->
  @body = yield Service.findOne
    env: @params.env
    app: @params.app
  @status=404 if @body is null

module.exports = api
