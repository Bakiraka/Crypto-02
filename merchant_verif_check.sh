#!/bin/bash
###############################################################################
####                         merchant_verif_check.sh                      #####
####     Arguments : Name of the invoice                                  #####
####                 <check_output> : the result of the check             #####
####     The check will be of the form :                                  #####
####     Hash of the RSA public key of the commercant crypt by clientSK   #####
####     Hash of the RSA public key of the client crypt by BankSk         #####
####     Uid crypt by clientSk                                            #####
####     Sum crypt by clientSk                                            #####
####     hash of the type above crypt by clientSk                         #####
####     type : '<sum> <uid> <Hash_commercant_PK>                         #####
####     Output : Nothing, The error field if the check is modified       #####
###############################################################################


#checking the arguments
if test $# -lt 2
then
	echo "No amount for the invoice entered !"
	exit 0
fi

facture=$1
check=$2
line_marqueur=""
cmp=1
marqueur="0000000000000"
# check what lines are the marqueur in the file and stock the line in the line_marqueur variable
for i in $( cat $check ); do
    #if the line is the marqueur, stock the number of line in the variable
    if [ "$i" = "$marqueur" ]; then
	line_marqueur="$line_marqueur $cmp"
    fi
	cmp=$(( $cmp + 1 ))
done
# split the file into 5 file xx** when they attein the line of the marqueur
csplit $check $line_marqueur > /dev/null
# recover the ciphered in their file and reconstitute the key (they are stocked into some lines)
clepubmerchant_ciphered=`cat xx00 | tr -d '\n\r'`
clepubclient_ciphered=`cat xx01 | sed '1d' | tr -d '\n\r'`
uid_ciphered=`cat xx02 | sed '1d' | tr -d '\n\r'`
sum_ciphered=`cat xx03 | sed '1d' | tr -d '\n\r'`
hash_uid_pk_sum_ciphered=`cat xx04 | sed '1d' | tr -d '\n\r'`
# remove the files
rm -rf xx*
# decipher the uid 
uid=`echo $uid_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk `
# recover the true uid in the facture
uid_true=`cat $facture | head -1`
# recover the true sum in the facture
sum_true=`cat $facture | tail -1`
# decipher the sum 
sum=`echo $sum_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
# decipher the hash of the sum, uid and the commercant pk
hash_uid_pk_sum=`echo $hash_uid_pk_sum_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
# decipher the hash of the client Pk encrypted
clepubclient=`echo $clepubclient_ciphered | base64 --decode | openssl rsautl -pubin -encrypt -raw -inkey banquePk`
# decipher the hash of the merchant Pk encrypted
clepubmerchant=`echo $clepubmerchant_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
# recover the true PK of the client and the merchant
clepubclient_true=`openssl dgst -sha1 clientPk | cut -d' ' -f2`
clepubmerchant_true=`openssl dgst -sha1 commercantPk | cut -d' ' -f2`
# tests of the uid, clientPK, merchantPK, Sum and the Hash, if this is correct, don't print it, else print the field of error
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
#recover the true hash
uid_pk_sum_content_nothash="$sum $uid $clepubmerchant_true"
hash_uid_pk_sum_true=`echo $uid_pk_sum_content_nothash | openssl dgst -sha1`

if [ "$hash_uid_pk_sum" != "$hash_uid_pk_sum_true" ] ; then
    echo hash not good !
fi
