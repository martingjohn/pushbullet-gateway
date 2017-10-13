# pushbullet-gateway
Email to Pushbullet gateway

This creates a docker container which when you send an email to the configured user on the container, will convert that to a PushBullet note notification. You'll need a PushBullet API key.

    docker run \
       -d \
       --network=pub_net \
       --ip=192.168.10.202 \
       -e "EMAIL_HOST=pushbullet.home" \
       -e "EMAIL_USER=pushbullet" \
       -e "PB_KEY=xxxxxxxxxx" \
       -e "TZ=Europe/London" \
       martinjohn/pushbullet-gateway

Here I've put it on a macvlan network (pub_net) with a fixed IP
You probably want the EMAIL_HOST to match the dns record.
