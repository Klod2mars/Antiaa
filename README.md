# Cognitive System — Documentation de référence

## 1) Objet de ce dépôt
Ce dépôt décrit un **système cognitif local gouverné**.

Il ne s’agit pas :
- d’un logiciel,
- d’un agent autonome,
- d’un produit,
- ni d’un journal automatique.

Il s’agit d’un **cadre de travail documentaire** destiné à :
- structurer l’usage d’une intelligence artificielle locale,
- maintenir une autorité humaine explicite,
- garantir la lisibilité, la sécurité et la transmissibilité du système.

Ce dépôt est une **documentation d’architecture cognitive**, comparable à un manuel d’architecture ou à une API publique.

---

## 2) Nature du système
Le système est conçu comme :
- un **compagnon de réflexion**,
- un **système de travail gouverné**,
- un **prototype philosophique conscient**,
- un **outil durable**, compréhensible par un tiers sans contexte implicite.

Il repose sur un principe central non négociable :

> **L’autorité unique est l’humain.**

L’IA :
- ne décide jamais seule,
- n’agit jamais sans demande explicite,
- n’écrit jamais en mémoire sans validation humaine.

Formule structurante :
> **Autonome dans la réflexion, dépendant dans l’action.**

---

## 3) Philosophie générale
Le système est volontairement :
- **sobre** (peu de règles),
- **strict** (lignes rouges claires),
- **lisible** (priorité à la compréhension humaine),
- **contextuel** (interprétation raisonnée plutôt qu’automatisme).

Principes directeurs :
- Clarté > exhaustivité  
- Responsabilité > performance  
- Prévention des dérives > optimisation  
- Gouvernance explicite > confort opérationnel  

Toute règle existe pour **prévenir un risque réel**, pas pour imposer une idéologie.

---

## 4) Structure du dépôt
L’arborescence est organisée par **responsabilités clairement séparées**, inspirées d’une Clean Architecture appliquée à un système cognitif.

cognitive-system
├── AGENTS → rôle et conduite des agents
├── GOVERNANCE → règles, constitution, permissions
├── LOGS → traçabilité des actions et sessions
├── MEMORY → mémoire épistémique gouvernée
├── OPERATIONS → procédures, checklists, outils
└── README.md → ce document


Chaque dossier est documenté pour être compris **isolément**.

---

## 5) Contenu et limites du dépôt
Ce dépôt contient :
- des règles,
- des cadres décisionnels,
- des conventions,
- de la documentation de référence.

Il ne contient jamais :
- de code exécutable,
- de clés, tokens ou secrets,
- de données personnelles non nécessaires,
- de mémoire écrite sans validation humaine,
- de spéculations techniques ou promesses futures.

Un fichier vide ou minimal est parfois **volontaire**.

---

## 6) Gouvernance humaine
La gouvernance repose sur :
- une **micro-constitution**,
- peu de règles,
- des lignes rouges non négociables,
- des règles interprétables pour éviter les blocages.

Les documents de référence sont dans `GOVERNANCE/`.

En cas de doute :
- ralentir,
- expliciter le risque,
- demander une décision humaine.

---

## 7) Mémoire et traçabilité
Le système distingue strictement :
- **LOGS** : ce qui s’est passé (historique),
- **MEMORY** : ce qui est su et assumé (connaissance validée).

La mémoire est :
- qualitative,
- gouvernée,
- jamais automatique.

Un log n’est jamais une mémoire.

---

## 8) Mode de lecture recommandé
Pour un nouvel arrivant :

1. Lire ce `README.md`
2. Lire `GOVERNANCE/constitution.md`
3. Lire `AGENTS/main.md`
4. Explorer ensuite selon le besoin :
   - mémoire → `MEMORY/`
   - opérations → `OPERATIONS/`
   - traçabilité → `LOGS/`

Aucune lecture exhaustive n’est nécessaire pour un usage sûr.

---

## 9) Évolution du système
Le système est **vivant**, mais non instable.

Il évolue :
- par clarification,
- par retour d’expérience réel,
- par renforcement des garde-fous.

Il n’évolue pas :
- par empilement de règles,
- par automatisation incontrôlée,
- par dérive fonctionnelle.

Toute évolution doit préserver :
- la lisibilité humaine,
- la responsabilité,
- la gouvernance explicite.

---

## 10) Statut de ce document
Ce `README.md` est un **document de cadrage fondamental**.

Il doit rester :
- lisible,
- stable,
- non technique.

S’il devient trop long, trop flou ou trop ambitieux,  
il doit être **simplifié**, pas enrichi.
