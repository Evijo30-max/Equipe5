# Projet 2 — MongoDB : fiche d'installation et de connexion (Livrable C1)

**ITT3-IR — Groupe 5 — Rôle M1 Chef d'équipe : KEUMEKA SOKING WILFRIED GULLIT**

---

## 1. État du Docker au moment du diagnostic

| Élément | Résultat observé |
|---|---|
| Docker Client / Server | `29.9.2` / `29.9.2` |
| Image MongoDB | `mongo:8.0` — ID `b9924c330a8b` — 1,28 Go |
| Conteneur MongoDB | `mongodb-tp` — image `mongo:8.0` — initialement `Exited (255)` |
| Mappage de port | `127.0.0.1:27017 -> 27017/tcp` |
| Authentification | `MONGO_INITDB_ROOT_USERNAME=admin` / `MONGO_INITDB_ROOT_PASSWORD=<MOT_DE_PASSE_MONGO>`, base `admin` |
| Version du serveur | `8.0.34` |
| Bases présentes | `admin`, `config`, `local`, `tp_bases` |

> ⚠️ La base attendue `universite_tp` n'existe pas encore au moment de ce diagnostic : elle sera créée par le script `01_structure.js` du lot M3-Antoine. La base `tp_bases` contient un document de test isolé (`nom: 'Prince'`) qui ne doit **pas** être confondu avec le jeu de données du Groupe 5.

---

## 2. Commandes exactes de démarrage et de vérification (PowerShell)

```powershell
# 1. Inventaire des conteneurs et images MongoDB
docker ps -a --format '{{.Names}} | {{.Image}} | {{.Status}} | {{.Ports}}'
docker images --format '{{.Repository}}:{{.Tag}} | {{.ID}} | {{.Size}}'

# 2. Démarrage du conteneur existant
docker start mongodb-tp

# 3. Vérification de l'état (doit afficher "Up ... 127.0.0.1:27017->27017/tcp")
docker ps --filter name=mongodb-tp --format '{{.Names}} | {{.Status}} | {{.Ports}}'

# 4. Contrôle des logs de démarrage
docker logs --tail 20 mongodb-tp

# 5. Contrôle réseau depuis l'hôte Windows
Test-NetConnection -ComputerName 127.0.0.1 -Port 27017

# 6. Test de connexion mongosh avec les identifiants root
docker exec mongodb-tp mongosh --quiet -u admin -p <MOT_DE_PASSE_MONGO> --authenticationDatabase admin --eval "print('VERSION=' + db.version())"
```

