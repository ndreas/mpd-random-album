config =
    mpd:
        host: process.env.MPD_HOST || "volumio.local"
        port: process.env.MPD_PORT || 6600

module.exports = config
