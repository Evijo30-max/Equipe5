# RAPPORT FINAL — PROJET 2 : MongoDB
## Groupe 5 — Gestion des dossiers étudiants

**Niveau : ITT3-IR** | **Examinateur : M. SASSA Giquel** | **Équipe : 5 membres (M1 à M5)**  
**Version du modèle : 1.0 — 23/11/2026** | **Statut : modèle prêt à assembler**

| Code | Membre | Rôle permanent |
|---|---|---|
| **M1** | **KEUMEKA SOKING WILFRIED GULLIT** | **Chef d'équipe : coordination, environnement/connexion, vérification finale, assemblage** |
| M2 | FADIMATOU SAIDOU | Membre : réalisation technique + rédaction de sa partie |
| M3 | NGUEGNI ONGOLO ANTOINE | Membre : réalisation technique + rédaction de sa partie |
| M4 | ABBO ALKAMILA | Membre : réalisation technique + rédaction de sa partie |
| M5 | EVINA MBAHO ERIC | Membre : réalisation technique + rédaction de sa partie |

**Périmètre :** travail commun (II, points 1 à 8) + travail spécifique du **Groupe 5 — MongoDB : Gestion des dossiers étudiants** (III, points 1 à 8). Les correspondances C (commun) et S (spécifique) sont indiquées dans le sommaire.

---

## Sommaire et répartition actualisée

**Découpage officiel du sujet :** I. Contexte général · II. Travail demandé à tous les groupes (points 1 à 8) · III. Travail spécifique à chaque groupe — Groupe 5 (points 1 à 8) · IV. Conclusion (ajoutée pour le rapport final).

| Section du sujet | Intitulé | Correspondance | Responsable | Emplacement |
|---|---|---|---|---|
| **I** | Contexte général | — | M1 | Rédigé ci-dessous |
| **II.1 / C1** | Installation, connexion, fiche pour l'équipe | C1 | M1 | Rédigé + fiche C1 |
| **II.2 / C2-S1** | Créer la base `universite_tp` et la collection `etudiants` | C2 / S1 | M3 | `[LOT M3]` |
| **II.3 / S3** | Modélisation du document : identité, formation, coordonnées, tableaux | S3 | M3 | `[LOT M3]` |
| **II.4 / C3-C4-S2** | Jeu de données, import, insertions (`insertOne`, `insertMany`) | C3, C4 / S2 | M5 | `[LOT M5]` |
| **II.5 / C5-S5** | Consultations, recherche par filière, agrégation par filière | C5 / S5 | M2 | `[LOT M2]` |
| **II.6 / C6-S4-S6** | Champs hétérogènes et mises à jour (`$set`, `$push`, `$unset`) | S4, C6 / S6 | M4 | `[LOT M4]` |
| **II.7 / C7-S7** | Suppression contrôlée du dossier de test | C7 / S7 | M2 | `[LOT M2]` |
| **II.8 / S8** | Comparaison document vs relationnel | S8 | M3 | `[LOT M3]` |
| **II.8 / C8** | Vérification finale de toutes les opérations | C8 | M1 | `[VERIFICATION FINALE M1]` |
| **IV** | Conclusion du Projet 2 | — | M1 | À compléter après C8 |

**Règle d'assemblage :** chaque membre remplace son balisage par son contenu définitif. M1 vérifie la cohérence des comptages et assemble le rapport final.

---

## I. Contexte général

L'université souhaite mettre en place une plateforme permettant de centraliser et d'exploiter les informations relatives aux étudiants, aux enseignants, aux formations, aux unités d'enseignement (UE), aux ressources pédagogiques, aux inscriptions et aux résultats académiques. Les dossiers étudiants contiennent des informations variables selon les formations : certains étudiants disposent de pièces justificatives supplémentaires, de certifications ou de stages à enregistrer.

Le modèle relationnel impose un nombre fixe de colonnes et multiplierait les tables filles et les jointures pour représenter ces éléments hétérogènes. MongoDB permet de stocker chaque dossier sous forme d'un **document** : les informations de formation et les coordonnées sont des sous-documents, tandis que les éléments multiples (notes, pièces, certifications, stages) sont des tableaux. Le schéma reste flexible : tous les étudiants ne portent pas les mêmes champs optionnels.

Le présent rapport couvre l'installation et la connexion (C1), la structure et la modélisation du document (C2/S1, S3), le jeu de données et les insertions (C3/C4/S2), les consultations et la suppression contrôlée (C5/S5, C7/S7), les champs hétérogènes et les mises à jour (S4, C6/S6), la comparaison document/relationnel (S8) et la vérification finale (C8).

---

## II.1 / C1 — Installation et connexion MongoDB

