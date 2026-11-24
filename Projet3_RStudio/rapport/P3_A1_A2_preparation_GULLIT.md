# Projet 3 — Préparation des données : réponses A1-A2 et plan d'intégration Groupe 2

**ITT3-IR — Groupe 2 — Rôle M1 Chef d'équipe : KEUMEKA SOKING WILFRIED GULLIT**

> Toutes les valeurs chiffrées ci-dessous proviennent de l'exécution réelle de `P3_00_preparation_GULLIT.R` dans le conteneur `rstudio-tp` (R 4.6.2), le 22/11/2026. Graine de reproductibilité : `set.seed(2026)`.

---

## Rappel du diagnostic initial (§4.1-4.4)

| Contrôle | Résultat exact |
|---|---|
| Fichier importé | `jeu_donnees_clients_telecom.csv`, `na.strings = c("", "NA")`, `stringsAsFactors = FALSE` |
| `dim(donnees)` | **120 × 12** (120 clients, 12 colonnes) |
| Types | `ID_Client` et 4 qualitatives en `chr` ; `Age`, `Anciennete_mois`, `Nb_services` en `int` ; 4 variables en `num` |
| `sum(duplicated(donnees))` | **0** doublon |
| Total `colSums(is.na(donnees))` | **6** valeurs manquantes |
| `dim(X_quant)` après préparation | **120 × 7** |

Statistiques descriptives des 7 variables quantitatives (extrait de `summary()`) :

| Variable | Min | 1ᵉʳ quartile | Médiane | Moyenne | 3ᵉ quartile | Max | NA |
|---|---:|---:|---:|---:|---:|---:|---:|
| `Age` | 18,00 | 24,00 | 33,00 | 32,91 | 40,25 | 57,00 | 0 |
| `Anciennete_mois` | 5,00 | 18,75 | 29,00 | 31,52 | 39,25 | 81,00 | 0 |
| `Heures_connexion_jour` | 0,300 | 2,275 | 3,100 | 3,296 | 4,600 | 7,300 | 0 |
| `Volume_donnees_Go_mois` | 1,00 | 15,55 | 26,50 | 28,31 | 38,50 | 73,40 | **2** |
| `Depenses_FCFA_mois` | 4 100 | 10 300 | 14 200 | 14 144 | 17 750 | 25 100 | **2** |
| `Nb_services` | 1,000 | 2,000 | 3,000 | 2,542 | 3,000 | 5,000 | 0 |
| `Nb_reclamations_mois` | 0,0000 | 0,0000 | 1,0000 | 0,9328 | 1,0000 | 5,0000 | **1** |

---

## Question A1 — Sélection explicite des variables quantitatives

La sélection est **explicite et nommée** dans le script : aucune sélection par position (`[, 2:8]`) n'est utilisée, ce qui protège le traitement contre un réordonnancement ultérieur des colonnes du CSV.

```r
vars_identifiant   <- c("ID_Client")
vars_qualitatives  <- c("Ville", "Categorie_socioprofessionnelle",
                        "Type_abonnement", "Satisfaction")
vars_quantitatives <- c("Age", "Anciennete_mois", "Heures_connexion_jour",
                        "Volume_donnees_Go_mois", "Depenses_FCFA_mois",
                        "Nb_services", "Nb_reclamations_mois")
```

**Réponse A1 :** les **7 variables quantitatives** retenues pour l'ACP et le K-means sont donc `Age`, `Anciennete_mois`, `Heures_connexion_jour`, `Volume_donnees_Go_mois`, `Depenses_FCFA_mois`, `Nb_services` et `Nb_reclamations_mois`.

**Exclusions justifiées :**

