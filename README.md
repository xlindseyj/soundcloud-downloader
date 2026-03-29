# SoundCloud Downloader (Docker)

A Docker container that automatically downloads your SoundCloud library (likes, playlists, reposts, uploads, and comments) on a daily cron schedule using [scdl](https://github.com/flyingrub/scdl).

> **Note:** This repository is a **Docker wrapper** around the excellent [`scdl`](https://github.com/flyingrub/scdl) tool. I did not create `scdl` — full credit goes to [flyingrub](https://github.com/flyingrub) and all contributors to that project. This repo simply packages it in a container with a cron schedule that works for my setup.

---

## Table of Contents
- [How It Works](#how-it-works)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
  - [1. SoundCloud OAuth Token](#1-soundcloud-oauth-token)
  - [2. Customize the Dockerfile](#2-customize-the-dockerfile)
  - [3. Customize docker-compose.yml](#3-customize-docker-composeyml)
  - [4. Build and Run](#4-build-and-run)
- [Cron Schedule](#cron-schedule)
- [scdl Options Reference](#scdl-options-reference)
- [Credits & Acknowledgements](#credits--acknowledgements)

---

## How It Works

When the container starts, it immediately runs an initial download of your SoundCloud likes. It then hands off to `cron`, which runs five nightly jobs to keep each category up to date:

| Category   | Flag | Time (container TZ) |
|------------|------|---------------------|
| Likes      | `-f` | 12:00 AM            |
| Playlists  | `-p` | 12:30 AM            |
| Reposts    | `-r` | 1:00 AM             |
| Uploads    | `-t` | 1:30 AM             |
| Comments   | `-C` | 2:00 AM             |

All downloads use `--original-art`, `--original-name`, `--original-metadata`, and the name format `{artist} - {title}` by default. The `-c` flag ensures already-downloaded tracks are skipped.

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) installed on your host machine.
- A SoundCloud account with an OAuth token (see below).
- Enough disk space on the host for your music library.

---

## Setup

### 1. SoundCloud OAuth Token

`scdl` requires your SoundCloud OAuth token to access likes, playlists, and other private data.

1. Log in to [SoundCloud](https://soundcloud.com) in your browser.
2. Open the Developer Console (F12) and go to the **Application** (Chrome) or **Storage** (Firefox) tab.
3. Under **Cookies → soundcloud.com**, find the cookie named `oauth_token` and copy its value.
4. Create (or edit) the scdl config file on your host machine:
   - **Mac/Linux:** `~/.config/scdl/scdl.cfg`
   - **Windows:** `C:\Users\<username>\.config\scdl\scdl.cfg`

   The file should contain:
   ```ini
   [DEFAULT]
   oauth_token=YOUR_OAUTH_TOKEN_HERE
   ```

This config directory is mounted into the container via `docker-compose.yml`, so the container will automatically use your token.

---

### 2. Customize the Dockerfile

The `Dockerfile` is pre-configured for my own SoundCloud username (`jake_lindsey`). **You must replace it with your own username and desired folder structure.**

Open `Dockerfile` and update the following lines:

```dockerfile
# Replace 'jake_lindsey' with your SoundCloud username (or any folder name you prefer)
RUN mkdir -p /Music/SoundCloud/jake_lindsey/Likes \
    && mkdir -p /Music/SoundCloud/jake_lindsey/Playlists \
    && mkdir -p /Music/SoundCloud/jake_lindsey/Reposts \
    && mkdir -p /Music/SoundCloud/jake_lindsey/Uploads \
    && mkdir -p /Music/SoundCloud/jake_lindsey/Comments
```

Also update the cron jobs and the `CMD` line at the bottom of the Dockerfile — replace every occurrence of `jake_lindsey` (in both the folder paths and the SoundCloud URL `https://soundcloud.com/jake_lindsey`) with your own username.

**Example — if your SoundCloud username is `your_username`:**

```dockerfile
RUN mkdir -p /Music/SoundCloud/your_username/Likes \
    && mkdir -p /Music/SoundCloud/your_username/Playlists \
    ...

# In the cron job block, replace all occurrences of:
#   jake_lindsey  →  your_username

CMD ["sh", "-c", "scdl -f -c --original-art --original-name --original-metadata \
    --name-format '{artist} - {title}' \
    -l https://soundcloud.com/your_username \
    --path /Music/SoundCloud/your_username/Likes && cron -f"]
```

---

### 3. Customize docker-compose.yml

Open `docker-compose.yml` and update the volume mount to point to a directory on your host where you want music saved:

```yaml
volumes:
  # Left side  = host path (your machine)
  # Right side = container path (must match paths in Dockerfile)
  - /your/host/music/path:/Music/SoundCloud/your_username
  - ~/.config/scdl:/root/.config/scdl
```

The `~/.config/scdl` mount provides the container with your OAuth token automatically.

**Example:**
```yaml
volumes:
  - /home/alice/Music/SoundCloud:/Music/SoundCloud/alice
  - ~/.config/scdl:/root/.config/scdl
```

The timezone is set to `America/New_York` in the Dockerfile. To change it, update the `ENV TZ` line:
```dockerfile
ENV TZ=America/Los_Angeles
```

---

### 4. Build and Run

Once you have updated the Dockerfile and docker-compose.yml with your username and paths, build and start the container:

```bash
sudo docker compose up -d --build
```

The container will:
1. Run an immediate download of your likes on startup.
2. Stay running in the background and execute the nightly cron jobs automatically.

To view logs:
```bash
sudo docker logs -f soundcloud-downloader
```

To stop the container:
```bash
sudo docker compose down
```

---

## Cron Schedule

The five cron jobs are baked into the image at build time. They run nightly at the times shown below (using the timezone set in the Dockerfile, defaulting to `America/New_York`):

```
0  0 * * *  scdl -f -c ... -l https://soundcloud.com/<username> --path .../Likes
30 0 * * *  scdl -p -c ... -l https://soundcloud.com/<username> --path .../Playlists
0  1 * * *  scdl -r -c ... -l https://soundcloud.com/<username> --path .../Reposts
30 1 * * *  scdl -t -c ... -l https://soundcloud.com/<username> --path .../Uploads
0  2 * * *  scdl -C -c ... -l https://soundcloud.com/<username> --path .../Comments
```

---

## scdl Options Reference

The following options are provided by [scdl](https://github.com/flyingrub/scdl) (not this project). They can be used to customize the download commands in the Dockerfile.

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
--add-description               Adds the description to a separate txt file (can be read by some players)
--no-playlist                   Skip downloading playlists
--opus                          Prefer downloading opus streams over mp3 streams
--yt-dlp-args                   String with custom args to forward to yt-dlp
```

For more examples and the full scdl documentation, visit the [scdl repository](https://github.com/flyingrub/scdl).

---

## Credits & Acknowledgements

- **[scdl](https://github.com/flyingrub/scdl)** by [flyingrub](https://github.com/flyingrub) and contributors — the actual SoundCloud downloader tool that does all the heavy lifting. This Docker container would not exist without their work. Please ⭐ their repository!
- **[xlindseyj/scdl](https://github.com/xlindseyj/scdl)** — personal fork of scdl.
- This repository (`soundcloud-downloader`) was created by [xlindseyj](https://github.com/xlindseyj) as a convenient Docker wrapper and cron schedule that worked for my personal setup. It is not affiliated with or endorsed by the scdl project.
