# RAPPORT FINAL — PROJET 3 : Analyse de données sous RStudio
## Groupe 2 — Module spécifique : Interprétation approfondie de l'ACP

**Niveau : ITT3-IR** | **Examinateur : M. SASSA Giquel** | **Équipe : 5 membres (M1 à M5)**  
**Version du modèle : 1.0 — 23/11/2026** | **Statut : modèle prêt à assembler**

| Code | Membre | Rôle permanent |
|---|---|---|
| **M1** | **KEUMEKA SOKING WILFRIED GULLIT** | **Chef d'équipe : coordination, mise en route, préparation A1-A2, assemblage** |
| M2 | FADIMATOU SAIDOU | Membre : réalisation technique + rédaction de sa partie |
| M3 | NGUEGNI ONGOLO ANTOINE | Membre : réalisation technique + rédaction de sa partie |
| M4 | ABBO ALKAMILA | Membre : réalisation technique + rédaction de sa partie |
| M5 | EVINA MBAHO ERIC | Membre : réalisation technique + rédaction de sa partie |

**Périmètre :** partie commune (mise en route §4 + questions A, B, C, D §5) + **module spécifique du Groupe 2 — Interprétation approfondie de l'ACP** (§6).  
**Livrables :** script R commenté, graphiques, réponses aux 23 questions, rapport, support de présentation (M3).

---

## Sommaire et répartition actualisée

| Section du sujet | Intitulé | Responsable | Emplacement |
|---|---|---|---|
| **1** | Contexte | M1 | Rédigé ci-dessous |
| **2** | Objectifs pédagogiques | M1 | Rédigé ci-dessous |
| **3** | Jeu de données commun | M1 | Rédigé ci-dessous |
| **4** | Mise en route dans RStudio (§4.1 à 4.4) | M1 | Rédigé ci-dessous |
| **5 — Partie A** | ACP normée (A1 à A7) | A1-A2 : M1 ; A3-A7 : M2 | A1-A2 rédigés ; `[LOT M2 - Partie A]` |
| **5 — Partie B** | AFC (B1 à B6) | M3 | `[LOT M3 - Partie B]` |
| **5 — Partie C** | ACP + intelligence artificielle (C1 à C5) | M4 | `[LOT M4 - Partie C + Module Spécifique G2 ACP approfondie]` |
| **5 — Partie D** | AFC + intelligence artificielle (D1 à D5) | M5 | `[LOT M5 - Partie D + Conclusion]` |
| **6** | Modules complémentaires spécifiques (Groupes 1 à 8) — Groupe 2 : Interprétation approfondie de l'ACP | M4, en binôme avec M2 | `[LOT M4 - Partie C + Module Spécifique G2 ACP approfondie]` |
| **7** | Conclusion générale | M5 | `[LOT M5 - Partie D + Conclusion]` |
| Annexes | Scripts, graphiques, captures | M1 | À compléter |

**Répartition actualisée (charge équilibrée) :**

| Membre | Projet 1 | Projet 2 | Projet 3 |
|---|---|---|---|
| M1 — GULLIT | Socle §1-3 + coordination | C1/C8 + introduction + coordination | §4 + A1-A2 + coordination |
| M2 — FADIMATOU | §4 privilèges + T6-T7 | C5/S5 + C7/S7 | Partie A (A3-A7) + binôme module G2 |
| M3 — ANTOINE | §5 pgvector + T8-T9 | C2/S1 + S3 + S8 | Partie B (B1-B6) + support P3 |
| M4 — ABBO | G2-T1 à T4 | S4 + C6/S6 + support P2 | Partie C (C1-C5) + **Module G2 ACP approfondie** |
| M5 — ERIC | G2-T5, T10 + test global + support P1 | C3/C4/S2 | Partie D (D1-D5) + conclusion |

---

## 1. Contexte

La société fictive **CamerDigital**, opérateur camerounais de services numériques, souhaite mieux comprendre les usages de ses clients. Elle veut identifier des profils de consommation, étudier les liens entre catégories socioprofessionnelles et satisfaction, puis utiliser les résultats pour améliorer ses offres. Le service d'analyse dispose d'un échantillon synthétique de **120 clients**. Les données sont fictives et conçues à des fins pédagogiques.

## 2. Objectifs pédagogiques

- importer et contrôler un jeu de données dans RStudio ;
- réaliser une **ACP normée** sur les variables quantitatives et interpréter axes, contributions et représentations ;
- réaliser une **AFC** à partir d'un tableau de contingence de variables qualitatives ;
- associer l'ACP à **K-means** pour regrouper les clients dans l'espace factoriel ;
- associer l'AFC à **K-means** pour regrouper les modalités représentées dans l'espace factoriel ;
- justifier les choix de préparation, de dimensionnement et d'interprétation, sans confondre association et causalité.

## 3. Jeu de données commun

Le fichier `jeu_donnees_clients_telecom.csv` contient **120 lignes et 12 colonnes**. Quelques valeurs manquantes ont été introduites volontairement pour l'exercice de contrôle qualité.