- `ID_Client` est un identifiant technique (`CL001` … `CL120`). Le inclure dans une ACP reviendrait à introduire une variable catégorielle sans signification métrique et à créer un axe artificiel lié à l'ordre de saisie.
- `Ville`, `Categorie_socioprofessionnelle`, `Type_abonnement` et `Satisfaction` sont qualitatives ; elles relèvent de l'**AFC** (analyse des correspondances) et des tris croisés, pas de l'ACP. Elles sont conservées dans `donnees_prep` pour ces usages.
- La vérification `setequal(names(donnees), c(identifiant, quantitatives, qualitatives))` renvoie **TRUE** (12 colonnes exactement), contrôle renforcé par un `stopifnot`.

La matrice exportée `X_quant_prep.rds` a pour dimensions **120 × 7** et conserve les noms de colonnes.

---

## Question A2 — Contrôle et imputation des 6 valeurs manquantes

### A2.1 État avant imputation (attendu vs observé)

| Variable | Attendu | Observé | Méthode retenue |
|---|---:|---:|---|
| `Volume_donnees_Go_mois` | 2 | **2** | Médiane |
| `Depenses_FCFA_mois` | 2 | **2** | Médiane |
| `Nb_reclamations_mois` | 1 | **1** | Médiane |
| `Ville` | 1 | **1** | Mode |
| **Total** | **6** | **6** | — |

Le script vérifie chaque compte par `stopifnot(all(na_par_colonne[names(na_attendu)] == na_attendu))` puis `stopifnot(sum(na_par_colonne) == 6)`. Les 6 valeurs sont donc parfaitement conformes à l'énoncé.

### A2.2 Imputation par la médiane (variables quantitatives)

| Variable | Valeur de médiane utilisée | NA imputés |
|---|---:|---:|
| `Volume_donnees_Go_mois` | **26,5 Go** | 2 |
| `Depenses_FCFA_mois` | **14 200 FCFA** | 2 |
| `Nb_reclamations_mois` | **1** réclamation | 1 |

