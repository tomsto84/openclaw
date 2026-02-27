# Contributing to OpenClaw Workspace

## 🌳 Branch Strategy

### Types de branches

| Préfixe | Usage | Exemple |
|---------|-------|---------|
| `feat/` | Nouvelle fonctionnalité | `feat/add-calendar-sync` |
| `fix/` | Correction de bug | `fix/memory-leak-sessions` |
| `chore/` | Maintenance, tooling | `chore/update-deps` |
| `docs/` | Documentation | `docs/api-reference` |
| `refactor/` | Refactoring code | `refactor/split-modules` |
| `test/` | Tests | `test/unit-coverage` |
| `hotfix/` | Urgence production | `hotfix/security-patch` |

### Workflow

```bash
# 1. Créer une branche depuis main
~/workspace/scripts/git-workflow.sh branch feat/ma-feature

# 2. Faire des commits conventionnels
git commit -m "feat: add calendar integration"

# 3. Push et créer PR
~/workspace/scripts/git-workflow.sh done

# 4. Merger via PR (jamais direct sur main)
~/workspace/scripts/git-workflow.sh merge
```

## 📝 Conventional Commits

Format : `<type>(<scope>): <description>`

### Types

- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `docs:` Documentation uniquement
- `style:` Formatage, missing semi-colons, etc. (pas de changement de code)
- `refactor:` Refactoring du code
- `perf:` Amélioration de performance
- `test:` Ajout ou correction de tests
- `chore:` Changements sur le build, tooling, dépendances
- `ci:` Configuration CI/CD
- `revert:` Annulation d'un commit

### Scopes (optionnels mais recommandés)

- `workspace` - Fichiers du workspace (AGENTS.md, SOUL.md, etc.)
- `scripts` - Scripts utilitaires
- `config` - Configuration OpenClaw
- `memory` - Fichiers de mémoire
- `tools` - Tooling

### Exemples

```bash
feat(workspace): add daily memory rotation

fix(scripts): handle edge case in sync

docs: update TOOLS.md with new workflow

chore(deps): update kimi-claw extension

refactor(memory): extract search logic
```

### Corps du message (optionnel)

```bash
git commit -m "feat(workspace): add calendar sync

- Add Google Calendar integration
- Support for multiple calendars
- Daily summary generation

Closes #123"
```

## 🔀 Merge Strategy

- **Uniquement Squash & Merge** sur `main`
- Les branches sont supprimées automatiquement après merge
- Chaque PR = une feature logique cohérente
- Garder les PR petites et reviewables (< 500 lignes idéalement)

## ✅ Checklist avant PR

- [ ] La branche est à jour avec `main`
- [ ] Les commits suivent Conventional Commits
- [ ] Pas de fichiers sensibles (secrets, tokens)
- [ ] Tests passent (si applicable)
- [ ] Documentation mise à jour

## 🛡️ Protection de branche

`main` est protégée avec :
- Pas de push direct (obligatoire via PR)
- Les conversations doivent être résolues
- Squash merge uniquement
- Suppression auto des branches mergées
