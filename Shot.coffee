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
    result.push {x: i, y:j}
    if tx <= ty
      break if i == iend
      tx += deltatx
      i += di
    else
      break if j == jend
      ty += deltaty
      j += dj
  result


doesIntersectCirle = (p1,p2,sc,r) ->

  # is one point inside the circle?
  if (p1.x - sc.x) * (p1.x - sc.x) + (p1.y - sc.y) * (p1.y - sc.y) < r * r ||
    (p2.x - sc.x) * (p2.x - sc.x) + (p2.y - sc.y) * (p2.y - sc.y) < r * r
      return true

  # is closest point from circle center on our line?
  u = ((sc.x - p1.x)*(p2.x - p1.x) + (sc.y - p1.y)*(p2.y - p1.y)) /
    ((p2.x - p1.x)*(p2.x - p1.x) + (p2.y - p1.y)*(p2.y - p1.y)) 
  unless 0 <= u <= 1
    return false


  dp = {}

  dp.x = p2.x - p1.x
  dp.y = p2.y - p1.y
  a = dp.x * dp.x + dp.y * dp.y
  b = 2 * (dp.x * (p1.x - sc.x) + dp.y * (p1.y - sc.y))
  c = sc.x * sc.x + sc.y * sc.y
  c += p1.x * p1.x + p1.y * p1.y
  c -= 2 * (sc.x * p1.x + sc.y * p1.y)
  c -= r * r
  bb4ac = b * b - 4 * a * c
  if (Math.abs(a) < Number.MIN_VALUE || bb4ac < 0)
    return false
  else
    return true

currentId = 0
class Shot
  constructor: ({@x, @y, @direction, @id, @shooterId}) ->
    @id = currentId++ unless @id
  speed: 20
  hit: false
  hitPlayerId: null
  toData: -> {@x, @y, @direction, @id, @hitPlayerId}
  update: (delta, players = []) ->
    if !@hit
      [oldX, oldY] = [@x, @y]
      @x += delta * @speed * Math.cos @direction
      @y += delta * @speed * Math.sin @direction

      passedCells = cellsOverlapped oldX, oldY, @x, @y
      for cell in passedCells
        if !(office[Math.floor(cell.y)][Math.floor(cell.x)] in WALKABLE)
          @hit = true
          @hitDate = Date.now()
      for player in players
        unless player.id == @shooterId
          if doesIntersectCirle {x:oldX, y:oldY}, {@x, @y}, player, 1
            @hit = true
            @hitDate = Date.now()
            @hitPlayerId = player.id
            return true
    false

  outdated: ->
    @hitDate && (@hitDate + 5000 < Date.now())

exports.Shot = Shot
exports.cellsOverlapped = cellsOverlapped
exports.doesIntersectCirle = doesIntersectCirle
