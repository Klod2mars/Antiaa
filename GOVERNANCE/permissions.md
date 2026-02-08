# GOVERNANCE / Permissions — Règles minimales

## 1) Objet
Ce fichier définit, de façon minimale et normative, les rôles humains pertinents pour l’autorité opérationnelle et le traitement des données, le périmètre de leurs droits, les conditions de validation humaine requises pour les écritures irréversibles, ainsi que les règles d’habilitation et d’audit.

Il complète la Constitution et ne remplace pas les règles opérationnelles détaillées présentes dans `OPERATIONS/` et `AGENTS/`. Voir en particulier : `GOVERNANCE/constitution.md`, `AGENTS/main.md`, `AGENTS/ingest_memory.md`, `MEMORY/index.md`, et `OPERATIONS/commit_real_piece.sh`. :contentReference[oaicite:0]{index=0} :contentReference[oaicite:1]{index=1} :contentReference[oaicite:2]{index=2} :contentReference[oaicite:3]{index=3} :contentReference[oaicite:4]{index=4}

---

## 2) Principes directeurs appliqués aux permissions
1. **Autorité humaine unique.** Toute écriture irréversible dépend d’une décision humaine explicite. :contentReference[oaicite:5]{index=5}  
2. **Append-only et traçabilité.** Les opérations de persistance doivent respecter le principe *append-only* et produire métadonnées vérifiables (hash, date, origine). :contentReference[oaicite:6]{index=6}  
3. **Séparation des responsabilités.** Les agents peuvent proposer et classer ; les humains habilités valident et autorisent les écritures finales. :contentReference[oaicite:7]{index=7}

---

## 3) Rôles humains (définition minimale)
> Remarque : ces rôles sont **humains** (personnes physiques identifiables). Les agents logiciels ne peuvent exercer ces rôles ni les usurper.

1. **Validator** *(validateur)*  
   - Rôle principal : autoriser explicitement les écritures irréversibles (stock, canon, entrée en `MEMORY/` en statut *Confirmé*, purge/migration irréversible).  
   - Droits : valider/autoriser, signer la validation, demander enregistrement dans `LOGS/actions` et écrire la trace (identité, date, motif).  
   - Périmètre : toutes les opérations qui, selon la Constitution, sont « irréversibles ». :contentReference[oaicite:8]{index=8}

2. **Registrar / Archivist** *(registre / archiviste)*  
   - Rôle principal : exécuter les opérations matérielles d’archivage et d’enregistrement (copie d’une pièce dans `STOCK`, dépôt du canon dans `INTERPRETATIONS/`, création de métadonnées) **sous l’autorisation d’un Validator**.  
   - Droits : effectuer les copies, écrire les fichiers dans le stock ou les répertoires d’interprétation, produire les métadonnées exigées, mais **sans** proclamer une entrée `MEMORY/` comme confirmée.  
   - Contraintes : chaque action append-only doit être accompagnée de la preuve d’autorisation (voir §5).

3. **Memory Curator** *(conservateur·rice de mémoire)*  
   - Rôle principal : préparer, classer et proposer des entrées pour `MEMORY/` (faits, décisions, glossaire) et opérer la promotion technique dans `MEMORY/` **après validation humaine explicite** par un Validator.  
   - Droits : proposer, modifier propositions en zone tampon, réclamer validation, exécuter la promotion technique après validation signée.

4. **Governance Administrator** *(administrateur·rice de gouvernance)*  
   - Rôle principal : maintenir les documents de gouvernance (constitution, modes, permissions), coordonner habilitations et révocations.  
   - Droits : modifier `GOVERNANCE/` sous procédure documentaire (toute modification importante doit être accompagnée d’une décision humaine explicite et traçable). Modifier la gouvernance constitue une décision humaine explicite qui doit être enregistrée (ex. `MEMORY/decisions/`). :contentReference[oaicite:9]{index=9}

5. **Auditor** *(auditeur·rice)*  
   - Rôle principal : vérifier la conformité, effectuer contrôles indépendants.  
   - Droits : lecture étendue des `LOGS/`, `STOCK/` et `MEMORY/` pour audit ; droits d’alerte et proposition de correction. Pas de droits d’écriture sur `MEMORY/` ou `STOCK/` sauf documentation d’un constat (logs, rapport).

> Tout autre rôle humain doit être défini et enregistré par une décision formelle (voir §7).

---

## 4) Droits & interdictions — mapping minimal (par zone)
> Principe : *proposer* ≠ *valider/écrire*. L’écriture en `MEMORY/` ou les commits définitifs dans `STOCK/INTERPRETATIONS/` exigent validation humaine.

- `STOCK/` (pièces, archives)  
  - Archivist : **peut écrire** (copier) une pièce dans `STOCK/` **si** dispose d’une autorisation valide signée par un Validator.  
  - Validator : **peut autoriser** l’écriture et exiger métadonnées.  
  - Auditor : lecture.

