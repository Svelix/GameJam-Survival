util = require("util")
office = require("./office").office
WALKABLE = require("./office").WALKABLE
cellsOverlapped = (x1, y1, x2, y2) ->
  result = []

  i = Math.floor x1
  j = Math.floor y1
  iend = Math.floor x2
  jend = Math.floor y2

  di = if (x1 < x2) then 1 else (if (x1 > x2) then -1 else 0)
  dj = if (y1 < y2) then 1 else (if (y1 > y2) then -1 else 0)

  minx = Math.floor x1
  maxx = minx + 1
  tx = if Math.abs(x2 - x1) > 0
    (if (x1 > x2) then (x1 - minx) else (maxx - x1)) / Math.abs(x2 - x1)
  else
    Infinity

  miny = Math.floor(y1)
  maxy = miny + 1
  ty = if Math.abs(y2 - y1) > 0
    (if (y1 > y2) then (y1 - miny) else (maxy - y1)) / Math.abs(y2 - y1)
  else
    Infinity

  deltatx = 1 / Math.abs(x2 - x1)
  deltaty = 1 / Math.abs(y2 - y1)

  loop
    result.push {x: i, y:j,
      x1, y1, x2, y2, deltatx, deltaty, di, dj, i, iend, j, jend, maxx, maxy, minx, miny, result, tx, ty
      }
    if tx <= ty
      break if i == iend
      tx += deltatx
      i += di
    else
      break if j == jend
      ty += deltaty
      j += dj
  result

class Shot
  constructor: ({@x, @y, @direction}) ->
  speed: 20
  hit: false
  toData: -> {@x, @y, @direction}
  update: (delta) ->
    if !@hit
      [oldX, oldY] = [@x, @y]
      @x += delta * @speed * Math.cos @direction
      @y += delta * @speed * Math.sin @direction


      if !(office[Math.floor(@y)][Math.floor(@x)] in WALKABLE)
        @hit = true

exports.Shot = Shot
exports.cellsOverlapped = cellsOverlapped
