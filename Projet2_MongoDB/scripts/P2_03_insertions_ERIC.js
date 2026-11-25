/**
 * P2_03_insertions_ERIC.js
 * ------------------------
 * Projet 2 - MongoDB (Groupe 5 : gestion des dossiers etudiants)
 *
 * Taches : S2 / C4 - insertion individuelle (insertOne) d'un dossier de
 *          test destine a la suppression controlee C7/S7 de M2.
 * Responsable : M5 - EVINA MBAHO ERIC
 * Relecteur   : M4 - ABBO
 *
 * Le jeu de donnees commun (5 etudiants) est deja insere par
 * P2_02_import_ERIC.js avec insertMany. Ce script demontre la seconde
 * forme d'insertion, explicitement demandee par le sujet : insertOne.
 *
 * IMPORTANT pour M2 et M1 :
 *   - filtre de suppression a utiliser : { matricule: "ETU-2026-9999" }
 *   - le matricule respecte le $jsonSchema de M3 (^ETU-[0-9]{4}-[0-9]{4}$).
 *     Le libelle "TEST-C7-S7" du script C8 de M1 n'est donc pas valide
 *     avec le validateur : utiliser ETU-2026-9999 a la place.
 *   - les champs sont imbriques : identite.nom, coordonnees.email.
 *
 * Mode d'emploi (depuis le dossier scripts/) :
 *   mongosh --quiet --file P2_03_insertions_ERIC.js
 */

"use strict";

db = db.getSiblingDB("universite_tp");

print("=== P2-03 INSERTION INDIVIDUELLE - DOSSIER DE TEST (M5 - ERIC) ===");
print("Base active : " + db.getName());

const MATRICULE_TEST = "ETU-2026-9999";

const dossierTest = {
  matricule: MATRICULE_TEST,
  identite: {
    nom: "DOSSIER_TEST_SUPPRESSION",
    prenoms: "Test",
    date_naissance: "2005-01-01",
    sexe: "M"
  },
  formation: {
    filiere: "Informatique",
    niveau: "L1",
    annee: "2025-2026",
    ue: ["BDD NoSQL"]
  },
  coordonnees: {
    email: "test.suppression@universite.local",
    telephone: "+237 600 00 00 00",
    adresse: { ville: "Yaounde", quartier: "Test" }
  }
};

// Rejouabilite : remplacer uniquement ce dossier precis.
db.etudiants.deleteOne({ matricule: MATRICULE_TEST });

const avant = db.etudiants.countDocuments({});
const resultat = db.etudiants.insertOne(dossierTest);
const apres = db.etudiants.countDocuments({});

print("insertOne : _id = " + resultat.insertedId);
print("Comptage avant insertOne : " + avant);
print("Comptage apres  insertOne : " + apres);
print("");
print("--- DOSSIER DE TEST INSERE ---");
printjson(db.etudiants.findOne({ matricule: MATRICULE_TEST }));

print("");
print("--- INSTRUCTIONS POUR LA CHAINE DE RELECTURE ---");
print("M2 (C7/S7) - afficher puis supprimer avec : { matricule: '" + MATRICULE_TEST + "' }");
print("M1 (C8) - verifier avec : { matricule: '" + MATRICULE_TEST + "' }");
print("M1 (C8) - champs imbriques : identite.nom = 'DOSSIER_TEST_SUPPRESSION'");
print("           coordonnees.email = 'test.suppression@universite.local'");
print("");
print("=== FIN P2-03 ===");
