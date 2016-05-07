LruCache = require("./lru_cache")
Tile = require("./tile")

class TileFactory
  constructor: (@rt) ->

  create: (id) ->
    [x, y] = id.split("x")
    new Tile(@rt, x, y)

class TileManager
  constructor: (rt) ->
    factory = new TileFactory(rt)
    onRemove = (tile) -> tile.destroy()
    @cache = new LruCache({factory, onRemove})

  get: (id) ->
    @cache.get(id)

module.exports = TileManager
