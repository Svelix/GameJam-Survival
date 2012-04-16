Player = require('./Player').Player
Shot = require('./Shot').Shot
Meeting = require("./Meeting").Meeting
cellsOverlapped = require('./Shot').cellsOverlapped
doesIntersectCirle = require('./Shot').doesIntersectCirle

COLORS = {
  X: '#000000'
  D: '#A63C00'
  C: '#222222'
  1: '#EEEEEE'
  2: '#EEEEEE'
  W: '#AAAAFF'
  }

OFFICEWIDTH = 178

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
    {
      x: mouseX
      y: mouseY
    }

  @main: =>
    @createCanvas()
    @office = require('./office').office
    @label = require('./office').label
    @refTime = Date.now()
    @socket = io.connect("/")
    @setupEventListener()
    @players = []
    @shots = []

  @startGame: (data) =>
    @localPlayer = new Player data
    @gameLoop()

  @newPlayer: (data) =>
    @players.push new Player data

  @newShot: (data) =>
    @shots.push new Shot data
  @hit: (data) =>
    shot = @shotById(data.id)
    shot?.hitPlayerId = data.hitPlayerId


  @removePlayer: (data) =>
    index = @players.indexOf @playerById data.id
    if index >= 0
      @players.splice(index, 1)
    else
      console.log "player not found: #{data.id}"

  @setupEventListener: =>
    addEventListener 'mousemove', (evt) =>
        @mousePos = @getMousePos @canvas, evt
    addEventListener 'click', (evt) =>
      return if @localPlayer.dead || @meeting
      pos = @getMousePos @canvas, evt
      pos.x += @offset
      pos.x /= 10
      pos.y /= 10
      @socket.emit "shoot", pos
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
    @socket.on "new shot", @newShot
    @socket.on "hit", @hit
    @socket.on "remove player", @removePlayer
    @socket.on "player moved", @playerMoved
    @socket.on "new meeting", @newMeeting
    @socket.on "meeting over", @meetingOver

  @newMeeting: (data) =>
    @meeting = new Meeting(data)

  @meetingOver: =>
    @meeting = null

  @playerById = (id) ->
    if @localPlayer.id == id
      @localPlayer
    else
      (@players.filter (player) ->
        player.id == id)[0]

  @shotById = (id) ->
    (@shots.filter (shot) ->
      shot.id == id)[0]

  @playerMoved: (data) =>
    player = @playerById(data.id)
    player.setData data

  @createCanvas: =>
    @canvas = document.getElementById 'canvas'
    @context = @canvas.getContext '2d'

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
    for shot in @shots
      shot.update(delta)
    @render()
    @refTime = now
    requestAnimFrame(@gameLoop)
    @meeting?.update(delta)


  @render: =>
    @context.clearRect(0,0,@canvas.width,@canvas.height)
    @context.save()

    playerX = @localPlayer.x * 10
    width = @canvas.width
    middle = width / 2
    @offset = 0
    @minX = 0
    @maxX = Math.ceil(width / 10)
    if playerX > middle
      @offset = playerX - middle
      @offset = Math.floor(Math.min(@offset, (OFFICEWIDTH + 1) * 10 - 2 * middle))
      @context.translate -@offset, 0
    @minX += Math.floor(@offset/10)
    @maxX += Math.ceil(@offset/10)
    @maxX = Math.min(@maxX, OFFICEWIDTH)

    @renderOffice()
    dx = @mousePos.x - @localPlayer.x * 10 + @offset
    dy = @mousePos.y - @localPlayer.y * 10
    if @localPlayer.setOrientation Math.atan2 dy, dx
      @socket.emit "orientation changed", @localPlayer.orientation
    @renderPlayer(@localPlayer)

    for player in @players
      @renderPlayer(player)
    i = 0
    while i < @shots.length
      shot = @shots[i]
      if shot.outdated() || shot.hitPlayerId
        @shots.splice(i, 1)
      else
        @renderShot(shot)
        i++

    @context.restore()

    @renderMeeting() if @meeting

    @renderStatus()

  @renderMeeting: =>
    @context.save()
    @context.textAlign = "center"
    @context.font = "20pt Calibri"
    if @localPlayer.status == 'M'
      @context.fillStyle = '#00FF00'
    else
      @context.fillStyle = '#FF0000'
    @context.fillText "Meeting in #{Math.round(@meeting.timeLeft)} seconds!", @canvas.width/2, 200
    @context.fillText "<---", @canvas.width/2, 250
    @context.restore()

  @renderStatus: =>
    stats =
      'coffee': '#A63C00'
      'work'  : '#00FF00'
      'health': '#AA0000'
    @context.save()
    @context.translate 50, 520
    @context.fillStyle = '#444444'
    @context.fillRect 0,0,204,2 + 14 * 3

    for stat, color of stats
      @context.fillStyle = '#000000'
      @context.fillRect 2,2,200,12
      @context.fillStyle = color
      @context.fillRect 2, 2, 200 * @localPlayer[stat], 12

      @context.font = "8pt Calibri"
      @context.fillStyle = '#FFFFFF'
      @context.fillText stat, 90, 11
      @context.translate 0, 14
    @context.restore()

    @context.save()
    @context.font = "16pt Calibri"
    @context.fillStyle = '#000000'
    @context.fillText "You survived #{Math.round @localPlayer.lifetime} seconds", 260, 540
    @context.restore()

    if @localPlayer.dead
      @context.save()
      @context.textAlign = "center"
      @context.font = "80pt Calibri"
      @context.fillStyle = '#FF0000'
      @context.fillText 'Game Over', @canvas.width/2, 200
      text = if @localPlayer.health <= 0
        'Better watch your health next time!'
      else if @localPlayer.work <= 0
        'You are fired! Work harder next time!'
      else if @localPlayer.meetingMissed
        "You are fired! Don't miss important meetings next time!"
      else
        'Better luck next time!'
      @context.font = "16pt Calibri"
      @context.fillText text, @canvas.width/2, 270
      @context.fillText 'Reload page to try again', @canvas.width/2, 290
      @context.restore()


  @renderOffice: =>
    for x in [@minX..@maxX]
      for y in [0..50]
        tile = @office[y][x]
        if (tile == 'M') && @meeting
          if @localPlayer.status == 'M'
            color = '#00FF00'
          else
            color = '#FF0000'
        else
          color = COLORS[tile]
        if color
          @context.fillStyle = color
          @context.fillRect 10 * x, 10 * y, 10, 10
    for label, pos of @label
      @context.font = "12pt Calibri"
      @context.fillText label, pos.x * 10, pos.y * 10


  @renderShot: (shot)=>
    @context.save()
    @context.translate(shot.x * 10, shot.y * 10)
    @context.rotate(shot.direction)
    @context.beginPath()
    @context.moveTo(-5,0)
    @context.lineTo(5, 0)
    @context.lineWidth = 3
    @context.strokeStyle = "#EEEE00"
    @context.lineCap = "round"
    @context.stroke()
    @context.restore()




  @renderPlayer: (player)=>
    @context.save()
    @context.translate(player.x * 10, player.y * 10)

    if player.dead
      @context.fillStyle = '#AAAAAA'
      @context.fillRect -2,-10,4,20
      @context.fillRect -6,-6,12,4
    else
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

