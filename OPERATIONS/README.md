# OPERATIONS — README

## Objet
Le dossier `OPERATIONS/` contient les procédures, scripts et outils opérationnels qui exécutent les écritures physiques, l’archivage et les transformations nécessaires au fonctionnement du système cognitif.

Ce README définit :
- les principes applicables aux opérations (sécurité, traçabilité, append-only, validation humaine) ;
- les workflows standards (enregistrement d’une pièce, commit réel, ingestion) ;
- la checklist minimale avant toute écriture irréversible ;
- le schéma minimal de métadonnées recommandé ;
- les règles d’intégration d’un nouvel outil opérationnel.

Ce document est **opérationnel** : il vise à décrire ce qu’il faut faire et comment le vérifier, sans implémenter de logique métier supplémentaire.

> Références clés (lecture recommandée) :  
> `GOVERNANCE/constitution.md` (micro-constitution), `GOVERNANCE/permissions.md` (mapping rôles→droits), `MEMORY/index.md` (statuts mémoire), `AGENTS/ingest_memory.md` et `AGENTS/main.md` (contrats agents / orchestrateur).

---

## Principes opérationnels (rappel)
1. **Autorité humaine unique** : toute écriture irréversible exige une validation explicite d’un humain habilité (Validator). (Voir `GOVERNANCE/permissions.md`.)  
2. **Append-only** : les écritures définitives refusent l’écrasement ; toute destination doit être inexistante avant écriture. Les scripts doivent vérifier l’absence de destination et échouer si elle existe. :contentReference[oaicite:0]{index=0}  
3. **Traçabilité et vérifiabilité** : toute opération crée des métadonnées vérifiables (hash, date, origine) et laisse une trace lisible dans `LOGS/actions`. :contentReference[oaicite:1]{index=1}  
4. **Séparation des zones** : `INCOMING`, `STOCK`, `INTERPRETATIONS`, `MEMORY`, `LOGS` sont des espaces fonctionnels distincts ; leur usage est normé. :contentReference[oaicite:2]{index=2}  
5. **Les agents proposent, les humains valident** : les agents peuvent produire des propositions et métadonnées ; **seul** un humain habilité valide l’écriture définitive dans `STOCK/` ou `MEMORY/`. :contentReference[oaicite:3]{index=3}

---

## Contenu du dossier OPERATIONS (vue rapide)
- `commit_real_piece.sh` — script d’écriture irréversible (gate de validation humaine, append-only, métadonnées). Exemple d’usage et garde-fous intégrés. :contentReference[oaicite:4]{index=4}  
- `tools/register_piece.py` — script d’enregistrement des pièces brutes (création d’un JSON de fiche pièce, mouvement/copie dans STOCK). :contentReference[oaicite:5]{index=5}  
- `tools/ocr/ocr_image.py` — outils d’extraction de texte (OCR) utilisés par le flux d’ingestion (exemple de transformation). :contentReference[oaicite:6]{index=6}  
- Autres scripts et sous-dossiers : chaque script doit être accompagné d’un usage (`--help`), d’un README local si besoin, et d’un test de non-régression.

---

## Workflows standards

### 1) Enregistrement d’une pièce brute (INCOMING → STOCK)
1. Placer la pièce dans `INCOMING/` (répertoire d’origine prévu pour la source).  
2. Exécuter `tools/register_piece.py <path>` pour créer la fiche `STOCK/pieces/<piece_id>.json`. Le script produit une entité JSON contenant : `piece_id`, `file.path`, `file.hash` (sha256), `received_at`, `status: raw`, etc. :contentReference[oaicite:7]{index=7}  
3. Vérifier que la fiche `STOCK/pieces/<piece_id>.json` existe et que le hash correspond au fichier copié/mové. (Commandes : `sha256sum`, `cat`.)

**Note** : `register_piece.py` ne valide pas l’entrée en `MEMORY/` ni ne qualifie l’élément comme confirmé — il enregistre la *pièce brute*. :contentReference[oaicite:8]{index=8}

---

### 2) Commit réel d’une pièce (opération irréversible)
Utiliser `OPERATIONS/commit_real_piece.sh` pour toute écriture irréversible (copie de la pièce dans le stock définitif, écriture du canon dans `INTERPRETATIONS/`, création des métadonnées définitives).

**Résumé du comportement du script** :
- refuse l’écrasement (append-only) ; vérifie l’absence de destination ; calcule hashes ; exige une **validation humaine explicite** (gate interactive).  
- écrit : la pièce, le canon (copie brute), et un fichier metadata JSON minimal vérifiable.  
- exécute une vérification post-copie (hash match) et recommande les commandes de vérification (`ls -la`, `sha256sum`, `head -n 40` du canon, `cat` du meta). :contentReference[oaicite:9]{index=9}

**Usage d’exemple** :
```bash
OPERATIONS/commit_real_piece.sh \
  --piece INCOMING/telegram/img_001.jpg \
  --canon-file /tmp/canon.txt \
  --status yellow \
  --confirm

