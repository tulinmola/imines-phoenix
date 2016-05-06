assert = require("assert")
LruCache = require("../../web/static/js/lru_cache")

describe "LRU cache", ->
  createCache = (options = {}) ->
    options.factory ||= create: (id) -> id
    new LruCache(options)

  it "should be empty", ->
    cache = createCache()
    assert.equal 0, cache.count

  it "should create element only once", ->
    cache = createCache()
    assert.equal "first", cache.get("first")
    assert.equal 1, cache.count
    cache.get("first")
    assert.equal 1, cache.count

  it "should set as first element the last recently used", ->
    cache = createCache()
    cache.get(id) for id in ["first", "second", "first"]
    assert.equal "first", cache.at(0)
    assert.equal "second", cache.at(1)

  it "should loWater cache when passing hiWater", ->
    cache = createCache(loWater: 1, hiWater: 2)
    cache.get(id) for id in ["first", "second", "third"]
    assert.equal 1, cache.count
    assert.equal "third", cache.at(0)
