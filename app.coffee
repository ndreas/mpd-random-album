config = require("./config")
mpd = require("mpd")
restify = require("restify")

client = mpd.connect
    host: config.mpd.host
    port: config.mpd.port

whenPlayingLastSong = (callback) ->
    cmd = mpd.cmd("status", [])

    client.sendCommand cmd, (err, status) ->
        if err
            console.log(err)
            return

        state = status.match(/^state: (.*)$/mi)

        if state && state[1].trim() == "play"
            nextSong = status.match(/^nextsongid: .*$/mi)
            callback() unless nextSong

addRandomAlbum = (clearPlaylist = false) ->
    cmd = mpd.cmd("list", [ "album" ])

    client.sendCommand cmd, (err, msg) ->
        if err
            console.log(err)
            return

        lines = msg.split("\n")
        len = lines.length

        album = lines[Math.floor(Math.random() * len)].match(/^Album: (.+)$/m) until album
        addCmd = mpd.cmd("findadd", [ "album", album[1] ])

        if clearPlaylist
            client.sendCommand "clear", (err, msg) ->
                if err
                    console.log(err)
                    return

                client.sendCommand addCmd, (err, msg) ->
                    if err
                        console.log(err)
                        return

                    client.sendCommand "play", (err, msg) -> console.log(err) if err
        else
            client.sendCommand addCmd, (err, msg) -> console.log(err) if err

onChange = -> whenPlayingLastSong addRandomAlbum

client.on "system-player",   -> whenPlayingLastSong addRandomAlbum
client.on "system-playlist", -> whenPlayingLastSong addRandomAlbum

server = restify.createServer()

server.get "/album/random", (req, res, next) ->
    addRandomAlbum(true)
    res.send("OK")

server.listen config.restify.port, ->
    console.log("Random Album REST API listening on %s", server.url)
