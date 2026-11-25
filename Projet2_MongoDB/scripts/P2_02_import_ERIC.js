/**
 * P2_02_import_ERIC.js
 * --------------------
 * Projet 2 - MongoDB (Groupe 5 : gestion des dossiers etudiants)
 *
 * Taches : C3 (importer le jeu de donnees commun) + C4 (insertions)
 * Responsable : M5 - EVINA MBAHO ERIC
 * Relecteur   : M4 - ABBO
 *
 * Prerequis : le lot M3 (P2_01_structure_ANTOINE.js) doit avoir cree la
 *             collection `etudiants` dans la base `universite_tp` avec le
 *             validateur $jsonSchema. Ce script ne cree PAS la collection.
 *
 * Mode d'emploi (depuis le dossier scripts/ du projet) :
 *   mongosh --quiet --file P2_02_import_ERIC.js
 *
 * Le fichier donnees_etudiants.json est lu avec le module fs de mongosh.
 * Le script est rejouable : il ne supprime que les documents dont le
 * matricule est dans le jeu de donnees (jamais deleteMany({})).
 */

"use strict";

const fs = require("fs");
const path = require("path");

db = db.getSiblingDB("universite_tp");

print("=== P2-02 IMPORT DU JEU DE DONNEES COMMUN (M5 - ERIC) ===");
print("Base active : " + db.getName());
print("Serveur     : " + db.version());

// ---------------------------------------------------------------
// 0. Controle du prerequis - structure (lot M3)
// ---------------------------------------------------------------
const collections = db.getCollectionNames();
if (collections.indexOf("etudiants") === -1) {
  throw new Error(
    "Collection 'etudiants' absente. Executer d'abord P2_01_structure_ANTOINE.js (lot M3)."
  );
}
print("Collection 'etudiants' : PRESENTE");

// ---------------------------------------------------------------
// 1. Lecture du JSON commun (5 dossiers etudiants)
// ---------------------------------------------------------------
const cheminJSON = path.resolve("donnees_etudiants.json");
const documents = EJSON.parse(fs.readFileSync(cheminJSON, "utf8"));
print("Fichier lu : " + cheminJSON);
print("Documents dans le JSON : " + documents.length);

if (documents.length < 5) {
  throw new Error("Le jeu de donnees doit contenir au moins 5 etudiants.");
}

// ---------------------------------------------------------------
// 2. Index d'unicite sur l'identifiant metier
// ---------------------------------------------------------------
// Le matricule est la cle lisible et unique demandee dans le sujet.
// L'index est cree ici sans modifier le script de M3.
db.etudiants.createIndex({ matricule: 1 }, { unique: true, name: "uniq_matricule" });
print("Index unique cree/verifie sur 'matricule'.");

// ---------------------------------------------------------------
// 3. Rejouabilite : retirer uniquement nos propres dossiers
// ---------------------------------------------------------------
const matricules = documents.map(function (d) { return d.matricule; });
const filtre = { matricule: { $in: matricules } };
const avant = db.etudiants.countDocuments(filtre);
const supprimes = db.etudiants.deleteMany(filtre);
print("Dossiers deja presents avant import : " + avant);
print("Dossiers remplaces (filtre precis)  : " + supprimes.deletedCount);

// ---------------------------------------------------------------
// 4. C3 / C4 : insertion groupee (insertMany)
// ---------------------------------------------------------------
const resultat = db.etudiants.insertMany(documents, { ordered: true });
print("insertMany : " + Object.keys(resultat.insertedIds).length + " document(s) insere(s).");

// ---------------------------------------------------------------
// 5. Controle final
// ---------------------------------------------------------------
print("");
print("--- CONTROLE APRES IMPORT ---");
print("Nombre total de documents dans etudiants : " + db.etudiants.countDocuments({}));
print("Matricules importes : " + matricules.join(", "));
print("Extraits :");
db.etudiants.find({ matricule: { $in: matricules } }).limit(2).forEach(function (doc) {
  printjson(doc);
});

print("");
print("--- HETEROGENEITE DES CHAMPS (utile a M4 pour S4) ---");
["certifications", "stages", "pieces_justificatives"].forEach(function (champ) {
  const f = {};
  f[champ] = { $exists: true };
  print("  " + champ + " : " + db.etudiants.countDocuments(f) + " dossier(s)");
});

print("");
print("=== FIN P2-02 ===");
