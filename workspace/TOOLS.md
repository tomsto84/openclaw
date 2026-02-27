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

## GitHub Auto-Sync

Le workspace est synchronisé automatiquement avec GitHub.

- **Repo:** https://github.com/tomsto84/openclaw
- **Fréquence:** Toutes les 5 minutes
- **Process:** 
  - Détecte les changements locaux
  - Crée une branche `auto-sync-YYYYMMDD-HHMMSS`
  - Commit + Push
  - Crée une PR
  - Merge automatique (squash)
  - Supprime la branche

### Commandes manuelles

```bash
# Forcer un sync maintenant
~/workspace/scripts/sync-now.sh

# Voir le statut git
cd ~/.openclaw && git status
```

---

Add whatever helps you do your job. This is your cheat cheat.
