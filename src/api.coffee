Router  = require 'koa-router'
{Service,Template} = require './model'

api = new Router

api.use (next)->
  try
    yield next
  catch e
    console.error e.stack
    @body = e
    @status = 500

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

api.get "/service/:env/:app", findSvc, ->
  yield return

api.put "/serivce/:env/:app", findSvc, ->
  merge @body, @request.body
  yield @body.save()

api.delete "/service/:env/:app", findSvc, ->
  yield @body.remove()

api.post "/service", ->
  @body = new Service @request.body
  yield @body.save()

api.get "/template", ->
  @body = yield Template.find()

api.get "/template/:name", ->
  @body = yield Template.findByName(@params.name)
  return @status=404 if @body is null

module.exports = api
