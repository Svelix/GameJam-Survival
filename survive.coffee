COLORS = {
  X: '#000000',
  D: '#A63C00',
  C: '#222222'
  }

class Survive
  main: ->
    @createCanvas()
    @context.font = "40pt Calibri"
    @context.fillText('Survive!', 100, 100)
    @office = require './office'
    @renderOffice()
    player = 
      x: 10
      y: 10
      orientation: 1
      color: '#ff00ff'


    @renderPlayer(player)

  createCanvas: ->
    @canvas = document.getElementById 'canvas'
    @context = @canvas.getContext '2d'
    @canvas.width = document.body.clientWidth
    @canvas.height = 510

  renderOffice: ->
    for x in [0..178]
      for y in [0..50]
        tile = @office[y][x]
        color = COLORS[tile]
        if color
          @context.fillStyle = color
          @context.fillRect 10 * x, 10 * y, 10, 10

  renderPlayer: (player)->
    ###
   <ellipse id="svg_7" ry="5" rx="2" cy="0" cx="20" stroke-width="0" stroke="#000000" fill="#ffaaaa"/>
   <ellipse ry="5" rx="2" id="svg_6" cy="0" cx="3" stroke-width="0" stroke="#000000" fill="#ffaaaa"/>
   <ellipse ry="5" rx="12" id="svg_1" cy="3" cx="12" stroke-width="0" stroke="#000000" fill="#FF0000"/>
   <circle id="svg_3" r="6" cy="3" cx="12" stroke-width="0" stroke="#000000" fill="#000000"/>

    @context.arc(centerX, centerY, radius, 0, 2 * Math.PI, false)
    ###
    @context.save()
    @context.translate(player.x * 10, player.y * 10)
    @context.rotate(player.orientation)

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
  survive = new Survive
  survive.main()

