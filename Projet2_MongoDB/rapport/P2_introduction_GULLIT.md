# Projet 2 — MongoDB : introduction du rapport et grille de relecture M3

**ITT3-IR — Groupe 5 — Rôle M1 Chef d'équipe : KEUMEKA SOKING WILFRIED GULLIT**

---

## Introduction générale du rapport

La plateforme de services universitaires du Groupe 5 a pour vocation de centraliser les informations relatives aux étudiants : identification, scolarité, contacts, pièces administratives, certifications et expériences professionnelles. Contrairement à un simple répertoire d'utilisateurs, le **dossier étudiant** est un objet vivant et hétérogène. Deux étudiants inscrits dans la même filière peuvent avoir des profils très différents : l'un dispose d'un stage et de trois certifications, l'autre d'aucun ; l'un a quatre pièces justificatives numérisées, l'autre seulement une CNI ; les notes, les adresses et les contacts peuvent eux-mêmes être absents, uniques ou multiples. Cette variabilité n'est pas une anomalie de données, elle est inhérente au métier.

Dans le cadre du Projet 1, nous avons modélisé une gestion commerciale avec PostgreSQL. Le modèle relationnel impose une structure rigide : chaque table possède un nombre fixe de colonnes, les relations sont décrites par des clés étrangères et les données absentes sont représentées par `NULL`. Appliqué aux dossiers étudiants, ce modèle montre rapidement ses limites. Pour représenter les pièces justificatives, les certifications ou les stages, il faudrait créer autant de tables filles, puis enchaîner les jointures pour reconstituer un seul dossier. Chaque nouvelle information (par exemple un type de bourse ou un second contact d'urgence) imposerait une migration du schéma : `ALTER TABLE`, propagation sur les environnements, interruption de service potentielle. Les tableaux de valeurs deviennent soit des colonnes répétées (`piece_1`, `piece_2`…), soit des tables de liaison avec contraintes d'unicité, ce qui éloigne la structure de la réalité métier et alourdit les requêtes de lecture.

Le choix du **modèle orienté document MongoDB** répond directement à cette problématique. Un document `etudiants` contient l'ensemble des informations d'un dossier dans une seule structure imbriquée : les sous-documents (`adresse`) regroupent les données fortement liées, les tableaux (`notes`, `pieces_justificatives`, `certifications`, `stages`) absorbent la cardinalité variable, et chaque document peut posséder un jeu de champs différent sans contrainte globale. MongoDB conserve toutefois les garanties nécessaires à un travail de chef d'œuvre : typage des valeurs (`ObjectId`, `ISODate`, numériques), indexation, agrégations (`$group`, `$project`, `$unwind`) pour produire les statistiques par filière et par niveau, et opérations de suppression contrôlées. Le cadre de travail retenu est donc le suivant : souplesse du schéma pour l'évolution métier, rigueur des contrôles via les scripts `01_structure.js` et `P2_99_verification_GULLIT.js`, et traçabilité des preuves dans `captures/`.

Ce rapport présente successivement l'installation et la connexion à l'instance locale Docker (C1), la structure de la base `universite_tp` et de la collection `etudiants`, la modélisation retenue (S3), les traitements et vérifications (C7/S7, C8), puis la comparaison argumentée entre le modèle documentaire et le modèle relationnel (S8). L'ensemble des livrables est produit sous le rôle M1 (Chef d'équipe) et doit permettre une relecture technique autonome par M3-Antoine.

---

## Grille de relecture technique — lot de M3-Antoine

> À cocher lors de la relecture du lot : `01_structure.js`, modélisation sous-documents/tableaux (S3), comparaison document vs relationnel (S8).

| # | Point contrôlé | Critère d'acceptation | État |
|---|---|---|---|
| 1 | Présence de `scripts/01_structure.js` | Fichier dans `Projet2_MongoDB/scripts/`, commenté en français, encodage UTF-8 | ☐ |
| 2 | Création de la structure | `use universite_tp` / `db.getSiblingDB('universite_tp')` puis création de `etudiants` ; exécution idempotente (drop ou `createCollection` conditionnel) | ☐ |
| 3 | Connexion correcte | Script exécutable via `docker exec ... mongosh -u admin -p ... --authenticationDatabase admin --file ...`, sans erreur d'authentification | ☐ |
| 4 | Champs de base | Présence et typage de `matricule`, `nom`, `prenom`, `date_naissance` (`ISODate`), `email`, `filiere`, `niveau`, `statut` | ☐ |
| 5 | S3 — sous-documents | `adresse` modélisée en sous-document (`ville`, `quartier`, `code_postal`), pas de chaîne plate | ☐ |
| 6 | S3 — tableaux | `notes`, `pieces_justificatives`, `certifications`, `stages` sous forme de tableaux de sous-documents | ☐ |
| 7 | Hétérogénéité des schémas | Au moins deux documents avec des jeux de champs optionnels différents ; vérifiable via `$exists` dans C8 | ☐ |
| 8 | Jeu de données | `countDocuments()` cohérent avec l'énoncé ; aucun document orphelin ni champ obligatoire manquant | ☐ |
| 9 | Agrégations | Effectifs par filière, par niveau et croisés produits par C8 ; somme des groupes = total général | ☐ |
| 10 | C7/S7 — suppression contrôlée | Dossier de test identifié par `matricule`/`email`/`nom` documenté, supprimé, et C8 affiche 0 document restant | ☐ |
| 11 | S8 — comparaison | Tableau comparatif document vs relationnel couvrant : flexibilité du schéma, jointures, performance de lecture, transactions, normalisation, cas d'usage | ☐ |
| 12 | Livrables M1 présents | `P2_C1_installation_connexion_GULLIT.md`, `P2_C1_connexion_output.txt`, `P2_99_verification_GULLIT.js`, `P2_introduction_GULLIT.md` | ☐ |
| 13 | Qualité rédactionnelle | Nommage cohérent, commentaires en français, captures lisibles, absence de données sensibles hors cadre pédagogique | ☐ |

### Remarques de relecture

```text
Relecteur : M3-Antoine
Date      : ...........................
Points conformes : ....................
Points à corriger : ...................
Signature : ...........................
```
