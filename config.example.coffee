config =
    mpd:
        host: process.env.MPD_HOST || "volumio.local"
        port: process.env.MPD_PORT || 6600
    restify:
        port: process.env.WEB_PORT || 3000

module.exports = config
