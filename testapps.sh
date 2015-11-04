case "$1" in
'')
  printf "Pas d'arguments fournis, rien à faire.\n"
    ;;
'1')
  printf "Lancement de init.sh...\n"
  ./init.sh
    ;;
'2')
  printf "Lancement de merchant_generate_invoice.sh...\n"
  printf "Génération du fichier test_invoice avec une somme de 50..\n"
  ./merchant_generate_invoice.sh test_invoice 50
    ;;
'3')
  printf "Lancement de generateCheck.sh...\n"
  printf "Génération du chèque test_check...\n"
  ./createCheck.sh test_invoice test_check
    ;;
'4')
  printf "Lancement de merchant_verif_invoice_n_check.sh...\n"
  printf "Vérification du chèque de la part du marchand...\n"
  ./merchant_verif_check.sh test_invoice test_check
    ;;
'5')
  printf "Lancement de bank_check.sh...\n"
  printf "Encaissement du chèque par la banque...\n"
  ./bank_check.sh test_check
    ;;
'6')
  printf "Suppression des fichiers générés...\n"
  rm -f test_check test_invoice clientPk clientSk commercantPk commercantSk banquePk banqueSk clientPkEncode *.sv
    ;;
esac
