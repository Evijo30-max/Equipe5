-- =====================================================================
-- Projet 1 - PostgreSQL local (hors Docker)
-- ITT3-IR - Groupe 2 - Role M1 Chef d'equipe
-- KEUMEKA SOKING WILFRIED GULLIT
--
-- P1_01_socle_GULLIT.sql
-- Objectif : recreer proprement la base `entreprise_tp`, creer les 6
-- tables du sujet (fautes de frappe du PDF corrigees), charger les
-- donnees initiales et afficher un controle de chargement.
--
-- Ce script est idempotent : il peut etre rejete autant de fois que
-- necessaire, la base etant supprimee puis recreee a chaque execution.
-- A executer depuis `psql -U postgres` (connexion initiale sur `postgres`).
-- =====================================================================

\set ON_ERROR_STOP on

\echo '=== [1/6] Suppression et recreation de la base entreprise_tp ==='
DROP DATABASE IF EXISTS entreprise_tp;
CREATE DATABASE entreprise_tp;

\echo '=== [2/6] Connexion a entreprise_tp ==='
\c entreprise_tp

\echo '=== [3/6] Creation des 6 tables et de leurs contraintes ==='

-- Table 1 : clients
CREATE TABLE clients (
    id_client SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    ville VARCHAR(100),
    email VARCHAR(150) UNIQUE
);

-- Table 2 : utilisateurs
CREATE TABLE utilisateurs (
    id_utilisateur SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    fonction VARCHAR(50) NOT NULL,
    actif BOOLEAN DEFAULT TRUE
);

-- Table 3 : produits
CREATE TABLE produits (
    id_produit SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    prix NUMERIC(12,2) NOT NULL CHECK (prix >= 0),
    stock INTEGER NOT NULL CHECK (stock >= 0)
);

-- Table 4 : commandes
CREATE TABLE commandes (
    id_commande SERIAL PRIMARY KEY,
    id_client INTEGER NOT NULL REFERENCES clients(id_client),
    id_utilisateur INTEGER REFERENCES utilisateurs(id_utilisateur),
    date_commande TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statut VARCHAR(20) NOT NULL DEFAULT 'EN_ATTENTE'
        CHECK (statut IN ('EN_ATTENTE', 'VALIDEE', 'ANNULEE', 'LIVREE')),
    montant_total NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (montant_total >= 0)
);

-- Table 5 : lignes_commande
CREATE TABLE lignes_commande (
    id_ligne SERIAL PRIMARY KEY,
    id_commande INTEGER NOT NULL REFERENCES commandes(id_commande),
    id_produit INTEGER NOT NULL REFERENCES produits(id_produit),
    quantite INTEGER NOT NULL CHECK (quantite > 0),
    prix_unitaire NUMERIC(12,2) NOT NULL CHECK (prix_unitaire >= 0),
    UNIQUE (id_commande, id_produit)
);

-- Table 6 : paiements
CREATE TABLE paiements (
    id_paiement SERIAL PRIMARY KEY,
    id_commande INTEGER NOT NULL REFERENCES commandes(id_commande),
    montant NUMERIC(12,2) NOT NULL CHECK (montant > 0),
    date_paiement TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statut VARCHAR(20) NOT NULL DEFAULT 'EN_ATTENTE'
        CHECK (statut IN ('EN_ATTENTE', 'CONFIRME', 'REJETE'))
);

\echo '=== [4/6] Chargement des donnees initiales ==='

INSERT INTO clients (nom, ville, email) VALUES
    ('Alice',   'Yaounde',   'alice@example.com'),
    ('Boris',   'Douala',    'boris@example.com'),
    ('Carine',  'Bafoussam', 'carine@example.com'),
    ('David',   'Garoua',    'david@example.com'),
    ('Estelle', 'Yaounde',   'estelle@example.com');

INSERT INTO utilisateurs (nom, fonction) VALUES
    ('Paul',  'Commercial'),
    ('Marie', 'Responsable stock'),
    ('Jean',  'Comptable'),
    ('Sarah', 'Logisticien');

INSERT INTO produits (libelle, prix, stock) VALUES
    ('Ordinateur', 350000, 10),
    ('Imprimante',  85000, 15),
    ('Clavier',     12000, 30),
    ('Souris',       8000, 40),
    ('Routeur',     45000, 12);

INSERT INTO commandes (id_client, id_utilisateur, statut, montant_total) VALUES
    (1, 1, 'EN_ATTENTE', 374000),
    (2, 1, 'VALIDEE',    85000),
    (3, 2, 'EN_ATTENTE', 97000),
    (4, 3, 'VALIDEE',   366000),
    (5, 1, 'ANNULEE',    12000);

INSERT INTO lignes_commande (id_commande, id_produit, quantite, prix_unitaire) VALUES
    (1, 3, 2, 12000),
    (1, 4, 1, 8000),
    (1, 1, 1, 350000),
    (2, 2, 1, 85000),
    (3, 2, 1, 85000),
    (3, 4, 1, 8000),
    (3, 3, 1, 12000),
    (4, 1, 1, 350000),
    (4, 4, 2, 8000),
    (5, 3, 1, 12000);

INSERT INTO paiements (id_commande, montant, statut) VALUES
    (1, 200000, 'CONFIRME'),
    (2,  85000, 'CONFIRME'),
    (3,  50000, 'EN_ATTENTE'),
    (4, 366000, 'CONFIRME'),
    (5,  12000, 'REJETE');

-- Bonne pratique : les identifiants etant fournis explicitement, on
-- resynchronise les sequences SERIAL pour les prochaines insertions.
SELECT setval(pg_get_serial_sequence('clients', 'id_client'),
              (SELECT MAX(id_client) FROM clients));
SELECT setval(pg_get_serial_sequence('utilisateurs', 'id_utilisateur'),
              (SELECT MAX(id_utilisateur) FROM utilisateurs));
SELECT setval(pg_get_serial_sequence('produits', 'id_produit'),
              (SELECT MAX(id_produit) FROM produits));
SELECT setval(pg_get_serial_sequence('commandes', 'id_commande'),
              (SELECT MAX(id_commande) FROM commandes));
SELECT setval(pg_get_serial_sequence('lignes_commande', 'id_ligne'),
              (SELECT MAX(id_ligne) FROM lignes_commande));
SELECT setval(pg_get_serial_sequence('paiements', 'id_paiement'),
              (SELECT MAX(id_paiement) FROM paiements));

\echo '=== [5/6] Controle du nombre d enregistrements (valeurs attendues) ==='
SELECT * FROM (VALUES
    (1, 'clients',         (SELECT COUNT(*) FROM clients),         5),
    (2, 'utilisateurs',    (SELECT COUNT(*) FROM utilisateurs),    4),
    (3, 'produits',        (SELECT COUNT(*) FROM produits),        5),
    (4, 'commandes',       (SELECT COUNT(*) FROM commandes),       5),
    (5, 'lignes_commande', (SELECT COUNT(*) FROM lignes_commande), 10),
    (6, 'paiements',       (SELECT COUNT(*) FROM paiements),       5)
) AS v(ordre, table_name, nb_obtenu, nb_attendu)
ORDER BY ordre;

\echo '=== [6/6] Liste des relations (meta-commande dt) ==='
\dt

\echo '=== FIN DU SCRIPT SOCLE P1_01_socle_GULLIT.sql ==='
