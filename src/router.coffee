Router  = require 'koa-router'
router = new Router

router.get '/Status/Version', ->
  @body = process.env
  yield return

router.get '*', ->
  @render 'index'
  yield return

module.exports = router
