#!/bin/bash
###################################################################
####    Bank program taking a check verified by the merchant   ####
####    as a parameter and checking if the check hasn't already####
####    been cashed before                                     ####
####    Arguments : - check file                               ####
####    Output : Either that the check is fine or not          ####
####    How does a bank check if a check has been cashed       ####
####        or not ?                                           ####
####    - Save a file with the 20 first number of the          ####
####         merchant's key's hash it encounters in the check  ####
####     -> inside the file, puts on each line, the unique     ####
####      number the merchant has produced and the customer's  ####
####      key, separated by a space                            ####
####    If it's fine, the bank with cash the check and add     ####
####        the line to the right file                         ####
###################################################################

#checking the arguments
if test $# -lt 1
then
	echo "No amount for the invoice entered !"
	exit 0
fi
check=$1

#Getting and deciphering the data in the check
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
# remove the file where the split were stocked
rm -rf xx*
# decipher the uid 
uid=`echo $uid_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
# decipher the sum
sum=`echo $sum_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
# decipher the hash
hash_uid_pk_sum=`echo $hash_uid_pk_sum_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
# decipher the hash of the client Pk
clepubclient=`echo $clepubclient_ciphered | base64 --decode | openssl rsautl -pubin -encrypt -raw -inkey banquePk`
# decipher the hash of the merchant Pk
clepubmerchant=`echo $clepubmerchant_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
# recover the true client Pk
clepubclient_true=`openssl dgst -sha1 clientPk | cut -d' ' -f2`
# recover the true merchant Pk
clepubmerchant_true=`openssl dgst -sha1 commercantPk | cut -d' ' -f2`
# test of the client and merchant Pk 
if [ "$clepubclient" != "$clepubclient_true" ] ; then
    echo cle publique client not good !
fi
if [ "$clepubmerchant" != "$clepubmerchant_true" ] ; then
    echo cle publique merchant not good !
fi
somethingswrong=0
#mercfirstchar=${clepubmerchant:0:40}
echo clepubmerchant_true : $clepubmerchant_true
mercfirstchar=`echo $clepubmerchant | head -c 20`
echo mercfirstchar : $mercfirstchar
echo clepubmerchant : $clepubmerchant

#Vérification que les données chiffrées correspondent aux données originales
dataspacecombi="$sum $uid $clepubmerchant_true"
hash_true=`echo $dataspacecombi | openssl dgst -sha1`
dataspacecombiatester=`echo $sum $uid $clepubmerchant | tr "\v" " " `
echo dataspacecombi : $dataspacecombi
echo dataspacecombiatester : $dataspacecombiatester # DEBUG #
# comparaison hash
if [ "$hash_true" != "$hash_uid_pk_sum" ]; then
   echo "La combinaison n'est pas bonne !"
   somethingswrong=1
fi
# si le fichier du marchand est déjà présent, regarde si le cheque est deja enregistré, si il est deja enregistré, il est refusé 
if [ -e "${mercfirstchar}.sv" ] ;
then
    valeursaved=`cat "${mercfirstchar}.sv" | grep "$uid|$sum|$clepubmerchant"`
fi
if [ "$valeursaved" != "" ] ;
then
    echo "Le groupe UID/cléeclient/hashcléecommercant dans ce chèque est reconnu comme déjà ayant été encaissé !"
    somethingswrong=1
fi

if test $somethingswrong -eq 0 ;
then
  echo "$uid|$sum|$clepubmerchant" >> "${mercfirstchar}.sv"
  echo -e "ok !"
fi
