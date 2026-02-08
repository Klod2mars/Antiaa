# README.md — Présentation générale du système cognitif

## 1) Objet de ce document
Ce fichier est la **porte d’entrée humaine** du système.

Il explique :
- ce qu’est ce système cognitif,
- pourquoi il existe,
- comment il est structuré,
- comment le lire et l’utiliser sans connaissance préalable.

Il s’adresse à :
- l’humain opérateur principal,
- un tiers futur (collaborateur, auditeur, héritier du système),
- toute personne devant comprendre l’architecture **sans lire tout le reste**.

👉 Ce document doit rester **lisible, stable et non technique**.

---

## 2) Nature du système
Ce dépôt décrit un **système cognitif local gouverné**, conçu comme :

- un **compagnon de réflexion** (aide à penser, structurer, décider),
- un **système de travail** (procédures, checklists, traçabilité),
- un **prototype philosophique conscient** (responsabilité, limites, épistémologie),
- un **outil durable et transmissible**, compréhensible sans dépendance à une IA spécifique.

Ce n’est **pas** :
- un produit commercial,
- un agent autonome,
- un système auto-apprenant incontrôlé,
- un journal intime automatisé,
- une expérimentation opaque.

---

## 3) Principe central : gouvernance humaine
Le système repose sur un principe non négociable :

**L’autorité unique est l’humain.**

Conséquences directes :
- l’IA ne décide jamais seule,
- l’IA ne mémorise jamais sans validation,
- l’IA n’agit jamais sans demande explicite,
- toute autonomie est **limitée à la réflexion**, jamais à l’action.

Formule structurante :
> **Autonome dans la réflexion, dépendant dans l’action.**

---

## 4) Philosophie de conception
Le système est volontairement :
- **sobre** (peu de règles),
- **strict** (lignes rouges claires),
- **lisible** (compréhension humaine prioritaire),
- **contextuel** (interprétation raisonnée plutôt qu’automatisme).

Principes directeurs :
- Clarté > exhaustivité  
- Responsabilité > performance  
- Prévention des dérives > optimisation  
- Compréhension humaine > confort de l’IA  

Toute règle existe pour **éviter un risque réel**, pas pour imposer une idéologie.

---

## 5) Structure générale du dépôt
L’arborescence est organisée par **responsabilités claires**, inspirée d’une Clean Architecture appliquée à un système cognitif.

cognitive-system
├── AGENTS → rôle et conduite des agents
├── GOVERNANCE → règles, constitution, permissions
├── LOGS → traçabilité des actions et sessions
├── MEMORY → mémoire épistémique gouvernée
├── OPERATIONS → procédures, checklists, outils
└── README.md → ce document


Chaque dossier est **documenté individuellement** et peut être compris isolément.

---

## 6) Ce que ce dépôt contient
Ce dépôt contient **exclusivement** :
- de la documentation de référence,
- des règles explicites,
- des structures de gouvernance,
- des cadres de décision,
- des conventions de travail.

Il peut contenir :
- des fichiers volontairement minimalistes,
- des dossiers vides expliqués,
- des README servant de garde-fous.

---

## 7) Ce que ce dépôt ne contient jamais
Ce dépôt ne doit **jamais** contenir :
- du code exécutable,
- des clés, tokens ou secrets,
- des données personnelles non nécessaires,
- des logs bruts non contextualisés,
- des mémoires écrites sans validation humaine,
- des promesses futures ou spéculations techniques.

S’il manque quelque chose, c’est souvent **volontaire**.

---

## 8) Mode de lecture recommandé
Pour un nouvel arrivant :

1. Lire ce `README.md`
2. Lire `GOVERNANCE/constitution.md`
3. Lire `AGENTS/main.md`
4. Explorer ensuite selon le besoin :
   - mémoire → `MEMORY/`
   - procédures → `OPERATIONS/`
   - traçabilité → `LOGS/`

Aucune lecture exhaustive n’est requise pour utiliser le système de manière sûre.

---

## 9) Évolution du système
Ce système est **vivant**, mais pas instable.

Il évolue :
- par clarification,
- par ajout de garde-fous,
- par retour d’expérience réel.

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
Ce `README.md` est un **document de référence fondamental**.

Il doit être modifié :
- rarement,
- avec intention,
- pour améliorer la compréhension globale ou la sécurité.

S’il devient trop long, trop technique ou trop vague, il doit être **réduit**, pas enrichi.

Son rôle n’est pas de tout dire, mais de **donner le cadre juste**.
