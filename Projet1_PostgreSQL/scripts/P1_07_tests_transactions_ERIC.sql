-- =====================================================================
-- Projet 1 — PostgreSQL (ITT3-IR, Groupe 2)
--
-- P1_07_tests_transactions_ERIC.sql
--
-- Questions G2-T5, T10 et test global.
-- Responsable : M5 — EVINA MBAHO ERIC
-- Relecteur   : M4 — ABBO (auteur des declencheurs testes ici)
--
-- PREREQUIS (ordre de rejeu, voir rapport P1_LOT_M5_ERIC.md) :
--   1. P1_01_socle_GULLIT.sql      (M1) — base vierge entreprise_tp
--   2. P1_02_privileges_M2.sql     (M2)
--   3. P1_03_pgvector_ANTOINE.sql  (M3)
--   4. P1_04_triggers_stock_ABBO.sql (M4) — declencheurs T1-T4
--   5. P1_05_requetes_M2.sql       (M2)
--   6. P1_06_vectoriel_stock_ANTOINE.sql (M3)
--   7. CE SCRIPT (M5)
--
-- Usage :
--   psql -U postgres -d entreprise_tp -f P1_07_tests_transactions_ERIC.sql
--   (ou : psql -U postgres -f P1_07_tests_transactions_ERIC.sql apres le socle,
--    car le socle contient deja un \c entreprise_tp)
--
-- Comportement :
--   - le test global (structures, comptages, extension, declencheurs)
--     s'execute TOUJOURS ;
--   - les 4 cas transactionnels ne s'executent que si au moins un
--     declencheur utilisateur est present sur `lignes_commande`.
--     Sinon un message explicite "EN ATTENTE DU LOT M4" est affiche.
--
-- Chaque cas affiche le stock AVANT et APRES, comme demande par T5.
-- =====================================================================

\set ON_ERROR_STOP on
\timing off

\echo ''
\echo '=== P1-07 TESTS TRANSACTIONNELS (M5 - ERIC) ==='
\echo 'Base :' :DBNAME

-- ---------------------------------------------------------------------
-- A. TEST GLOBAL — etat de la base apres rejeu des scripts dans l'ordre
-- ---------------------------------------------------------------------
\echo ''
\echo '--- A1. Tables attendues (6) ---'
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

\echo ''
\echo '--- A2. Comptages (valeurs du socle M1 : 5 / 4 / 5 / 5 / 10 / 5) ---'
SELECT 'clients' AS table_name, COUNT(*) AS nb FROM clients
UNION ALL SELECT 'utilisateurs', COUNT(*) FROM utilisateurs
UNION ALL SELECT 'produits', COUNT(*) FROM produits
UNION ALL SELECT 'commandes', COUNT(*) FROM commandes
UNION ALL SELECT 'lignes_commande', COUNT(*) FROM lignes_commande
UNION ALL SELECT 'paiements', COUNT(*) FROM paiements
ORDER BY table_name;

\echo ''
\echo '--- A3. Extension pgvector (prerequis M3 ; absente = environnement local) ---'
SELECT COALESCE((SELECT extversion FROM pg_extension WHERE extname = 'vector'),
                'NON INSTALLEE') AS version_pgvector;

\echo ''
\echo '--- A4. Declencheurs utilisateurs presents (lot M4 attendu) ---'
SELECT c.relname AS table_name, t.tgname AS trigger_name
FROM pg_trigger t
JOIN pg_class c ON c.oid = t.tgrelid
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND NOT t.tgisinternal
ORDER BY c.relname, t.tgname;

-- ---------------------------------------------------------------------
-- B. Presence des declencheurs M4 : on decidite avec \if (psql >= 10)
-- ---------------------------------------------------------------------
SELECT CASE WHEN EXISTS (
         SELECT 1 FROM pg_trigger t
         JOIN pg_class c ON c.oid = t.tgrelid
         JOIN pg_namespace n ON n.oid = c.relnamespace
         WHERE n.nspname = 'public' AND c.relname = 'lignes_commande'
           AND NOT t.tgisinternal
       ) THEN 'true' ELSE 'false' END AS declencheurs_presents \gset

\echo ''
\if :declencheurs_presents
  \echo '>>> Declencheurs M4 detectes : execution des 4 cas T5.'
