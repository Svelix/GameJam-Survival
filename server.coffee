express = require('express')
util = require("util")
io = require("socket.io")
Player = require("./Player").Player
Player.server = true
Shot = require("./Shot").Shot
Meeting = require("./Meeting").Meeting
getStartPos = require('./office').getStartPos

port = process.env.PORT || 8080

refTime = null
socket = null

startServer = ->
  refTime = Date.now()
  initExpress()
  initSocketIO()

initExpress = ->
  @app = express.createServer()
  @app.listen(port)

  bundle = require('browserify')(__dirname + '/survive.coffee', {mount: '/all.js'})
  @app.use(bundle)

  @app.get '/', (req, res) ->
    res.sendfile 'index.html'


initSocketIO = ->
  socket = io.listen(@app)
  ## Heroku only supports long-polling at the moment
  if process.env.HEROKU
    socket.configure () ->
      socket.set "transports", ["xhr-polling"]
      socket.set "polling duration", 10
  setupEventHandlers()

setupEventHandlers = ->
  socket.sockets.on "connection", onSocketConnection









players = []

shots = []

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

  pos = getStartPos()
  util.log "#{pos.x}#{pos.y}"
  player = new Player x: pos.x, y: pos.y, id: client.id, direction: 0, color: COLORS[nextColor]


  client.emit "start game", player.toData()
  client.broadcast.emit "new player", player.toData()
  for otherPlayer in players
    client.emit "new player", otherPlayer.toData()
    client.emit("new meeting", meeting.toData()) if meeting
  for shot in shots
    client.emit "new shot", shot.toData()

  players.push player

  client.on "disconnect", onClientDisconnect
  client.on "keys changed", onKeysChanged
  client.on "shoot", onShoot
  client.on "orientation changed", onOrientationChanged

onClientDisconnect = ->
  util.log("Player disconnected: " + this.id)
  util.log(player.id for player in players)
  index = players.indexOf playerById this.id
  players.splice(index, 1) if index >= 0
  util.log(player.id for player in players)
  this.broadcast.emit("remove player", id: this.id)

onOrientationChanged = (data) ->
  player = playerById(this.id)
  if player
    player.setOrientation data
  else
    util.log "Player not found: #{this.id}"

onKeysChanged = (data) ->
  util.log "Keys changed #{data}"
  player = playerById(this.id)
  if player
    player.updateKeys data
  else
    util.log "Player not found: #{this.id}"

onShoot = (data) ->
  util.log "Shoot #{data}"
  player = playerById(this.id)
  if player && !player.dead && !meeting
    x = player.x
    y = player.y
    dx = data.x - player.x
    dy = data.y - player.y
    direction = Math.atan2 dy, dx
    shot = new Shot({x,y,direction, shooterId: player.id})
    shots.push shot
    socket.sockets.emit("new shot", shot.toData())
  else
    util.log "Player not found: #{this.id}"


playerById = (id) ->
  (players.filter (player) ->
    player.id == id)[0]

nextMeeting = Date.now() + 15000
meeting = null

gameLoop = ->
  now = Date.now()
  delta = (now - refTime) / 1000
  refTime = now

  for player in players
    if player.update(delta)
      socket.sockets.emit("player moved", player.toData())
  i = 0
  while i < shots.length
    shot = shots[i]
    if shot.outdated() || shot.hitPlayerId
      shots.splice(i, 1)
    else
      if shot.update(delta, players)
        socket.sockets.emit("hit", shot.toData())
      i++
  meeting?.update(delta, players)
  if meeting?.finished
    socket.sockets.emit("meeting over", {})
    meeting = null

  if nextMeeting < now
    meeting = new Meeting({timeLeft: 60})
    nextMeeting = now + (120 + Math.random() * 60) * 1000
    socket.sockets.emit("new meeting", meeting.toData())



startServer()

setInterval gameLoop, 25


