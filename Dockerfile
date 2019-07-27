FROM ubuntu:16.04

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update && apt-get install -y \
               cpanminus \
               curl \
               gcc \
               libssl-dev \
               make \
               procmail \
               rsyslog \
               tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && cpan install \
            WWW::PushBullet \
            LWP::Protocol::https \
    && rm /etc/postfix/main.cf \
    && touch /etc/postfix/main.cf

ENV EMAIL_HOST=host.domain
ENV EMAIL_USER=pushbullet
ENV PB_KEY=x
ENV TZ="Europe/London"

COPY start.sh /tmp/start.sh

RUN chmod 755 /tmp/start.sh

ENTRYPOINT ["/bin/bash"]
CMD ["/tmp/start.sh"]
