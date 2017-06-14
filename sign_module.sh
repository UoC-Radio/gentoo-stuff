#!/bin/bash

SIGN_SCRIPT="/usr/src/linux/scripts/sign-file"
KEY_PRIV="/usr/src/linux/signing_key.priv"
KEY_X509="/usr/src/linux/signing_key.x509"

perl ${SIGN_SCRIPT} sha512 ${KEY_PRIV} ${KEY_X509} ${1}
