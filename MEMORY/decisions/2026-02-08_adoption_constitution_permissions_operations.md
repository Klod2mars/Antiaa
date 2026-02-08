title: Adoption : constitution / permissions / operations
author: Klod2mars
date: 2026-02-08T18:15:35+01:00
decision:
  - adopter GOVERNANCE/constitution.md (version finale)
  - adopter GOVERNANCE/permissions.md (version finale)
  - ajouter OPERATIONS/README.md et outils d'enregistrement (register_piece, commit_real_piece)
consequences:
  - toutes les écritures irréversibles exigent une validation humaine explicite et un log d'action
  - les métadonnées doivent contenir un bloc `validation` et le dossier LOGS/actions doit contenir une preuve
