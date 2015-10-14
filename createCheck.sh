#!/bin/bash
Facture=$1
fichierout=$2
uid=`cat factureTest | head -1`
montant=`cat $Facture | tail -1`
uidcrypt=`echo $uid | openssl rsautl -sign -inkey clientSk | base64`
echo uidcrypt : $uidcrypt
montantcrypt=`echo $montant | openssl rsautl -sign -inkey clientSk | base64 `
echo montantcrypt : $montantcrypt
clientPKHash=`cat clientPkEncode`
echo clientPkHash : $clientPKHash
commercantPkEncode=`openssl dgst -sha1 commercantPk | cut -d' ' -f2 | openssl rsautl -sign -inkey clientSk | base64`
echo commercantPkEncode : $commercantPkEncode
resultxor=$(( montant ^ uid ))
resultxorcrypt=`echo $resultxor | openssl rsautl -sign -inkey clientSk | base64 `
echo resultxorcrypt : $resultxorcrypt
echo "$commercantPkEncode\n$clientPKHash\n$uidcrypt\n$montantcrypt\n$resultxorcrypt" > $2
