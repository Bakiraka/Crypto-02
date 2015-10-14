#!/bin/bash

facture=$1
check=$2
clepubmerchant_ciphered=`cat $2 | head -3 | tr -d '\n\r'`
echo $clepubmerchant_ciphered
clepubclient_ciphered=`cat $2 | head -6 | tail -3 | tr -d '\n\r'`
echo $clepubclient_ciphered
uid_ciphered=`cat $2 | head -9 | tail -3  | tr -d '\n\r'`
echo $uid_ciphered
sum_ciphered=`cat $2 | head -12 | tail -3  | tr -d '\n\r'`
echo $sum_ciphered
xor_ciphered=`cat $2 | tail -3  | tr -d '\n\r'`
uid=`echo $uid_ciphered | base64 --decode | openssl rsautl -verify -pubin -inkey clientPk `
uid_true=`cat $facture | head -1`
sum_true=`cat $facture | tail -1`
sum=`echo $sum_ciphered | base64 --decode | openssl rsautl -verify -pubin -inkey clientPk`
xor=`echo $xor_ciphered | base64 --decode | openssl rsautl -verify -pubin -inkey clientPk`
clepubclient=`echo $clepubclient_ciphered | base64 --decode | openssl rsautl -pubin -verify -inkey banquePk`
clepubmerchant=`echo $clepubmerchant_ciphered | base64 --decode | openssl rsautl -verify -pubin -inkey clientPk`
clepubclient_true=`openssl dgst -sha1 clientPk | cut -d' ' -f2`
clepubmerchant_true=`openssl dgst -sha1 commercantPk | cut -d' ' -f2`
if [ "$uid" != "$uid_true" ] ; then
    echo uid not good !
fi
if [ "$sum" != "$sum_true" ] ; then
    echo sum not good !
fi
if [ "$clepubclient" != "$clepubclient_true" ] ; then
    echo cle publique client not good !
fi
if [ "$clepubmerchant" != "$clepubmerchant_true" ] ; then
    echo cle publique merchant not good !
fi
