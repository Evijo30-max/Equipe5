# Projet 1 — Texte du lot M5 (à insérer dans le rapport final)

> **Destination :** remplacer la balise `> [LOT M5]` de la section
> **IV — G2-T5, T10 et test global** dans `RAPPORT_FINAL_P1_G2_MODELE.md`.
> **Responsable :** M5 — EVINA MBAHO ERIC · **Relecteur :** M4 — ABBO
> Livré séparément pour ne pas modifier le modèle assemblé par M1.

---

## G2-T5, T10 et test global

**Responsable : M5 — EVINA MBAHO ERIC** | **Relecteur : M4 — ABBO**

### 1. Test global — rejeu des scripts dans l'ordre

Procédure à suivre sur une base vierge (aucune donnée conservée d'une séance
précédente) :

| Ordre | Script | Auteur | Rôle |
|---:|---|---|---|
| 1 | `P1_01_socle_GULLIT.sql` | M1 | supprime/recrée `entreprise_tp`, 6 tables, données initiales |
| 2 | `P1_02_privileges_M2.sql` | M2 | rôles, comptes, privilèges |
| 3 | `P1_03_pgvector_ANTOINE.sql` | M3 | extension `vector`, colonnes vectorielles, données M3 |
| 4 | `P1_04_triggers_stock_ABBO.sql` | M4 | déclencheurs T1-T4 (à créer **après** les données initiales) |
| 5 | `P1_05_requetes_M2.sql` | M2 | jointures T6 et sous-requête T7 |
| 6 | `P1_06_vectoriel_stock_ANTOINE.sql` | M3 | recherche T8 et stocks associés T9 |
| 7 | `P1_07_tests_transactions_ERIC.sql` | M5 | contrôles + cas T5 |

Commande de rejeu (PowerShell, depuis `Projet1_PostgreSQL/scripts/`) :

```powershell
$PSQL = 'C:\Program Files\PostgreSQL\18\bin\psql.exe'
foreach ($f in @(
  'P1_01_socle_GULLIT.sql',
  'P1_02_privileges_M2.sql',
  'P1_03_pgvector_ANTOINE.sql',
  'P1_04_triggers_stock_ABBO.sql',
  'P1_05_requetes_M2.sql',
  'P1_06_vectoriel_stock_ANTOINE.sql',
  'P1_07_tests_transactions_ERIC.sql')) {
  if (Test-Path $f) { & $PSQL -w -U postgres -h 127.0.0.1 -f $f }
  else { Write-Host "EN ATTENTE : $f n est pas encore livre" }
}
```

**Résultat du rejeu partiel effectué le 25/11/2026** (capture
`captures/P1_M5_tests_transactions_output.txt`) :

| Contrôle | Attendu | Obtenu | Conclusion |
|---|---|---|---|
| Tables présentes | 6 | 6 | OK |
| `clients` / `utilisateurs` / `produits` | 5 / 4 / 5 | 5 / 4 / 5 | OK |
| `commandes` / `lignes_commande` / `paiements` | 5 / 10 / 5 | 5 / 10 / 5 | OK |
| Extension `vector` | présente | **NON INSTALLEE** | environnement local sans pgvector |
| Déclencheurs utilisateurs | T1-T4 (M4) | 0 | **lot M4 non livré** |

Le script M5 détecte l'absence de déclencheur et affiche
`EN ATTENTE DU LOT M4` au lieu de produire des résultats trompeurs. Il faudra le
rejouer dès que `P1_04_triggers_stock_ABBO.sql` sera commité, puis remplacer la
capture `P1_M5_tests_transactions_output.txt` par le nouveau résultat. Les scripts M2/M3
absents de l'arborescence au moment de ce lot sont signalés dans la même boucle.

**Environnement de la capture :** cluster PostgreSQL 18.6 temporaire, port 55432,
authentification `trust`, créé hors du dépôt uniquement pour reproduire le socle
de M1 sans demander le mot de passe du serveur de production. Le serveur local de
M1 (`localhost:5432`) n'a pas été modifié.

### 2. G2-T5 — Tableau des tests transactionnels

Le script `P1_07_tests_transactions_ERIC.sql` affiche le stock avant, pendant et
après chaque transaction. Les valeurs ci-dessous proviennent d'une **validation
de méthode avec des déclencheurs temporaires de simulation** (fichier hors dépôt,
jamais commité) : elles prouvent que le script M5 s'exécute correctement, **elles
ne valident pas le lot M4**. Le tableau définitif sera rempli après rejeu avec les
vrais déclencheurs de M4.

