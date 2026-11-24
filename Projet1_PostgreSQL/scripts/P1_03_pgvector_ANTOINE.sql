-- ============================================================
-- P1_03_pgvector.sql
-- Projet 1 — PostgreSQL + pgvector (Groupe 2 — ITT3-IR)
--
-- Tâche : §5 (Partie commune — recherche sémantique) + 8 questions
-- Livrable : script commenté, captures des requêtes, réponses rédigées
--
-- Responsable : M3 — NGUEGNI ONGOLO ANTOINE
-- Pré-requis : le socle (01_socle.sql) est déjà exécuté.
--   → La base entreprise_tp et les 6 tables existent.
--   → La colonne `embedding` n'a pas encore été ajoutée.
--
-- Ordre d'exécution :
--   1. Se connecter à la base `entreprise_tp` (pas au template !)
--   2. Exécuter ce script dans l'ordre.
--   3. Prendre une capture à chaque étape marquée [CAPTURE].
-- ============================================================

\echo '=== P1_03_pgvector.sql — recherche sémantique avec pgvector ==='

-- ------------------------------------------------------------
-- §5.1  Vérifier l'installation de pgvector sur le serveur
-- ------------------------------------------------------------
-- L'extension pgvector doit être installée sur le *serveur* PostgreSQL
-- (pas seulement dans la base). On vérifie qu'elle est disponible.
-- Si la commande échoue, il faut installer pgvector sur le serveur :
--   - Linux  : sudo apt install postgresql-16-pgvector   (version adéquate)
--   - Docker : utiliser l'image `pgvector/pgvector:pg16`
--
-- La requête ci-dessous doit renvoyer au moins une ligne
-- (nom='vector', default_version non nul).
SELECT
    name,
    default_version,
    installed_version
FROM pg_available_extensions
WHERE name = 'vector';

