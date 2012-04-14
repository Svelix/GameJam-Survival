express = require('express')
util = require("util")
io = require("socket.io")
Player = require("./Player").Player

startServer = ->
  initExpress()
  initSocketIO()

initExpress = ->
  @app = express.createServer()
  @app.listen(8080)

  bundle = require('browserify')(__dirname + '/survive.js', {watch: true, mount: '/all.js'})
  @app.use(bundle)

  @app.get '/', (req, res) ->
    res.sendfile 'index.html'


initSocketIO = ->
  @socket = io.listen(@app)
  setupEventHandlers()

setupEventHandlers = ->
  @socket.sockets.on "connection", onSocketConnection

onSocketConnection = (client) ->
  util.log "New player has connected: " + client.id
  client.on "disconnect", onClientDisconnect
  client.on "new player", onNewPlayer
  client.on "move player", onMovePlayer

onClientDisconnect = ->
        util.log("Player disconnected: " + this.id)
        players.splice(players.indexOf playerById this.id, 1)
        this.broadcast.emit("remove player", id: this.id)

players = []

onNewPlayer = (data) ->
  newPlayer = new Player(data.x, data.y, this.id)

  this.broadcast.emit("new player",
    id: this.id
    x: data.x
    y: data.y)
  for existingPlayer in players
    this.emit("new player",
      id: existingPlayer.id
      x: existingPlayer.x
      y: existingPlayer.y
    )
  players.push newPlayer

onMovePlayer = (data) ->
  movePlayer = playerById(@id)

  movePlayer.setX data.x
  movePlayer.setY data.y

  this.broadcast.emit("move player",
    id:movePlayer.id
    x: movePlayer.x
    y: movePlayer.y
  )

playerById = (id) ->
        (players.filter (player) ->
                player.id == id)[0]
onNewPlayer = (data) ->
onMovePlayer = (data) ->

startServer()
