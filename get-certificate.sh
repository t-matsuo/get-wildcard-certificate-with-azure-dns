#!/bin/bash

DOMAIN=$1
MAIL=$2
RG=$3
OPTS=$4

cd `dirname $0`
DIR=`pwd`

if [ "$DOMAIN" = "" ] || [ "$MAIL" == "" ] || [ "$RG" == "" ]; then
	echo "ERROR: invalid args"
	echo "usage: $0 test.example.com test@test.example.com my-resource-group"
	exit 1
fi
export RG

certbot certonly $OPTS \
		--manual \
		--manual-auth-hook $DIR/certbot-auth-hook.sh \
		--manual-cleanup-hook $DIR/certbot-cleanup-hook.sh \
		--server https://acme-v02.api.letsencrypt.org/directory \
		--preferred-challenges dns \
		-d *.$DOMAIN -d $DOMAIN \
		-m $MAIL \
		--agree-tos \
		--force-renewal \
		--manual-public-ip-logging-ok