-- [CAPTURE] P1_G2-§5.1_pgvector_install.png
-- Si la table est vide : pgvector n'est PAS installé.
-- → Arrêter ici et installer pgvector sur le serveur (consigne du
--   chef d'équipe) avant de continuer.

-- ------------------------------------------------------------
-- §5.2  Activer l'extension dans la base entreprise_tp
-- ------------------------------------------------------------
-- CREATE EXTENSION doit être exécuté avec un compte qui a le
-- privilège de créer des extensions (généralement le super-utilisateur
-- local, ou un rôle avec le privilège CREATEROLE + ownership de la base).
CREATE EXTENSION IF NOT EXISTS vector;

-- [CAPTURE] P1_G2-§5.2_extension_active.png
-- Vérification :
SELECT extname, extversion
FROM pg_extension
WHERE extname = 'vector';

-- ------------------------------------------------------------
-- §5.3a  Ajouter la colonne vectorielle sur la table produits
-- ------------------------------------------------------------
-- Le sujet utilise des vecteurs de 3 dimensions pour la démonstration
-- (produits simples, jeu de données petit). En production, les
-- embeddings réels font 768 à 1536 dimensions.
ALTER TABLE produits
    ADD COLUMN embedding VECTOR(3);

-- [CAPTURE] P1_G2-§5.3_colonne_embedding.png
-- Vérification de la colonne :
\d produits

-- ------------------------------------------------------------
-- §5.3b  Initialiser les vecteurs de démonstration
-- ------------------------------------------------------------
-- Vecteurs artificiels — pas de sémantique réelle. Le vecteur du
-- produit 1 (Ordinateur) est proche de celui du produit 2 (Imprimante)
-- car les deux ont une composante [0] élevée ; le produit 3 (Clavier)
-- est plus éloigné (composante [1] élevée).
UPDATE produits
SET embedding = CASE id_produit
    WHEN 1 THEN '[0.90, 0.10, 0.10]'::vector
    WHEN 2 THEN '[0.80, 0.20, 0.10]'::vector
    WHEN 3 THEN '[0.10, 0.90, 0.10]'::vector
    WHEN 4 THEN '[0.10, 0.80, 0.20]'::vector
    WHEN 5 THEN '[0.70, 0.20, 0.20]'::vector
END;

-- [CAPTURE] P1_G2-§5.3_embeddings.png
-- Vérification :
SELECT id_produit, libelle, embedding
FROM produits
ORDER BY id_produit;

-- ------------------------------------------------------------
-- §5.4  Recherche des produits les plus proches
-- ------------------------------------------------------------
-- Vecteur « requête » : [0.85, 0.15, 0.10] (produit 1 — Ordinateur).
-- L'opérateur `<=>` calcule la *distance de cosinus* entre le vecteur
-- stocké et le vecteur de requête.
--
-- RÉSULTAT ATTENDU (tri par distance croissante) :
--   1.  id=1  (Ordinateur)  — distance ≈ 0        (vecteur quasi identique)
--   2.  id=2  (Imprimante)  — distance ≈ 0.0069
--   3.  id=5  (Routeur)     — distance ≈ 0.0123
--
-- [CAPTURE] P1_G2-§5.4_recherche_proches.png
SELECT
    id_produit,
    libelle,
    prix,
    stock,
    embedding <=> '[0.85, 0.15, 0.10]'::vector AS distance_cosinus
FROM produits
WHERE embedding IS NOT NULL
ORDER BY embedding <=> '[0.85, 0.15, 0.10]'::vector
LIMIT 3;

-- ------------------------------------------------------------
-- §5.5  Interprétation du classement (rédiger dans le rapport)
-- ------------------------------------------------------------
-- Le produit 1 (Ordinateur) arrive en tête car son vecteur
-- [0.90, 0.10, 0.10] est le plus proche du vecteur de requête
-- [0.85, 0.15, 0.10]. La distance de cosinus mesure l'angle entre
-- deux vecteurs ; plus l'angle est petit, plus les deux sont « alignés »,
-- et plus la similarité est forte.
--
-- Le produit 2 (Imprimante) arrive en deuxième position car son
-- vecteur [0.80, 0.20, 0.10] conserve une forte composante [0].
-- Le produit 5 (Routeur) [0.70, 0.20, 0.20] est le troisième retourné.
--
-- Les produits 3 (Clavier) et 4 (Souris) sont écartés car leurs
-- vecteurs sont centrés sur la composante [1], bien moins alignée
-- avec la requête.

-- ============================================================
-- RÉPONSES AUX 8 QUESTIONS DU §5 (à copier dans le rapport)
-- ============================================================

-- Q1. Quel est le rôle de pgvector ?
-- pgvector est une extension PostgreSQL qui ajoute le type `vector` et
-- des opérateurs de comparaison de similarité (cosinus, L1, L2,
-- produit scalaire) ainsi qu'index (IVFFlat, HNSW). Elle transforme
-- PostgreSQL en base capable de faire de la recherche sémantique :
-- stocker des embeddings produits par un modèle d'IA et retrouver les
-- éléments les plus proches d'une requête textuelle.

-- Q2. Quelle est la fonction de la colonne `embedding` ?
-- Elle stocke le vecteur numérique (embedding) qui représente un
-- produit dans un espace vectoriel. C'est la « signature sémantique »
-- du produit. C'est elle qui est comparée aux autres embeddings par
-- l'opérateur de distance. Dans ce TP, c'est un vecteur de 3
-- dimensions (démonstration) ; en production ce serait 768-1536
-- dimensions (modèles modernes).

-- Q3. Que représente le vecteur fourni dans la requête ?
-- Le vecteur [0.85, 0.15, 0.10]::vector est le vecteur de REQUÊTE :
-- il représente ce que l'utilisateur cherche (« un produit proche de
-- l'Ordinateur »). En production, ce vecteur serait produit par un
-- modèle d'embeddings (ex. : sentence-transformers) à partir du texte
-- de la requête.

-- Q4. Que signifie l'opérateur `<=>` ?
-- C'est l'opérateur de DISTANCE DE COSINUS de pgvector.
-- `a <=> b` renvoie le complément à 1 de la similarité de cosinus :
--   distance = 1 - (a·b) / (||a|| * ||b||)
-- 0 = parfaitement alignés (identiques), 1 = orthogonaux (rien à voir).
-- On trie donc par distance CROISSANTE pour obtenir les plus proches.

-- Q5. Pourquoi les résultats sont-ils classés selon la distance ?
-- La clause `ORDER BY embedding <=> '...'` force le tri par similarité
-- (plus la distance est petite, plus le produit est proche). `LIMIT 3`
-- ne garde que les 3 plus proches. C'est le principe même de la
-- recherche vectorielle : on ne filtre plus par texte, on filtre par
-- proximité dans l'espace vectoriel.

-- Q6. Différence entre recherche par mots-clés (LIKE) et recherche
--     vectorielle ?
--   - LIKE '%ordinateur%' : recherche LEXICALE exacte. Ne trouve rien
--     si le mot n'est pas écrit exactement. Ne comprend pas le sens
--     (« portable », « laptop », « PC » ne sont pas des synonymes
--     pour LIKE).
--   - Recherche vectorielle : recherche SÉMANTIQUE. Deux textes
--     proches en sens (pas en mots) ont des vecteurs proches ;
--     on retrouve donc « portable » quand on cherche « laptop »,
--     même si aucun mot ne se ressemble.
--  Le TP de base : LIKE est rapide et précis ; pgvector est plus
--  expressif (recherche d'intention, pas de littéralité).

-- Q7. Pourquoi 3 dimensions ne suffisent-elles pas pour une vraie
--     compréhension sémantique ?
-- Avec 3 dimensions, l'espace est trop pauvre pour représenter la
-- richesse du sens. Deux produits différents peuvent partager les 3
-- mêmes axes (ex. « cher » + « gros » + « électronique »), alors
-- qu'en réalité ils ne sont pas interchangeables (un clavier n'est
-- pas un ordinateur même s'ils partagent ces 3 traits).
-- Les modèles réels (768, 1024, 1536 dimensions) capturent des
-- nuances que 3 axes ne permettent pas de distinguer. C'est pour
-- ça que le sujet qualifie ces vecteurs d'« artificiels » : ils
-- servent la démo, pas la compréhension du langage.

-- Q8. Quel est le rôle du modèle d'IA dans la production des
--     embeddings ?
-- Le modèle d'IA (ex. : BERT, sentence-transformers, Claude) lit le
-- texte (ici la description du produit) et le transforme en un
-- vecteur numérique qui encode le SENS du texte. C'est lui qui
-- décide des similarités ; PostgreSQL (avec pgvector) se contente
-- de STOCKER ces vecteurs et de les COMPARER par distance.
-- Sans le modèle d'IA, on n'aurait pas de vecteur sémantique à
-- comparer, seulement des coordonnées arbitraires.
--
-- [RAPPORT] Q1-Q8 sont rédigées ci-dessus. Les captures sont à
-- prendre dans psql / pgAdmin / DBeaver après chaque étape.