**Responsable : M1 — GULLIT**

L'environnement retenu est un conteneur Docker local `mongodb-tp` basé sur l'image `mongo:8.0`, avec le port `27017` mappé. Le serveur est en version **8.0.34** et l'authentification root est `admin` / `<MOT_DE_PASSE_MONGO>` (base `admin`).

Commandes de référence :

```powershell
docker start mongodb-tp
docker ps --filter name=mongodb-tp --format '{{.Names}} | {{.Status}} | {{.Ports}}'
docker exec -it mongodb-tp mongosh -u admin -p <MOT_DE_PASSE_MONGO> --authenticationDatabase admin
```

Dans `mongosh` : `show dbs`, `use universite_tp`, `show collections`, `db.etudiants.find().pretty()`.

La fiche complète (Docker, mongosh, MongoDB Compass, structure attendue) est disponible dans `Projet2_MongoDB/rapport/P2_C1_installation_connexion_GULLIT.md`. La preuve de connexion est conservée dans `Projet2_MongoDB/captures/P2_C1_connexion_output.txt`.

> **État au diagnostic :** la base `universite_tp` n'existe pas encore ; elle sera créée par `01_structure.js` (lot M3). La base `tp_bases` contient un document isolé de test (`nom: 'Prince'`) à ne pas confondre avec le jeu de données du Groupe 5.

---

## II.2 / C2-S1 — Création de la base et de la collection — `[LOT M3]`

**Responsable : M3 — NGUEGNI ONGOLO ANTOINE** | **Relecteur : M1 — GULLIT**

Contenu attendu :

- script `01_structure.js` idempotent et commenté en français ;
- `db = db.getSiblingDB('universite_tp')` puis création de la collection `etudiants` ;
- éventuelle règle `$jsonSchema` limitée aux champs obligatoires ;
- vérification `show collections` et `countDocuments()`.

**Fichier attendu :** `P2_01_structure_ANTOINE.js` (ou `01_structure.js`).

> `[LOT M3]` — remplacer ce bloc par le contenu définitif.

---

## II.3 / S3 — Modélisation du document étudiant — `[LOT M3]`

**Responsable : M3 — ANTOINE** | **Relecteur : M1**

Le modèle doit couvrir :

- **identité** : `matricule` (unique et lisible), `nom`, `prenom`, `date_naissance` (`ISODate`), `email`, `telephone` ;
- **formation** : sous-document `formation` avec `filiere`, `niveau`, `annee` ;
- **coordonnées** : sous-document `adresse` avec `ville`, `quartier`, `code_postal` ;
- **éléments multiples** : tableaux `notes`, `pieces_justificatives`, `certifications`, `stages` ;
- champs optionnels non imposés à tous les documents.

**Fichier attendu :** `P2_01_structure_ANTOINE.js` + modèle du document (schéma) + texte comparatif S8.

> `[LOT M3]` — remplacer ce bloc par le contenu définitif.

---

## II.4 / C3-C4-S2 — Jeu de données, import et insertions — `[LOT M5]`

**Responsable : M5 — EVINA MBAHO ERIC** | **Relecteur : M4 — ABBO**

Contenu attendu :

- construire le jeu de données commun (étudiants, formations, UE) au format JSON, selon le modèle de M3 ;
- **C3** : importer les données communes (`mongoimport` ou `insertMany`) ;
- **S2 / C4** : insérer au moins **5 documents étudiants**, dont au moins deux insertions démontrées séparément (`insertOne` et `insertMany`) ;
- prévoir un **dossier de test** destiné à la suppression contrôlée de M2 (C7/S7) ;
- vérifier les comptages et conserver les captures.

**Fichiers attendus :** `donnees_etudiants.json`, `P2_02_import_ERIC.js`, `P2_03_insertions_ERIC.js`, captures.

> `[LOT M5]` — remplacer ce bloc par le contenu définitif.

---

## II.5 / C5-S5 — Consultations, recherche par filière, agrégation — `[LOT M2]`

**Responsable : M2 — FADIMATOU SAIDOU** | **Relecteur : M5 — ERIC**

Contenu attendu :

- **C5** : au moins deux consultations avec `find`, filtre, projection et tri ;
- **S5** : rechercher les étudiants d'une filière donnée avec un filtre sur un champ imbriqué, par exemple `formation.filiere` ;
- **requête bonus** : agrégation `$group` du nombre d'étudiants par filière ;
- captures et explications.

**Fichier attendu :** `P2_04_consultations_FADIMATOU.js`.

> `[LOT M2]` — remplacer ce bloc par le contenu définitif.

---

## II.6 / S4-C6-S6 — Champs hétérogènes et mises à jour — `[LOT M4]`

