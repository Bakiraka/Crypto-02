#!/bin/bash

#checking the arguments
if test $# -lt 2
then
	echo "No amount for the invoice entered !"
	exit 0
fi

nameofinvoice=$1
amount=$2

echo $nameofinvoice
echo $amount
#Génération
tr -cd '[:digit:]' < /dev/urandom | fold -w30 | head -n1 > $nameofinvoice
