_ = require 'underscore'
Path = require 'path'
PromiseUtils = require './promise-utils'
config = require './config'
require('source-map-support').install()

Koa     = require 'koa'
KLogger = require 'koa-logger'
KBody   = require 'koa-body'
KStatic = require 'koa-static'
Jade    = require 'koa-jade'
Mount   = require 'koa-mount'


app = new Koa
app.use KLogger()
app.use KBody()
app.use Mount "/public", KStatic('public',maxage: 3600)

views = new Jade
  viewPath: Path.resolve __dirname,'../views'
  locals: config: config
app.use views.middleware

router = require './router'
app.use router.routes()
app.use router.allowedMethods()

[host,port] = config.httpd.listen.split ':'
[port,host] = [host,'0.0.0.0'] if port is undefined
if host is 'unix'
  app.listen port, -> console.info "Listening on #{host}:#{port}"
else
  app.listen port, host, -> console.info "Listening on #{host}:#{port}"

