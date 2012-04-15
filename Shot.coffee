util = require("util")
office = require("./office").office
WALKABLE = require("./office").WALKABLE

class Shot
  constructor: ({@x, @y, @direction}) ->
  speed: 20
  toData: -> {@x, @y, @direction}
  update: (delta) ->
    changed = false
    @x += delta * @speed * Math.cos @direction
    @y += delta * @speed * Math.sin @direction

exports.Shot = Shot
