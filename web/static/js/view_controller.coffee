Navigator = require("./navigator")
EventEmitter = require("./events")
TileRenderer = require("./tile_renderer")

mod = (a, b) -> ((a % b) + b) % b
hash = (x, y) -> "#{x}x#{y}"
tileInArray = (tile, array) -> array.indexOf(tile) >= 0

BLOCK_SIZE = 32 # TODO: Adapt this block size depending on current mobile/desktop environment
TILE_SIZE = 8   # TODO: Get from some kind of config?

class ViewController extends EventEmitter
  constructor: (element, @tiles) ->
    @$el = $(element)
    @$axes = @$el.find(".axes")
    @$arena = @$el.find(".arena")
    [@icons] = $("#icons-2x")   # TODO: Get icon based on device pixel ratio

    @navigator = new Navigator(this)
    @currentTiles = []
    @renderers = {}

    $(window).on "resize", @resize
    setTimeout ( => @resize()), 1

  resize: =>
    @offset = @$el.offset()
    @width = @$el.width()
    @height = @$el.height()
    @update()

  getTileAndPosition: ({x, y}) ->
    # world position
    wx = Math.floor(x / BLOCK_SIZE)
    wy = Math.floor(y / BLOCK_SIZE)
    # tile coordinates
    tx = Math.floor(wx / TILE_SIZE)
    ty = Math.floor(wy / TILE_SIZE)
    tile = @tiles.get(hash(tx, ty))
    # in-tile relative position
    rx = mod(wx, TILE_SIZE)
    ry = mod(wy, TILE_SIZE)
    {tile, x: rx, y: ry}

  tap: (position) ->
    {tile, x, y} = @getTileAndPosition(position)
    tile.show(x, y)

  press: (position) ->
    {tile, x, y} = @getTileAndPosition(position)
    # TODO: Add flag

  dtap: (position) ->
    {tile, x, y} = @getTileAndPosition(position)
    # TODO: Zooming?

  getViewport: (sx, sy, scale) ->
    iScale = 1 / scale
    width = @width * iScale
    height = @height * iScale
    x = -sx - width * 0.5
    y = -sy - height * 0.5
    {x, y, width, height}

  setTransforms: (x, y, scale) ->
    w2 = @width * 0.5
    h2 = @height * 0.5
    @$axes.css
      transform: "scale3d(#{scale}, #{scale}, 1) translate3d(#{w2}px, #{h2}px, 0)"
    @$arena.css
      transform: "translate3d(#{x}px, #{y}px, 0)"

  getVisibleTiles: (x, y, scale) ->
    viewport = @getViewport(x, y, scale)
    size = BLOCK_SIZE * TILE_SIZE
    x0 = Math.floor(viewport.x / size)
    y0 = Math.floor(viewport.y / size)
    x1 = Math.ceil((viewport.x + viewport.width) / size)
    y1 = Math.ceil((viewport.y + viewport.height) / size)
    tiles = []
    for ty in [y0...y1]
      for tx in [x0...x1]
        id = hash(tx, ty)
        tiles.push(id)
    tiles

  showNewTiles: (tiles) ->
    for id in tiles
      tile = @tiles.get(id)
      isNew = tileInArray(id, tiles) && !tileInArray(id, @currentTiles)
      if isNew && !@renderers[id]
        renderer = @renderers[id] = new TileRenderer(@icons, tile)
        @$arena.append(renderer.$el)
    undefined

  hideOldTiles: (tiles) ->
    for id in @currentTiles
      isOld = tileInArray(id, @currentTiles) && !tileInArray(id, tiles)
      if isOld
        renderer = @renderers[id]
        renderer.destroy()
        delete @renderers[id]
    undefined

  update: ->
    {x, y, scale} = @navigator
    @setTransforms(x, y, scale)
    tiles = @getVisibleTiles(x, y, scale)
    @showNewTiles(tiles)
    @hideOldTiles(tiles)
    @currentTiles = tiles

module.exports = ViewController
