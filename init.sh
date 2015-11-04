#!/bin/bash
############################################################################### 
###                            INIT.SH                                       ##
###  1) create public and private Key of the client, commercant and the bank ##
###  2) crypt a hash of the public key of the client by the bank SK          ##
###############################################################################

# generate rsa private and public key for the client
openssl genrsa 1024 > clientSk;
openssl rsa -in clientSk -pubout -out clientPk;
# generate rsa public and private key for the commercant 
openssl genrsa 1024 > commercantSk; 
openssl rsa -in commercantSk -pubout -out commercantPk;
# generate rsa public and private key for the bank
openssl genrsa 1024 > banqueSk;
openssl rsa -in banqueSk -pubout -out banquePk;
# Hash the client public key and encrypt it by the bank SK
openssl dgst -sha1 clientPk | cut -d' ' -f2 | openssl rsautl -decrypt -raw -inkey banqueSk | base64 > clientPkEncode
