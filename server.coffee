express = require('express')
app = express.createServer()
app.listen(8080)

bundle = require('browserify')(__dirname + '/survive.js', {watch: true, mount: '/all.js'})
app.use(bundle)

app.get '/', (req, res) ->
  res.sendfile 'index.html'