| Cas | Action | Stock avant | Pendant | Après | Résultat attendu |
|---|---|---:|---:|---:|---|
| 1 | `INSERT` 2 claviers sur la commande 2, puis `COMMIT` | 30 | 28 | **28** | baisse définitive du stock |
| 2 | `INSERT` 9999 ordinateurs sur la commande 2 → erreur, puis `ROLLBACK` | 10 | erreur | **10** | stock insuffisant refusé, rien n'est confirmé |
| 3 | `UPDATE` de 2 à 5 claviers, puis `COMMIT` | 28 | 25 | **25** | l'écart (+3) est décrémenté une seule fois |
| 4 | `DELETE` de la ligne, puis `ROLLBACK` | 25 | 30 | **25** | restitution annulée par le ROLLBACK |

Points de méthode :

- **ne jamais décrémenter le stock à la main** en plus du déclencheur : ce serait
  compter la sortie deux fois (le script M5 ne fait que lire le stock) ;
- l'erreur attendue du cas 2 est volontairement laissée visible : `ON_ERROR_STOP`
  est désactivé uniquement le temps du `ROLLBACK`, puis réactivé ;
- les deux insertions du cas 1 et du cas 2 portent sur des couples
  `(id_commande, id_produit)` distincts, pour ne pas être masquées par la contrainte
  `UNIQUE(id_commande, id_produit)` ;
- `set.seed` n'est pas pertinent ici (PostgreSQL), mais l'ordre de rejeu l'est :
  les déclencheurs doivent être créés **après** le chargement des stocks initiaux.

Capture de validation de méthode :
`captures/P1_M5_tests_avec_declencheurs_SIMULATION.txt`.

### 3. G2-T10 — Pourquoi deux produits similaires ne sont pas interchangeables

La recherche vectorielle de M3 (T8) renvoie des produits **proches dans l'espace
des caractéristiques** : par exemple un clavier et une souris, ou deux modèles de
clavier, peuvent avoir une distance cosinus faible. Cette proximité est une
similarité de *description*, pas une équivalence *fonctionnelle*.

Trois raisons de ne pas les considérer comme interchangeables :

1. **La similarité porte sur un vecteur partiel.** Le vecteur ne retient que
   quelques attributs (libellé, prix, caractéristiques techniques). Deux produits
   proches peuvent différer sur un attribut non vectorisé (compatibilité, garantie,
   délai de livraison). Une petite distance ne garantit pas les mêmes usages.
2. **La similarité est symétrique, la disponibilité ne l'est pas.** Le résultat de
   T9 montre les stocks : un produit peut être à 30 unités et son « voisin » à 0.
   Remplacer l'un par l'autre suppose une disponibilité réelle au moment de la
   commande, ce que la distance ne mesure pas. Le déclencheur de M4 peut d'ailleurs
   refuser la sortie si le stock est insuffisant (cas 2 de T5).
3. **Le prix et la marge ne suivent pas la distance.** Deux vecteurs proches peuvent
   avoir des prix éloignés ; substituer l'un à l'autre change le montant de la
   commande et le chiffre d'affaires.

Formulation à retenir à l'oral : *« La recherche vectorielle répond à "qu'est-ce
qui ressemble à ce produit ?", pas à "qu'est-ce qui peut le remplacer en stock ?".
Pour répondre à la deuxième question, il faut croiser le résultat avec la table
des stocks (T9) et avec les contraintes métier (T5). »*

Les distances « attendues » annotées dans les commentaires de M3
(≈ 0,0069 ; ≈ 0,0123 ; ≈ 0,0035 ; ≈ 0,0118 ; ≈ 0,7769) sont des ordres de
grandeur indicatifs. **Les valeurs à citer sont celles réellement affichées dans
les captures de M3**, l'environnement local n'ayant pas `pgvector` installé.

### 4. Relecture demandée à M4

M4 est invité à : (a) relire le prérequis « déclencheurs créés après les données
initiales », (b) rejouer `P1_07` avec ses vrais déclencheurs et contrôler les
quatre lignes du tableau T5, (c) vérifier que le cas 2 lève bien une exception
claire (`RAISE EXCEPTION`) plutôt qu'une simple violation de contrainte, et
(d) confirmer que le script M5 ne modifie jamais le stock directement.

---

**Fichiers livrés par M5 :**
`scripts/P1_07_tests_transactions_ERIC.sql`,
`captures/P1_M5_tests_transactions_output.txt`,
`captures/P1_M5_tests_avec_declencheurs_SIMULATION.txt`,
`rapport/P1_LOT_M5_ERIC.md`,
`presentation/P1_support_presentation_ERIC.md`.