**Justification méthodologique.** La médiane est un estimateur **robuste aux valeurs extrêmes** : le jeu de données présente des étendues larges (jusqu'à 73,4 Go et 25 100 FCFA), et la moyenne serait davantage attirée par ces queues de distribution. Elle préserve la tendance centrale observée et n'invente pas de valeur hors de l'échelle réelle. Surtout, elle garantit le **maintien des 120 clients** : l'ACP (FactoMineR) et le K-means (cluster) exigent une matrice complète ; supprimer les 5 lignes concernées réduirait l'échantillon à 115 (soit **−4,2 %**) et retirerait précisément des profils à forte consommation, donc un biais de sélection.

### A2.3 Imputation par le mode (variable qualitative `Ville`)

- Modalité la plus fréquente : **Douala**, avec **43 occurrences sur 119** valeurs renseignées.
- 1 `NA` imputé par `Douala` → **0 NA** après traitement.

**Justification.** Le mode respecte la distribution catégorielle existante. Créer une modalité artificielle de type `Inconnu` introduirait une catégorie supplémentaire dans l'AFC et fausserait les tris croisés (`Ville × Type_abonnement`, `Ville × Satisfaction`). La suppression de la ligne serait ici encore plus coûteuse : elle amputerait l'AFC d'un individu pour une seule donnée manquante.

### A2.4 Contrôle final

| Indicateur | Avant | Après |
|---|---:|---:|
| Dimensions | 120 × 12 | **120 × 12** |
| `sum(is.na(donnees_prep))` | 6 | **0** |
| Lignes conservées | 120 | **120** |

`stopifnot(sum(is.na(donnees_prep)) == 0L)` et `stopifnot(nrow(donnees_prep) == 120L)` sont validés. Le résultat affiché est : `RESULTAT A2 : OK - 0 valeur manquante, 120 clients conserves.`

### A2.5 Livrables de préparation (échanges inter-équipes)

| Fichier | Taille | Usage |
|---|---:|---|
| `scripts/donnees_prep.rds` | 2 547 octets | Jeu complet nettoyé, relecture R rapide |
| `scripts/donnees_prep.csv` | 9 401 octets | Échange avec M2, M3, M4, M5 (outils non-R) |
| `scripts/X_quant_prep.rds` | 1 675 octets | Matrice 120 × 7 pour ACP / K-means |
| `captures/P3_00_preparation_output.txt` | 7 184 octets | Preuve d'exécution console |

Les empreintes SHA-256 des trois fichiers générés ont été comparées avec succès entre le conteneur `rstudio-tp` et le poste Windows (par exemple `donnees_prep.rds` : `d652458128e21680364a93c59a08b72064d8800afe204ab760492cb1ff268be3`).

---

## Note de cadrage — Intégration du périmètre du Groupe 2 dans la planification

### Nouveau module ajouté au lot de production

| Module | Intitulé | Responsable | Binôme | Dépendance | Livrable attendu |
|---|---|---|---|---|---|
| **G2-ACP+** | **Interprétation approfondie de l'ACP** : classement des contributions, examen des $\cos^2$ variables/individus, interprétations robustes vs prudentes | **M4-Abbo** | **M2-Fadimatou** | `X_quant_prep.rds` (ce script P3-00) | Note d'interprétation + tableaux `contrib` / `cos2` + captures |

### Contenu précis du module G2-ACP+

1. **Classement des contributions** : pour chaque variable et chaque dimension (Dim1, Dim2), calculer `contrib = cos2 × 100 / somme_des_cos2_sur_la_dimension`, puis trier par ordre décroissant. Identifier les 3 variables qui structurent principalement chaque axe.
2. **Examen des $\cos^2$** :
   - **variables** : qualité de représentation sur un axe ; seuil robuste retenu $\cos^2 > 0,5$, zone prudente $0,2 < \cos^2 \le 0,5$, au-delà de l'axe concerné l'interprétation est écartée ;
   - **individus** : repérer les clients les mieux représentés (par ex. `CL__`) et ceux à interpréter avec réserve ; croiser avec `Ville` et `Type_abonnement` issus de `donnees_prep`.
3. **Interprétations robustes vs prudentes** : rédiger deux niveaux de lecture. Une interprétation **robuste** s'appuie sur une contribution élevée **et** un $\cos^2 > 0,5$ ; une interprétation **prudente** est formulée dès qu'un seul des deux critères est réuni, en mentionnant explicitement l'incertitude.
4. **Sensibilité à l'imputation** : signaler que 6 valeurs (5 quantitatives + 1 qualitative) ont été imputées ; vérifier que les individus correspondants ne sont pas systématiquement en tête des $\cos^2$ et ajouter une phrase de mise en garde dans le rapport.

### Planning récapitulatif (jalons)

| Jalon | Responsable | Dépendance | Statut |
|---|---|---|---|
| J1 — Préparation A1/A2, export `X_quant_prep.rds` | **M1-Gullit** | CSV du groupe | ✅ Livré (ce rapport + P3-00) |
| J2 — ACP/FactoMineR + K-means de base | M2-Fadimatou | J1 | À lancer |
| J3 — **Interprétation approfondie ACP (G2-ACP+)** | **M4-Abbo** (binôme M2-Fadimatou) | J1 + J2 | **Nouveau module intégré** |
| J4 — AFC / tris croisés sur `donnees_prep` | M5 | J1 | À lancer |
| J5 — Arbre de décision `rpart` (cible `Satisfaction`) | M3-Antoine | J1 | À coordonner avec le lot MongoDB |
| J6 — Consolidation rapport, relecture croisée | **M1-Gullit** | J2 → J5 | À programmer |

**Rôle de M1 :** je fournis le jeu nettoyé et la matrice quantitative, je verrouille la graine `2026`, je relis les tableaux de contributions/cos² produits par M4-Abbo et M2-Fadimatou, et j'archive toutes les captures dans `Projet3_RStudio/captures/`. Le module G2-ACP+ est désormais inscrit comme dépendance directe du jalon J1 et ne bloque pas le démarrage parallèle de J2 et J4.
