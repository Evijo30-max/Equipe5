# Recueil des Projets Académiques ITT3-IR

**Examinateur : M. SASSA Giquel**  
**Niveau : ITT3-IR**  
**Équipe 5 — 5 membres**

| Code | Membre | Rôle permanent |
|---|---|---|
| **M1** | **KEUMEKA SOKING WILFRIED GULLIT** | **Chef d'équipe : coordination, socles techniques, intégration et assemblage final des rapports** |
| M2 | FADIMATOU SAIDOU | Membre : réalisation technique + rédaction de sa partie |
| M3 | NGUEGNI ONGOLO ANTOINE | Membre : réalisation technique + rédaction de sa partie |
| M4 | ABBO ALKAMILA | Membre : réalisation technique + rédaction de sa partie |
| M5 | EVINA MBAHO ERIC | Membre : réalisation technique + rédaction de sa partie |

---

## Architecture officielle du dépôt

Chaque projet suit exactement la même arborescence de référence :

```text
Equipe5_repo/
├── .gitignore
├── README.md
├── Projet1_PostgreSQL/
│   ├── scripts/
│   ├── captures/
│   ├── rapport/
│   └── presentation/
├── Projet2_MongoDB/
│   ├── scripts/
│   ├── captures/
│   ├── rapport/
│   └── presentation/
└── Projet3_RStudio/
    ├── scripts/
    ├── captures/
    ├── rapport/
    └── presentation/
```

