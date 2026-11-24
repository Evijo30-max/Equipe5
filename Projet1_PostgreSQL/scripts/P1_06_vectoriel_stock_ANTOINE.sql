-- ============================================================
-- P1_06_vectoriel_stock.sql
-- Projet 1 — PostgreSQL + pgvector (Groupe 2 — ITT3-IR)
--
-- Tâches : G2-T8 (produits similaires à un produit donné)
--          G2-T9 (afficher les stocks des produits retournés)
--
-- Responsable : M3 — NGUEGNI ONGOLO ANTOINE
-- Pré-requis : 01_socle.sql + 03_pgvector.sql déjà exécutés.
-- ============================================================

\echo '=== P1_06_vectoriel_stock.sql — recherche vectorielle + stocks ==='

-- ------------------------------------------------------------
-- G2-T8 : Rechercher les produits similaires à un produit donné
-- ------------------------------------------------------------
-- On prend le produit 1 (Ordinateur, id=1) comme point de départ.
-- Le vecteur du produit 1 est [0.90, 0.10, 0.10] (voir 03_pgvector.sql).
--
-- [CAPTURE] P1_G2-T8_similaires.png
SELECT
    id_produit,
    libelle,
    prix,
    embedding <=> (SELECT embedding FROM produits WHERE id_produit = 1)
                  AS distance_similarite
FROM produits
WHERE embedding IS NOT NULL
  AND id_produit <> 1                 -- exclure le produit de départ
ORDER BY embedding <=> (SELECT embedding FROM produits WHERE id_produit = 1)
LIMIT 3;

-- RÉSULTAT ATTENDU :
--   1.  id=2  (Imprimante)  — distance ≈ 0.0035
--   2.  id=5  (Routeur)     — distance ≈ 0.0118
--   3.  id=4  (Souris)      — distance ≈ 0.7769
-- (Le produit 3 « Clavier » est écarté car sa distance est plus grande)
--
-- INTERPRÉTATION : le produit « le plus proche sémantiquement » de
-- l'Ordinateur est l'Imprimante (les deux partagent une composante
-- [0] élevée). En production, le modèle d'IA déciderait quel
-- produit est réellement « similaire » (ex. : « laptop » est proche
-- de « ordinateur », pas « imprimante »).

-- ------------------------------------------------------------
-- G2-T9 : Afficher les stocks des produits retournés par la
--          recherche vectorielle
-- ------------------------------------------------------------
-- On reprend la requête ci-dessus et on y joint la colonne `stock`.
-- C'est exactement l'utilité du module Groupe 2 : la recherche
-- sémantique ne dit pas SI le produit est disponible.

-- [CAPTURE] P1_G2-T9_stocks_proches.png
SELECT
    p.id_produit,
    p.libelle,
    p.prix,
    p.stock,
    p.embedding <=> (SELECT embedding FROM produits WHERE id_produit = 1)
                    AS distance_similarite
FROM produits p
WHERE p.embedding IS NOT NULL
  AND p.id_produit <> 1
ORDER BY p.embedding <=> (SELECT embedding FROM produits WHERE id_produit = 1)
LIMIT 3;

-- RÉSULTAT ATTENDU (stock au départ du socle) :
--   id=2  Imprimante  stock = 15
--   id=5  Routeur     stock = 12
--   id=4  Souris      stock = 40
--
-- REMARQUE : si les déclencheurs de M4 (04_triggers_stock.sql)
-- sont déjà actifs, les stocks ont pu évoluer avec les tests.
-- Toujours prendre une capture APRÈS les tests de M5 pour montrer
-- que la recherche vectorielle s'adapte à l'état réel du stock.

-- ------------------------------------------------------------
-- G2-T10 : Pourquoi deux produits similaires ne sont pas
--           nécessairement interchangeables
-- ------------------------------------------------------------
-- (Explication à rédiger dans le rapport, en s'appuyant sur les
--  résultats de M3 ci-dessus.)
--
-- Deux produits « sémantiquement proches » (ex. : Ordinateur et
-- Imprimante, car les deux sont de l'informatique) peuvent être
-- totalement incompatibles :
--   - Ordinateur : produit de 350 000 FCFA, gros appareil, stock = 10
--   - Imprimante : produit de 85 000 FCFA, accessoire, stock = 15
--
-- La similarité vectorielle ne mesure PAS :
--   - le prix,
--   - le stock disponible,
--   - la compatibilité technique,
--   - les spécifications détaillées.
--
-- La similarité ne garantit donc PAS la disponibilité. Un produit
-- « très proche sémantiquement » peut être :
--   - épuisé (stock = 0),
--   - incompatible avec le contexte (une imprimante ne remplace pas
--     un ordinateur),
--   - d'un prix différent (facteur commercial).
--
-- C'est pour cela que le module « Automatisation de la gestion des
-- stocks » (G2) est nécessaire : il vérifie la disponibilité et
-- met à jour le stock automatiquement, indépendamment de la
-- recherche sémantique.

