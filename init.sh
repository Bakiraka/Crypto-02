#!/bin/bash

openssl genrsa 1024 -out clientSk > /dev/null;
openssl rsa -in clientSk -pubout -out clientPk;
openssl genrsa 1024 -out commercantSk > /dev/null; 
openssl rsa -in commercantSk -pubout -out commercantPk;
openssl genrsa 1024 -out banqueSk > /dev/null;
openssl rsa -in banqueSk -pubout -out banquePk;
openssl dgst -sha1 clientPk | cut -d' ' -f2 | openssl rsautl -sign -inkey banqueSk | base64 > clientPkEncode
