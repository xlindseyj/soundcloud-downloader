FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends git curl python3 python3-pip python3-dev build-essential sudo pkg-config ca-certificates locales tzdata golang fontconfig gcc cron ffmpeg && dpkg-reconfigure locales && apt-get clean

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN mkdir -p /Music/SoundCloud/jake_lindsey/Likes && mkdir -p /Music/SoundCloud/jake_lindsey/Playlists && mkdir -p /Music/SoundCloud/jake_lindsey/Reposts && mkdir -p /Music/SoundCloud/jake_lindsey/Uploads && mkdir -p /Music/SoundCloud/jake_lindsey/Comments

RUN mkdir /etc/crontabs

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

RUN pip3 install scdl

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN scdl --version

RUN echo '0 0 * * * scdl -f -c --original-art --original-name --original-metadata --name-format "{artist} - {title}" -l https://soundcloud.com/jake_lindsey --path /Music/SoundCloud/jake_lindsey/Likes --debug' > /crontab.txt && echo '30 0 * * * scdl -p -c --original-art --original-name --original-metadata --name-format "{artist} - {title}" -l https://soundcloud.com/jake_lindsey --path /Music/SoundCloud/jake_lindsey/Playlists --debug' >> /crontab.txt && echo '0 1 * * * scdl -r -c --original-art --original-name --original-metadata --name-format "{artist} - {title}" -l https://soundcloud.com/jake_lindsey --path /Music/SoundCloud/jake_lindsey/Reposts --debug' >> /crontab.txt && echo '30 1 * * * scdl -t -c --original-art --original-name --original-metadata --name-format "{artist} - {title}" -l https://soundcloud.com/jake_lindsey --path /Music/SoundCloud/jake_lindsey/Uploads --debug' >> /crontab.txt && echo '0 2 * * * scdl -C -c --original-art --original-name --original-metadata --name-format "{artist} - {title}" -l https://soundcloud.com/jake_lindsey --path /Music/SoundCloud/jake_lindsey/Comments --debug' >> /crontab.txt && crontab /crontab.txt && rm /crontab.txt

CMD ["sh", "-c", "echo 'Starting downloads...' && scdl -f -c --original-art --original-name --original-metadata --name-format '{artist} - {title}' -l https://soundcloud.com/jake_lindsey --path /Music/SoundCloud/jake_lindsey/Likes && echo 'Likes done. Starting cron...' && cron -f"]