**Remarque méthodologique :** l'ACP est réalisée sur les variables quantitatives. L'AFC nécessite un tableau de contingence ; elle n'est pas appliquée directement à l'ensemble des colonnes mixtes. Le tableau principal croise `Categorie_socioprofessionnelle` et `Satisfaction`.

---

## 4. Mise en route dans RStudio (§4.1 à 4.4)

**Responsable : M1 — GULLIT**

Le script `Projet3_RStudio/scripts/P3_00_preparation_GULLIT.R` (équivalent de `00_preparation.R`) exécute l'importation, les contrôles et la préparation. Il est reproductible avec `set.seed(2026)`.

```r
donnees <- read.csv("jeu_donnees_clients_telecom.csv",
                    na.strings = c("", "NA"),
                    stringsAsFactors = FALSE)
dim(donnees); str(donnees); summary(donnees)
colSums(is.na(donnees)); sum(duplicated(donnees))
```

**Résultats exacts :**

| Contrôle | Résultat |
|---|---|
| Dimensions | **120 × 12** |
| Doublons | **0** |
| Valeurs manquantes | **6** |
| `Volume_donnees_Go_mois` | 2 NA → médiane **26,5** |
| `Depenses_FCFA_mois` | 2 NA → médiane **14 200** |
| `Nb_reclamations_mois` | 1 NA → médiane **1** |
| `Ville` | 1 NA → mode **Douala** (43/119) |
| Après imputation | **0 NA**, **120 lignes** |
| `X_quant` | **120 × 7** |

**Fichiers partagés :** `donnees_prep.rds`, `donnees_prep.csv`, `X_quant_prep.rds` (dans `Projet3_RStudio/scripts/`). La capture console est `Projet3_RStudio/captures/P3_00_preparation_output.txt`.

> **Point de vigilance :** une seule version de `donnees_prep` pour toute l'équipe, sinon les résultats des parties A à D ne concordent pas.

---

## 5. Questions communes obligatoires (à réaliser par les huit groupes)

### Partie A — ACP normée (A1 à A7)

#### A1-A2 — M1 (rédigés)

- **A1** : les 7 variables quantitatives retenues sont `Age`, `Anciennete_mois`, `Heures_connexion_jour`, `Volume_donnees_Go_mois`, `Depenses_FCFA_mois`, `Nb_services`, `Nb_reclamations_mois`. `ID_Client` et les 4 qualitatives sont exclues.
- **A2** : les 6 valeurs manquantes sont imputées par la **médiane** (quantitatives) et le **mode** (`Ville`), afin de préserver les 120 clients pour l'ACP, l'AFC et K-means. Justification détaillée dans `P3_A1_A2_preparation_GULLIT.md`.

#### A3-A7 — `[LOT M2 - Partie A]`

**Responsable : M2 — FADIMATOU SAIDOU** | **Relecteur : M4 — ABBO**

- **A3** : réaliser l'ACP normée et justifier le centrage-réduction ;
- **A4** : valeurs propres, variance expliquée, nombre d'axes retenus et justification ;
- **A5** : cercle des corrélations, contributions et cos² ;
- **A6** : projection des individus, oppositions entre profils ;
- **A7** : deux conclusions opérationnelles et leurs limites.

**Fichier attendu :** `P3_01_acp_FADIMATOU.R`, graphiques ACP, réponses A3-A7. Transmettre à M4 l'objet `res_acp` et le nombre d'axes retenus.

> `[LOT M2 - Partie A]` — remplacer ce bloc par le contenu définitif.

### Partie B — AFC (B1 à B6) — `[LOT M3 - Partie B]`

**Responsable : M3 — NGUEGNI ONGOLO ANTOINE** | **Relecteur : M5 — ERIC**

- **B1** : tableau de contingence `Categorie_socioprofessionnelle × Satisfaction` ;
- **B2** : profils lignes et colonnes, avec interprétation ;
- **B3** : AFC et examen de l'inertie expliquée ;
- **B4** : interprétation des axes et de la carte factorielle (associations et oppositions) ;
- **B5** : prise en compte des effectifs et de la qualité de représentation ;
- **B6** : conclusion prudente — une association n'est pas une causalité.

**Fichier attendu :** `P3_02_afc_ANTOINE.R`, graphiques AFC, réponses B1-B6, diapositives du Projet 3. Transmettre `res_afc` à M5.

> `[LOT M3 - Partie B]` — remplacer ce bloc par le contenu définitif.

### Partie C — ACP + intelligence artificielle (C1 à C5) — `[LOT M4 - Partie C + Module Spécifique G2 ACP approfondie]`

**Responsable : M4 — ABBO ALKAMILA** | **Relecteur : M2 — FADIMATOU**

- **C1** : extraire les coordonnées des clients sur les axes retenus par M2 ;
- **C2** : appliquer K-means avec plusieurs initialisations (`nstart`) ;
- **C3** : silhouette moyenne pour k de 2 à 6 et choix justifié de k ;
- **C4** : visualiser les groupes et comparer leurs moyennes sur les variables initiales ;
- **C5** : nommer les profils à partir des résultats uniquement (l'identifiant n'est jamais une variable).

