/**
 * P2_01_structure.js
 * ------------------
 * Projet 2 — MongoDB (Groupe 5 : Gestion des dossiers étudiants)
 *
 * Tâches : C2 (créer base + collection) + S1 (créer collection) +
 *          S3 (concevoir le modèle du document) + $jsonSchema optionnel
 *
 * Responsable : M3 — NGUEGNI ONGOLO ANTOINE
 * Livrables :   01_structure.js, modèle du document (schéma),
 *               texte comparatif S8
 *
 * Pré-requis :   MongoDB installé et accessible (voir fiche C1 du chef)
 * Étape :        Étape 1 du projet (Cadrage) — exécuter AVANT
 *                que M5 crée le jeu de données.
 *
 * Ordre d'exécution dans mongosh :
 *   mongosh "mongodb://localhost:27017/etudiants_db"
 *   > load("P2_01_structure.js")
 */

"use strict";

// ============================================================
// C2 / S1 — Créer la base et la collection
// ============================================================
// MongoDB crée la base au premier document inséré. Pour être
// explicite, on crée la collection.
db.createCollection("etudiants");
print("Collection `etudiants` créée (si elle n'existait pas).");

// [CAPTURE] P2_S1_collection_etudiants.png
// sh > show collections
//   etudiants

// ============================================================
// S3 — Le modèle du document étudiant (à partager avec M5)
// ============================================================
// Ce modèle est le contrat entre M3 (conception) et M5 (données).
// Il doit être validé par l'équipe avant que M5 crée les documents.
//
// Règles de modélisation (justifiées dans le rapport) :
//   1. Un identifiant lisible et UNIQUE : `matricule` (pas _id auto).
//   2. Imbrication (sub-documents) pour les blocs logiques :
//        - identite   : nom, prénom, date de naissance, sexe
//        - formation  : filière, niveau, année, UE (tableau)
//        - coordonnees: email, téléphone, adresse
//   3. Tableaux pour les éléments multiples (UE, certifications,
//      stages) — pas une table par type.
//   4. Champs optionnels (S4) : pièces_justificatives,
//      certifications, stages — présents seulement chez certains
//      étudiants. On ne force PAS le même schéma à tous.
//
// Exemple de document type (celui-ci servira de référence à M5) :
//
//   {
//     matricule: "ETU-2026-0001",
//     identite: {
//       nom: "MBARGA",
//       prenoms: "Sylvie",
//       date_naissance: "2003-05-12",
//       sexe: "F"
//     },
//     formation: {
//       filiere: "Informatique",
//       niveau: "L3",
//       annee: "2025-2026",
//       ue: ["BDD NoSQL", "IA", "Réseaux"]
//     },
//     coordonnees: {
//       email: "sylvie.mbarga@etu.univ.cm",
//       telephone: "+237 690 11 22 33",
//       adresse: { ville: "Douala", quartier: "Akwa" }
//     },
//     // Champs optionnels (S4) — absents chez certains :
//     certifications: [
//       { nom: "Certification CCNA", date_obtention: "2025-07-01" }
//     ],
//     stages: [
//       { entreprise: "CamerDigital", periode: "2024-2025", statut: "termine" }
//     ],
//     pieces_justificatives: [
//       { type: "bulletin_semestre_1", date_depot: "2025-10-15" }
//     ]
//   }
//
// ============================================================
// Règle de validation $jsonSchema (OPTIONNELLE mais recommandée)
// ============================================================
// On valide UNSEULEMENT les champs obligatoires (S3). Les champs
// S4 (optionnels) ne sont PAS contraints pour laisser la souplesse
// du schéma flexible.

db.createCollection("etudiants", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: [
        "matricule",
        "identite",
        "formation",
        "coordonnees"
      ],
      properties: {
        matricule: {
          bsonType: "string",
          pattern: "^ETU-[0-9]{4}-[0-9]{4}$",
          description: "Matricule lisible, unique, au format ETU-AAAA-NNNN"
        },
        identite: {
          bsonType: "object",
          required: ["nom", "prenoms"],
          properties: {
            nom: { bsonType: "string" },
            prenoms: { bsonType: "string" },
            date_naissance: { bsonType: "string" },
            sexe: { enum: ["M", "F"] }
          }
        },
        formation: {
          bsonType: "object",
          required: ["filiere", "niveau", "annee"],
          properties: {
            filiere: { bsonType: "string" },
            niveau: { enum: ["L1", "L2", "L3", "M1", "M2"] },
            annee: { bsonType: "string" },
            ue: {
              bsonType: "array",
              items: { bsonType: "string" }
            }
          }
        },
        coordonnees: {
          bsonType: "object",
          required: ["email"],
          properties: {
            email: {
              bsonType: "string",
              pattern: "^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$"
            },
            telephone: { bsonType: "string" },
            adresse: {
              bsonType: "object",
              properties: {
                ville: { bsonType: "string" },
                quartier: { bsonType: "string" }
              }
            }
          }
        },
        // Les champs S4 sont INTENTIONNELLEMENT absents du schéma
        // de validation : ils peuvent exister sans être contraints.
        certifications: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["nom", "date_obtention"],
            properties: {
              nom: { bsonType: "string" },
              date_obtention: { bsonType: "string" }
            }
          }
        },
        stages: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["entreprise", "periode"],
            properties: {
              entreprise: { bsonType: "string" },
              periode: { bsonType: "string" },
              statut: { enum: ["en_cours", "termine", "annule"] }
            }
          }
        },
        pieces_justificatives: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["type", "date_depot"],
            properties: {
              type: { bsonType: "string" },
              date_depot: { bsonType: "string" }
            }
          }
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

print("Validation $jsonSchema appliquée sur `etudiants`.");
print("  - Champs OBLIGATOIRES : matricule, identite, formation, coordonnees.");
print("  - Champs OPTIONNELS  : certifications, stages, pieces_justificatives.");
print("  - validationLevel    : strict   (tous les inserts sont validés)");
print("  - validationAction   : error    (un document invalide est refusé)");

// [CAPTURE] P2_S3_jsonSchema_etudiants.png
// sh > db.getCollectionInfos({ name: "etudiants" })

// ============================================================
// Contrôle final — la collection existe et est vide
// ============================================================
print("\nÉtat final :");
print("  Collection        : " + db.getCollectionNames().join(", "));
print("  Nombre de docs    : " + db.etudiants.countDocuments({}));
print("  Indexes           :");
db.etudiants.getIndexes().forEach(i => print("   - " + JSON.stringify(i)));

// ============================================================
// S8 — Comparaison document vs relationnel (texte à insérer dans
// le rapport — rédigé dans P2_S8_comparaison.md)
// ============================================================
// L'exemple de schéma relationnel équivalent serait :
//
//   etudiants( matricule PK, nom, prenom, date_naissance, sexe,
//              id_filiere FK, email, telephone, adresse )
//   filieres ( id_filiere PK, nom, niveau, annee )
//   ue ( id_ue PK, code, intitule )
//   inscriptions_ue ( id_etudiant FK, id_ue FK )
//   certifications ( id_certif PK, id_etudiant FK, nom, date_obtention )
//   stages ( id_stage PK, id_etudiant FK, entreprise, periode, statut )
//   pieces_justificatives ( id_pj PK, id_etudiant FK, type, date_depot )
//
// Pour afficher le dossier complet d'un étudiant, il faudrait
// 4 à 7 JOIN selon les informations souhaitées. Avec MongoDB,
// 1 seul find() par matricule suffit.

