class Survive
  main: ->
    @createCanvas()
    @context.font = "40pt Calibri"
    @context.fillText('Survive!', 100, 100)
    @office = require './office'
    @renderOffice()

  createCanvas: ->
    @canvas = document.getElementById 'canvas'
    @context = @canvas.getContext '2d'
    @canvas.width = document.body.clientWidth
    @canvas.height = document.body.clientHeight

  renderOffice: ->
    for row in @office
      for tile in row
        console.log tile


window.onload = () ->
  survive = new Survive
  survive.main()

