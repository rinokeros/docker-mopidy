#FROM debian:stretch-slim
FROM debian:jessie

# Set the username
RUN set -ex \
    # Official Mopidy install for Debian/Ubuntu along with some extensions
    # (see https://docs.mopidy.com/en/latest/installation/debian/ )
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        gcc \
        gstreamer0.10-alsa \
        gstreamer0.10-plugins-bad \
        gstreamer1.0-plugins-bad \
        python-crypto \
 && curl -L https://apt.mopidy.com/mopidy.gpg -o /tmp/mopidy.gpg \
 && curl -L https://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list \
 && apt-key add /tmp/mopidy.gpg \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        mopidy \
        mopidy-soundcloud \
        mopidy-spotify \
 && curl -L https://bootstrap.pypa.io/get-pip.py | python - \
 && pip install -U six \
 && pip install \
        Mopidy-Moped \
        Mopidy-GMusic \
        Mopidy-YouTube \
        pyasn1==0.1.8 \
    # Clean-up
 && apt-get purge --auto-remove -y \
        curl \
        gcc \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache

ENV UNAME user

# Default configuration
COPY mopidy.conf /home/${UNAME}/.config/mopidy/mopidy.conf

RUN set -ex \
 # Create the user
 && useradd --create-home ${UNAME} \
 # Create the config dir
 && chown -R ${UNAME} /home/${UNAME}/

# Copy the pulse-client configuratrion
COPY pulse-client.conf /etc/pulse/client.conf

# Run as user
USER ${UNAME}

VOLUME ["/var/lib/mopidy/local", "/var/lib/mopidy/media"]

EXPOSE 6600 6680

CMD ["/usr/bin/mopidy"]
