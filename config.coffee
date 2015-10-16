module.exports =
  httpd:
    listen: process.env.HTTP_PORT || "127.0.0.1:8083"
    base: "/daikon/"

