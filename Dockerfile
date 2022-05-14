# The Garmin ConnectIQ sdk in an Ubuntu installation.
#
# The tools are compiled on Ubuntu and hence work best in that distribution
# (previously using very old ubuntu 20.04-only dependencies).
#
# This does not include eclipse, as my workflow is only based on make and the
# command line tools of the ConnectIQ SDK.
FROM ubuntu:22.04

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Check at https://developer.garmin.com/downloads/connect-iq/sdks/sdks.json
#          https://developer.garmin.com/downloads/connect-iq/sdk-manager/sdk-manager.json
ENV CONNECT_IQ_SDK_URL https://developer.garmin.com/downloads/connect-iq

RUN apt-get update -y \
    && apt-get install --no-install-recommends -qqy openjdk-11-jdk \
    && apt-get install --no-install-recommends -qqy unzip wget curl git ssh tar gzip make tzdata ca-certificates gnupg2 libsm6 libpng16-16 libwebkit2gtk-4.0-37 libusb-1.0\
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "Downloading Connect IQ SDK Manager:" \
    && cd /opt \
    && curl -LsS -o ciq-sdk-manager.zip ${CONNECT_IQ_SDK_URL}/sdk-manager/connectiq-sdk-manager-linux.zip \
    && unzip ciq-sdk-manager.zip -d ciq \
    && rm -f ciq-sdk-manager.zip

# Set user=1000 and group=100 as the owner of all files under /home/developer and /opt
RUN mkdir -p /home/developer \
    && echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd \
    && chown -R 1000:100 /home/developer && chmod -R ug+rw /home/developer \
    && chown -R 1000:100 /opt && chmod -R ug+rw /opt

USER developer
ENV HOME /home/developer
WORKDIR /home/developer

ENV CIQ_HOME        /opt/ciq
ENV PATH ${PATH}:${CIQ_HOME}/bin

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD [ "/bin/bash" ]
