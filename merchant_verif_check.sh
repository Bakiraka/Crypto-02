#!/bin/bash

facture=$1
check=$2
variable=""
cmp=1
cmpbefore=-1
marqueur="0000000000000"

for i in $( cat $check ); do
    if [ "$i" = "$marqueur" ]; then
	variable="$variable $cmp"
    fi
	cmp=$(( $cmp + 1 ))
done
csplit $check $variable > /dev/null
clepubmerchant_ciphered=`cat xx00 | tr -d '\n\r'`
clepubclient_ciphered=`cat xx01 | sed '1d' | tr -d '\n\r'`
uid_ciphered=`cat xx02 | sed '1d' | tr -d '\n\r'`
sum_ciphered=`cat xx03 | sed '1d' | tr -d '\n\r'`
xor_ciphered=`cat xx04 | sed '1d' | tr -d '\n\r'`
rm -rf xx*
uid=`echo $uid_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk `
uid_true=`cat $facture | head -1`
sum_true=`cat $facture | tail -1`
sum=`echo $sum_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
xor=`echo $xor_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
clepubclient=`echo $clepubclient_ciphered | base64 --decode | openssl rsautl -pubin -encrypt -raw -inkey banquePk`
clepubmerchant=`echo $clepubmerchant_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
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

contentnothash="$sum $uid $clepubmerchant_true"
xor_true=`echo $contentnothash | openssl dgst -sha1`
if [ "$xor" != "$xor_true" ] ; then
    echo hash not good !
fi
