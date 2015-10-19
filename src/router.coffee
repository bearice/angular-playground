Router  = require 'koa-router'
router = new Router

api = require './api'

router.use '/api', api.routes(), api.allowedMethods()
router.get '/Status/Version', ->
  @body = process.env
  yield return

router.get '*', ->
  @render 'index'
  yield return

module.exports = router