**Fichier attendu :** `P3_03_acp_kmeans_ABBO.R`, graphiques, tableau des moyennes, réponses C1-C5.

> `[LOT M4 - Partie C + Module Spécifique G2 ACP approfondie]` — remplacer ce bloc par le contenu définitif.

### Partie D — AFC + intelligence artificielle (D1 à D5) — `[LOT M5 - Partie D + Conclusion]`

**Responsable : M5 — EVINA MBAHO ERIC** | **Relecteur : M3 — ANTOINE**

- **D1** : reprendre l'AFC de M3 ;
- **D2** : extraire les coordonnées des modalités-lignes (catégories socioprofessionnelles) ;
- **D3** : appliquer K-means et afficher le groupe de chaque catégorie ;
- **D4** : interpréter les regroupements en revenant au tableau de contingence ;
- **D5** : expliquer ce que l'algorithme apporte à l'AFC et ce qui est perdu en se limitant à deux axes.

**Fichier attendu :** `P3_04_afc_kmeans_ERIC.R`, graphiques, réponses D1-D5, conclusion générale.

> `[LOT M5 - Partie D + Conclusion]` — remplacer ce bloc par le contenu définitif.

---

## 6. Modules complémentaires spécifiques (Groupes 1 à 8) — Groupe 2 : Interprétation approfondie de l'ACP

**Responsable : M4 — ABBO ALKAMILA, en binôme avec M2 — FADIMATOU SAIDOU**  
**Dépendance :** `X_quant_prep.rds` + objet `res_acp` de la Partie A.  
**Emplacement :** `[LOT M4 - Partie C + Module Spécifique G2 ACP approfondie]`

Le module doit produire une lecture approfondie de l'ACP, au-delà du simple cercle des corrélations :

1. **Classement des contributions** : pour chaque variable et chaque dimension retenue, calculer `contrib = cos2 × 100 / somme_des_cos2_sur_la_dimension`, puis classer par ordre décroissant. Identifier les 3 variables qui structurent principalement chaque axe.
2. **Examen des cos² des variables** : qualifier la représentation de chaque variable sur chaque axe. Seuil robuste : `cos² > 0,5` ; zone prudente : `0,2 < cos² ≤ 0,5` ; au-delà de l'axe concerné, l'interprétation est écartée.
3. **Examen des cos² des individus** : repérer les clients les mieux représentés et ceux à interpréter avec réserve ; croiser avec `Ville` et `Type_abonnement` issus de `donnees_prep`.
4. **Interprétations robustes vs prudentes** : une lecture **robuste** s'appuie sur une contribution élevée **et** un `cos² > 0,5` ; une lecture **prudente** est formulée dès qu'un seul des deux critères est réuni, en mentionnant explicitement l'incertitude.
5. **Sensibilité à l'imputation** : signaler que 6 valeurs ont été imputées (5 quantitatives + 1 qualitative) et vérifier que les individus concernés ne sont pas systématiquement en tête des cos². Ajouter une phrase de mise en garde dans le rapport.

**Livrables attendus :** note d'interprétation, tableaux `contrib` et `cos2` (variables et individus), graphiques annotés, captures, paragraphe de synthèse prêt à insérer dans le rapport.

> `[LOT M4 - Partie C + Module Spécifique G2 ACP approfondie]` — remplacer ce bloc par le contenu définitif. M2 relit les calculs et la cohérence avec la Partie A.

---

## 7. Conclusion générale — `[LOT M5 - Partie D + Conclusion]`

**Responsable : M5 — ERIC** | **Relecteur : M3 — ANTOINE**

Synthèse des parties A à D :

- profils de consommation identifiés par l'ACP et K-means ;
- associations entre catégorie socioprofessionnelle et satisfaction (AFC), sans causalité ;
- apports et limites de la classification sur les coordonnées factorielles ;
- apports du module G2 (contributions, cos², robustesse) ;
- limites générales : taille de l'échantillon (n = 120), données synthétiques, valeurs imputées, réduction à deux axes.

> `[LOT M5 - Partie D + Conclusion]` — remplacer ce bloc par le contenu définitif.

---

## Annexes

| Annexe | Contenu | Emplacement |
|---|---|---|
| A | Script de préparation et capture | `Projet3_RStudio/scripts/P3_00_preparation_GULLIT.R`, `captures/P3_00_preparation_output.txt` |
| B | Jeu de données préparé | `Projet3_RStudio/scripts/donnees_prep.rds`, `donnees_prep.csv`, `X_quant_prep.rds` |
| C | Réponses A1-A2 et note de cadrage G2 | `Projet3_RStudio/rapport/P3_A1_A2_preparation_GULLIT.md` |
| D | Scripts et graphiques A, B, C, D | À compléter par M2, M3, M4, M5 |
| E | Support de présentation | À préparer par M3 |

---

**Validation M1 :** modèle vérifié et prêt pour l'assemblage. Les balises `[LOT M2 - Partie A]`, `[LOT M3 - Partie B]`, `[LOT M4 - Partie C + Module Spécifique G2 ACP approfondie]` et `[LOT M5 - Partie D + Conclusion]` doivent être remplacées avant la remise finale.
