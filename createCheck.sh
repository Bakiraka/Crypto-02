#!/bin/bash
Facture=$1
fichierout=$2
marqueur="0000000000000"
uid=`cat $Facture | head -1`
montant=`cat $Facture | tail -1`
uidcrypt=`echo $uid | openssl rsautl -decrypt -inkey clientSk -raw | base64`
echo uidcrypt : $uidcrypt
montantcrypt=`echo $montant | openssl rsautl -decrypt -inkey clientSk -raw | base64 `
echo montantcrypt : $montantcrypt
clientPKHash=`cat clientPkEncode`
echo clientPkHash : $clientPKHash
commercantPkEncode=`openssl dgst -sha1 commercantPk | cut -d' ' -f2 | openssl rsautl -decrypt -raw -inkey clientSk | base64`
echo commercantPkEncode : $commercantPkEncode
resultxor="$montant $uid $factureTest"
resultxorcrypt=`echo $resultxor | openssl dgst -sha1 | openssl rsautl -decrypt -raw -inkey clientSk | base64 `
echo resultxorcrypt : $resultxorcrypt
echo "$commercantPkEncode\n$marqueur\n$clientPKHash\n$marqueur\n$uidcrypt\n$marqueur\n$montantcrypt\n$marqueur\n$resultxorcrypt" > $2