Si le conteneur n'existe plus, le recréer à partir de l'image déjà présente (le volume interne `/data/db` est conservé tant que le conteneur n'est pas supprimé) :

```powershell
docker run -d --name mongodb-tp -p 27017:27017 `
  -e MONGO_INITDB_ROOT_USERNAME=admin `
  -e MONGO_INITDB_ROOT_PASSWORD=<MOT_DE_PASSE_MONGO> `
  mongo:8.0
```

---

## 3. Connexion via `mongosh`

### 3.1 En ligne de commande, à l'intérieur du conteneur (méthode recommandée)

`mongosh` est bien présent dans l'image (`/usr/bin/mongosh`) ; la commande legacy `mongo` n'existe plus en version 8.0.

```powershell
docker exec -it mongodb-tp mongosh -u admin -p <MOT_DE_PASSE_MONGO> --authenticationDatabase admin
```

Une fois dans le shell :

```javascript
show dbs                 // admin, config, local, tp_bases, (universite_tp après création)
use universite_tp
show collections         // etudiants
db.etudiants.countDocuments({})
db.etudiants.find().limit(5).pretty()
db.version()             // 8.0.34
```

Mode non interactif (utile pour les scripts et les captures) :

```powershell
docker exec mongodb-tp mongosh --quiet -u admin -p <MOT_DE_PASSE_MONGO> --authenticationDatabase admin `
  --eval "print(db.version()); db.getMongo().getDBNames().forEach(d => print(d))"
```

> Astuce PowerShell : pour éviter les problèmes de guillemets doubles avec `docker exec`, écrire le JavaScript dans une chaîne à apostrophes ou dans un fichier `.js` copié via `docker cp`, puis le lancer avec `--file /tmp/mon_script.js`.

### 3.2 En local depuis le poste Windows (`mongodb://localhost:27017`)

`mongosh` n'est **pas installé** sur le poste au moment du diagnostic. Deux possibilités :

1. Utiliser exclusivement `docker exec` (méthode retenue pour ce TP) ;
2. Installer `mongosh` (MongoDB Shell) sur Windows, puis :

```powershell
# Connexion à la base d'authentification admin
mongosh "mongodb://admin:<MOT_DE_PASSE_MONGO>@localhost:27017/admin?authSource=admin"

# Connexion directe à la base du Groupe 5
mongosh "mongodb://localhost:27017/universite_tp" -u admin -p <MOT_DE_PASSE_MONGO> --authenticationDatabase admin
```

Si l'authentification est désactivée sur une autre instance locale, la forme minimale devient `mongosh "mongodb://localhost:27017/universite_tp"`.

### 3.3 Connexion via MongoDB Compass

| Paramètre | Valeur |
|---|---|
| URI complète | `mongodb://admin:<MOT_DE_PASSE_MONGO>@localhost:27017/?authSource=admin` |
| Host | `localhost` |
| Port | `27017` |
| Authentication | `Username / Password` |
| Username | `admin` |
| Password | `<MOT_DE_PASSE_MONGO>` |
| Authentication database | `admin` |
| TLS / SSL | Désactivé |
| Base à ouvrir après connexion | `universite_tp` → collection `etudiants` |

Dans Compass, l'URI peut être collée directement dans la barre de connexion. Le bouton **Connect** doit afficher `admin@localhost:27017`. En cas d'échec, vérifier que le conteneur est bien `Up` et que le port 27017 n'est pas pris par un autre service.

---

## 4. Structure attendue de la base `universite_tp`

- **Base** : `universite_tp`
- **Collection principale** : `etudiants`
- **Un document = un dossier étudiant complet** (pas de normalisation en tables filles).

Champs de base attendus (à confirmer avec `01_structure.js`) :

| Champ | Type MongoDB | Remarque |
|---|---|---|
| `_id` | `ObjectId` | Généré automatiquement |
| `matricule` | `string` | Identifiant métier, unique |
| `nom`, `prenom` | `string` | Obligatoires |
| `date_naissance` | `ISODate` | Type date natif |
| `email`, `telephone` | `string` | Contact |
| `filiere`, `niveau` | `string` | Utilisés par les agrégations C8 |
| `statut` | `string` | Ex. `ACTIF`, `SUSPENDU` |
| `adresse` | **sous-document** | `{ ville, quartier, code_postal }` |
| `notes` | **tableau de sous-documents** | `[{ matiere, note }]` |

Champs optionnels illustrant l'hétérogénéité des schémas :

| Champ | Type | Présence |
|---|---|---|
| `pieces_justificatives` | tableau | Optionnel — variant selon le dossier |
| `certifications` | tableau | Optionnel |
| `stages` | tableau | Optionnel |

Exemple de document cible :

```javascript
{
  matricule: 'ETU2026001',
  nom: 'Alice',
  prenom: 'Mballa',
  date_naissance: new Date('2003-04-12'),
  email: 'alice@universite-tp.cm',
  telephone: '+237 6XX XXX XXX',
  filiere: 'Informatique',
  niveau: 'Licence 3',
  statut: 'ACTIF',
  adresse: { ville: 'Yaounde', quartier: 'Mendong', code_postal: 'CPP001' },
  notes: [ { matiere: 'Bases de données', note: 15 } ],
  pieces_justificatives: [ { type: 'CNI', reference: 'CNI-12345' } ],
  certifications: [ { libelle: 'MongoDB Associate', annee: 2026 } ],
  stages: [ { entreprise: 'TpTech', periode: 'Janvier-Mars 2026' } ]
}
```

Le script `P2_99_verification_GULLIT.js` contrôle précisément la présence de ces trois champs optionnels et produit les agrégations par filière et par niveau.

---

## 5. Preuve d'exécution

La capture du test de connexion propre est conservée dans :

```text
Projet2_MongoDB/captures/P2_C1_connexion_output.txt
```

Elle contient l'horodatage, la version `8.0.34`, le résultat de `show dbs` et le statut d'authentification (`admin`, rôle `root` sur `admin`).

> Les identifiants ci-dessus sont ceux du conteneur pédagogique local. En environnement de production, ils doivent être remplacés et injectés via un gestionnaire de secrets.
