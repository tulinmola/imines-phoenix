EventEmitter = require("./events")

TILE_SIZE = 8  # TODO: Get from some kind of config?
valuesIndex = (x, y) -> (y * TILE_SIZE) + x

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

  show: (x, y) ->
    @channel.push("show", {x, y})

  destroy: ->
    @channel.leave()
    @emit("destroy")

  update: (x, y, value) ->
    @values[valuesIndex(x, y)] = value
    @emit("refresh")

  get: (x, y) ->
    @values[valuesIndex(x, y)]

module.exports = Tile
