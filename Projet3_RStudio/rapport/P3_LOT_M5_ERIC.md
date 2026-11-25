# Projet 3 — Texte du lot M5 (à insérer dans le rapport final)

> **Destination :** remplacer les deux balises `> [LOT M5 - Partie D + Conclusion]`
> (section **5 — Partie D** et section **7 — Conclusion générale**) dans
> `RAPPORT_FINAL_P3_G2_MODELE.md`.
> **Responsable :** M5 — EVINA MBAHO ERIC · **Relecteur :** M3 — ANTOINE
> Livré séparément pour ne pas modifier le modèle assemblé par M1.

---

## Partie D — AFC + intelligence artificielle (D1 à D5)

**Responsable : M5 — EVINA MBAHO ERIC** | **Relecteur : M3 — ANTOINE**

### D1 — Reprise de l'AFC

L'AFC porte sur le croisement `Categorie_socioprofessionnelle` (4 modalités-lignes)
× `Satisfaction` (3 modalités-colonnes) calculé sur les 120 clients de
`donnees_prep.rds`. Le tableau de contingence est :

| Catégorie | Elevée | Faible | Moyenne | Total |
|---|---:|---:|---:|---:|
| Entrepreneur | 4 | 11 | 8 | 23 |
| Etudiant | 9 | 5 | 15 | 29 |
| Fonctionnaire | 5 | 7 | 13 | 25 |
| Salarié privé | 8 | 11 | 24 | 43 |

Les deux premiers axes portent **100 % de l'inertie** (axe 1 : 0,0521 soit 84,11 % ;
axe 2 : 0,0098 soit 15,89 %). Le plan factoriel est donc ici une représentation
complète du tableau, ce qui autorise une lecture directe des distances.

**Point de chaîne — à traiter par M1 à l'assemblage :** le script de M3
(`P3_02_afc_ANTOINE.R`) ne se parse pas (instruction `row lab = "left"` en ligne 129)
et utilise `get_pca_cos2` / `get_pca_contrib`, absents de `factoextra` 2.2.0. Il n'a
donc pas produit `res_afc.rds`. Le script M5 `P3_04_afc_kmeans_ERIC.R` privilégie
`res_afc.rds` s'il existe ; sinon il reconstruit l'objet avec **exactement le même
appel** (`CA(tab_afc, graph = FALSE)`), ce qui donne un résultat identique. La
capture `P3_M5_afc_kmeans_output.txt` indique explicitement quelle source a été
utilisée. M3 doit corriger son script avant la remise finale.

### D2 — Coordonnées des modalités-lignes

| Catégorie | Dim 1 | Dim 2 | cos² Dim 1 | cos² Dim 2 |
|---|---:|---:|---:|---:|
| Entrepreneur | +0,4276 | +0,0773 | 0,968 | 0,032 |
| Etudiant | −0,2581 | +0,1338 | 0,788 | 0,212 |
| Fonctionnaire | −0,0036 | −0,0459 | 0,006 | 0,994 |
| Salarié privé | −0,0526 | −0,1049 | 0,201 | 0,799 |

Modalités-colonnes : `Faible` (+0,3619 ; +0,0131), `Elevee` (−0,1770 ; +0,1723),
`Moyenne` (−0,1284 ; −0,0821).

Lecture prudente : `Entrepreneur` est très bien représenté par l'axe 1 (cos² 0,968)
et s'oppose à `Etudiant` sur cet axe. `Fonctionnaire` et `Salarié privé` sont presque
au centre de l'axe 1 et ne s'interprètent que par l'axe 2 (cos² 0,994 et 0,799) :
leur position sur l'axe 1 ne doit pas être commentée.

### D3 — K-means et groupe de chaque catégorie

Les coordonnées des 4 modalités-lignes sur les deux axes sont le seul input du
K-means : ni identifiant, ni effectif, ni variable initiale n'entre dans le calcul.
`nstart = 50` et `set.seed(2026)` sont fixés avant chaque exécution.

| k | Silhouette moyenne | Plus petit groupe |
|---:|---:|---:|
| 2 | **0,4327** | 1 |
| 3 | 0,3777 | 1 |

**k = 2 est retenu** (silhouette plus élevée et lecture plus simple). Résultat :

| Catégorie | Groupe | Silhouette individuelle |
|---|---:|---:|
| Entrepreneur | 1 | 0,0000 |
| Salarié privé | 2 | 0,6188 |
| Fonctionnaire | 2 | 0,5673 |
| Etudiant | 2 | 0,5447 |

Centres : groupe 1 (0,4276 ; 0,0773), groupe 2 (−0,1048 ; −0,0057). Le groupe 1 ne
contient qu'une modalité : sa silhouette individuelle vaut 0 par définition, pas
parce que le point est mal classé. Ce résultat doit donc être présenté comme une
**tendance**, pas comme une segmentation robuste (4 points seulement).

