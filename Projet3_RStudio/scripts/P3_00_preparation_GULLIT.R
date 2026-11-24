# =====================================================================
# Projet 3 - Analyse de donnees sous RStudio
# ITT3-IR - Role M1 Chef d'equipe : KEUMEKA SOKING WILFRIED GULLIT
#
# P3_00_preparation_GULLIT.R
#
# Objectif : importation, diagnostic et preparation du jeu de donnees
# clients telecom (n = 120) avant ACP, AFC, K-means et arbre de decision.
#
# Plan :
#   §4.1-4.4  Importation et diagnostic descriptif
#   Question A1 : selection explicite des 7 variables quantitatives
#   Question A2 : controle et imputation des 6 valeurs manquantes
#   Sauvegardes : donnees_prep.rds / .csv et X_quant_prep.rds
#
# Reproductibilite : set.seed(2026) des la premiere ligne utile.
# =====================================================================

set.seed(2026)

# ---------------------------------------------------------------------
# §4.1-4.4 - IMPORTATION ET DIAGNOSTIC DESCRIPTIF
# ---------------------------------------------------------------------
cat("=== P3-00 PREPARATION DES DONNEES - GROUPE 2 ===\n")
cat("Date d'execution : ", as.character(Sys.time()), "\n", sep = "")
cat("Version de R : ", R.version.string, "\n", sep = "")
cat("Graine aleatoire : 2026\n\n")

fichier_entree <- file.path(getwd(), "jeu_donnees_clients_telecom.csv")
cat("Fichier importe : ", fichier_entree, "\n", sep = "")

