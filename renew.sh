#!/bin/bash

set -e

export CERT_NAME=$(kubectl get certificates  -o name | cut -d'/' -f 2)

export ORIGINAL_CERT_EXPIRY=$(kubectl get certificate  -o=jsonpath='{.items[0].status.notAfter}')

echo "Certificate expires on $ORIGINAL_CERT_EXPIRY"

kubectl delete certificate $CERT_NAME

export CERTS_SECRET=$(kubectl get secrets -o=jsonpath='{.items[1].metadata.name}')

kubectl delete secrets $CERTS_SECRET

kubectl apply -f ./cluster-issuer.yaml

echo "Sleeping for 40 seconds to give the certificate time to generate"
sleep 40


export NEW_CERT_EXPIRY=$(kubectl get certificate  -o=jsonpath='{.items[0].status.notAfter}')

echo "New Certificate expires on $NEW_CERT_EXPIRY"

if [ $NEW_CERT_EXPIRY_DATE -ge $ORIGINAL_CERT_EXPIRY_DATE ];
then
    echo "Success! New certificate generated. New expiry date is $NEW_CERT_EXPIRY"
else
    echo "***ERROR!! Expiry date not updated. Old expiry date: $ORIGINAL_CERT_EXPIRY. New expiry date: $NEW_CERT_EXPIRY"
    exit 1
fi
