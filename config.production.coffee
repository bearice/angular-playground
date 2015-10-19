module.exports =
  mongodb:
    url: 'mongodb://mongodb-16.local,mongodb-26.local,mongodb-36.local/daikon?replicaSet=rs-daikon'
  httpd:
    listen: process.env.HTTP_PORT || "127.0.0.1:8083"
    base: "/"

