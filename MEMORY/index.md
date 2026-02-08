
Chaque sous-dossier correspond à une **fonction précise**.
Aucune ambiguïté de rôle n’est tolérée.

---

## 5) Rôle des sous-dossiers

### 5.1 `MEMORY/decisions/`
Contient :
- des décisions humaines explicites,
- ayant un impact sur la structure, la gouvernance ou le fonctionnement.

Chaque entrée doit préciser :
- la décision,
- le contexte,
- la date,
- les conséquences connues.

Ne doit jamais contenir :
- des débats,
- des hésitations,
- des propositions non validées.

---

### 5.2 `MEMORY/facts/`
Contient :
- des informations factuelles,
- jugées suffisamment stables pour être réutilisées.

Chaque fait doit indiquer :
- son niveau de certitude,
- sa source ou justification,
- son périmètre de validité.

Ne doit jamais contenir :
- des hypothèses,
- des intuitions,
- des interprétations non confirmées.

---

### 5.3 `MEMORY/glossary.md`
Définit :
- le vocabulaire de référence du système.

Tout terme structurant utilisé ailleurs doit être :
- défini ici,
- utilisé conformément à cette définition.

---

## 6) Statuts de mémoire (qualité épistémique)
Toute entrée mémoire doit être associée à un **statut explicite** :

- **Confirmé / incontestable**  
  Information vérifiée, stable, utilisable sans réserve.

- **À recouper / sous surveillance**  
  Information plausible mais nécessitant vérification ou suivi.

- **En attente de validation**  
  Proposition formulée, non encore acceptée par l’humain.

👉 Aucun statut implicite n’est autorisé.

---

## 7) Zone tampon (principe)
Les éléments non validés doivent :
- rester **hors de la mémoire officielle**,
- être identifiés comme temporaires,
- être régulièrement traités (validation, reclassement, purge).

La zone tampon :
- protège la mémoire,
- évite l’accumulation confuse,
- force la décision consciente.

---

## 8) Processus d’entrée en mémoire (résumé)
1. L’agent **propose** une entrée (contenu + statut + justification).
2. L’humain :
   - valide,
   - modifie,
   - reclasse,
   - ou refuse.
3. L’entrée validée est placée au bon endroit (`facts/` ou `decisions/`).
4. Toute modification ultérieure est traçable.

---

## 9) Ce qui ne doit jamais entrer en mémoire
- Discussions brutes.
- Logs de session.
- Sorties intermédiaires.
- Réflexions non stabilisées.
- Données sensibles non nécessaires.
- Contenu écrit sans validation humaine.

Si un doute existe → **ne pas mémoriser**.

---

## 10) Relation entre MEMORY et LOGS
- **LOGS** = ce qui s’est passé.
- **MEMORY** = ce qui est su et assumé.

Un log peut mener à une décision.
Une décision validée peut entrer en mémoire.
Un log n’est jamais une mémoire en soi.

---

## 11) Statut du document
`MEMORY/index.md` est un **document de contrôle**.

Il doit rester :
- clair,
- strict,
- lisible isolément.

S’il y a une ambiguïté sur la mémoire, **ce document fait foi**.
