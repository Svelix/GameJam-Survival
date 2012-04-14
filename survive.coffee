Player = require('./Player').Player

COLORS = {
  X: '#000000'
  D: '#A63C00'
  C: '#222222'
  1: '#EEEEEE'
  2: '#EEEEEE'
  }

requestAnimFrame = (() ->
  window.requestAnimationFrame       ||
  window.webkitRequestAnimationFrame ||
  window.mozRequestAnimationFrame    ||
  window.oRequestAnimationFrame      ||
  window.msRequestAnimationFrame     ||
  (callback, element) ->
    window.setTimeout(callback, 1000 / 60)
)()

class Survive
  @mousePos: {
    x: 0
    y: 0
  }

  @keys =
    up: false
    down: false
    left: false
    right: false

  @getMousePos: (canvas, evt) ->
    obj = canvas
    top = 0
    left = 0
    while obj && obj.tagName != 'BODY'
        top += obj.offsetTop
        left += obj.offsetLeft
        obj = obj.offsetParent
    mouseX = evt.clientX - left + window.pageXOffset
    mouseY = evt.clientY - top + window.pageYOffset
    @mousePos = {
      x: mouseX
      y: mouseY
    }

  @main: =>
    @createCanvas()
    @office = require('./office').office
    @label = require('./office').label
    @refTime = Date.now()
    @socket = io.connect("/", {port: 8080})
    @setupEventListener()
    @players = []

  @startGame: (data) =>
    @localPlayer = new Player data
    @gameLoop()

  @newPlayer: (data) =>
    @players.push new Player data

  @removePlayer: (data) =>
    index = @players.indexOf @playerById data.id
    if index >= 0
      @players.splice(index, 1)
    else
      console.log "player not found: #{data.id}"

  @setupEventListener: =>
    @canvas.addEventListener 'mousemove', (evt) =>
        @mousePos = @getMousePos @canvas, evt
    addEventListener "keydown", (evt) =>
      switch evt.keyCode
        when 38, 87
          @keys.up = true
        when 40, 83
          @keys.down = true
        when 37, 65
          @keys.left = true
        when 39, 68
          @keys.right = true
      evt.preventDefault()
      false
    addEventListener "keyup", (evt) =>
      switch evt.keyCode
        when 38, 87
          @keys.up = false
        when 40, 83
          @keys.down = false
        when 37, 65
          @keys.left = false
        when 39, 68
          @keys.right = false
      evt.preventDefault()
      false
    @socket.on "start game", @startGame
    @socket.on "new player", @newPlayer
    @socket.on "remove player", @removePlayer
    @socket.on "player moved", @playerMoved

  @playerById = (id) ->
    if @localPlayer.id == id
      @localPlayer
    else
      (@players.filter (player) ->
        player.id == id)[0]

  @playerMoved: (data) =>
    player = @playerById(data.id)
    player.setData data

  @createCanvas: =>
    @canvas = document.getElementById 'canvas'
    @context = @canvas.getContext '2d'
    @canvas.width = document.body.clientWidth
    @canvas.height = 610


  @updatePlayer: (delta)=>
    if @localPlayer.updateKeys @keys
      @socket.emit "keys changed", @localPlayer.keys
    @localPlayer.update(delta)

  @gameLoop: =>
    now = Date.now()
    delta = (now - @refTime) / 1000

    fps = document.getElementById 'fps'
    fps.innerHTML = 1/delta

    @context = @canvas.getContext '2d'
    @updatePlayer(delta)
    @render()
    @refTime = now
    requestAnimFrame(@gameLoop)


  @render: =>
    @context.clearRect(0,0,@canvas.width,@canvas.height)
    @renderOffice()
    dx = @mousePos.x - @localPlayer.x * 10
    dy = @mousePos.y - @localPlayer.y * 10
    @localPlayer.orientation = Math.atan2 dy, dx
    @renderPlayer(@localPlayer)
    for player in @players
      @renderPlayer(player)
    @renderStatus()

  @renderStatus: =>
    @context.save()
    @context.translate 50, 520
    @context.fillStyle = '#444444'
    @context.fillRect 0,0,204,16

    @context.fillStyle = '#000000'
    @context.fillRect 2,2,200,12
    @context.fillStyle = '#A63C00'
    @context.fillRect 2,2,200*@localPlayer.coffee,12

    @context.font = "8pt Calibri"
    @context.fillStyle = '#FFFFFF'
    @context.fillText 'coffee', 90, 11
    @context.restore()

  @renderOffice: =>
    for x in [0..178]
      for y in [0..50]
        tile = @office[y][x]
        color = COLORS[tile]
        if color
          @context.fillStyle = color
          @context.fillRect 10 * x, 10 * y, 10, 10
    for label, pos of @label
      @context.font = "12pt Calibri"
      @context.fillText label, pos.x * 10, pos.y * 10


  @renderPlayer: (player)=>
    @context.save()
    @context.translate(player.x * 10, player.y * 10)
    @context.rotate(player.orientation)

    @context.rotate(Math.PI/2)

    @context.save()
    @context.scale(0.4,1)
    @context.beginPath()
    @context.arc(14, -3, 7, 0, 2 * Math.PI, false)
    @context.fillStyle = "#ffaaaa"
    @context.fill()
    @context.restore()

    @context.save()
    @context.scale(0.4,1)
    @context.beginPath()
    @context.arc(-14, -3, 7, 0, 2 * Math.PI, false)
    @context.fillStyle = "#ffaaaa"
    @context.fill()
    @context.restore()

    @context.save()
    @context.scale(1,0.5)
    @context.beginPath()
    @context.arc(0, 0, 10, 0, 2 * Math.PI, false)
    @context.fillStyle = player.color
    @context.fill()
    @context.restore()

    @context.save()
    @context.beginPath()
    @context.arc(0, 0, 5, 0, 2 * Math.PI, false)
    @context.fillStyle = '#000000'
    @context.fill()
    @context.restore()

    @context.restore()


window.onload = () ->
  Survive.main()

