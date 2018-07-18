FROM debian:stretch-slim

# Default configuration
COPY mopidy.conf /var/lib/mopidy/.config/mopidy/mopidy.conf

# Start helper script
COPY entrypoint.sh /entrypoint.sh

RUN set -ex
    # Official Mopidy install for Debian/Ubuntu along with some extensions
    # (see https://docs.mopidy.com/en/latest/installation/debian/ )
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        gcc \
        gnupg \
        gstreamer1.0-alsa \
        gstreamer1.0-plugins-bad \
        python-crypto \
        dumb-init
        
RUN curl -L https://apt.mopidy.com/mopidy.gpg | apt-key add -
RUN curl -L https://apt.mopidy.com/mopidy.list -o /etc/apt/sources.list.d/mopidy.list

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
        mopidy
        
RUN curl -L https://bootstrap.pypa.io/get-pip.py | python -
RUN pip install -U six
RUN pip Mopidy-Moped
RUN pip pyasn1==0.3.2
RUN pip install Mopidy-SomaFM
        
    # Clean-up
RUN apt-get purge --auto-remove -y \
        curl \
        gcc
RUN apt-get clean

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache
    
    # Limited access rights.
RUN chown mopidy:audio -R /var/lib/mopidy/.config
RUN chmod +x /entrypoint.sh
RUN chown mopidy:audio /entrypoint.sh

# Run as mopidy user
USER mopidy

VOLUME ["/var/lib/mopidy/local", "/var/lib/mopidy/media"]

EXPOSE 6600 6680

ENTRYPOINT ["/usr/bin/dumb-init", "/entrypoint.sh"]
CMD ["/usr/bin/mopidy"]
