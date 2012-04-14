util = require("util")
office = require("./office").office
WALKABLE = require("./office").WALKABLE

class Player
  constructor: ({@x, @y, @id, @direction, @color}) ->
    @keys =
      up: false
      down: false
      left: false
      right: false

  @server: false
  lifetime: 0
  lastChange: 0
  coffee: 0.5
  status: " "
  toData: -> {@x, @y, @id, @direction, @color, @coffee, @status}
  setData: ({@x, @y, @direction, @coffee, @status}) ->
  getX: -> @x
  getY: -> @y
  setX: (@x) ->
  setY: (@y) ->
  getSpeed: ->
    4 + @coffee * 8
  updateKeys: ({up, down, left, right}) =>
    if up != @keys.up || down != @keys.down || left != @keys.left || right != @keys.right
      @keys = {up, down, left, right}
  update: (delta) ->
    changed = false

    [newX, newY] = [@x, @y]

    newX += delta * @getSpeed() if @keys.right
    newX -= delta * @getSpeed() if @keys.left
    newY += delta * @getSpeed() if @keys.down
    newY -= delta * @getSpeed() if @keys.up

    if !(office[Math.floor(@y - 1)][Math.floor(newX + 1.1)] in WALKABLE) ||
       !(office[Math.floor(@y + 0)][Math.floor(newX + 1.1)] in WALKABLE) ||
       !(office[Math.floor(@y + 1)][Math.floor(newX + 1.1)] in WALKABLE)
      newX = @x

    if !(office[Math.floor(@y - 1)][Math.floor(newX - 1.1)] in WALKABLE) ||
       !(office[Math.floor(@y + 0)][Math.floor(newX - 1.1)] in WALKABLE) ||
       !(office[Math.floor(@y + 1)][Math.floor(newX - 1.1)] in WALKABLE)
      newX = @x

    if !(office[Math.floor(newY + 1.1)][Math.floor(newX - 1)] in WALKABLE) ||
       !(office[Math.floor(newY + 1.1)][Math.floor(newX + 0)] in WALKABLE) ||
       !(office[Math.floor(newY + 1.1)][Math.floor(newX + 1)] in WALKABLE)
      newY = @y

    if !(office[Math.floor(newY - 1.1)][Math.floor(newX - 1)] in WALKABLE) ||
       !(office[Math.floor(newY - 1.1)][Math.floor(newX + 0)] in WALKABLE) ||
       !(office[Math.floor(newY - 1.1)][Math.floor(newX + 1)] in WALKABLE)
      newY = @y

    if newX != @x || newY != @y
      [@x, @y] = [newX, newY]
      changed = true

    if Player.server
      newStatus = office[Math.floor @y][Math.floor @x]
      if newStatus != @status
        changed = true
        @status = newStatus

      @lifetime += delta
      while @lifetime - @lastChange > 1
        @lastChange += 1
        if @status == '2'
          if @coffee < 1
            changed = true
            @coffee += 0.1
            @coffee = 1 if @coffee > 1
        else
          if @coffee > 0
            changed = true
            @coffee -= 0.01
            @coffee = 0 if @coffee < 0

    changed


exports.Player = Player
