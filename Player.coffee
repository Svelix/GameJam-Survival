util = require("util")
office = require("./office").office
WALKABLE = require("./office").WALKABLE

class Player
  constructor: ({@x, @y, @id, @orientation, @color, @dead}) ->
    @keys =
      up: false
      down: false
      left: false
      right: false

  @server: false
  lifetime: 0
  lastChange: 0
  coffee: 0.5
  work: 0.5
  health: 1
  dead: false
  meetingMissed: false
  status: " "
  toData: -> {@x, @y, @id, @orientation, @color, @coffee, @status, @work, @health, @dead, @lifetime, @meetingMissed}
  setData: ({@x, @y, @orientation, @coffee, @status, @work, @health, @dead, @lifetime, @meetingMissed}) ->
  getX: -> @x
  getY: -> @y
  setX: (@x) ->
  setY: (@y) ->
  getSpeed: ->
    4 + @coffee * 8
  updateKeys: ({up, down, left, right}) =>
    return if @dead
    if up != @keys.up || down != @keys.down || left != @keys.left || right != @keys.right
      @keys = {up, down, left, right}
  setOrientation: (orientation) =>
    return if @dead
    orientation = Math.round(orientation * 20) / 20
    @needsUpdate = true
    @orientation = orientation if @orientation != orientation
  hit: () =>
    @health = Math.max(0, @health - 0.1)
    @needsUpdate = true
  meeting: () =>
    unless @status == 'M'
      @needsUpdate = true
      @meetingMissed = true
  update: (delta) ->
    return if @dead
    changed = false

    if @needsUpdate
      changed = true
      @needsUpdate = false

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

    ## Server only
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

        if @status == '1'
          if @work < 1
            changed = true
            @work += 0.1 * @coffee
            @work = 1 if @work > 1
        else
          if @work > 0
            changed = true
            @work -= 0.01
            @work = 0 if @work < 0
        if @status == 'W'
          if @health < 1
            changed = true
            @health += 0.05
            @health = 1 if @health > 1

      if @work <= 0 || @health <= 0 || @meetingMissed
        @dead = true
        changed = true
    ## End Server only

    changed


exports.Player = Player
