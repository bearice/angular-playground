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

findSvc = (next) ->
  @body = yield Service.findOne
    env: @params.env
    app: @params.app
  return @status=404 if @body is null
  yield next

api.get "/service/:env/:app", findSvc
api.put "/serivce/:env/:app", findSvc, ->
  merge @body, @request.body
  yield @body.save()

api.delete "/service/:env/:app", ->
  yield @body.delete()

api.post "/service", ->
  @body = new Service @request.body
  yield @body.save()

module.exports = api
