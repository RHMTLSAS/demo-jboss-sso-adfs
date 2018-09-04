#!/bin/bash

# Functions
function gen_key
{
  local keyfile=$1
  if [ ! -f ${keyfile} ]; then
    openssl genrsa 4096 > $keyfile
  else
    echo "Keyfile: ${keyfile} already exist"
  fi
}

function gen_dhparam
{
  local keyfile=$1
  if [ ! -f ${keyfile} ]; then
    openssl dhparam -out $keyfile 4096
  else
    echo "DHParams file: ${keyfile} already exist"
  fi
}

# Generate the keys
gen_key account.key
gen_key adfs.key
gen_key rhsso.key
# Generate the dhparams
gen_dhparam dhparams.out

openssl req -new -sha256 -key adfs.key -subj "/" -reqexts SAN -config <(cat openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:adfs.sso.doogie.ca,DNS:enterpriseregistration.sso.doogie.ca")) > adfs.csr
openssl req -new -sha256 -key rhsso.key -subj "/" -reqexts SAN -config <(cat openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:rhsso.sso.doogie.ca")) > rhsso.csr

