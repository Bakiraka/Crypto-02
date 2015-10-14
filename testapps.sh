case "$1" in
'1')
  printf "Lancement de init.py...\n"
  python3.4 init.py
    ;;
'2')
  printf "Lancement de merchant_generate_invoice.py...\n"
  printf "Génération de 5 produits dans le fichier test_invoice..\n"
  python3.4 merchant_generate_invoice.py test_invoice 5
    ;;
'3')
  printf "Lancement de generateCheck.py...\n"
  printf "Génération du chèque test_check...\n"
  python3.4 generateCheck.py test_invoice test_check
    ;;
'4')
  printf "Lancement de merchant_verif_invoice_n_check.py...\n"
  printf "Vérification du chèque de la part du marchand...\n"
  python3.4 merchant_verif_invoice_n_check.py test_invoice test_check clientPk commercantPk
    ;;
'5')
  printf "Lancement de bank_check.py...\n"
  printf "Encaissement du chèque par la banque...\n"
  python3.4 bank_check.py test_check clientPk commercantPk
esac
