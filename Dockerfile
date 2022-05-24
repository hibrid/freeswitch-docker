FROM debian:buster as build_freeswitch
ADD script /tmp/freeswitch
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates gnupg2 wget lsb-release
RUN wget --http-user=signalwire --http-password={SIGNALWIRE PAT} -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg
RUN /bin/echo "machine freeswitch.signalwire.com login signalwire password {SIGNALWIRE PAT}" > /etc/apt/auth.conf
RUN /bin/echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list
RUN /bin/echo "deb-src [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list
RUN apt-get update && apt-get install -y freeswitch freeswitch-mod-console freeswitch-mod-sofia freeswitch-mod-commands freeswitch-mod-conference freeswitch-mod-db freeswitch-mod-dptools freeswitch-mod-hash freeswitch-mod-dialplan-xml freeswitch-mod-sndfile freeswitch-mod-native-file freeswitch-mod-tone-stream freeswitch-mod-say-en freeswitch-mod-event-socket
RUN /bin/bash -c "source /tmp/freeswitch/make_min_archive.sh"
RUN /bin/mkdir /tmp/build_image
RUN /bin/tar zxvf ./freeswitch_img.tar.gz -C /tmp/build_image

FROM scratch
COPY --from=build_freeswitch /tmp/build_image /
ADD etc/freeswitch /etc/freeswitch
CMD ["/usr/bin/freeswitch", "-nc", "-nf", "-nonat"]
