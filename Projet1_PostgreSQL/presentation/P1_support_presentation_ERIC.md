# Support de présentation — Projet 1 (PostgreSQL)

**Préparé par M5 — EVINA MBAHO ERIC** · ITT3-IR Groupe 2 · Soutenance Projet 1

> Format diaporama en Markdown : chaque séparateur `---` correspond à une diapositive.
> Le chef (M1) peut convertir ce fichier en `.pptx` ou le recopier dans le support
> commun. Les lignes « À DIRE » sont les notes de l'orateur, volontairement écrites
> sans jargon pour un public non informaticien.

---

## 1. Projet 1 — Une base pour une entreprise

**Gestion des commandes et des stocks — Groupe 2**

- Une base de données = un classeur géant, mais avec des règles de cohérence.
- 6 tables : clients, utilisateurs, produits, commandes, lignes de commande, paiements.
- Question du projet : **comment garder le stock exact quand une commande change ?**

**À DIRE :** « Quand un client commande deux claviers, il faut que le nombre de
claviers en rayon baisse de deux, automatiquement. C'est tout le problème. »

---

## 2. Les 6 tables, en une image

```
clients ──< commandes >── lignes_commande >── produits
              │                                 
              └── paiements        utilisateurs ──┘
```

- `lignes_commande` contient les quantités : c'est le point sensible.
- `produits.stock` est la valeur à protéger (jamais négative).

**À DIRE :** « On ne tape jamais le stock à la main. La base le calcule toute seule
dès qu'une ligne de commande est modifiée. »

---

## 3. Le déclencheur : un employé invisible

Un **déclencheur** (trigger) = une règle automatique attachée à une table.

| Événement | Action automatique |
|---|---|
| Ajout d'une ligne | décrémenter le stock |
| Quantité modifiée | ajuster la différence |
| Ligne supprimée | restituer la quantité |
| Stock insuffisant | refuser la commande avec un message clair |

**À DIRE :** « C'est comme un employé qui regarde le registre des commandes et
met à jour le stock en temps réel, sans qu'on ait à le lui demander. »

---

## 4. Test 1 — Une commande confirmée

| Étape | Stock du clavier |
|---|---:|
| Avant | 30 |
| Pendant la transaction | 28 |
| Après validation (`COMMIT`) | **28** |

**À DIRE :** « On ajoute une commande, on regarde le stock *pendant* l'opération,
puis on valide. Le résultat reste à 28 : la baisse est bien enregistrée. »

---

## 5. Test 2 — Une commande impossible

| Étape | Stock de l'ordinateur |
|---|---:|
| Avant | 10 |
| Tentative de 9999 unités | **refusée** |
| Après annulation (`ROLLBACK`) | **10** |

**À DIRE :** « On a demandé plus que ce qui existe. Le système a refusé, et comme
on a annulé l'opération, le stock n'a pas bougé. C'est la preuve qu'on ne peut pas
vendre quelque chose qu'on n'a pas. »

---

## 6. Test 3 — On corrige la quantité

| Étape | Stock du clavier |
|---|---:|
| Avant | 28 |
| On passe de 2 à 5 unités | 25 |
| Après validation | **25** |

**À DIRE :** « On s'était trompé dans la quantité. On corrige, et le stock est
ajusté de la *différence* seulement — pas deux fois. C'est piégeux, c'est pour ça
qu'on le teste. »

---

## 7. Test 4 — On supprime, puis on annule

| Étape | Stock du clavier |
|---|---:|
| Avant | 25 |
| Ligne supprimée | 30 (quantité rendue) |
| `ROLLBACK` | **25** |

**À DIRE :** « Supprimer une ligne rend les produits au stock.Mais si on annule la
suppression, le stock revient à 25. L'annulation remet tout comme avant, y compris
le travail automatique du déclencheur. »

---

## 8. Le test global

On **rejoue tous les scripts depuis zéro**, dans l'ordre, et on vérifie :

- 6 tables présentes ;
- 5 clients, 4 utilisateurs, 5 produits, 5 commandes, 10 lignes, 5 paiements ;
- extension de recherche vectorielle disponible ou signalée absente ;
- déclencheurs présents avant de lancer les tests.

**À DIRE :** « Un logiciel qui marche une fois ne prouve rien. On recommence
depuis une base vierge pour être sûr que ça marche toujours. »

---

## 9. Produits similaires ≠ produits interchangeables

La recherche vectorielle répond à : *« qu'est-ce qui ressemble ? »*
Elle ne répond pas à : *« qu'est-ce qui est disponible ? »*

| Similarité | Disponibilité |
|---|---|
| proche dans la description | stock réel au moment voulu |
| calculée sur quelques attributs | vérifiée dans la table des stocks |
| symétrique | dépend de la commande en cours |

**À DIRE :** « Deux claviers peuvent se ressembler sur le papier, mais si l'un est
en rupture, on ne peut pas le remplacer automatiquement. Il faut regarder le stock
et le prix. »

---

## 10. Ce qu'on peut conclure — et ce qu'on ne peut pas conclure

**On peut dire :** les déclencheurs maintiennent le stock cohérent dans les quatre
cas testés ; la similarité aide à chercher, pas à décider.

**On ne peut pas dire :** que deux produits proches sont équivalents ; que le
résultat reste vrai si l'environnement change (pgvector absent en local).

**À DIRE :** « On a testé quatre situations précises. On ne prétend pas que tous
les cas du monde sont couverts. »

---

## 11. Ce que j'ai livré

- `P1_07_tests_transactions_ERIC.sql` — script commenté des 4 cas + test global ;
- deux captures : environnement réel et validation de méthode ;
- le texte T10 et le tableau des tests dans le rapport ;
- ce support de présentation.

**À DIRE :** « Le script détecte tout seul si les déclencheurs de M4 sont là.
S'ils ne sont pas là, il le dit au lieu d'afficher un faux résultat. »

---

## 12.Questions ?

**Dépendances à signaler au chef :**

1. déclencheurs de M4 non encore livrés → rejouer `P1_07` après leur commit ;
2. `pgvector` non installé sur le serveur local → utiliser le conteneur Docker
   `pgvector-tp` (port 5433) pour les captures définitives T8-T9 ;
3. scripts M2 (privilèges, requêtes) absents de l'arborescence au moment du test.
