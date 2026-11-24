#!/usr/bin/env Rscript
# ============================================================
# P3_02_afc.R
# Projet 3 — RStudio (Partie B : AFC) — ITT3-IR
#
# Tâches : B1 (tableau de contingence), B2 (profils lignes/colonnes),
#          B3 (AFC + inertie), B4 (interprétation des axes et carte
#          factorielle), B5 (effectifs + qualité de représentation),
#          B6 (conclusion prudente — association ≠ causalité)
#
# Responsable : M3 — NGUEGNI ONGOLO ANTOINE
# Pré-requis :
#   - M1 a livré `donnees_prep.rds` (120 clients CamerDigital).
#   - Les packages `FactoMineR`, `factoextra` sont installés.
#
# Ordre d'exécution :
#   1. Charger donnees_prep.rds (fourni par M1).
#   2. Exécuter ce script.
#   3. Produire les graphiques demandés + les réponses B1-B6.
# ============================================================

suppressPackageStartupMessages({
  library(FactoMineR)
  library(factoextra)
  library(dplyr)
})

# ------------------------------------------------------------
# 0. Charger les données préparées
# ------------------------------------------------------------
donnees_prep <- readRDS("donnees_prep.rds")
cat("\n=== P3_02_afc.R — AFC (Categorie_socioprofessionnelle x Satisfaction) ===\n")
cat("Lignes de donnees_prep :", nrow(donnees_prep), "\n")
str(donnees_prep)

# Vérifier que les deux variables qualitatives existent
stopifnot("Categorie_socioprofessionnelle" %in% names(donnees_prep))
stopifnot("Satisfaction" %in% names(donnees_prep))

# Forcer les variables en facteur (ordre des niveaux)
donnees_prep$Categorie_socioprofessionnelle <-
  as.factor(donnees_prep$Categorie_socioprofessionnelle)
donnees_prep$Satisfaction <-
  as.factor(donnees_prep$Satisfaction)

# ============================================================
# B1 — Tableau de contingence
# ============================================================
tab_afc <- table(donnees_prep$Categorie_socioprofessionnelle,
                 donnees_prep$Satisfaction)

cat("\n--- B1 — Tableau de contingence ---\n")
print(tab_afc)

# [CAPTURE] P3_B1_tableau_contingence.png
# (À prendre via capture de l'environnement global de RStudio, ou
#  via `png("P3_B1_tableau_contingence.png", width=700, height=400);
#   print(tab_afc); dev.off()`)

# ============================================================
# B2 — Profils lignes et colonnes
# ============================================================
# Profils LIGNES : répartition de la variable Satisfaction à
# l'intérieur de chaque catégorie socioprofessionnelle.
profils_lignes <- prop.table(tab_afc, margin = 1)

# Profils COLONNES : répartition des catégories socioprofessionnelles
# à l'intérieur de chaque niveau de Satisfaction.
profils_colonnes <- prop.table(tab_afc, margin = 2)

cat("\n--- B2 — Profils LIGNES (par catégorie) ---\n")
print(round(profils_lignes * 100, 1))
cat("\n--- B2 — Profils COLONNES (par satisfaction) ---\n")
print(round(profils_colonnes * 100, 1))

# [CAPTURE] P3_B2_profils.png

# ------------------------------------------------------------
# INTERPRÉTATION B2 (rédiger dans le rapport)
# ------------------------------------------------------------
# Les profils lignes répondent à : « Pour chaque catégorie
# socioprofessionnelle, quelle est la répartition des réponses de
# satisfaction ? ». Ils sont comparables entre catégories si leurs
# effectifs marginaux sont de même ordre ; sinon, une catégorie
# minoritaire peut sembler « tout satisfaire » par le simple effet
# de taille.
#
# Les profils colonnes répondent à : « Pour chaque niveau de
# satisfaction, quelle est la répartition des catégories
# socioprofessionnelles ? ». Ils permettent de voir quelle
# catégorie prédomine dans les satisfaits / insatisfaits.

# ============================================================
# B3 — AFC : réaliser et examiner l'inertie expliquée
# ============================================================
res_afc <- CA(tab_afc, graph = FALSE)

cat("\n--- B3 — Valeurs propres et inertie expliquée ---\n")
print(res_afc$eig)
print(round(res_afc$eig[1:2, ], 4))  # les 2 premiers axes

# [CAPTURE] P3_B3_eig.png (print(res_afc$eig) ou fviz_eig(res_afc))
# Le graphique fviz_eig est demandé par le sujet :
fviz_eig(res_afc, choices = 1:2, mini.hist = TRUE,
         title = "B3 — AFC : valeurs propres (inertie expliquée)")

# [CAPTURE] P3_B3_viz_eig.png
# (Dans RStudio : enregistrer le graphique avec « Enregistrer »)

