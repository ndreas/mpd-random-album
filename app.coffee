config = require("./config")
mpd = require("mpd")

client = mpd.connect
    host: config.host
    port: config.port

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

addRandomAlbum = ->
    cmd = mpd.cmd("list", [ "album" ])

    client.sendCommand cmd, (err, msg) ->
        if err
            console.log(err)
            return

        lines = msg.split("\n")
        len = lines.length

        album = lines[Math.floor(Math.random() * len)].match(/^Album: (.+)$/m) until album

        cmd = mpd.cmd("findadd", [ "album", album[1] ])

        client.sendCommand cmd, (err, msg) -> console.log(err) if err

onChange = -> whenPlayingLastSong addRandomAlbum

client.on "system-player",   -> whenPlayingLastSong addRandomAlbum
client.on "system-playlist", -> whenPlayingLastSong addRandomAlbum
