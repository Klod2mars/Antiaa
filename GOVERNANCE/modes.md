# MODES — Nœuds et instances opérationnelles

## 1) Objet
Ce document définit, de façon normative et minimale, ce qu’est un **nœud** dans l’architecture du système cognitif, les types de nœuds reconnus, leurs responsabilités opérationnelles, les interdictions essentielles, ainsi que les règles de vie (provisionnement, maintenance, audit).  
Il complète la Constitution, les règles de permissions et les procédures opérationnelles.

---

## 2) Définition
Un **nœud** est une instance physique ou virtuelle (machine, conteneur, instance cloud, NAS, service isolé) qui exécute une portion identifiée du système : agents, services d’ingestion, stockage persistant, indexation ou interface opérateur.  
Un nœud doit être nommé et géré comme une unité opérationnelle identifiable : **identifiant**, **rôle**, **responsable humain**, **configuration minimale**.

---

## 3) Principes applicables aux nœuds
1. **Autorité humaine et contrôle** — aucun nœud ne doit permettre une écriture irréversible sans validation humaine explicite conformément à la gouvernance.  
2. **Séparation des responsabilités** — chaque nœud a un rôle unique et clair ; les responsabilités croisées doivent être documentées.  
3. **Traçabilité et vérifiabilité** — toutes les actions critiques réalisées par un nœud produisent des logs et des métadonnées vérifiables.  
4. **Append-only pour le stockage final** — les nœuds exposant du stockage définitif respectent le principe d’append-only et la vérification par hash.  
5. **Minimisation des privilèges** — chaque nœud opère avec le minimum de privilèges nécessaires ; secrets et clés ne résident pas dans des dépôts de code ou fichiers non chiffrés.  
6. **Agents ≠ autorités** — les agents exécutés sur un nœud peuvent proposer et traiter, mais ne valident pas une écriture en mémoire sans l’intervention humaine prévue par la gouvernance.

---

## 4) Types de nœuds et responsabilités minimales

### 4.1 Nœud Orchestrateur (Main / Orchestrator)
**Responsabilités** : interpréter intentions, router vers agents spécialisés, restituer à l’utilisateur.  
**Interdits** : stocker directement en `MEMORY/` ou prendre des décisions opérationnelles sans validation humaine.

### 4.2 Nœud d’Ingestion (Ingest)
**Responsabilités** : réception des pièces brutes, extraction (OCR/parsing), production de `memory_delta` et de résumés, création d’artefacts temporaires et d’index.  
**Interdits** : promotion automatique en `MEMORY/` sans validation humaine ; suppression non tracée de la source brute.

### 4.3 Nœud de Stockage (Storage / STOCK)
**Responsabilités** : stockage des pièces brutes et des artefacts append-only, fourniture d’accès en lecture, calcul et vérification de hachage.  
**Contraintes** : refus d’écrasement des destinations finales ; métadonnées obligatoires (id, created_at, sha256, size, origine).

### 4.4 Nœud d’Interprétation (INTERPRETATIONS)
**Responsabilités** : héberger canons et résumés validés/à valider ; fournir lecture humaine et pointeurs d’index.  
**Interdits** : accepter des dépôts finaux sans preuve de validation (validation block ou référence LOGS/MEMORY).

### 4.5 Nœud Mémoire (MEMORY)
**Responsabilités** : héberger la mémoire épistémique officielle (decisions, facts, glossary) en respectant les statuts (En attente / À recouper / Confirmé).  
**Contraintes** : accès en écriture restreint ; toute modification est traçable ; la zone tampon doit être physiquement ou logiquement séparée si possible.

### 4.6 Nœud Index & Recherche (Retrieval / Index)
**Responsabilités** : indexation et recherche ; pointer vers archives brutes et entrées mémoire plutôt que contenir du contenu validé en propre.  
**Contraintes** : préserver intégrité des pointeurs et vérifier la cohérence avec les artefacts référencés.

### 4.7 Nœud Audit / Logs
**Responsabilités** : centraliser `LOGS/`, garantir immutabilité des logs d’événements critiques et permettre l’accès pour l’audit.  
**Contraintes** : conservation et export faciles pour les contrôles.

### 4.8 Nœud Opérateur (Console humaine)
**Responsabilités** : interface humaine pour validation (Validator UI), supervision et déclenchement des gates de validation.  
**Contraintes** : toute action opérateur est journalisée.

---

## 5) Règles opérationnelles

### 5.1 Provisioning & configuration
- Toute création de nœud est documentée (ID, rôle, responsable humain, méthode d’accès, configuration minimale).  
- Images/templates utilisés sont versionnés et signés si possible.

### 5.2 Sécurité et secrets
- Les nœuds **ne stockent pas** de secrets en clair dans le code ; les accès privilégiés sont limités et audités.  
- Les clés/jetons sont fournis via un coffre (secret manager) et renouvelés périodiquement.

### 5.3 Logs et métadonnées
- Les nœuds produisent des logs structurés pour chaque opération critique (action, validateur, timestamp, artefacts impliqués, hashes). Ces logs sont conservés dans `LOGS/` et disponibles pour l’audit.  
- Les métadonnées d’écritures irréversibles suivent le modèle utilisé par `OPERATIONS/commit_real_piece.sh` (id, created_at, status, piece{sha256}, canon{sha256}, validation{validator,…}).

### 5.4 Modes d’exploitation
- **Normal** : fonctionnement standard ; validations humaines requises pour écritures irréversibles.  
- **Maintenance / read-only** : nœuds de stockage passent en lecture seule ; écritures rejetées ou soumises à procédure spéciale.  
- **Emergency** : procédure de dérogation documentée (ex. intervention du Governance Administrator) ; toute dérogation est enregistrée comme incident.

### 5.5 Mises à jour et migrations
- Mises à jour testées en environnements isolés et validées par un responsable humain.  
- Migrations garantissent append-only, produisent métadonnées et sont validées.

---

## 6) Interactions entre nœuds et agents
- Les agents s’exécutent sur des nœuds et **proposent** `memory_delta` ; ils **ne changent pas** les statuts officiels sans validation humaine.  
- Les communications inter-nœuds sont chiffrées et documentées (API contract). Toute intégration automatique résultant en écriture finale doit être explicitement couverte par une décision humaine.

---

## 7) Audit, incidents et conformité
- Chaque nœud permet l’extraction des logs d’activité pour l’Auditor. Les anomalies (écrasement, absence de preuve, écriture non autorisée) constituent un incident et sont consignées et traitées.  
- Toute création / suppression / révocation de nœud est enregistrée (qui, pourquoi, conséquences).

---

## 8) Hors-périmètre
Les nœuds **n’exercent pas** l’autorité sur le contenu épistémique : ils appliquent la gouvernance définie par des humains et ne peuvent remplacer une décision humaine.

---

## 9) Statut du document
`GOVERNANCE/MODES.md` est un texte opérationnel et minimal. Il peut être complété par playbooks techniques (provisionnement, scripts, templates d’audit) ; toute extension doit rester cohérente avec la Constitution, les Permissions et les procédures d’`OPERATIONS/`.
