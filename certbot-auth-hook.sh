#!/bin/bash
# az-cli <= 2.5.1 has a bug : https://github.com/Azure/azure-cli/issues/12804

RECORD_NAME="_acme-challenge"
TIMEOUT="320" # > Negative Cache TTL (300s)

echo "INFO: CERTBOT_VALIDATION = $CERTBOT_VALIDATION"
echo "INFO: CERTBOT_DOMAIN = $CERTBOT_DOMAIN"

ZONES=`az network dns zone list -o tsv | cut -d "	" -f 5`
echo $ZONES | grep -q -w "$CERTBOT_DOMAIN"
if [ $? -ne 0 ]; then
	echo "ERROR: Zone \"$CERTBOT_DOMAIN\" does not exist"
	exit 1
fi

az network dns record-set txt show --resource-group $RG --zone-name $CERTBOT_DOMAIN -n $RECORD_NAME  > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "INFO: creating new txt '$RECORD_NAME' with ttl 10"
	az network dns record-set txt create --resource-group $RG --zone-name $CERTBOT_DOMAIN -n $RECORD_NAME --ttl 10 > /dev/null
	if [ $? -ne 0 ]; then
		echo "INFO: creating ${RECORD_NAME}.$CERTBOT_DOMAIN failed"
		exit 1
	fi
fi

az network dns record-set txt add-record --resource-group $RG --zone-name $CERTBOT_DOMAIN -n $RECORD_NAME --value "$CERTBOT_VALIDATION" > /dev/null
if [ $? -ne 0 ]; then
	echo "ERROR: adding TXT record \"$CERTBOT_VALIDATION\" failed"
	exit 1
fi

while true; do 
	RECORD=`dig -t TXT $RECORD_NAME.$CERTBOT_DOMAIN +short @1.1.1.1`
	echo $RECORD | grep -q -w "$CERTBOT_VALIDATION"
	if [ $? -eq 0 ]; then
		echo "INFO: TXT record \"$CERTBOT_VALIDATION\" added"
		break
	fi
	TIMEOUT=$(( $TIMEOUT - 1 ))
	if [ "$TIMEOUT" -eq 0 ]; then
		echo "ERROR: timed out"
		exit 1
	fi
	echo "INFO: waiting TXT record \"$CERTBOT_VALIDATION\" (${TIMEOUT}s)"
	sleep 1
done
echo "INFO: succeeded"

