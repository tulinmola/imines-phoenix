EventEmitter = require("./events")

SIZE = 8
valuesIndex = (x, y) -> (y * SIZE) + x

class Tile extends EventEmitter
  constructor: (@rt, @x, @y) ->
    @values = (-1 for index in [1..(SIZE*SIZE)])
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

  update: (x, y, value) ->
    @values[valuesIndex(x, y)] = value
    @emit("refresh")

  get: (x, y) ->
    @values[valuesIndex(x, y)]

module.exports = Tile