donnees <- read.csv(
  fichier_entree,
  header = TRUE,
  sep = ",",
  na.strings = c("", "NA"),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

cat("\n--- S4.2 DIMENSIONS ---\n")
cat("dim : ", paste(dim(donnees), collapse = " x "), "\n", sep = "")

cat("\n--- S4.3 STRUCTURE (str) ---\n")
str(donnees)

cat("\n--- S4.4 RESUME STATISTIQUE (summary) ---\n")
print(summary(donnees))

cat("\n--- S4.4 VALEURS MANQUANTES PAR COLONNE ---\n")
na_par_colonne <- colSums(is.na(donnees))
print(na_par_colonne)
cat("Total des valeurs manquantes : ", sum(na_par_colonne), "\n", sep = "")

cat("\n--- S4.4 CONTROLE DES DOUBLONS ---\n")
nb_doublons <- sum(duplicated(donnees))
cat("Nombre de lignes en double : ", nb_doublons, "\n", sep = "")

# ---------------------------------------------------------------------
# QUESTION A1 - SELECTION EXPLICITE DES 7 VARIABLES QUANTITATIVES
# ---------------------------------------------------------------------
cat("\n=== QUESTION A1 - VARIABLES QUANTITATIVES ===\n")

vars_identifiant <- c("ID_Client")
vars_qualitatives <- c(
  "Ville",
  "Categorie_socioprofessionnelle",
  "Type_abonnement",
  "Satisfaction"
)
vars_quantitatives <- c(
  "Age",
  "Anciennete_mois",
  "Heures_connexion_jour",
  "Volume_donnees_Go_mois",
  "Depenses_FCFA_mois",
  "Nb_services",
  "Nb_reclamations_mois"
)

cat("Identifiant exclu : ", paste(vars_identifiant, collapse = ", "), "\n", sep = "")
cat("Variables qualitatives exclues (AFC) : ",
    paste(vars_qualitatives, collapse = ", "), "\n", sep = "")
cat("Variables quantitatives retenues (ACP / K-means) : ",
    paste(vars_quantitatives, collapse = ", "), "\n", sep = "")
cat("Nombre de variables quantitatives : ", length(vars_quantitatives), "\n", sep = "")

attendu_colonnes <- c(vars_identifiant, vars_quantitatives, vars_qualitatives)
cat("Verification des colonnes (12 attendues) : ",
    setequal(names(donnees), attendu_colonnes), "\n", sep = "")
stopifnot(setequal(names(donnees), attendu_colonnes))

# ---------------------------------------------------------------------
# QUESTION A2 - CONTROLE DETAILLE ET IMPUTATION DES 6 VALEURS MANQUANTES
# ---------------------------------------------------------------------
cat("\n=== QUESTION A2 - TRAITEMENT DES VALEURS MANQUANTES ===\n")

na_attendu <- c(
  Volume_donnees_Go_mois = 2,
  Depenses_FCFA_mois     = 2,
  Nb_reclamations_mois   = 1,
  Ville                  = 1
)

cat("\n--- A2.1 ETAT AVANT IMPUTATION (attendu vs observe) ---\n")
for (v in names(na_attendu)) {
  cat(sprintf("%-28s attendu=%d  observe=%d\n",
              v, na_attendu[[v]], na_par_colonne[[v]]))
}
cat("Total attendu = ", sum(na_attendu),
    " | Total observe = ", sum(na_par_colonne[na_par_colonne > 0]), "\n", sep = "")
stopifnot(all(na_par_colonne[names(na_attendu)] == na_attendu))
stopifnot(sum(na_par_colonne) == 6)

donnees_prep <- donnees

# --- A2.2 Imputation par la MEDIANE pour les variables quantitatives ---
# Justification : la mediane est robuste aux valeurs extremes, conservant
# ainsi la structure de distribution. Surtout, elle preserve l'effectif
# complet de 120 clients, indispensable a l'ACP et au K-means.
cat("\n--- A2.2 IMPUTATION PAR LA MEDIANE (quantitatives) ---\n")
vars_quant_a_imputer <- intersect(names(na_attendu), vars_quantitatives)
valeurs_medianes <- sapply(vars_quant_a_imputer, function(v) {
  as.numeric(median(donnees_prep[[v]], na.rm = TRUE))
})
for (v in vars_quant_a_imputer) {
  cat(sprintf("%-28s mediane = %s | NA imputes = %d\n",
              v, format(valeurs_medianes[[v]], digits = 6),
              sum(is.na(donnees_prep[[v]]))))
  donnees_prep[[v]][is.na(donnees_prep[[v]])] <- valeurs_medianes[[v]]
}
print(valeurs_medianes)

# --- A2.3 Imputation par le MODE pour la variable qualitative Ville ---
# Justification : le respect de la distribution categorielle et le maintien
# des 120 lignes pour l'AFC et les tris croises. Recourir a une modalite
# "Inconnu" introduirait une categorie artifactielle dans l'AFC.
cat("\n--- A2.3 IMPUTATION PAR LE MODE (Ville) ---\n")
tab_ville <- table(donnees_prep$Ville, useNA = "no")
mode_ville <- names(which.max(tab_ville))
cat("Modalite la plus frequente : ", mode_ville,
    " (", max(tab_ville), " occurrences sur ", sum(tab_ville), ")\n", sep = "")
cat("NA avant imputation Ville : ", sum(is.na(donnees_prep$Ville)), "\n", sep = "")
donnees_prep$Ville[is.na(donnees_prep$Ville)] <- mode_ville
cat("NA apres imputation Ville : ", sum(is.na(donnees_prep$Ville)), "\n", sep = "")

# --- A2.4 Controle final d'integrite ---
cat("\n--- A2.4 CONTROLE FINAL ---\n")
cat("Dimensions avant : ", paste(dim(donnees), collapse = " x "), "\n", sep = "")
cat("Dimensions apres  : ", paste(dim(donnees_prep), collapse = " x "), "\n", sep = "")
cat("sum(is.na(donnees_prep)) = ", sum(is.na(donnees_prep)), "\n", sep = "")
stopifnot(sum(is.na(donnees_prep)) == 0L)
stopifnot(nrow(donnees_prep) == 120L)
cat("RESULTAT A2 : OK - 0 valeur manquante, 120 clients conserves.\n")

cat("\n--- A2.5 RECAPITULATIF NA AVANT / APRES ---\n")
na_apres <- colSums(is.na(donnees_prep))
recapitulatif <- data.frame(
  Variable   = names(na_attendu),
  NA_avant   = as.integer(na_attendu),
  NA_apres   = as.integer(na_apres[names(na_attendu)]),
  Methode    = ifelse(names(na_attendu) %in% vars_quantitatives, "Mediane", "Mode"),
  stringsAsFactors = FALSE
)
print(recapitulatif, row.names = FALSE)

# ---------------------------------------------------------------------
# MATRICE QUANTITATIVE POUR LES ETAPES SUIVANTES (ACP / K-MEANS)
# ---------------------------------------------------------------------
cat("\n=== MATRICE QUANTITATIVE X_quant ===\n")
X_quant <- as.matrix(donnees_prep[, vars_quantitatives, drop = FALSE])
cat("dim(X_quant) : ", paste(dim(X_quant), collapse = " x "), "\n", sep = "")
print(head(X_quant))

saveRDS(donnees_prep, "donnees_prep.rds")
write.csv(donnees_prep, "donnees_prep.csv", row.names = FALSE, fileEncoding = "UTF-8")
saveRDS(X_quant, "X_quant_prep.rds")

cat("\n--- FICHIERS GENERES ---\n")
cat("donnees_prep.rds  : ", file.size("donnees_prep.rds"), " octets\n", sep = "")
cat("donnees_prep.csv  : ", file.size("donnees_prep.csv"), " octets\n", sep = "")
cat("X_quant_prep.rds  : ", file.size("X_quant_prep.rds"), " octets\n", sep = "")
cat("\n=== FIN DU SCRIPT P3-00 ===\n")
