# Mostly vendored from kalemena/connectiq
FROM ubuntu:22.04

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Check at https://developer.garmin.com/downloads/connect-iq/sdks/sdks.json
#          https://developer.garmin.com/downloads/connect-iq/sdk-manager/sdk-manager.json
ENV CONNECT_IQ_SDK_URL https://developer.garmin.com/downloads/connect-iq

# libwebkitgtk-1.0-0
# RUN echo "deb http://cz.archive.ubuntu.com/ubuntu bionic main universe" >> /etc/apt/sources.list

# Compiler tools
RUN    apt-get update -y \
    && apt-get install --no-install-recommends -qqy openjdk-11-jdk \
    && apt-get install --no-install-recommends -qqy unzip wget curl git ssh tar gzip make tzdata ca-certificates gnupg2 libsm6 libpng16-16 libwebkit2gtk-4.0-37 libusb-1.0\
    && apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN    echo "Downloading Connect IQ SDK Manager:" \
    && cd /opt \
    && curl -LsS -o ciq-sdk-manager.zip ${CONNECT_IQ_SDK_URL}/sdk-manager/connectiq-sdk-manager-linux.zip \
    && unzip ciq-sdk-manager.zip -d ciq \
    && rm -f ciq-sdk-manager.zip

# Fix missing libpng12 (monkeydo)
# RUN ln -s /usr/lib/x86_64-linux-gnu/libpng16.so.16 /usr/lib/x86_64-linux-gnu/libpng12.so.0

# Install Eclipse IDE
ENV ECLIPSE_VERSION         2021-09/R/eclipse-java-2021-09-R-linux-gtk-x86_64.tar.gz
ENV ECLIPSE_DOWNLOAD_URL    https://www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/${ECLIPSE_VERSION}&r=1
RUN    curl -LsS -o eclipse.tar.gz "${ECLIPSE_DOWNLOAD_URL}" \
    && echo "Installing eclipse JavaEE ${ECLIPSE_DOWNLOAD_URL}" \
    && tar -C /opt -xf eclipse.tar.gz \
    && rm -rf eclipse.tar.gz

# Eclipse IDE plugins
RUN    echo "Installing Connect IQ Eclipse Plugins" \
    && cd /opt/eclipse \
    && ./eclipse -clean -noSplash \
        -application org.eclipse.equinox.p2.director \
        -repository ${CONNECT_IQ_SDK_URL}/eclipse/ \
        -installIU connectiq.feature.ide.feature.group/,connectiq.feature.sdk.feature.group/

# Few prefs
# ADD [ "eclipse-workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/IQ_IDE.prefs", "/home/developer/eclipse-workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings/IQ_IDE.prefs" ]
# ADD [ "org.eclipse.ui.ide.prefs", "/opt/eclipse/configuration/.settings/org.eclipse.ui.ide.prefs" ]

# Set user=1000 and group=100 as the owner of all files under /home/developer and /opt
RUN    mkdir -p /home/developer \
    && echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd \
    && chown -R 1000:100 /home/developer && chmod -R ug+rw /home/developer \
    && chown -R 1000:100 /opt && chmod -R ug+rw /opt

USER developer
ENV HOME /home/developer
WORKDIR /home/developer

ENV ECLIPSE_HOME    /opt/eclipse
ENV CIQ_HOME        /opt/ciq
ENV PATH ${PATH}:${CIQ_HOME}/bin:${ECLIPSE_HOME}

COPY ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# CMD [ "/opt/eclipse/eclipse" ]
CMD [ "/bin/bash" ]
