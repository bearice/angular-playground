_ = require 'underscore'
Path = require 'path'
PromiseUtils = require './promise-utils'
config = require './config'
require('source-map-support').install()

Koa     = require 'koa'
KLogger = require 'koa-logger'
KBody   = require 'koa-body'
KStatic = require 'koa-static'
Router  = require 'koa-router'
Jade    = require 'koa-jade'

router = new Router

views = new Jade
  viewPath: Path.resolve __dirname,'../views'
  locals:
    config: config

app = new Koa
app.use KLogger()
app.use KBody()
app.use KStatic('public')
app.use router.routes()
app.use router.allowedMethods()
app.use views.middleware
app.use (next)->
  yield next
  @render 'index'

[host,port] = config.httpd.listen.split ':'
[port,host] = [host,'0.0.0.0'] if port is undefined

app.listen port, host, -> console.info "Listening on #{host}:#{port}"
