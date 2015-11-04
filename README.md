# Crypto-02
Bash version of the customer-merchant-bank check
*[FRENCH]*

 **Cryptographie Avancée : Problème du chèque**
---

Lien dépot Github : https://github.com/Bakiraka/Crypto-02

*Description rapide du problème :*
>Nous avons 3 acteurs : un client, un commerçant, une banque.
Comment faire en sorte qu’une transaction commerciale grave à un chèque puisse être effectuée, en supposant par exemple que ni le client, ni le commerçant ne peuvent contacter la banque pendant l’achat (les deux sont dans un avion), et cela sans qu’aucun acteur ne puisse tricher sur les autres ?
(nous ne traiterons pas du sujet d’un chèque en bois dans ce cas)


## Traitement du problème

Présomption de départ : le client doit avoir sa clé publique signée par la banque (par exemple à son adhésion à la banque).

La transaction se fait de façon active (échange entre les acteurs).

Le chèque contient 5 informations principales :
 - Le chiffrement par le client de la clé publique du commerçant hashé
 - Le chiffrement par la banque de la clé publique du client hashé
 - La somme de la transaction (en nombre entier) chiffré par le client
 - Un numéro unique généré par le commerçant pour vérifier que le chèque ne soit pas copié par un client malveillant chiffré par le client
 - Un hash de l'uid, la somme et la clé du commercant chiffré par le client

Lors de la fin de la transaction, le commerçant aura le chèque vérifié avec la facture

Quand la banque reçoit le chèque, la banque signera le chèque et le gardera en mémoire afin de pouvoir garantir l’unicité des chèques => un chèque sera viré une et une fois seulement par la banque

----

## Création d’une preuve de concept

>Langage utilisé : Bash/Sh

*5 programmes principaux :*

1. Initialisation
  - Génération clé publique/privée banque
  - Génération clé publique/privée client
  - Génération clé publique/privée commerçant
  - Chiffrer la clé publique du client avec la clé privée de la banque :
2. Programme du commerçant
  - Génération d’une facture contenant :
  - Id (UUID par exemple)
  - Somme
3. Programme du client qui prend en paramètre la facture et va produire le chèque :
  - Clé publique du commerçant chiffrée par le client
  - Clé publique du client chiffrée par la banque
  - Somme de la transaction et numéro unique chiffrés par le client
  - Hash de l'uid, la somme et la clé publique du commercant chiffré par le client
4. Programme du commerçant : prend facture et le chèque et répond si c’est ok ou pas
  - Vérifie que les données du chèque n’ont pas été altérées par le client
5. Programme de la banque : va prendre chèque et effectue la transaction (ou pas)
  - S’assure que le chèque n’est pas une copie d’un chèque déjà déposé
  - Vérifie que le chèque a bien été chiffré par le client

## Fonctionnement des programmes

1. 1er programme : init.sh

  - Génération clé publique/privée banque
  - Génération clé publique/privée client
  - Génération clé publique/privée commerçant
  - Chiffrer la clé publique du client avec la clé privée de la banque

 **Lancement du programme :**
```
 ./init.sh
```

2. merchant_generate_invoice.sh

  Programme du marchand générant une facture.

  *Paramètres :*
  - Nom de la facture a générer
  - (optionnel) Nombre de produits à générer
  Sortie : fichier facture généré

  La facture est sous la forme :

  > uniqueid

  > sommedesprix

 **Lancement du programme :(Exemple)**
  ```
  ./merchant_generate_invoice.sh <test_invoice> <sum_products>
  ```
  L'unique id généré tente d'utiliser le générateur d'aléatoires fourni par le système d'exploitation.
  La fonction os.urandom() va par exemple chercher dans * /dev/urandom * sur un système unix.

