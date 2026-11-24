# S8 — Comparaison document vs relationnel

> Texte à insérer dans le rapport final du projet 2.
> Responsable : M3 — NGUEGNI ONGOLO ANTOINE

## 1. Le dossier étudiant en un document MongoDB

Un étudiant (ex. Sylvie MBARGA, matricule `ETU-2026-0001`) est stocké en
**un seul document** :

```json
{
  "_id": "ETU-2026-0001",
  "matricule": "ETU-2026-0001",
  "identite":    { "nom": "MBARGA", "prenoms": "Sylvie", "date_naissance": "2003-05-12", "sexe": "F" },
  "formation":   { "filiere": "Informatique", "niveau": "L3", "annee": "2025-2026",
                   "ue": ["BDD NoSQL", "IA", "Réseaux"] },
  "coordonnees": { "email": "sylvie.mbarga@etu.univ.cm", "telephone": "+237 690 11 22 33" },
  "certifications": [
    { "nom": "Certification CCNA", "date_obtention": "2025-07-01" }
  ],
  "stages": [
    { "entreprise": "CamerDigital", "periode": "2024-2025", "statut": "termine" }
  ],
  "pieces_justificatives": [
    { "type": "bulletin_semestre_1", "date_depot": "2025-10-15" }
  ]
}
```

**Lecture** : `db.etudiants.findOne({ matricule: "ETU-2026-0001" })`
→ **une seule requête**, tout le dossier est renvoyé.

## 2. Le même dossier en base relationnelle

Le schéma équivalent :

```sql
CREATE TABLE etudiants (
    matricule CHAR(15) PRIMARY KEY,
    nom         VARCHAR(50),
    prenoms     VARCHAR(50),
    sexe        CHAR(1),
    date_naissance DATE,
    email       VARCHAR(150),
    telephone   VARCHAR(30),
    id_filiere  INTEGER NOT NULL REFERENCES filieres(id_filiere)
);
CREATE TABLE filieres (
    id_filiere INTEGER PRIMARY KEY,
    nom        VARCHAR(50),
    niveau     CHAR(3),
    annee      VARCHAR(10),
    ue         TEXT          -- ou une autre table
);
CREATE TABLE certifications (
    id_certif INTEGER PRIMARY KEY,
    matricule CHAR(15) REFERENCES etudiants(matricule),
    nom       VARCHAR(100),
    date_obtention DATE
);
CREATE TABLE stages (
    id_stage INTEGER PRIMARY KEY,
    matricule CHAR(15) REFERENCES etudiants(matricule),
    entreprise VARCHAR(100),
    periode    VARCHAR(20),
    statut     VARCHAR(20)
);
CREATE TABLE pieces_justificatives (
    id_pj INTEGER PRIMARY KEY,
    matricule CHAR(15) REFERENCES etudiants(matricule),
    type    VARCHAR(50),
    date_depot DATE
);
```

**Lecture** : pour afficher le même dossier :

```sql
SELECT e.*, f.nom AS filiere, c.* AS certifs, s.* AS stages, pj.* AS pj
FROM etudiants e
JOIN filieres f ON e.id_filiere = f.id_filiere
LEFT JOIN certifications c   ON e.matricule = c.matricule
LEFT JOIN stages s           ON e.matricule = s.matricule
LEFT JOIN pieces_justificatives pj ON e.matricule = pj.matricule
WHERE e.matricule = 'ETU-2026-0001';
```

→ **5 tables, 4 JOIN** (dont 3 optionnelles via `LEFT JOIN`).

## 3. Avantages du modèle document

| Critère | Document (MongoDB) | Relationnel |
|---|---|---|
| Requête pour un dossier complet | `findOne` | `SELECT … JOIN × 4` |
| Ajouter un champ hétérogène (ex. `langues`) | Ajouter le champ au document | `ALTER TABLE` + migration |
| Hétérogénéité (certains étudiants ont des certifications, d'autres non) | Champ absent | Colonnes `NULL` |
| Lecture atomique | Le document est atomique | Plusieurs tables, risque d'incohérence transitoire |
| Import / migration | `insertMany` d'un JSON | `INSERT` par table |
| Schéma rigide | Flexible (optionnel) | Strict (contraintes) |

## 4. Limites du modèle document

- **Pas d'intégrité referentielle forte** : un `certifications.matricule`
  peut pointer vers un étudiant qui n'existe pas (pas de `FOREIGN KEY`).
  La cohérence se fait par application, pas par SGBD.
- **Mises à jour inter-tables** : si l'on change le nom d'une filière,
  il faut parcourir tous les documents (pas de `UPDATE` sur une clé
  étrangère).
- **Agrégations complexes** (multi-tables, sous-requêtes) : le pipeline
  `$lookup` existe mais est moins lisible que le SQL.
- **Transactionalité** : les transactions multi-documents existent depuis
  MongoDB 4.0 mais sont plus coûteuses que les transactions relationnelles.
- **Schéma rigide manquant** : on peut avoir des incohérences entre
  documents (ex. certains ont `formation.filiere`, d'autres non) — le
  `$jsonSchema` de M3 corrige ce défaut pour les champs obligatoires.

## 5. Conclusion

Pour le dossier étudiant, **le modèle document est plus adapté** car :

- le dossier est **atomique** (on veut le lire d'un coup),
- les informations sont **hétérogènes** (champs optionnels S4),
- les jointures relationnelles seraient coûteuses et peu lisibles.

La **souplesse du schéma** permet d'ajouter des types de documents
sans migration. Le `$jsonSchema` de M3 garantit les champs
obligatoires. Les limites (intégrité referentielle, transactions
longues) sont acceptables pour ce type de données « document »
à usage de consultation, pas de comptabilité stricte.

> À insérer dans la section S8 du rapport final du projet 2.

