assert = require("assert")
EventEmitter = require("events")
Tile = require("../../web/static/js/tile")

class Channel extends EventEmitter
  push: (event, payload) ->
    @emit("push", event, payload)
    result = receive: (status, callback) =>
      setTimeout (-> callback(status, payload)), 1
    result
  leave: ->
    @emit("leave")

describe "Tile", ->
  rt = join: (_name, _payload, callback) ->
    setTimeout (-> callback(null, values: [])), 1
    new Channel()

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

  it "should leave channel when destroying", (done) ->
    tile = new Tile(rt, 0, 0)
    tile.channel.on "leave", done
    tile.destroy()

  it "should send show to channel", (done) ->
    tile = new Tile(rt, 0, 0)
    tile.channel.on "push", (event, payload) ->
      assert.equal "show", event
      assert.deepEqual {x: 1, y: 2}, payload
      done()
    tile.show(1, 2, (->))

  it "should receive status when sending show", (done) ->
    tile = new Tile(rt, 0, 0)
    tile.show 1, 2, (status, _message) ->
      assert.equal "ok", status
      done()

  it "should update value", ->
    tile = new Tile(rt, 0, 0)
    tile.update(0, 0, 42)
    assert.equal 42, tile.get(0, 0)
