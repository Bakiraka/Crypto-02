#!/bin/bash
###################################################################
####    Bank program taking a check verified by the merchant   ####
####    as a parameter and checking if the check hasn't already####
####    been cashed before                                     ####
####    Arguments : - check file                               ####
####    Output : Either that the check is fine or not          ####
####    How does a bank check if a check has been cashed       ####
####        or not ?                                           ####
####    - Save a file with the 40 first number of each         ####
####       merchant's key it encounters                        ####
####     -> inside the file, puts on each line, the unique     ####
####      number the merchant has produced and the customer's  ####
####      key, separated by a space                            ####
####    If it's fine, the bank with cash the check and add     ####
####        the line to the right file                         ####
###################################################################

#Getting the arguments
check=$1

clepubmerchant_ciphered=`cat $check | head -3 | tr -d '\n\r'`
echo $clepubmerchant_ciphered
clepubclient_ciphered=`cat $check | head -6 | tail -3 | tr -d '\n\r'`
echo $clepubclient_ciphered
uid_ciphered=`cat $check | head -9 | tail -3  | tr -d '\n\r'`
echo $uid_ciphered
sum_ciphered=`cat $check | head -12 | tail -3  | tr -d '\n\r'`
echo $sum_ciphered
xor_ciphered=`cat $check | tail -3  | tr -d '\n\r'`
uid=`echo $uid_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
sum=`echo $sum_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
xor=`echo $xor_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
clepubclient=`echo $clepubclient_ciphered | base64 --decode | openssl rsautl -pubin -encrypt -raw -inkey banquePk`
clepubmerchant=`echo $clepubmerchant_ciphered | base64 --decode | openssl rsautl -encrypt -raw -pubin -inkey clientPk`
clepubclient_true=`openssl dgst -sha1 clientPk | cut -d' ' -f2`
clepubmerchant_true=`openssl dgst -sha1 commercantPk | cut -d' ' -f2`

#Vérification du XOR
resultxor="$sum $uid $clepubmerchant"

if [ "$clepubclient" != "$clepubclient_true" ] ; then
    echo cle publique client not good !
fi
if [ "$clepubmerchant" != "$clepubmerchant_true" ] ; then
    echo cle publique merchant not good !
fi
somethingswrong=0
mercfirstchar=${clepubmerchant:0:40}
#mercfirstchar = echo $clepubmerchant head -c 10
if [ -e "${mercfirstchar}.sv"] ;
then
  valeursaved = `cat "${mercfirstchar}.sv" | grep "$uid_true|$sum_true|$clepubmerchant"`
  if [ $valeursaved != "" ] ;
  then
    echo "Le couple identifiant unique/clée de client dans ce chèque est reconnu comme déjà ayant été encaissé !"
    $somethingswrong = 1
  fi
  if [ echo $valeur | tr '[|]' ' ' != resultxor] then
    echo "Le Xor n'est pas bon !"
    $somethingswrong = 1
  fi
fi

if [somethingswrong == 0] ;
then
  "$uid_true|$sum_true|$clepubmerchant">> "${mercfirstchar}.sv"
  echo -e "ok !\n"
fi
