{Socket} = require("phoenix")

class Realtime
  constructor: (params) ->
    @socket = new Socket("/socket", {params: params})
    @socket.connect()

  join: (name, payback = {}, callback) ->
    channel = @socket.channel(name, payback)
    channel.join()
      .receive "ok", (response) -> callback?(null, response)
      .receive "error", (response) -> callback?(response)
    channel

module.exports = Realtime
