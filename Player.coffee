util = require("util")

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

    [@x, @y] = [newX, newY] if newX != @x || newY != @y


exports.Player = Player