- `scripts/` : scripts commentés (`.sql`, `.js`, `.R`) et fichiers de données préparés.
- `captures/` : preuves d'exécution (mongosh, psql, console R, graphiques).
- `rapport/` : textes rédigés, réponses aux questions et modèles de rapports finaux.
- `presentation/` : supports de soutenance (présents via `.gitkeep` tant qu'ils sont vides).

> Le kit de partage WhatsApp (`KIT_PARTAGE_EQUIPE/`) est diffusé **hors du dépôt Git** : il ne doit pas être versionné.

---

## Répartition officielle des tâches

| Membre | Projet 1 — PostgreSQL + pgvector | Projet 2 — MongoDB | Projet 3 — RStudio |
|---|---|---|---|
| **M1 — GULLIT** | Socle §1-3 : base `entreprise_tp`, 6 tables, données, schéma relationnel (§2.7) ; coordination et assemblage | C1 environnement/connexion, introduction, C8 vérification finale, assemblage | §4 mise en route + préparation des données (A1-A2) ; coordination et assemblage |
| **M2 — FADIMATOU** | §4 rôles/privilèges + G2-T6/T7 (jointures, sous-requête) | C5/S5 consultations, recherche par filière, agrégation ; C7/S7 suppression contrôlée | Partie A — ACP normée A3-A7 ; **binôme du module G2 avec M4** |
| **M3 — ANTOINE** | §5 pgvector + 8 questions + G2-T8/T9 (recherche vectorielle et stocks) | C2/S1 base et collection, S3 modèle du document, S8 comparaison document/relationnel | Partie B — AFC B1-B6 ; support de présentation |
| **M4 — ABBO** | G2-T1 à T4 : déclencheurs de gestion des stocks | S4 champs hétérogènes, C6/S6 mises à jour ; support de présentation | Partie C — ACP + K-means C1-C5 ; **Module Spécifique Groupe 2 : Interprétation approfondie de l'ACP** |
| **M5 — ERIC** | G2-T5 tests transactionnels, T10, test global ; support de présentation | C3/C4/S2 jeu de données, import, insertions | Partie D — AFC + K-means D1-D5 ; conclusion générale |

### Module Spécifique Groupe 2 — Projet 3

Responsable : **M4 — ABBO**, en binôme relecture avec **M2 — FADIMATOU**.

- Classer les variables selon leur contribution aux axes retenus.
- Examiner les `cos2` des variables et des individus.
- Distinguer les interprétations **robustes** (`cos² > 0,5` + contribution élevée) des interprétations **prudentes** (`0,2 < cos² ≤ 0,5`).
- Signaler la sensibilité aux 6 valeurs imputées lors de la préparation A2.

---

## Règles de nommage et de livrable

- Format obligatoire : `P<n°>_<numéro>_<sujet>_<NOM>`
  - Exemples : `P1_04_triggers_stock_ABBO.sql`, `P2_01_structure_ANTOINE.js`, `P3_03_acp_kmeans_ABBO.R`
- Captures : nommées selon la tâche du sujet, par exemple `P1_G2-T4_stock_negatif.png`.
- Chaque lot doit contenir : **(1)** un script commenté, **(2)** les captures de résultat, **(3)** le texte rédigé avec les réponses aux questions.
- RStudio : une seule version de `donnees_prep` pour toute l'équipe et `set.seed(2026)` avant chaque K-means.
- MongoDB : ne jamais lancer `deleteMany({})` ; toujours un filtre précis sur le dossier de test.

---

## Ordre d'exécution des socles

1. **`Projet1_PostgreSQL/scripts/P1_01_socle_GULLIT.sql`** — à exécuter **en premier par tous** : création de `entreprise_tp`, des 6 tables, des contraintes et des données initiales (5 / 4 / 5 / 5 / 10 / 5).
2. **`Projet2_MongoDB/rapport/P2_C1_installation_connexion_GULLIT.md`** — installer MongoDB/mongosh/Compass et se connecter. **M3 valide le modèle du document à M5 avant la création des données.**
3. **`Projet3_RStudio/scripts/P3_00_preparation_GULLIT.R`** — import, contrôle qualité et imputation. Produit **`donnees_prep.rds`** (jeu préparé 120 × 12), `donnees_prep.csv` et `X_quant_prep.rds` (120 × 7). Une seule version de `donnees_prep.rds` doit circuler dans l'équipe.
4. Les lots M2/M3/M4/M5 sont ensuite réalisés en parallèle selon les dépendances : `res_acp` de M2 vers M4, `res_afc` de M3 vers M5.
5. `Projet2_MongoDB/scripts/P2_99_verification_GULLIT.js` (C8) est exécuté par M1 après livraison des lots MongoDB.

> Les identifiants de TP ne sont **jamais versionnés** : ils sont injectés via variables d'environnement (`MONGO_ROOT_PASSWORD`, `PGPASSWORD`) ou saisis localement. Voir la section Sécurité.

---

## Binômes de relecture croisée

Le relecteur rejoue le script et vérifie les captures avant l'assemblage.

| Projet | Relectures |
|---|---|
| **Projet 1 — PostgreSQL** | M5 relit M1 · M3 relit M2 · M2 relit M3 · M5 relit M4 · M4 relit M5 |
| **Projet 2 — MongoDB** | M2 relit M1 · M5 relit M2 · M1 relit M3 · M3 relit M4 · M4 relit M5 |
| **Projet 3 — RStudio** | M2 relit M1 · M4 relit M2 · M5 relit M3 · M2 relit M4 · M3 relit M5 |

M1 assure la relecture finale et l'assemblage des trois rapports.

---

## Règles d'équipe (conservées du README initial de M5-Eric)

- Aucun fichier généré par IA n'est accepté sans relecture et compréhension par son responsable.
- Chaque membre doit pouvoir expliquer **tout** le projet à la soutenance, pas seulement sa partie.
- Relecture croisée obligatoire avant assemblage.
- Point d'avancement court tous les 2 jours ; tout blocage est signalé au chef d'équipe dans la journée.
- Répétition générale avant chaque soutenance.

---

## Historique et sécurité

- Les commits d'initialisation de **M5-Eric** sont conservés dans l'historique Git (`d97f9d4` pour `.gitignore`, `de3d94e` pour la première structure de README).
- `.gitignore` est conservé tel qu'il a été livré par M5 (ignore `.env`, `*.log`, `.RData`, etc.).
- **Aucun mot de passe n'est présent dans le dépôt.** Les commandes d'exemple utilisent des placeholders (`<MOT_DE_PASSE_MONGO>`, `<MOT_DE_PASSE_POSTGRES_LOCAL>`). Chaque membre doit renseigner ces valeurs localement via variables d'environnement, puis les partager uniquement par le canal sécurisé de l'équipe.