3. 3eme programme : createCheck.sh
           prend 2 parametres : le fichier contenant la facture
                      le fichier qui contiendra le cheque

  Programme du client qui prend en paramètre la facture et va produire le chèque :
  ```  
    Hash de la clé publique du commerçant chiffrée par le client
    Hash de la clé publique du client chiffrée par la banque
    Uid de la transaction chiffré par le client
    Montant de la transaction chiffré par le client
    Hash de l'uid, du montant et de la clé du commercant par le client
  ```

   **Lancement du programme :(Exemple)**
  ```
  ./generateCheck.sh <fileFacture> <fileOutCheck>
  ```

4. merchant_verif_check.sh

  Programme du marchand vérifiant si un chèque a ou non été modifié :
 ```
	Verification des clés publiques du client et du commercant
	Verification du montant et de l'uid de la facture
	Verification du hash de la clé publique, l'uid et le montant de la facture
 ```
  Paramètres :
  - fichier facture
  - chèque "signé" par le client
  - clé publique du client
  - clé publique du marchand

 Sortie : Rien si le cheque est correct, le champ modifié si le cheque ne l'est pas

  **Lancement du programme :(Exemple)**
 ```
 ./merchant_verif_check.sh <test_invoice> <test_check>
 ```

5. bank_check.sh

  Programme de la banque qui va encaisser un chèque.
  Vérifie si un chèque est correct ou si il a déjà été encaissé ou non.

  Arguments :
  - fichier chèque
  - clée publique du client
  - clée publique du marchand
  Sortie : Une indication si le chèque a bien été encaissé ou non.

 **Lancement du programme :(Exemple)**
  ```
  ./bank_check.sh <test_check>
  ```

  Fonctionnement :
  La banque va utiliser les 40 premiers caractères de la clée publique du marchand pour faire un fichier d'historique. Elle va ainsi pouvoir vérifier rapidement dans ce fichier, l'existence ou non de l'id unique associé à la clée publique du client.

## Tests
Pour tester les scripts, lancer ./testapps.sh $ , avec $ le numéro du script a tester.

Ceux-ci sont à lancer dans l'ordre, il est évident que la génération d'un chèque nécessitera une facture.

Le script numéro 6 sert à supprimer les fichiers crées lors de l'utilisation des scripts (Clés, factures, chèques).

## Scénarios

### Énonciation des différents scénarios abordés

#### Scénario n°1 :
Modification d'un chèque de la part du marchand

Initialisation :
  ```
  ./init.sh
  ```

  * Le marchand crée une facture pour un client
  ```
  ./merchant_generate_invoice.sh invoice1 50
  ```
  * Le client va créer un chèque à partir de cette facture
  ```
  ./generateCheck.sh invoice1 check_invoice1
  ```
  * Le marchand utilise ce chèque et modifie un élément, des caractères dans le quatrième champ du chèque (la somme de la transaction chiffrée par le client)
  ```
  $diff check_1 check_caduque
  5c5
  < IxOIlOKf76ypsHGAKSqMAdPBKZ28AEaACp4zdt3tdJBvXIk2LtTqs5mPQPdf3XwT/ps73i/d06v2
  \---
  > IxPIlOKf76ypsHGAKSqMAdPBKZ28AEaACp4zdt3tdJBvXIk2LtTqs5mPQPdf3XwT/ps73i/d06v2
  ```
  * La banque va effectuer la vérification et indiquer une erreur à cet endroit
  ```
  $./bank_check.sh <test_check>
  Lancement de bank_check.py...
  Encaissement du chèque par la banque...
  clepubmerchant_true : ef23327f4ad5cebc17082e5d3d442a5d58054c4a
  mercfirstchar : ef23327f4ad5cebc1708
  clepubmerchant : ef23327f4ad5cebc17082e5d3d442a5d58054c4a
  dataspacecombi : +��g��u���J��´a��Y��=�ݠmkG��>�����Լ��P�<!nh�f��U�~:��;�m�vt�m���G�P5�P�U�9G�̚����p8�^+sb+��?�t 063679349397773358075491549324 ef23327f4ad5cebc17082e5d3d442a5d58054c4a
  dataspacecombiatester : +��g��u���J��´a��Y��=�ݠmkG��>�����Լ��P�<!nh�f��U�~:��;�m�vt�m���G�P5�P�U�9G�̚����p8�^+sb+��?�t 063679349397773358075491549324 ef23327f4ad5cebc17082e5d3d442a5d58054c4a
  La combinaison n'est pas bonne !
  ```
  * Cleaning :
  ```
  ./testapps.sh 6
  ```
