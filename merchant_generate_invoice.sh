#!/bin/bash
###################################################################
####    Merchant program generating and invoice                ####
####    Arguments : Name of the invoice                        ####
####                invoice_sum in the invoice                 ####
####    Output (in specified file) : Invoice generated	       ####                                                           ####
####    The invoice will be of the form :                      ####
####    unique id                                              ####
####    invoice_sum                                            ####
###################################################################

#checking the arguments
if test $# -lt 2
then
	echo "No amount for the invoice entered ! Default amount 50 used."
	nameofinvoice=50
else
	nameofinvoice=$1
fi

amount=$2

#UID generation
tr -cd '[:digit:]' < /dev/urandom | fold -w30 | head -n1 > $nameofinvoice
#File writting
echo $amount >> $nameofinvoice
