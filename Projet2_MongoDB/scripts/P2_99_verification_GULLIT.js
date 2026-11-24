// =====================================================================
// Projet 2 - MongoDB - Groupe 5 "Gestion des dossiers étudiants"
// ITT3-IR - Role M1 Chef d'equipe : KEUMEKA SOKING WILFRIED GULLIT
//
// P2_99_verification_GULLIT.js  (Livrable C8)
//
// Objectif : executer tous les controles finaux sur la base universite_tp
// et la collection etudiants :
//   1. existence de la collection + comptage total
//   2. apercu formatte + heterogeneite des schemas (champs optionnels)
//   3. aggregations : effectif par filiere, par niveau et croise
//   4. verification de la suppression controlee du dossier de test C7/S7
//
// Ce script est READ-ONLY : il ne modifie aucune donnee.
//
// Execution recommande :
//   docker cp P2_99_verification_GULLIT.js mongodb-tp:/tmp/P2_99_verification_GULLIT.js
//   docker exec -it mongodb-tp mongosh -u admin -p <MOT_DE_PASSE_MONGO> \
//     --authenticationDatabase admin --file /tmp/P2_99_verification_GULLIT.js
// =====================================================================

// --- Parametres (adapter ici les criteres du dossier de test C7/S7) ---
const NOM_BASE = 'universite_tp';
const NOM_COLLECTION = 'etudiants';
const MATRICULE_TEST = 'TEST-C7-S7';
const EMAIL_TEST = 'test.suppression@universite.local';
const NOM_TEST = 'DOSSIER_TEST_SUPPRESSION';

// Bascule explicite sur la base cible du Groupe 5.
db = db.getSiblingDB(NOM_BASE);

print('=== P2-99 CONTROLES FINAUX - GROUPE 5 ===');
print('Horodatage : ' + new Date().toISOString());
print('Base active : ' + db.getName());
print('Version du serveur : ' + db.version());

// ---------------------------------------------------------------------
// 1. Existence de la collection et comptage total
// ---------------------------------------------------------------------
print('');
print('--- 1. EXISTENCE DE LA COLLECTION ET COMPTAGE ---');
var nomsCollections = db.getCollectionNames();
var collectionPresente = (nomsCollections.indexOf(NOM_COLLECTION) !== -1);
var totalDocuments = 0;

print('Collections de ' + NOM_BASE + ' : ' + JSON.stringify(nomsCollections));
print('Collection "' + NOM_COLLECTION + '" : ' + (collectionPresente ? 'PRESENTE' : 'ABSENTE'));

if (collectionPresente) {
  totalDocuments = db.getCollection(NOM_COLLECTION).countDocuments({});
}
print('Nombre total de documents : ' + totalDocuments);

if (!collectionPresente || totalDocuments === 0) {
  print('>>> EN ATTENTE : le lot M3 (01_structure.js + insertions) doit encore alimenter la collection.');
  print('>>> Les controles 2 et 3 sont ignores tant que la collection est vide.');
}

// ---------------------------------------------------------------------
// 2. Apercu formatte + heterogeneite des schemas
// ---------------------------------------------------------------------
if (collectionPresente && totalDocuments > 0) {
  print('');
  print('--- 2a. APERCUS DES 10 PREMIERS DOCUMENTS ---');
  db.getCollection(NOM_COLLECTION).find().limit(10).forEach(function(doc) {
    printjson(doc);
  });

  print('');
  print('--- 2b. HETEROGENEITE DES SCHEMAS (champs optionnels) ---');
  var champsOptionnels = ['pieces_justificatives', 'certifications', 'stages'];
  champsOptionnels.forEach(function(champ) {
    var filtre = {};
    filtre[champ] = { $exists: true };
    var nb = db.getCollection(NOM_COLLECTION).countDocuments(filtre);
    print('  ' + champ + ' : ' + nb + ' document(s) sur ' + totalDocuments);
  });

  print('');
  print('--- 2c. FREQUENCE DE TOUS LES CHAMPS OBSERVES ---');
  db.getCollection(NOM_COLLECTION).aggregate([
    { $project: { listeChamps: { $objectToArray: '$$ROOT' } } },
    { $unwind: '$listeChamps' },
    { $group: { _id: '$listeChamps.k', occurrences: { $sum: 1 } } },
    { $sort: { occurrences: -1, _id: 1 } }
  ]).forEach(function(row) {
    print('  ' + row._id + ' : ' + row.occurrences);
  });
}

// ---------------------------------------------------------------------
// 3. Aggregations recapitulatives
// ---------------------------------------------------------------------
if (collectionPresente && totalDocuments > 0) {
  print('');
  print('--- 3a. EFFECTIF PAR FILIERE ---');
  db.getCollection(NOM_COLLECTION).aggregate([
    { $group: { _id: '$filiere', effectif: { $sum: 1 } } },
    { $sort: { _id: 1 } }
  ]).forEach(function(row) { printjson(row); });

  print('');
  print('--- 3b. EFFECTIF PAR NIVEAU ---');
  db.getCollection(NOM_COLLECTION).aggregate([
    { $group: { _id: '$niveau', effectif: { $sum: 1 } } },
    { $sort: { _id: 1 } }
  ]).forEach(function(row) { printjson(row); });

  print('');
  print('--- 3c. EFFECTIF CROISE FILIERE x NIVEAU ---');
  db.getCollection(NOM_COLLECTION).aggregate([
    { $group: { _id: { filiere: '$filiere', niveau: '$niveau' }, effectif: { $sum: 1 } } },
    { $sort: { '_id.filiere': 1, '_id.niveau': 1 } }
  ]).forEach(function(row) { printjson(row); });
}

// ---------------------------------------------------------------------
// 4. Suppression controlee du dossier de test (C7 / S7)
// ---------------------------------------------------------------------
print('');
print('--- 4. VERIFICATION DE LA SUPPRESSION CONTROLEE C7/S7 ---');
print('Criteres : matricule=' + MATRICULE_TEST +
      ' OU email=' + EMAIL_TEST +
      ' OU nom=' + NOM_TEST);

var dossiersRestants = 0;
if (collectionPresente) {
  dossiersRestants = db.getCollection(NOM_COLLECTION).countDocuments({
    $or: [
      { matricule: MATRICULE_TEST },
      { email: EMAIL_TEST },
      { nom: NOM_TEST }
    ]
  });
}
print('Dossiers de test restants : ' + dossiersRestants);
if (dossiersRestants === 0) {
  print('RESULTAT : OK - le dossier de test a bien ete supprime (ou n a jamais ete insere).');
} else {
  print('RESULTAT : ANOMALIE - ' + dossiersRestants + ' dossier(s) de test subsistent.');
}

print('');
print('=== FIN DES CONTROLES P2-99 ===');