#### Scénario n°2 :
Combinaison d'éléments de deux chèques pour créer un troisième chèque

Initialisation :
  ```
  ./init.sh
  ```

  * Le marchand crée deux factures pour un client.
```
./merchant_generate_invoice.sh invoice1 50
./merchant_generate_invoice.sh invoice2 100
```

  * Le client va créer deux chèques avec ces deux factures
  ```
  ./createCheck.sh invoice1 check_invoice1 check_invoice1
uidcrypt : Llo9WvrhSfRJ/WXB5KdOxPdHWxcfz5wqd6tp2dMb/JsAYZ4Lapy7RyY89t7rDxS1hOQhZK2r6ABl xY3165RY9eflWqKRU0mJyQB1G7iE9k1uDOZR6kyjT+NCfcMqwjku5vfyZ4PfbcqLIDzx4wbGnOMi aU04Vxk3fB6+raURQC4=
montantcrypt : ce7uif7b/8XRU1eBD027zL+h0bAArr7Q3V+AsFVK9r443TgzR7RownGfsoVyEUhbtcTH4DFWh24J L81NV3bsV+jcG2k3MOrrEQH1Ex3brLjoY6zc/cn9sTaPYhywxAoOESuQ3603arNZeHfpNvcdvBAS 2h8DT8FU49WZvZejTYk=
clientPkHash : eJx1WkQ0yl+EwYXiGMhxlGIJzgTSEQ5O1U3B+2Ur4O/3OBopKjEiQEePiVfpY8JDGGocEA9m0MeP sHeZ0BnWAtw8ERAUutJvo3FWnl5mgHkraImkmCG03r2fNdaYQQcXtOrh3cXNfnqf/0AyHe+qVue9 p1jJz51I74Bvepoo6GY=
commercantPkEncode : nEKosmiewT2bgbLuSAzm8C7URSNd6PM50cDpapyjacLX0UqEB80LuXt4u9h4L8rUW4OxADCH3B5t JZVMrW4G4B49TnOYhtcUyU2pql6NSujaA5WFY3FFchNw0CQoAgr19qnSv+0UCniNUurXDbaBDfTv 1K0+NmRqHMm916fZ0mc=
resultxorcrypt : BfvBryZz+9tDkEzc6+0Tk1rBY/TeraUInqNIhVO9SSzY7r+6Q/qzc6+KffK8lzMG6KNcA2oiZHM7 SxqbzskgvvPljR0apEqdujdTBQxVDYG3PfFxX7qQ6HesBKJA2Q4U/52OO18ZPYS8K3wBq6v2wXgK QcEnQdgxZhMYKgpdWPQ=

  ./createCheck.sh invoice1 check_invoice1
  uidcrypt : TLWhNVuiAwrvDK7sm7dDZpCEN7atYNV6TMUIxD89Oelizn8bRS37r+wzVL7hlRh8BUTwrm+IdZM2 pDxysUTI1mfog2dBC/+RWDmysektc7tToeNOME+kgNSByBHSMilQBUNaww9I7d8n8V+FVQOPOps/ CMdoAVMqMca5IF+i638=
montantcrypt : MLldwKfyF45eO3wL1LNuzXKVOayGNaz6xtcY7EJnc1w7grQ/+dJJZfF1OxeqzihmC9vYwf0TPMpo /06wybaYm06QL3UyE+F8CLb/NpMemikdBEA9RuD3bPoRWHJ5iHKe/4wKAQEEWL7k1IinEeGm/Nly kQpH7iDvObJK5E7jBfI=
clientPkHash : eJx1WkQ0yl+EwYXiGMhxlGIJzgTSEQ5O1U3B+2Ur4O/3OBopKjEiQEePiVfpY8JDGGocEA9m0MeP sHeZ0BnWAtw8ERAUutJvo3FWnl5mgHkraImkmCG03r2fNdaYQQcXtOrh3cXNfnqf/0AyHe+qVue9 p1jJz51I74Bvepoo6GY=
commercantPkEncode : nEKosmiewT2bgbLuSAzm8C7URSNd6PM50cDpapyjacLX0UqEB80LuXt4u9h4L8rUW4OxADCH3B5t JZVMrW4G4B49TnOYhtcUyU2pql6NSujaA5WFY3FFchNw0CQoAgr19qnSv+0UCniNUurXDbaBDfTv 1K0+NmRqHMm916fZ0mc=
resultxorcrypt : HQJszdwiuDjTz+Sc5m84kA9+LeWrQSzzb7OgQYF9/VLbwWr5gzvwmaz8ga70RgxIV+0SfEoC6oJq pSpT3TMTnlHZDzDoEOmRFAcXh/xmE0Co9vMoezTJQmQZ+thjb1WQ9XAVj4Ys71d88xmseVfyDUUE NEO6joqxPlndFg6nVLs=

  ```
  * Le marchand prends un élément d'un chèque et l'utilise pour remplacer un élément
  dans le second chèque.
  Ici, on prend les deux derniers champs du chèque : [Montant de la transaction chiffré par le client] et [Hash de l'uid, du montant et de la clé du commercant par le client]
```
  diff check_invoice2 check_invoice2_original
  13,15c13,15
  < ce7uif7b/8XRU1eBD027zL+h0bAArr7Q3V+AsFVK9r443TgzR7RownGfsoVyEUhbtcTH4DFWh24J
  < L81NV3bsV+jcG2k3MOrrEQH1Ex3brLjoY6zc/cn9sTaPYhywxAoOESuQ3603arNZeHfpNvcdvBAS
  < 2h8DT8FU49WZvZejTYk=
  \---
  > MLldwKfyF45eO3wL1LNuzXKVOayGNaz6xtcY7EJnc1w7grQ/+dJJZfF1OxeqzihmC9vYwf0TPMpo
  > /06wybaYm06QL3UyE+F8CLb/NpMemikdBEA9RuD3bPoRWHJ5iHKe/4wKAQEEWL7k1IinEeGm/Nly
  > kQpH7iDvObJK5E7jBfI=
  17,19c17,19
  < BfvBryZz+9tDkEzc6+0Tk1rBY/TeraUInqNIhVO9SSzY7r+6Q/qzc6+KffK8lzMG6KNcA2oiZHM7
  < SxqbzskgvvPljR0apEqdujdTBQxVDYG3PfFxX7qQ6HesBKJA2Q4U/52OO18ZPYS8K3wBq6v2wXgK
  < QcEnQdgxZhMYKgpdWPQ=
  \---
  > HQJszdwiuDjTz+Sc5m84kA9+LeWrQSzzb7OgQYF9/VLbwWr5gzvwmaz8ga70RgxIV+0SfEoC6oJq
  > pSpT3TMTnlHZDzDoEOmRFAcXh/xmE0Co9vMoezTJQmQZ+thjb1WQ9XAVj4Ys71d88xmseVfyDUUE
  > NEO6joqxPlndFg6nVLs=
```

  * La banque vérifie le chèque à encaisser et indique une erreur
  ```
  ./bank_check.sh check_invoice2
clepubmerchant_true : ef23327f4ad5cebc17082e5d3d442a5d58054c4a
mercfirstchar : ef23327f4ad5cebc1708
clepubmerchant : ef23327f4ad5cebc17082e5d3d442a5d58054c4a
dataspacecombi : 50 033587451164849536466398497969 ef23327f4ad5cebc17082e5d3d442a5d58054c4a
dataspacecombiatester : 50 033587451164849536466398497969 ef23327f4ad5cebc17082e5d3d442a5d58054c4a
La combinaison n'est pas bonne !
  ```
  * Cleaning :
  ```
  ./testapps.sh 6
  ```
