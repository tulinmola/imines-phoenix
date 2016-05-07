Tile = require("./tile")

BLOCK_SIZE = 32 # TODO: Adapt this block size depending on current mobile/desktop environment
TILE_SIZE = 8  # TODO: Get from some kind of config?

class TileRenderer
  constructor: (@icons, @tile) ->
    @iconSize = @icons.height
    @$el = @createCanvas()
    @tile.on "refresh", @onTileUpdate
    @tile.on "destroy", @onTileDestroy
    @onTileUpdate() if @tile.values

  destroy: ->
    @$el.remove()
    @tile.removeListener "refresh", @onTileUpdate
    @tile.removeListener "destroy", @onTileDestroy

  createCanvas: ->
    canvasSize = TILE_SIZE * @iconSize
    canvas = document.createElement("canvas")
    canvas.width = canvas.height = canvasSize
    {x, y} = @tile
    elementSize = TILE_SIZE * BLOCK_SIZE
    $el = $(canvas)
      .addClass("tile")
      .css
        transform: "translate3d(#{x * elementSize}px, #{y * elementSize}px, 0)"
        width: elementSize
        height: elementSize

  onTileUpdate: =>
    context = @$el[0].getContext("2d")
    size = @iconSize
    for y in [0...TILE_SIZE]
      for x in [0...TILE_SIZE]
        cx = x * @iconSize
        cy = y * @iconSize
        value = @tile.get(x, y)
        sprite = value || parseInt(value, 10)
        context.drawImage(@icons, sprite * size, 0, size, size,
                                  cx, cy, size, size)
    undefined

  onTileDestroy: =>
    throw "not implemented"

module.exports = TileRenderer
