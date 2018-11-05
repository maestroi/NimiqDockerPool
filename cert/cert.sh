#!/bin/bash

up=$PWD

# challenge details
project="productie"
domain_base="alphapool.pro"
email="EMAIL"
secret="SECRET"

# set domains
sed -i "*.example.com example.com/*.$domain_base $domain_base/g" ./cert/domains.conf

# Handle arguments
parse_arg () {
arg_strip=$(echo $arg | cut -d'=' -f1)
arg_val=$(echo $arg | cut -d'=' -f2)

case $arg_strip in
	--project)
	project=$arg_val;;

	--domain)
	domain=$arg_val;;

	--email)
	email=$arg_val;;
esac
}

if [ $# -gt 0 ]; then
       	if [ "$1" != "" ]; then
       		arg=$1
 		parse_arg
	fi
	if [ "$2" != "" ]; then
		arg=$2
		parse_arg
	fi
	if [ "$3" != "" ]; then
		arg=$3
		parse_arg
	fi
fi	

docker run \
    --name letsencrypt-dns \
    --volume cert/domains.conf:/etc/letsencrypt/domains.conf \
    --volume cert:/etc/letsencrypt \
    --env 'LETSENCRYPT_USER_MAIL=$email' \
    --env 'LEXICON_PROVIDER=cloudflare' \
    --env 'LEXICON_CLOUDFLARE_USERNAME=$email' \
    --env 'LEXICON_CLOUDFLARE_TOKEN=$secret' \
    adferrand/letsencrypt-dns

#  cert:
#    image: adferrand/letsencrypt-dns
#    environment:
#      LETSENCRYPT_USER_MAIL: email
#      LEXICON_PROVIDER: cloudflare
#      LEXICON_CLOUDFLARE_USERNAME: email
#      LEXICON_CLOUDFLARE_TOKEN: secret
#    volumes:
#    - cert:/node/cert:rw
#    - cert/domains.conf:/etc/letsencrypt/domains.con