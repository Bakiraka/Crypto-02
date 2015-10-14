#!/bin/bash

openssl genrsa 1024 > clientSk;
openssl rsa -in clientSk -pubout -out clientPk;
openssl genrsa 1024 > commercantSk; 
openssl rsa -in commercantSk -pubout -out commercantPk;
openssl genrsa 1024 > banqueSk;
openssl rsa -in banqueSk -pubout -out banquePk;
openssl dgst -sha1 clientPk | cut -d' ' -f2 | openssl rsautl -decrypt -raw -inkey banqueSk | base64 > clientPkEncode
