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
      orientation: 30
      color: '#0000ff'


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
    @context.save()
    @context.moveTo(player.x,player.y)
    @context.save()
    @context.fillStyle = "#ffaaaa"
    @context.transform(0.04499771,0,0,0.04459232,162.92379,29.408366)
    @context.beginPath()
    @context.moveTo(309.10667,172.51932)
    @context.translate(275.771635,172.51932)
    @context.scale(0.29729729512794123,1)
    @context.arc(0,0,112.12693672727278,0,3.141592653589793,0)
    @context.scale(3.363636388180566,1)
    @context.translate(-275.771635,-172.51932)
    @context.translate(275.771635,172.51932)
    @context.scale(0.29729729512794123,1)
    @context.arc(0,0,112.12693672727278,3.141592653589793,6.283185307179586,0)
    @context.scale(3.363636388180566,1)
    @context.translate(-275.771635,-172.51932)
    @context.closePath()
    @context.fill()
    @context.stroke()
    @context.restore()
    @context.save()
    @context.fillStyle = "#ffaaaa"
    @context.transform(0.04499771,0,0,0.04459232,178.84062,29.408366)
    @context.beginPath()
    @context.moveTo(309.10667,172.51932)
    @context.translate(275.771635,172.51932)
    @context.scale(0.29729729512794123,1)
    @context.arc(0,0,112.12693672727278,0,3.141592653589793,0)
    @context.scale(3.363636388180566,1)
    @context.translate(-275.771635,-172.51932)
    @context.translate(275.771635,172.51932)
    @context.scale(0.29729729512794123,1)
    @context.arc(0,0,112.12693672727278,3.141592653589793,6.283185307179586,0)
    @context.scale(3.363636388180566,1)
    @context.translate(-275.771635,-172.51932)
    @context.closePath()
    @context.fill()
    @context.stroke()
    @context.restore()
    @context.save()
    @context.fillStyle = player.color
    @context.strokeStyle = "#000000"
    @context.lineWidth = 1
    @context.lineCap = "butt"
    @context.lineJoin = "miter"
    @context.transform(0.04082446,0,0,0.03733757,166.16161,31.985969)
    @context.beginPath()
    @context.moveTo(660.63976,234.13863)
    @context.translate(417.192995,234.13863)
    @context.scale(1,0.3236514669572928)
    @context.arc(0,0,243.446765,0,3.141592653589793,0)
    @context.scale(1,3.089743449647192)
    @context.translate(-417.192995,-234.13863)
    @context.translate(417.192995,234.13863)
    @context.scale(1,0.3236514669572928)
    @context.arc(0,0,243.446765,3.141592653589793,6.283185307179586,0)
    @context.scale(1,3.089743449647192)
    @context.translate(-417.192995,-234.13863)
    @context.closePath()
    @context.fill()
    @context.stroke()
    @context.restore()
    @context.save()
    @context.fillStyle = "#000000"
    @context.strokeStyle = "#000000"
    @context.lineWidth = 1
    @context.lineCap = "butt"
    @context.lineJoin = "miter"
    @context.transform(0.05978698,0,0,0.0597654,156.4658,24.59396)
    @context.beginPath()
    @context.moveTo(505.07628,261.41275)
    @context.translate(447.49759,261.4313368811172)
    @context.scale(1,1)
    @context.arc(0,0,57.578693,-0.0003228083246665498,3.141915461914787,0)
    @context.scale(1,1)
    @context.translate(-447.49759,-261.4313368811172)
    @context.translate(447.49759,261.39416311888283)
    @context.scale(1,1)
    @context.arc(0,0,57.578693,3.1412698452651266,6.2835081155045795,0)
    @context.scale(1,1)
    @context.translate(-447.49759,-261.39416311888283)
    @context.closePath()
    @context.fill()
    @context.stroke()
    @context.restore()
    @context.restore()


window.onload = () ->
  survive = new Survive
  survive.main()

