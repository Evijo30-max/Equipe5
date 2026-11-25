#!/usr/bin/env Rscript
# =====================================================================
# Projet 3 — Analyse de donnees sous RStudio (ITT3-IR, Groupe 2)
#
# P3_04_afc_kmeans_ERIC.R
#
# Partie D — AFC + intelligence artificielle (questions D1 a D5)
# + element de redaction de la conclusion generale du projet.
#
# Responsable : M5 — EVINA MBAHO ERIC
# Relecteur   : M3 — NGUEGNI ONGOLO ANTOINE
# Dependance  : M1 (donnees_prep.rds) et M3 (objet res_afc).
#
# Ordre d'execution (depuis le dossier scripts/) :
#   Rscript P3_04_afc_kmeans_ERIC.R
#
# Sorties :
#   - console -> captures/P3_M5_afc_kmeans_output.txt
#   - graphiques PNG -> captures/
#   - texte rédige -> rapport/P3_LOT_M5_ERIC.md
#
# Reproductibilite : set.seed(2026) avant CHAQUE kmeans (regle de l'equipe).
# =====================================================================

suppressPackageStartupMessages({
  library(FactoMineR)
  library(factoextra)
  library(ggplot2)
})

set.seed(2026)

DIR_CAPTURES <- file.path("..", "captures")
if (!dir.exists(DIR_CAPTURES)) dir.create(DIR_CAPTURES, recursive = TRUE)

cat("=== P3-04 AFC + K-MEANS - M5 ERIC ===\n")
cat("R version :", R.version.string, "\n")
cat("Jeu de donnees : donnees_prep.rds (livre par M1)\n")

# ---------------------------------------------------------------------
# 0. Jeu de donnees commun (une seule version pour toute l'equipe)
# ---------------------------------------------------------------------
donnees_prep <- readRDS("donnees_prep.rds")
stopifnot("Categorie_socioprofessionnelle" %in% names(donnees_prep))
stopifnot("Satisfaction" %in% names(donnees_prep))
cat("Lignes :", nrow(donnees_prep), "| colonnes :", ncol(donnees_prep), "\n")

# ---------------------------------------------------------------------
# D1 — Reprendre l'AFC de M3
# ---------------------------------------------------------------------
# L'objet attendu est res_afc.rds (saved par P3_02_afc_ANTOINE.R).
# Au moment de la production de ce lot, ce fichier n'est pas disponible
# (le script de M3 ne se parse pas : `row lab` en ligne 129, et les
# fonctions get_pca_cos2/get_pca_contrib n'existent pas dans factoextra).
# On reconstruit donc EXACTEMENT le même objet : meme tableau de
# contingence, meme appel CA(tab_afc, graph = FALSE). Des que M3 aura
# livré res_afc.rds, ce script le preferera automatiquement.
cat("\n--- D1 — Reprise de l'AFC ---\n")
tab_afc <- table(donnees_prep$Categorie_socioprofessionnelle,
                 donnees_prep$Satisfaction)

if (file.exists("res_afc.rds")) {
  res_afc <- readRDS("res_afc.rds")
  cat("Source : res_afc.rds fourni par M3 (objet original). \n")
} else {
  res_afc <- CA(tab_afc, graph = FALSE)
  cat("Source : AFC reconstruite depuis donnees_prep.rds (res_afc.rds absent).\n")
  cat("         Meme appel que M3 : CA(table(Categorie_socioprofessionnelle,\n")
  cat("         Satisfaction), graph = FALSE) -> objet identique.\n")
}
cat("Tableau de contingence :\n")
print(tab_afc)

# Inertie : verification que les deux axes retiennent toute l'inertie.
cat("\n--- D1 — Inertie (les deux premiers axes) ---\n")
eig_afc <- res_afc$eig
print(round(eig_afc[1:2, ], 4))
cat("Cumul sur axes 1-2 :",
    round(eig_afc[2, "cumulative percentage of variance"], 2), "%\n")

png(file.path(DIR_CAPTURES, "P3_D1_eig_axes.png"),
    width = 900, height = 600, res = 120)
print(fviz_eig(res_afc, choice = "variance", addlabels = TRUE,
               title = "D1 — AFC : inertie expliquee par les axes"))
invisible(dev.off())
cat("[CAPTURE] P3_D1_eig_axes.png\n")

# ---------------------------------------------------------------------
# D2 — Extraire les coordonnees des modalites-lignes
# ---------------------------------------------------------------------
# On garde les deux axes retenus par l'analyse de M3 (B3) : ils portent
# 100 % de l'inertie ici. Les modalites-lignes sont les 4 categories
# socioprofessionnelles ; ce sont elles que l'on va classifier.
cat("\n--- D2 — Coordonnees des modalites-lignes (axes 1-2) ---\n")
coord_lignes <- as.data.frame(res_afc$row$coord[, 1:2, drop = FALSE])
names(coord_lignes) <- c("Dim1", "Dim2")
print(round(coord_lignes, 4))

cat("\n--- D2 — Coordonnees des modalites-colonnes (pour l'interpretation D4) ---\n")
coord_colonnes <- as.data.frame(res_afc$col$coord[, 1:2, drop = FALSE])
names(coord_colonnes) <- c("Dim1", "Dim2")
print(round(coord_colonnes, 4))

