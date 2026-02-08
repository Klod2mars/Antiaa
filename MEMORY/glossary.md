# MEMORY/glossary.md — Glossaire conceptuel du système

## 1) Objet de ce document
Ce fichier définit le **vocabulaire de référence** du système cognitif.

Il sert à :
- éviter les malentendus sémantiques,
- stabiliser le sens des mots clés,
- permettre à un humain tiers de comprendre le système sans contexte implicite,
- prévenir les dérives liées à des interprétations floues ou changeantes.

👉 Ce glossaire est **normatif** : lorsqu’un terme défini ici est utilisé ailleurs, c’est **ce sens précis** qui s’applique.

---

## 2) Règle fondamentale du glossaire
- Chaque terme est défini **une seule fois**.
- Les définitions sont :
  - courtes,
  - humaines,
  - non techniques sauf nécessité.
- Pas de jargon décoratif.
- Pas de synonymes approximatifs.
- Si un terme n’est pas défini ici, **il ne doit pas être utilisé comme concept structurant**.

---

## 3) Définitions

### Agent
Interface cognitive contrôlée, chargée de réfléchir, structurer, proposer ou exécuter **sur demande explicite** de l’humain.

Un agent :
- est autonome dans la réflexion,
- est dépendant dans l’action,
- ne possède aucune autorité propre.

---

### Autorité (humaine)
Capacité exclusive de :
- décider,
- valider,
- autoriser,
- invalider,
- écrire en mémoire,
- déclencher une action réelle.

Dans ce système, **l’autorité est unique et humaine**.

---

### Clean Architecture (appliquée au cognitif)
Principe d’organisation visant à séparer clairement :
- les responsabilités,
- les règles,
- les flux de décision,
- les zones à risque.

Ici, elle est appliquée à un **système cognitif**, pas à du code.

---

### Constitution
Document de gouvernance fondamental définissant :
- les principes non négociables,
- les lignes rouges,
- la hiérarchie des règles.

La constitution prévaut sur toute autre documentation.

---

### Décision
Choix explicite validé par l’humain, ayant des conséquences sur :
- la mémoire,
- les règles,
- les opérations,
- la structure du système.

Une décision importante doit être traçable.

---

### Gouvernance
Ensemble minimal de règles et de principes destinés à :
- encadrer l’agent,
- protéger l’humain,
- prévenir les dérives,
- maintenir la lisibilité et la responsabilité.

La gouvernance n’est pas une automatisation.

---

### Ligne rouge
Limite non négociable destinée à empêcher :
- une perte de contrôle humain,
- une dérive autonome,
- une corruption de la mémoire,
- un comportement dangereux ou irréversible.

Face à une ligne rouge, l’agent **ralentit et demande arbitrage**.

---

### Log
Trace factuelle d’une action, d’une session ou d’une décision.

Un log :
- décrit ce qui s’est passé,
- ne stocke pas de mémoire conceptuelle,
- ne contient pas d’interprétation longue.

Les logs servent à la **traçabilité**, pas à la connaissance.

---

### Mémoire
Registre épistémique gouverné contenant :
- des faits,
- des décisions,
- des concepts stabilisés.

La mémoire :
- est qualitative,
- est contrôlée par l’humain,
- n’est jamais automatique.

---

### Registre épistémique
Espace structuré où sont conservées des informations **en fonction de leur statut de certitude**, et non de leur simple apparition.

Opposé à :
- un cache,
- un historique brut,
- un journal automatique.

---

### Statut mémoire
Niveau de certitude associé à une information mémorisable.

Statuts reconnus :
- confirmé / incontestable,
- à recouper / sous surveillance,
- en attente de validation.

---

### Zone tampon
Espace temporaire destiné à accueillir :
- des propositions,
- des hypothèses,
- des informations non validées.

Tout élément en zone tampon doit être :
- validé,
- reclassé,
- ou purgé.

---

## 4) Ce qui doit figurer dans ce glossaire
- Les concepts structurants du système.
- Les termes ambigus nécessitant un sens précis.
- Les mots utilisés dans la gouvernance, la mémoire et les opérations.

---

## 5) Ce qui ne doit jamais figurer dans ce glossaire
- Des termes marketing.
- Des néologismes non nécessaires.
- Des concepts non utilisés ailleurs.
- Des définitions vagues ou poétiques.
- Des promesses ou projections futures.

---

## 6) Évolution du glossaire
Le glossaire évolue :
- lentement,
- par clarification,
- par stabilisation du vocabulaire.

Ajouter un terme est un **acte de gouvernance** :
- il doit répondre à un besoin réel,
- il doit réduire une ambiguïté existante,
- il doit être validé par l’humain.

Supprimer un terme est préférable à en laisser un flou.

---

## 7) Statut du document
`MEMORY/glossary.md` est un **document de référence transversal**.

Il doit rester :
- lisible isolément,
- cohérent dans le temps,
- aligné avec la constitution.

S’il devient trop long, il doit être **simplifié**, pas enrichi.
