#!/bin/bash
set -euo pipefail
export IFS=$'\n\t'

export KEYID1=F9BC985B3BF972C7
export KEYID2=0F6D5021A87F92BA

GPG=$(which gpg) # the path for the gpg program
PASSWORD_STORE_DIR=${PASSWORD_STORE_DIR:=$HOME/.password-store}
TEMP_DIR=$(mktemp --directory)
echo $TEMP_DIR

for path in $(find ${PASSWORD_STORE_DIR} -iname '*.gpg'); do
  echo "Processing ${path}"
  temp_file="${TEMP_DIR}/${path##*/}"

  ${GPG} -q --decrypt "${path}" | ${GPG} --no-throw-keyids --encrypt -r $KEYID1 -r $KEYID2 --output "${temp_file}"

  mv -f "${temp_file}" "${path}"
done

echo
echo "Creating git commit with all the changes"
read -n 1 -s -r -p "Press any key to continue, ctrl+c to stop"
echo
git commit -a -m "Adding key ids (i.e. gpg --no-throw-keyids)"