**Responsable : M4 — ABBO ALKAMILA** | **Relecteur : M3 — ANTOINE**

Contenu attendu :

- **S4** : ajouter des informations complémentaires à certains étudiants seulement (`pieces_justificatives`, `certifications`, `stages`), sans imposer les mêmes champs à tous ;
- **C6 / S6** : mettre à jour les informations d'un étudiant avec `$set`, `$push`, `$unset` ;
- montrer le document **avant / après** chaque mise à jour ;
- expliquer la souplesse du schéma (*flexible schema*) à partir de ces exemples ;
- préparer le **support de présentation du Projet 2**.

**Fichier attendu :** `P2_05_mises_a_jour_ABBO.js`, captures avant/après, diapositives.

> `[LOT M4]` — remplacer ce bloc par le contenu définitif.

---

## II.7 / C7-S7 — Suppression contrôlée du dossier de test — `[LOT M2]`

**Responsable : M2 — FADIMATOU** | **Relecteur : M5**

Contenu attendu :

- afficher le dossier de test **avant** suppression ;
- utiliser un filtre précis et `deleteOne` (jamais `deleteMany({})`) ;
- prouver que le dossier n'existe plus (`countDocuments` = 0) ;
- conserver les captures avant/après.

**Fichier attendu :** `P2_06_suppression_FADIMATOU.js`.

> `[LOT M2]` — remplacer ce bloc par le contenu définitif.

---

## II.8 / S8 — Comparaison document vs relationnel — `[LOT M3]`

**Responsable : M3 — ANTOINE** | **Relecteur : M1**

Produire un texte comparatif argumenté :

- intégration des informations dans un document vs stockage dans plusieurs tables relationnelles ;
- exemple de schéma relationnel équivalent (tables `etudiants`, `formations`, `pieces`, `certifications`, `stages`) ;
- avantages : lecture d'un dossier en une requête, absence de jointures, schéma flexible ;
- limites : redondance possible, validation applicative, transactions multi-documents, cohérence des données ;
- conclusion : cas où le document est adapté, cas où le relationnel reste préférable.

> `[LOT M3]` — remplacer ce bloc par le contenu définitif.

---

## II.8 / C8 — Vérification finale — `[VERIFICATION FINALE M1]`

**Responsable : M1 — GULLIT**

Le script `Projet2_MongoDB/scripts/P2_99_verification_GULLIT.js` exécute :

1. existence de la collection `etudiants` et `countDocuments()` ;
2. aperçu formaté et contrôle des champs optionnels (`pieces_justificatives`, `certifications`, `stages`) ;
3. agrégations par filière, par niveau et croisées ;
4. vérification que le dossier de test C7/S7 a bien été supprimé.

Exécution de référence :

```powershell
docker cp Projet2_MongoDB/scripts/P2_99_verification_GULLIT.js mongodb-tp:/tmp/P2_99_verification_GULLIT.js
docker exec -it mongodb-tp mongosh -u admin -p <MOT_DE_PASSE_MONGO> --authenticationDatabase admin --file /tmp/P2_99_verification_GULLIT.js
```

La capture de référence est `Projet2_MongoDB/captures/P2_99_verification_output.txt`. Au dernier passage, la collection `etudiants` était absente (lot M3 non encore livré) : le script a affiché « EN ATTENTE » et le contrôle C7/S7 a renvoyé 0 dossier restant.

> `[VERIFICATION FINALE M1]` — remplacer ce bloc par la sortie définitive après livraison des lots M3, M5, M2 et M4.

---

## IV. Conclusion du Projet 2

À compléter après la vérification finale : rappeler le nombre de documents, les champs hétérogènes observés, les opérations réalisées, les apports du modèle document pour les dossiers étudiants et les limites (validation, cohérence multi-documents, nécessité d'un identifiant métier stable).

---

## Annexes

| Annexe | Contenu | Emplacement |
|---|---|---|
| A | Fiche d'installation et de connexion C1 | `Projet2_MongoDB/rapport/P2_C1_installation_connexion_GULLIT.md` |
| B | Preuve de connexion | `Projet2_MongoDB/captures/P2_C1_connexion_output.txt` |
| C | Script de vérification C8 et capture | `Projet2_MongoDB/scripts/P2_99_verification_GULLIT.js`, `captures/P2_99_verification_output.txt` |
| D | Scripts des lots M3, M5, M2, M4 | À compléter par chaque membre |
| E | Captures mongosh / Compass | À compléter par chaque membre |
| F | Support de présentation | À préparer par M4 |

---

**Validation M1 :** modèle vérifié et prêt pour l'assemblage. Les balises `[LOT ...]` et `[VERIFICATION FINALE M1]` doivent être remplacées avant la remise finale.
