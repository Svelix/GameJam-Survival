express = require('express')
util = require("util")
io = require("socket.io")
Player = require("./Player").Player
Player.server = true

refTime = null
socket = null

startServer = ->
  refTime = Date.now()
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
  socket = io.listen(@app)
  setupEventHandlers()

setupEventHandlers = ->
  socket.sockets.on "connection", onSocketConnection









players = []

COLORS = [
  '#FF0000',
  '#00FF00',
  '#0000FF',
  '#FFFF00',
  '#FF00FF',
  '#00FFFF'
]
nextColor = -1

onSocketConnection = (client) ->
  util.log "New player has connected: " + client.id

  nextColor = (nextColor + 1) % 5
  player = new Player x: 10, y:10, id: client.id, direction: 0, color: COLORS[nextColor]


  client.emit "start game", player.toData()
  client.broadcast.emit "new player", player.toData()
  for otherPlayer in players
    client.emit "new player", otherPlayer.toData()

  players.push player

  client.on "disconnect", onClientDisconnect
  client.on "keys changed", onKeysChanged

onClientDisconnect = ->
  util.log("Player disconnected: " + this.id)
  util.log(player.id for player in players)
  index = players.indexOf playerById this.id
  players.splice(index, 1) if index >= 0
  util.log(player.id for player in players)
  this.broadcast.emit("remove player", id: this.id)

onKeysChanged = (data) ->
  util.log "Keys changed #{data}"
  player = playerById(this.id)
  if player
    player.updateKeys data
  else
    util.log "Player not found: #{this.id}"


playerById = (id) ->
  (players.filter (player) ->
    player.id == id)[0]

gameLoop = ->
  now = Date.now()
  delta = (now - refTime) / 1000
  refTime = now

  for player in players
    if player.update(delta)
      socket.sockets.emit("player moved", player.toData())


startServer()

setInterval gameLoop, 25