\else
  \echo '>>> EN ATTENTE DU LOT M4 : aucun declencheur sur lignes_commande.'
  \echo '>>> Le test global ci-dessus a ete execute. Les cas T5 seront'
  \echo '>>> rejoues des que P1_04_triggers_stock_ABBO.sql sera livre.'
\endif

\if :declencheurs_presents

-- ---------------------------------------------------------------------
-- CAS 1 — Insertion valide : COMMIT confirme la baisse de stock
-- Produit 3 "Clavier" : stock initial 30. On ajoute 2 unites a la cmd 2.
-- ---------------------------------------------------------------------
\echo ''
\echo '--- CAS 1 : insertion valide puis COMMIT (stock attendu 30 -> 28) ---'
SELECT stock AS stock_avant_C1 FROM produits WHERE id_produit = 3;

BEGIN;
INSERT INTO lignes_commande (id_commande, id_produit, quantite, prix_unitaire)
VALUES (2, 3, 2, 12000);
SELECT stock AS stock_dans_la_transaction_C1 FROM produits WHERE id_produit = 3;
COMMIT;
SELECT stock AS stock_apres_COMMIT_C1 FROM produits WHERE id_produit = 3;

-- ---------------------------------------------------------------------
-- CAS 2 — Stock insuffisant : erreur puis ROLLBACK
-- On demande 9999 unites du produit 1. Le declencheur T4 doit refuser.
-- ON_ERROR_STOP est temporairement desactive POUR CETTE ERREUR ATTENDUE,
-- afin que le ROLLBACK et la suite du script s'executent quand meme.
-- ---------------------------------------------------------------------
\echo ''
\echo '--- CAS 2 : stock insuffisant, erreur attendue puis ROLLBACK ---'
SELECT stock AS stock_avant_C2 FROM produits WHERE id_produit = 1;
\set ON_ERROR_STOP off
BEGIN;
INSERT INTO lignes_commande (id_commande, id_produit, quantite, prix_unitaire)
VALUES (2, 1, 9999, 350000);
SELECT 'ANOMALIE : cette ligne ne devrait pas apparaitre' AS verification_C2;
ROLLBACK;
\set ON_ERROR_STOP on
SELECT stock AS stock_apres_ROLLBACK_C2 FROM produits WHERE id_produit = 1;

-- ---------------------------------------------------------------------
-- CAS 3 — Modification de quantite : le declencheur T2 ajuste le stock
-- On passe la ligne du CAS 1 de 2 a 5 unites : 3 unites supplementaires.
-- Stock attendu : 28 -> 25.
-- ---------------------------------------------------------------------
\echo ''
\echo '--- CAS 3 : UPDATE de quantite puis COMMIT (stock attendu 28 -> 25) ---'
SELECT stock AS stock_avant_C3 FROM produits WHERE id_produit = 3;
BEGIN;
UPDATE lignes_commande
SET quantite = 5
WHERE id_commande = 2 AND id_produit = 3;
SELECT stock AS stock_dans_la_transaction_C3 FROM produits WHERE id_produit = 3;
COMMIT;
SELECT stock AS stock_apres_COMMIT_C3 FROM produits WHERE id_produit = 3;

-- ---------------------------------------------------------------------
-- CAS 4 — Suppression de ligne : restitution du stock puis ROLLBACK
-- Le declencheur T3 doit rendre 5 unites (25 -> 30) ; le ROLLBACK les
-- annule et le stock revient a 25. On prouve ainsi que ROLLBACK annule
-- aussi l'effet du declencheur.
-- ---------------------------------------------------------------------
\echo ''
\echo '--- CAS 4 : DELETE puis ROLLBACK (stock attendu 25 -> 30 -> 25) ---'
SELECT stock AS stock_avant_C4 FROM produits WHERE id_produit = 3;
BEGIN;
DELETE FROM lignes_commande
WHERE id_commande = 2 AND id_produit = 3;
SELECT stock AS stock_dans_la_transaction_C4 FROM produits WHERE id_produit = 3;
ROLLBACK;
SELECT stock AS stock_apres_ROLLBACK_C4 FROM produits WHERE id_produit = 3;

\echo ''
\echo '--- Bilan T5 : remplir le tableau du rapport avec les valeurs affichees ---'
SELECT id_produit, libelle, stock
FROM produits
WHERE id_produit IN (1, 3)
ORDER BY id_produit;

\endif

\echo ''
\echo '=== FIN P1-07 TESTS TRANSACTIONNELS (M5 - ERIC) ==='
