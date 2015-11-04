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


##Traitement du problème

Présomption de départ : le client doit avoir sa clé publique signée par la banque (par exemple à son adhésion à la banque).

La transaction se fait de façon active (échange entre les acteurs).

Le chèque contient 4 informations principales :
 - Le chiffrement par le client de la clé publique du commerçant
 - Le chiffrement par la banque de la clé publique du client  
 - La somme de la transaction (en nombre entier)
 - Un numéro unique généré par le commerçant pour vérifier que le chèque ne soit pas copié par un client malveillant

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
  - Somme de la transaction et numéro unique chiffrés
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
  Paramètres :
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
 *Sur la sortie standard :*
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

Voir le fichier Scénarios.md pour ceux-ci.
