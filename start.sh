#!/bin/bash

ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

postconf -e "myhostname=$EMAIL_HOST"
postconf -e "mynetworks_style=subnet"
postconf -e "compatibility_level=2"

useradd -m $EMAIL_USER
cat <<EOF > /home/$EMAIL_USER/.forward
"|IFS=' '&&exec /usr/bin/procmail -f-||exit 75 #$EMAIL_USER"
EOF

cat <<EOF > /home/$EMAIL_USER/.procmailrc
LOGFILE=/home/$EMAIL_USER/procmail-log
VERBOSE=yes

:0
| formail -k -X Subject: | /home/$EMAIL_USER/run.pl
EOF

cat <<EOF > /home/$EMAIL_USER/run.pl
#!/usr/bin/env perl
use strict;
use warnings;

use WWW::PushBullet;

my \$subject;
my \$body;
while (my \$line=<STDIN>)
{
        if (\$line=~/^Subject: (.*?)$/)
        {
                \$subject=\$1;
        }
        else
        {
                \$body.=\$line;
        }
}
\$body =~ s/^\s+|\s+$//g;

my \$pb = WWW::PushBullet->new({apikey => '$PB_KEY'});

\$pb->push_note(
        {
            device_iden => '$PB_DEVICE',
            title     => "\$subject",
            body      => "\$body"
        }
        );

EOF

chown $EMAIL_USER:$EMAIL_USER /home/$EMAIL_USER/.forward
chown $EMAIL_USER:$EMAIL_USER /home/$EMAIL_USER/.procmailrc
chown $EMAIL_USER:$EMAIL_USER /home/$EMAIL_USER/run.pl
chmod 755 /home/$EMAIL_USER/run.pl

touch /home/$EMAIL_USER/procmail-log
touch /var/log/mail.log
touch /var/log/mail.err
chown $EMAIL_USER:$EMAIL_USER /home/$EMAIL_USER/procmail-log
chown syslog:adm /var/log/mail.*

service rsyslog start
service postfix start
tail -f /home/$EMAIL_USER/procmail-log &
tail -f /var/log/mail.log &
tail -f /var/log/mail.err &

sleep infinity