- `INTERPRETATIONS/` (canons, résumés finaux)  
  - Registrar / Archivist : **peut déposer** un canon ou résumé validé.  
  - Validator : **doit valider** et signer l’autorisation de dépôt.  
  - Memory Curator : **peut proposer** résumés pour validation.

- `MEMORY/decisions/`  
  - Validator / Governance Administrator : **peuvent écrire** décisions humaines explicites (doivent y figurer date, contexte, conséquences).  
  - Memory Curator : proposer contenu soumis à validation.

- `MEMORY/facts/`  
  - Memory Curator : **propose** entrées (avec statut).  
  - Validator : **peut autoriser** la promotion au statut *Confirmé* (inscription définitive).

- `LOGS/`  
  - Tous les acteurs (humains et scripts exécutés par des humains) : **doivent** consigner les actions importantes dans `LOGS/actions`. L’audit s’appuie sur ces logs.

- `GOVERNANCE/`  
  - Governance Administrator : **peut modifier** documents de gouvernance sous procédure documentée (toute modification significative doit être accompagnée d’une décision humaine enregistrée).  
  - Validator : doit être consulté pour modifications critiques.

---

## 5) Validation humaine et preuve (exigences minimales)
1. Toute opération qualifiée d’**irréversible** (voir Constitution) doit être accompagnée :  
   - d’une **autorisation explicite** d’un Validator ; et  
   - d’une **preuve** d’autorisation enregistrée et traçable.

2. **Formes acceptées de preuve** (au moins une doit être fournie) :  
   - **Gate interactive** : la validation de l’opérateur humain via une phrase exacte ou commande interactive (ex. mécanisme de `commit_real_piece.sh`). Le mécanisme doit laisser un enregistrement dans `LOGS/actions`. :contentReference[oaicite:10]{index=10}  
   - **Signature dans les métadonnées** : le Validator insère son identité, date/heure ISO et motif dans les métadonnées juxtaposées à l’opération (ex. champ `validator` avec signature/identifiant). Les métadonnées doivent être append-only et vérifiables (sha256). :contentReference[oaicite:11]{index=11}  
   - **Décision humaine enregistrée** : la décision d’autorisation est consignée dans `MEMORY/decisions/` (ou `LOGS/actions`) et référencée par identifiant lors du commit.

3. **Contenu minimal de la preuve** : identité du Validator, date/heure, portée de l’autorisation (id de la pièce, chemin de destination, statut demandé), et référence aux métadonnées produites.

4. **Interdiction** : les agents logiciels **ne peuvent pas** se substituer à un Validator ni générer la preuve humaine. Toute preuve produite par un agent doit être initiée et signée par un humain habilité.

---

## 6) Habilitation et révocation
1. **Habilitation**  
   - Toute habilitation d’un humain à un rôle (Validator, Archivist, Memory Curator, Governance Administrator, Auditor) **doit** faire l’objet d’une décision humaine explicite et documentée (enregistrée dans `MEMORY/decisions/`), indiquant la portée et la durée éventuelle. :contentReference[oaicite:12]{index=12}

2. **Révocation**  
   - Toute révocation d’habilitation **doit** être documentée de la même manière. La révocation n’efface pas l’historique : les écrits antérieurs restent traçables.

3. **Registre des habilitations**  
   - Le registre actuel des habilitations (mapping rôles → personnes) doit être disponible pour l’audit (par ex. dans `MEMORY/decisions/` ou `LOGS/actions`). La méthode de publication du registre relève de la Governance Administrator.

---

## 7) Audit et application
1. Les Auditor·rices ont accès en lecture aux `LOGS/`, `STOCK/` et `MEMORY/` afin de vérifier la conformité. Toute anomalie doit être rapportée et faire l’objet d’une décision corrective.  
2. Les opérations non conformes (absence de preuve, écriture non autorisée, écrasement) doivent être considérées comme incidents et traitées via procédure (enregistrement d’incident dans `LOGS/` et décision humaine corrective).

---

## 8) Dispositions complémentaires et extensibilité
1. Cette spécification est minimale. Les procédures plus strictes (ex. exigence de plusieurs validators pour certaines opérations) peuvent être introduites par décision humaine et enregistrées dans `MEMORY/decisions/` ou dans un document d’opération.  
2. Toute extension de rôles ou de droits doit suivre une décision humaine documentée et être consignée dans `GOVERNANCE/` ou `MEMORY/decisions/`.

---

## 9) Notes de référence
- Exemples opérationnels : `OPERATIONS/commit_real_piece.sh` (gate de validation, append-only, métadonnées vérifiables). :contentReference[oaicite:13]{index=13}  
- Contrat agent/orchestrateur : `AGENTS/main.md` et `AGENTS/ingest_memory.md`. :contentReference[oaicite:14]{index=14} :contentReference[oaicite:15]{index=15}  
- Statuts mémoire et zone tampon : `MEMORY/index.md`. :contentReference[oaicite:16]{index=16}

