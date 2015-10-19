db = require 'mongoose'
schema = new db.Schema
  app:
    type: String
    required: true
  env:
    type: String
    required: true
  template:
    type: String
    required: true
  options: {}

schema.index {app:1,env:1},{unique:1}
schema.index {env:1}
schema.index {template:1}

schema.statics.findByEnvApp = (env,app)->
  @findOne {env,app}

module.exports = db.model 'Service',schema
