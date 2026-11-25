# Projet 2 — Texte du lot M5 (à insérer dans le rapport final)

> **Destination :** remplacer la balise `> [LOT M5]` de la section **II.4 / C3-C4-S2**
> dans `RAPPORT_FINAL_P2_G5_MODELE.md`.
> **Responsable :** M5 — EVINA MBAHO ERIC · **Relecteur :** M4 — ABBO
> Ce fichier est livré séparément pour ne pas modifier le modèle de M1 :
> c'est le chef qui assure l'assemblage final.

---

## II.4 / C3-C4-S2 — Jeu de données, import et insertions

**Responsable : M5 — EVINA MBAHO ERIC** | **Relecteur : M4 — ABBO**

### 1. Principe de construction du jeu de données

Le jeu de données commun `donnees_etudiants.json` contient **5 dossiers étudiants**
(`ETU-2026-0001` à `ETU-2026-0005`). Il respecte **le contrat du document livré par
M3 dans `P2_01_structure_ANTOINE.js`**, seul référentiel technique validé pour la
création des données :

| Bloc | Champs utilisés | Remarque |
|---|---|---|
| Racine | `matricule` | identifiant lisible et unique, format `ETU-AAAA-NNNN` |
| `identite` | `nom`, `prenoms`, `date_naissance`, `sexe` | `prenoms` (au pluriel) et date en chaîne `AAAA-MM-JJ`, comme dans le schéma M3 |
| `formation` | `filiere`, `niveau`, `annee`, `ue` | tableau d'UE ; `niveau` dans l'énumération `L1…M2` |
| `coordonnees` | `email`, `telephone`, `adresse.{ville,quartier}` | sous-documents imbriqués |
| Optionnels | `certifications`, `stages`, `pieces_justificatives` | présents chez 2, 2 et 1 dossier(s) seulement, pour démontrer le schéma flexible (S4) |

> **Point d'attention pour l'assemblage :** le modèle descriptif du rapport final
> (rédigé par M1) mentionne `prenom`, `date_naissance` en `ISODate` et
> `adresse.code_postal`. Le script de M3, livré ensuite, utilise `prenoms`, une
> chaîne de date et `adresse.{ville,quartier}`. **M5 a suivi le script de M3**,
> conformément à la règle « le modèle validé par l'équipe prévaut ». M1 est invité
> à harmoniser la description du rapport lors de l'assemblage, sans modifier les
> données déjà insérées (le validateur `$jsonSchema` de M3 impose ces noms).

### 2. C3 — Import du jeu commun (`P2_02_import_ERIC.js`)

Le script :

1. sélectionne explicitement la base `universite_tp` (`db.getSiblingDB`) ;
2. contrôle que la collection `etudiants` existe (elle doit être créée par M3 avant) ;
3. lit `donnees_etudiants.json` avec `fs.readFileSync` + `EJSON.parse` ;
4. crée l'index unique `uniq_matricule` sur `matricule` ;
5. **remplace uniquement les 5 matricules du jeu** (`deleteMany` avec filtre précis,
   jamais `deleteMany({})`) puis `insertMany(documents, { ordered: true })` ;
6. affiche les comptages, deux extraits et la répartition des champs optionnels.

Le script est donc **rejouable** : un second passage redonne exactement 5 documents.

### 3. S2 / C4 — Insertion individuelle (`P2_03_insertions_ERIC.js`)

Pour satisfaire l'exigence « deux insertions démontrées séparément », le dossier
de test est inséré avec `insertOne`, après `deleteOne({ matricule: "ETU-2026-9999" })` :

| Propriété | Valeur |
|---|---|
| `matricule` | `ETU-2026-9999` |
| `identite.nom` | `DOSSIER_TEST_SUPPRESSION` |
| `coordonnees.email` | `test.suppression@universite.local` |

Ce dossier est volontairement **disponible pour la suppression contrôlée C7/S7 de
M2**. Le filtre à utiliser est `{ matricule: "ETU-2026-9999" }`.

> **Avertissement transmis à M1 et M2 :** le script de vérification C8 de M1
> (`P2_99_verification_GULLIT.js`) cherche encore
> `{ email: EMAIL_TEST }` / `{ nom: NOM_TEST }` au niveau racine et le libellé
> `TEST-C7-S7`, alors que le validateur de M3 impose le format `ETU-AAAA-NNNN` et
> que les champs sont imbriqués. Le dossier de test créé ici est conçu pour être
> trouvé avec les trois chemins : `matricule`, `identite.nom` et
> `coordonnees.email`.

### 4. Résultats observés (exécution réelle)

Capture : `captures/P2_M5_import_insertions_output.txt`
(serveur MongoDB local 7.0.5 — environnement précisé pour la soutenance).

| Étape | Commande clé | Résultat |
|---|---|---|
| Import commun | `insertMany` | **5** documents insérés |
| Comptage après import | `countDocuments({})` | **5** |
| Dossier de test | `insertOne` | 1 document, `_id` généré |
| Comptage après test | `countDocuments({})` | **6** |
| Hétérogénéité | `certifications` / `stages` / `pieces_justificatives` | 2 / 2 / 1 dossier(s) |
| Unicité | `createIndex({matricule:1},{unique:true})` | index `uniq_matricule` créé |

### 5. Relecture demandée à M4

M4 est invité à (a) rejouer `P2_02` puis `P2_03` sur une base `universite_tp` vidée,
(b) vérifier que le second passage de `P2_02` laisse 5 documents et non 10,
(c) confirmer que le dossier `ETU-2026-9999` est bien supprimable par M2 avec le
filtre indiqué, puis (d) vérifier que ses propres mises à jour S4/C6/S6 fonctionnent
sur les champs optionnels laissés absents chez 3 dossiers.

---

**Fichiers livrés par M5 :**
`scripts/donnees_etudiants.json`, `scripts/P2_02_import_ERIC.js`,
`scripts/P2_03_insertions_ERIC.js`,
`captures/P2_M5_import_insertions_output.txt`,
`rapport/P2_LOT_M5_ERIC.md`.
