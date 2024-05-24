FROM debian:bullseye

# Update and install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        curl \
        python3 \
        python3-pip \
        python3-dev \
        build-essential \
        sudo \
        pkg-config \
        ca-certificates \
        locales \
        tzdata \
        golang \
        fontconfig \
        gcc \
        cron \
        ffmpeg \
    && dpkg-reconfigure locales \
    && apt-get clean

# Create system link to python3
RUN ln -s /usr/bin/python3 /usr/bin/python

# Set up the download directories
RUN mkdir -p /Music/SoundCloud/jake_lindsey
RUN mkdir -p /Music/SoundCloud/hansworld
RUN mkdir -p /Music/SoundCloud/anthony-lugay-1
RUN mkdir -p /Music/SoundCloud/user-967098205

# Set up the cron environment
RUN mkdir /etc/crontabs

# Set up the locale environment
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Clone the scdl repository
RUN git clone https://github.com/flyingrub/scdl.git

# Change the working directory
WORKDIR /scdl

# Install the package
RUN python setup.py install

# Set up the timezone
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Validate SCDL
RUN scdl --version

# Create a crontab file
RUN echo "0 0 * * * scdl -f -c --onlymp3 -l https://soundcloud.com/jake_lindsey --path /Music/SoundCloud/jake_lindsey --debug >> /Music/SoundCloud/jake_lindsey.log 2>&1" > /crontab.txt \
 && echo "0 0 * * * scdl -f -c --onlymp3 -l https://soundcloud.com/hansworld --path /Music/SoundCloud/hansworld --debug >> /Music/SoundCloud/hansworld.log 2>&1" >> /crontab.txt \
 && echo "0 0 * * * scdl -f -c --onlymp3 -l https://soundcloud.com/anthony-lugay-1 --path /Music/SoundCloud/anthony-lugay-1 --debug >> /Music/SoundCloud/anthony-lugay-1.log 2>&1" >> /crontab.txt \
 && echo "0 0 * * * scdl -f -c --onlymp3 -l https://soundcloud.com/user-967098205 --path /Music/SoundCloud/user-967098205 --debug >> /Music/SoundCloud/user-967098205.log 2>&1" >> /crontab.txt \
 && crontab /crontab.txt \
 && rm /crontab.txt

# Run the cron job on container startup and then start cron daemon
CMD ["sh", "-c", "scdl -f -c --onlymp3 -l https://soundcloud.com/jake_lindsey --path /Music/SoundCloud/jake_lindsey --debug >> /Music/SoundCloud/jake_lindsey.log 2>&1 \
    && scdl -f -c --onlymp3 -l https://soundcloud.com/hansworld --path /Music/SoundCloud/hansworld --debug >> /Music/SoundCloud/hansworld.log 2>&1 \
    && scdl -f -c --onlymp3 -l https://soundcloud.com/anthony-lugay-1 --path /Music/SoundCloud/anthony-lugay-1 --debug >> /Music/SoundCloud/anthony-lugay-1.log 2>&1 \
    && scdl -f -c --onlymp3 -l https://soundcloud.com/user-967098205 --path /Music/SoundCloud/user-967098205 --debug >> /Music/SoundCloud/user-967098205.log 2>&1 \
    && cron -f"]
