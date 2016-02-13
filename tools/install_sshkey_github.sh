#!/bin/sh
#
# USAGE: install_sshkey_github.sh {DECRYPT_KEY} {ENCRYPTED_SSHKEY_FILE} {DECRYPTED_SSHKEY_FILE}

set -e

key=$1 ; shift
src=$1 ; shift
dst=$1 ; shift

echo "Host github.com\n\tStrictHostKeyChecking no\n\tIdentityFile $dst\n" >> ~/.ssh/config
openssl aes-256-cbc -k "$key" -in "$src" -d -a -out "$dst"
chmod 600 "$dst"