# ------------------------------------------------------------
# INTERPRÉTATION B3
# ------------------------------------------------------------
# L'inertie totale est de 1 (par construction de l'AFC).
# L'inertie expliquée par le premier axe est la plus grande des
# valeurs propres ; c'est le pourcentage de la variance
# (inertie) du tableau qu'un seul axe peut représenter.
#
# Règle usuelle : retenir les axes dont la valeur propre dépasse
# 1/n (n = nombre de modalités) et/ou dont le cumulé atteint 70-80 %
# de l'inertie totale. Avec peu de modalités, un ou deux axes
# suffisent souvent.

# ============================================================
# B4 — Interprétation des axes et carte factorielle
# ============================================================
# Biplot : modalités lignes (catégories) et modalités colonnes
# (niveaux de satisfaction) sur les 2 premiers axes.
p_biplot <- fviz_ca_biplot(res_afc,
                            row lab = "left",
                            col.label = "right",
                            repel = TRUE,
                            ellipse = TRUE,
                            title = "B4 — AFC : carte factorielle")
print(p_biplot)

# [CAPTURE] P3_B4_biplot.png

# ------------------------------------------------------------
# INTERPRÉTATION B4 (rédiger dans le rapport)
# ------------------------------------------------------------
# - Proximité : deux modalités proches dans le biplot sont
#   statistiquement associées (leur co-occurrence dépasse le hasard).
# - Opposition : deux modalités situées de part et d'autre de
#   l'origine (sur un même axe) sont opposées.
# - L'angle entre deux points mesure leur association : petit angle
#   = forte association ; angle droit = indépendance ; grand angle
#   = forte opposition.
#
# À écrire dans le rapport :
#   - Quel axe 1 oppose quelles modalités (ex. « satisfaits » vs
#     « insatisfaits ») ?
#   - Quelle catégorie socioprofessionnelle est associée à « satisfait »
#     (même côté du biplot) et laquelle à « insatisfait » ?
#   - Quels profils émergent ?

# ============================================================
# B5 — Effectifs et qualité de représentation
# ============================================================
# Cos^2 des modalités (projetion sur l'axe) : une modales mal
# représentée a un cos^2 faible.
cos2_lignes <- get_pca_cos2(res_afc)$cos2.row
cos2_colonnes <- get_pca_cos2(res_afc)$cos2.col

cat("\n--- B5 — Cos^2 des modalités (axes 1-2) ---\n")
print(round(cos2_lignes, 3))
print(round(cos2_colonnes, 3))

# [CAPTURE] P3_B5_cos2.png

# Contributions des lignes à l'inertie des axes
contrib_lignes <- get_pca_contrib(res_afc)$contrib.row
cat("\n--- B5 — Contributions des lignes ---\n")
print(round(contrib_lignes, 3))

# ------------------------------------------------------------
# INTERPRÉTATION B5
# ------------------------------------------------------------
# - Un cos^2 élevé (> 0,6) : la modales est bien projetée sur le
#   plan, on peut l'interpréter sans risque.
# - Un cos^2 faible (< 0,4) : la modales est perpendiculaire au plan,
#   sa position dans le biplot est peu fiable.
# - Une contribution forte mais un cos^2 faible : la modales
#   « tire » l'axe mais elle n'est pas bien représentée par lui
#   (paradoxe classique de l'AFC).
# - Toujours croiser cos^2 ET contribution : les deux sont
#   nécessaires pour interpréter.
# - Effectifs marginaux : une catégorie avec 5 clients ne doit
#   pas porter la même interprétation qu'une catégorie avec 80.

# ============================================================
# B6 — Conclusion prudente (association ≠ causalité)
# ============================================================
cat("\n--- B6 — Conclusion prudente ---\n")
cat("L'AFC met en évidence une ASSOCIATION statistique entre\n")
cat("Categorie_socioprofessionnelle et Satisfaction.\n")
cat("Cela ne permet PAS de conclure à une CAUSALITE :\n")
cat("  - le croisement n'a pas contrôlé d'autres facteurs (âge,\n")
cat("    revenu, ancienneté, offre souscrite...);\n")
cat("  - le jeu de données est de 120 clients (petit échantillon);\n")
cat("  - l'ordre des modalités dans le tableau ne modélise aucun\n")
cat("    mécanisme causal.\n")
cat("La conclusion correcte est : « telle catégorie est associée à\n")
cat("un taux de satisfaction plus élevé / plus faible ».\n")
cat("Une conclusion causale (« la catégorie X CAUSE la satisfaction Y »)\n")
cat("exigerais un design expérimental ou un modèle de régression\n")
cat("multivarié avec contrôles appropriés.\n")

# ============================================================
# Objet à transmettre à M5 (pour le K-means sur les modalités)
# ============================================================
# M5 (D1-D5) utilisera res_afc pour extraire les coordonnées
# des modalités-lignes (D2) et appliquer K-means dessus (D3).
# On sauvegarde l'objet pour qu'il soit disponible.
saveRDS(res_afc, "res_afc.rds")
cat("\n[ENVOI À M5] res_afc sauvegardé dans res_afc.rds\n")

cat("\n=== FIN P3_02_afc.R ===\n")

