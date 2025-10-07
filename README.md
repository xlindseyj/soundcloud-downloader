## Soundcloud Downloader
- Docker image that automatically downloads your SoundCloud likes daily.

## Getting Started
1. Update SoundCloud users and paths to match your system in ```docker-compose.yml``` and ```Dockerfile```
2. ```sudo docker compose up -d --build```

## Credits
- [scdl](https://github.com/flyingrub/scdl.git)
- [scdl](https://github.com/xlindseyj/scdl.git)

## Status of the project

As of version 3, this script is a wrapper around `yt-dlp` with some defaults/patches for backwards compatibility.
Development is not active and new features will likely not be merged, especially if they can be covered with the
use of `--yt-dlp-args`. Bug reports/fixes are welcome.

## Description

This script is able to download music from SoundCloud and set id3tag to the downloaded music.
Compatible with Windows, OS X, Linux.

## System requirements

* python3
* ffmpeg

## Installation Instructions
https://github.com/flyingrub/scdl/wiki/Installation-Instruction

# Installation
## Dependencies
Do not forget to install ffmpeg and to add it to your PATH.

## SCDL
There are various methods for installing scdl. It is recommended to use `pipx`:
#### Install with `pipx`
```bash
brew install ffmpeg pipx
pipx install scdl
```
Update:
```bash
pipx upgrade scdl
```

#### Install with PIP
```
pip3 install scdl
```
Update:
```
pip3 install scdl --upgrade
```

#### Install from the github repo
```
pip3 install git+https://github.com/flyingrub/scdl
```
Update:
```
pip3 install git+https://github.com/flyingrub/scdl --upgrade
```


### Using OS Specific package manager
#### Arch Linux

```
yay -S soundcloud-dl-git
```

#### Gentoo

```
layman -fa glicOne
sudo emerge -av net-misc/scdl
```

### Authentication

* Find your OAuth token by visiting SoundCloud after logging in and opening developer console (press F12) and going to the Storage tab. Then under cookies > soundcloud.com you can find the entry called oauth_token
* Place OAuth token in the config file (see below)
* You need to have this set to be able to use the `me` option
* You need to have this set to download original files (which may be lossless) if they are available
* If you have a GO+ account it will allow you to download some songs in 256 kbps AAC quality, and songs which are only available with GO+


### Config file locations
* Windows: `C:\Users\username\.config\scdl\scdl.cfg`
* Mac/Linux: `~/.config/scdl/scdl.cfg`
* If `XDG_CONFIG_HOME` is set: `$XDG_CONFIG_HOME/scdl/scdl.cfg`

#### Your `scdl.cfg` should look at least like this:
```scdl.cfg
[DEFAULT]
oauth_token=XXXXXXXXXXX
```

## Configuration
There is a configuration file left in `~/.config/scdl/scdl.cfg`

## Examples:
```
# Download track & repost of the user QUANTA
scdl -l https://soundcloud.com/quanta-uk -a

# Download likes of the user Blastoyz
scdl -l https://soundcloud.com/kobiblastoyz -f

# Download one track
scdl -l https://soundcloud.com/jumpstreetpsy/low-extender

# Download one playlist
scdl -l https://soundcloud.com/pandadub/sets/the-lost-ship

# Download only new tracks from a playlist
scdl -l https://soundcloud.com/pandadub/sets/the-lost-ship --download-archive archive.txt -c

# Sync playlist
scdl -l https://soundcloud.com/pandadub/sets/the-lost-ship --sync archive.txt

# Download your likes (with authentification token)
scdl me -f
```

## Options:
```
-h --help                       Show this screen
--version                       Show version
-l [url]                        URL can be track/playlist/user
-s [search_query]               Search for a track/playlist/user and use the first result
-n [maxtracks]                  Download the n last tracks of a playlist according to the creation date
-a                              Download all tracks of user (including reposts)
-t                              Download all uploads of a user (no reposts)
-f                              Download all favorites (likes) of a user
-C                              Download all tracks commented on by a user
-p                              Download all playlists of a user
-r                              Download all reposts of user
-c                              Continue if a downloaded file already exists
--force-metadata                This will set metadata on already downloaded track
-o [offset]                     Start downloading a playlist from the [offset]th track (starting with 1)
--addtimestamp                  Add track creation timestamp to filename,
                                which allows for chronological sorting
                                (Deprecated. Use --name-format instead.)
--addtofile                     Add artist to filename if missing
--debug                         Set log level to DEBUG
--error                         Set log level to ERROR
--download-archive [file]       Keep track of track IDs in an archive file,
                                and skip already-downloaded files
--extract-artist                Set artist tag from title instead of username
--hide-progress                 Hide the wget progress bar
--hidewarnings                  Hide Warnings. (use with precaution)
--max-size [max-size]           Skip tracks larger than size (k/m/g)
--min-size [min-size]           Skip tracks smaller than size (k/m/g)
--no-playlist-folder            Download playlist tracks into main directory,
                                instead of making a playlist subfolder
--onlymp3                       Download only mp3 files
--path [path]                   Use a custom path for downloaded files
--remove                        Remove any files not downloaded from execution
--sync [file]                   Compares an archive file to a playlist and downloads/removes any changed tracks
--flac                          Convert original files to .flac. Only works if the original file is lossless quality
--no-album-tag                  On some player track get the same cover art if from the same album, this prevent it
--original-art                  Download original cover art, not just 500x500 JPEG
--original-name                 Do not change name of original file downloads
--original-metadata             Do not change metadata of original file downloads
--no-original                   Do not download original file; only mp3, m4a, or opus
--only-original                 Only download songs with original file available
--name-format [format]          Specify the downloaded file name format. Use "-" to download to stdout
--playlist-name-format [format] Specify the downloaded file name format, if it is being downloaded as part of a playlist
--client-id [id]                Specify the client_id to use
--auth-token [token]            Specify the auth token to use
--overwrite                     Overwrite file if it already exists
--strict-playlist               Abort playlist downloading if one track fails to download
--add-description               Adds the description to a seperate txt file (can be read by some players)
--no-playlist                   Skip downloading playlists
--opus                          Prefer downloading opus streams over mp3 streams
--yt-dlp-args                   String with custom args to forward to yt-dlp
```


## Features
* Automatically detect the type of link provided
* Download all songs from a user
* Download all songs and reposts from a user
* Download all songs from one playlist
* Download all songs from all playlists from a user
* Download all songs from a user's favorites
* Download only new tracks from a list (playlist, favorites, etc.)
* Sync Playlist
* Set the tags with mutagen (Title / Artist / Album / Artwork)
* Create playlist files when downloading a playlist