### D4 — Interprétation au regard du tableau de contingence

| Catégorie | Groupe | Elevée | Faible | Moyenne |
|---|---:|---:|---:|---:|
| Entrepreneur | 1 | 17,4 % | 47,8 % | 34,8 % |
| Etudiant | 2 | 31,0 % | 17,2 % | 51,7 % |
| Fonctionnaire | 2 | 20,0 % | 28,0 % | 52,0 % |
| Salarié privé | 2 | 18,6 % | 25,6 % | 55,8 % |

Le groupe 1 (`Entrepreneur`) se singularise par le taux de satisfaction **faible**
le plus élevé (47,8 %) et le taux de satisfaction **élevée** le plus bas (17,4 %).
Sa coordonnée positive sur l'axe 1 le place du même côté que la modalité `Faible`
(+0,3619) : l'AFC et le tableau confirment la même tendance.

Le groupe 2 rassemble les trois autres catégories. `Etudiant` est du côté de
`Elevee` sur l'axe 1 (31,0 % de satisfaction élevée, 17,2 % de faible), tandis que
`Salarié privé` et `Fonctionnaire` sont proches de l'origine et se distinguent
surtout sur l'axe 2. Le regroupement ne doit donc pas être lu comme « trois
catégories identiques », mais comme « trois catégories sans opposition forte sur
l'axe principal ».

### D5 — Apport de l'algorithme et perte due aux deux axes

**Apport.** Le K-means transforme une carte qualitative en groupes nommables et
reproductibles ; il donne une frontière explicite entre `Entrepreneur` et les
autres et confirme l'opposition visuelle de l'axe 1. Il fournit en outre un critère
chiffré (silhouette) pour justifier le choix de k.

**Perte.** Réduire le tableau à deux axes écrase les écarts perpendiculaires au plan :
`Fonctionnaire` a un cos² de 0,006 sur l'axe 1, donc sa position horizontale est
presque insignifiante. L'algorithme ne conserve ni les effectifs (23, 29, 25, 43),
ni les libellés des modalités, ni les valeurs initiales des clients. Enfin, une
classification est une **association** : elle ne dit pas pourquoi les entrepreneurs
sont moins satisfaits, et elle ne prouve aucune causalité (conclusion prudente B6
de M3).

---

## 7. Conclusion générale

Le projet a porté sur un même jeu de 120 clients synthétiques, préparé une seule
fois par M1 (`donnees_prep.rds`, 6 valeurs imputées) et partagé par tous, condition
indispensable pour que les quatre parties puissent être comparées.

1. **Parties A et C — variables quantitatives.** L'ACP a réduit les 7 variables
   quantitatives à quelques axes, puis le K-means appliqué à ses coordonnées a
   proposé des profils de consommation. Le module spécifique du Groupe 2 a affiné
   cette lecture par les contributions et les cos², en distinguant les
   interprétations robustes des interprétations prudentes. *Les chiffres définitifs
   de ces deux parties sont ceux livrés par M2 et M4 ; M1 les insère à l'assemblage
   sans modifier la présente synthèse.*

2. **Parties B et D — variables qualitatives.** L'AFC montre une association entre
   catégorie socioprofessionnelle et satisfaction : les entrepreneurs se
   distinguent par 47,8 % de satisfaction faible, les étudiants par 31,0 % de
   satisfaction élevée. Le K-means sur les coordonnées AFC confirme cette tendance
   avec k = 2 (silhouette 0,4327) mais ne permet pas une segmentation solide, le
   jeu ne contenant que 4 modalités.

3. **Apport et limites de la classification factorielle.** Projeter puis classifier
   rend la lecture plus simple et donne un critère objectif de choix de k ; en
   revanche, la réduction à deux axes et la perte des effectifs appauvrissent
   l'interprétation. Le critère de silhouette doit toujours être accompagné du cos²
   et du tableau de contingence d'origine.

4. **Limites générales.** Échantillon petit (n = 120), données synthétiques,
   6 valeurs imputées, réduction à deux axes, absence de contrôle des autres
   facteurs (âge, revenu, ancienneté, offre souscrite). **Une association n'est pas
   une causalité** : aucune conclusion du type « la catégorie X cause la
   satisfaction Y » n'est recevable sur la base de ces seuls résultats.

---

**Fichiers livrés par M5 :**
`scripts/P3_04_afc_kmeans_ERIC.R`,
`captures/P3_M5_afc_kmeans_output.txt`,
`captures/P3_D1_eig_axes.png`,
`captures/P3_D1_D2_carte_afc.png`,
`captures/P3_D3_kmeans_groupes.png`,
`rapport/P3_LOT_M5_ERIC.md`.
