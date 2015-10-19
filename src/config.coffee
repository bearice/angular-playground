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
  config_filename = if process.env.ENV_NAME then "config.#{process.env.ENV_NAME}.coffee" else "config.coffee"
  local_config = require path.resolve process.cwd(),config_filename
  merge config,local_config
catch e
  console.error "failed to merge local config", e

module.exports = config
