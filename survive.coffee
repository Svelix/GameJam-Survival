class Survive
  main: ->
    @createCanvas()
    @context.font = "40pt Calibri"
    @context.fillText('Survive!', 100, 100)

  createCanvas: ->
      @canvas = document.getElementById 'canvas'
      @context = @canvas.getContext '2d'
      @canvas.width = document.body.clientWidth
      @canvas.height = document.body.clientHeight
 
window.onload = () ->
  survive = new Survive
  survive.main()

