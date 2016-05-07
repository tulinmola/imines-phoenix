EventEmitter = require("./events")

TILE_SIZE = 8  # TODO: Get from some kind of config?
valuesIndex = (x, y) -> (y * TILE_SIZE) + x

TILE_WATER = 10

class Tile extends EventEmitter
  constructor: (@rt, @x, @y) ->
    @values = (-1 for index in [1..TILE_SIZE * TILE_SIZE])
    name = "tiles:#{@x}x#{@y}"
    @channel = @rt.join name, {}, (error, response) =>
      unless error
        @emit("connect")
        @refresh(response.values)
      else
        @emit("error", error)
    @channel.on "update", ({x, y, value}) =>
      @update(x, y, value)

  refresh: (@values) ->
    @emit("refresh")

  show: (x, y, callback) ->
    @channel.push("show", {x, y})
      .receive "ok", (message) => callback(this, x, y, message)

  destroy: ->
    @channel.leave()
    @emit("destroy")

  update: (x, y, value) ->
    @values[valuesIndex(x, y)] = value
    @emit("refresh")

  get: (x, y) ->
    @values[valuesIndex(x, y)]

  isWater: (x, y) ->
    @get(x, y) == TILE_WATER

module.exports = Tile