cat("\n--- D2 — Qualite de representation (cos2) des modalites-lignes ---\n")
cos2_lignes <- as.data.frame(res_afc$row$cos2[, 1:2, drop = FALSE])
names(cos2_lignes) <- c("cos2_Dim1", "cos2_Dim2")
print(round(cos2_lignes, 3))

# Carte factorielle de depart (avant clustering), utile a la soutenance.
png(file.path(DIR_CAPTURES, "P3_D1_D2_carte_afc.png"),
    width = 1000, height = 700, res = 120)
print(fviz_ca_biplot(res_afc, axes = c(1, 2), repel = TRUE,
                     title = "D1-D2 — Carte AFC : categories x satisfaction"))
invisible(dev.off())
cat("[CAPTURE] P3_D1_D2_carte_afc.png\n")

# ---------------------------------------------------------------------
# D3 — K-means sur les coordonnees des modalites-lignes
# ---------------------------------------------------------------------
# X ne contient QUE les coordonnees AFC : ni identifiant, ni effectif,
# ni variable initiale (regle rappelee par le sujet).
X <- as.matrix(coord_lignes)

cat("\n--- D3 — Choix du nombre de groupes k (silhouette moyenne) ---\n")
# Avec 4 modalites seulement, tester k = 2 et k = 3 est suffisant :
# k = 4 donnerait un cluster par modalite et une silhouette non definie.
sil_moyen <- function(k, graine = 2026) {
  set.seed(graine)
  km <- kmeans(X, centers = k, nstart = 50, iter.max = 100)
  sil <- cluster::silhouette(km$cluster, dist(X))
  c(k = k, silhouette = mean(sil[, "sil_width"]), taille_min = min(km$size))
}
for (k_essai in c(2L, 3L)) {
  r <- sil_moyen(k_essai)
  cat("k =", r["k"], "| silhouette moyenne =", round(r["silhouette"], 4),
      "| plus petit groupe =", r["taille_min"], "\n")
}

# k = 2 est retenu : silhouette la plus elevee et lecture la plus simple.
K_RETENU <- 2L
set.seed(2026)
km_D <- kmeans(X, centers = K_RETENU, nstart = 50, iter.max = 100)
sil_D <- cluster::silhouette(km_D$cluster, dist(X))

groupes <- data.frame(
  categorie = rownames(coord_lignes),
  Dim1 = round(coord_lignes$Dim1, 4),
  Dim2 = round(coord_lignes$Dim2, 4),
  groupe = km_D$cluster,
  silhouette = round(sil_D[, "sil_width"], 4),
  row.names = NULL
)
groupes <- groupes[order(groupes$groupe, -groupes$Dim1), ]

cat("\n--- D3 — Centre des groupes (k =", K_RETENU, ") ---\n")
print(round(km_D$centers, 4))
cat("Taille des groupes :", paste(km_D$size, collapse = " / "), "\n")
cat("Silhouette moyenne :", round(mean(sil_D[, "sil_width"]), 4), "\n")
cat("\n--- D3 — Groupe de chaque categorie socioprofessionnelle ---\n")
print(groupes, row.names = FALSE)

png(file.path(DIR_CAPTURES, "P3_D3_kmeans_groupes.png"),
    width = 1000, height = 700, res = 120)
p <- ggplot(groupes, aes(x = Dim1, y = Dim2,
                         label = categorie, colour = factor(groupe))) +
  geom_point(size = 5) +
  geom_text(vjust = -1.1, size = 4) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey60") +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey60") +
  labs(colour = "Groupe K-means",
       title = "D3 — K-means sur les coordonnees AFC (k = 2)",
       subtitle = "Classification des 4 categories socioprofessionnelles") +
  theme_minimal()
print(p)
invisible(dev.off())
cat("[CAPTURE] P3_D3_kmeans_groupes.png\n")

# ---------------------------------------------------------------------
# D4 — Interpretier les regroupements avec le tableau de contingence
# ---------------------------------------------------------------------
cat("\n--- D4 — Profils lignes (%) rapproches du groupe ---\n")
profils_mat <- as.matrix(prop.table(tab_afc, margin = 1) * 100)
res_D4 <- data.frame(
  categorie = rownames(profils_mat),
  groupe = km_D$cluster[rownames(profils_mat)],
  stringsAsFactors = FALSE
)
for (nn in colnames(profils_mat)) {
  res_D4[[nn]] <- round(profils_mat[, nn], 1)
}
print(res_D4, row.names = FALSE)

cat("\n--- D4 — Lecture automatique (a commenter dans le rapport) ---\n")
for (g in seq_len(K_RETENU)) {
  cat("Groupe", g, ":",
      paste(groupes$categorie[groupes$groupe == g], collapse = ", "), "\n")
}

# ---------------------------------------------------------------------
# D5 — Apport de l'algorithme et perte liee aux deux axes
# ---------------------------------------------------------------------
cat("\n--- D5 — Bilan ---\n")
cat("Apport : le K-means transforme la carte AFC en groupes explicites et\n")
cat("reproductibles ; il confirme visuellement les oppositions de l'axe 1.\n")
cat("Perte   : la projection sur 2 axes ecrase les ecarts perpendiculaires\n")
cat("au plan (cos2 faible) ; l'algorithme ne retrouve ni les effectifs,\n")
cat("ni le libelle des modalites, ni la cause des associations.\n")
cat("Rappel  : association observee != causalite (conclusion B6 de M3).\n")

cat("\n=== FIN P3-04 AFC + K-MEANS (M5 ERIC) ===\n")
