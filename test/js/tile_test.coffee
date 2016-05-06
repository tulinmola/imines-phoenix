assert = require("assert")
EventEmitter = require("events")
Tile = require("../../web/static/js/tile")

describe "Tile", ->
  rt = join: (_name, _payload, callback) ->
    setTimeout (-> callback(null, values: [])), 1
    new EventEmitter()

  it "should emit 'connect' event when joining to channel", (done) ->
    tile = new Tile(rt, 0, 0)
    tile.on "connect", done

  it "should emit 'refresh' event when updating", (done) ->
    tile = new Tile(rt, 0, 0)
    tile.once "refresh", done
    tile.update(0, 0, 0)

  it "should emit 'destroy' event when destroying", (done) ->
    tile = new Tile(rt, 0, 0)
    tile.on "destroy", done
    tile.destroy()

  it "should update value", ->
    tile = new Tile(rt, 0, 0)
    tile.update(0, 0, 42)
    assert.equal 42, tile.get(0, 0)
