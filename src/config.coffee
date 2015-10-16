merge = require 'merge'
path = require 'path'
require 'coffee-script/register'
config =
  etcd:
    tls: false
    endpoint: "http://127.0.0.1:2379"
  docker:
    tls: false
  mongodb:
    url: "mongodb://127.0.0.1/daikon"
  httpd:
    listen: process.env.HTTP_PORT || 3000
    base: "/"

try
  local_config = require path.resolve process.cwd(),'./config.coffee'
  merge config,local_config
catch e
  console.error "failed to merge local config", e

module.exports = config
