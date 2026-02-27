# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## GitHub Workflow - Feature Branches

**Repo:** https://github.com/tomsto84/openclaw

### Workflow conventionnel

Pas de sync auto. On travaille sur des branches de feature qu'on merge quand c'est prêt.

```bash
# 1. Créer une branche pour une feature
~/workspace/scripts/git-workflow.sh branch feat/nom-de-la-feature

# 2. Travailler... puis commit
~/workspace/scripts/git-workflow.sh commit "message du commit"

# 3. Push et créer PR
~/workspace/scripts/git-workflow.sh done

# 4. Merger quand c'est prêt (ou décider ensemble)
~/workspace/scripts/git-workflow.sh merge
```

### Commandes disponibles

| Commande | Description |
|----------|-------------|
| `branch feat/xxx` | Crée une branche feature |
| `branch fix/xxx` | Crée une branche fix |
| `branch chore/xxx` | Crée une branche chore |
| `commit "msg"` | Commit les changements |
| `push` | Push la branche |
| `pr` | Crée une PR |
| `merge` | Merge la branche sur main |
| `sync` | Rebase sur main |
| `done` | Commit + push + PR |
| `status` | Statut git |

### Règles de nommage

- `feat/description` - Nouvelle fonctionnalité
- `fix/description` - Correction de bug
- `chore/description` - Tâches de maintenance
- `docs/description` - Documentation
- `refactor/description` - Refactoring

---

## GitHub Auto-Sync (OLD - Disabled)

~~Le workspace est synchronisé automatiquement avec GitHub.~~ **DÉSACTIVÉ**

Utiliser le workflow feature branches ci-dessus.

---

Add whatever helps you do your job. This is your cheat cheat.
