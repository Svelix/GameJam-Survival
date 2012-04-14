COLORS = {
  X: '#000000',
  D: '#A63C00',
  C: '#222222'
  }
WALKABLE = ' _1'

class Survive
  @mousePos: {
    x: 0
    y: 0
  }
  @keysDown: {}

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
    @context.font = "40pt Calibri"
    @context.fillText('Survive!', 100, 100)
    @office = require './office'
    @player =
      x: 10
      y: 10
      orientation: 1
      color: '#ff00ff'
      speed: 4
    @refTime = Date.now()

    @canvas.addEventListener 'mousemove', (evt) =>
        @mousePos = @getMousePos @canvas, evt
    addEventListener "keydown", (evt) =>
      @keysDown[evt.keyCode] = true
      evt.preventDefault()
      false

    addEventListener "keyup", (evt) =>
      delete @keysDown[evt.keyCode]
      evt.preventDefault()
      false

    setInterval(@gameLoop, 1)


  @createCanvas: =>
    @canvas = document.getElementById 'canvas'
    @context = @canvas.getContext '2d'
    @canvas.width = document.body.clientWidth
    @canvas.height = 510


  @updatePlayer: (delta)=>
    if 38 of @keysDown || 87 of @keysDown
      newY = @player.y - @player.speed * delta
      if !(@office[Math.floor newY - 1.1][Math.floor @player.x] in WALKABLE)
        newY = Math.ceil newY
      @player.y = newY
    if 40 of @keysDown || 83 of @keysDown
      newY = @player.y + @player.speed * delta
      if !(@office[Math.floor newY + 1.1][Math.floor @player.x] in WALKABLE)
        newY = Math.floor newY
      @player.y = newY
    if 37 of @keysDown || 65 of @keysDown
      newX = @player.x - @player.speed * delta
      if !(@office[Math.floor @player.y][Math.floor newX - 1.1] in WALKABLE)
        newX = Math.ceil newX
      @player.x = newX
    if 39 of @keysDown || 68 of @keysDown
      newX = @player.x + @player.speed * delta
      if !(@office[Math.floor @player.y][Math.floor newX + 1.1] in WALKABLE)
        newX = Math.floor newX
      @player.x = newX


  @gameLoop: =>
    now = Date.now()
    delta = (now - @refTime) / 1000

    fps = document.getElementById 'fps'
    fps.innerHTML = 1/delta

    @context = @canvas.getContext '2d'
    @updatePlayer(delta)
    @render()
    @refTime = now


  @render: =>
    @context.clearRect(0,0,@canvas.width,@canvas.height)
    @renderOffice()
    dx = @mousePos.x - @player.x * 10
    dy = @mousePos.y - @player.y * 10
    @player.orientation = Math.atan2 dy, dx
    @renderPlayer(@player)


  @renderOffice: =>
    for x in [0..178]
      for y in [0..50]
        tile = @office[y][x]
        color = COLORS[tile]
        if color
          @context.fillStyle = color
          @context.fillRect 10 * x, 10 * y, 10, 10


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

