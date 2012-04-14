util = require("util")
office = require("./office")

WALKABLE = ' _1'

class Player
  constructor: ({@x, @y, @id, @direction, @color}) ->
    @keys =
      up: false
      down: false
      left: false
      right: false
  speed: 4
  toData: -> {@x, @y, @id, @direction, @color}
  setData: ({@x, @y, @direction}) ->
  getX: -> @x
  getY: -> @y
  setX: (@x) ->
  setY: (@y) ->
  updateKeys: ({up, down, left, right}) =>
    if up != @keys.up || down != @keys.down || left != @keys.left || right != @keys.right
      @keys = {up, down, left, right}
  update: (delta) ->

    [newX, newY] = [@x, @y]

    newX += delta * @speed if @keys.right
    newX -= delta * @speed if @keys.left
    newY += delta * @speed if @keys.down
    newY -= delta * @speed if @keys.up

    if !(office[Math.floor(newY + 1.1)][Math.floor(newX + 1.1)] in WALKABLE)
      util.log "A #{newX} #{newY}"
      newX = Math.floor(newX + 1.1) - 1.11 
      newY = Math.floor(newY + 1.1) - 1.11 

    if !(office[Math.floor(newY + 1.1)][Math.floor(newX - 1.1)] in WALKABLE)
      util.log "B #{newX} #{newY}"
      newX = Math.floor(newX - 1.1) + 2.11 
      newY = Math.floor(newY + 1.1) - 1.11 

    if !(office[Math.floor(newY - 1.1)][Math.floor(newX + 1.1)] in WALKABLE)
      util.log "C #{newX} #{newY}"
      newX = Math.floor(newX + 1.1) - 1.11 
      newY = Math.floor(newY + 1.1) - 1.11 

    if !(office[Math.floor(newY - 1.1)][Math.floor(newX - 1.1)] in WALKABLE)
      util.log "D #{newX} #{newY}"
      newX = Math.floor(newX - 1.1) + 2.11 
      newY = Math.floor(newY - 1.1) + 2.11 

    [@x, @y] = [newX, newY] if newX != @x || newY != @y


exports.Player = Player
