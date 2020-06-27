#!/bin/bash
RECORD_NAME="_acme-challenge"

az network dns record-set txt delete --resource-group $RG --zone-name $CERTBOT_DOMAIN -n $RECORD_NAME --yes > /dev/null
