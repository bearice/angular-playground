db = require 'mongoose'
config = require '../config'
db.connect config.mongodb.url

module.exports = {
  Service: require './service'
}
