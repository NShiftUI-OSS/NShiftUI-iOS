# UPDATE — contrato do remapper

Usado por `Agents/UpdateHarness/SKILL.md`. Agentes devem seguir o skill; este arquivo é o checklist/contrato de saída.

## Quando rodar

- Mudança de targets/products/deps em `Package.swift`
- Nova API `public` ou remoção/renomeação
- Mudança de bootstrap/runtime (Config, Engine, Container, macros)
- Gap fechado ou nova lacuna descoberta
- Pedido explícito do usuário para refresh/remap do harness

## Checklist

1. Re-scan: `Package.swift`, `Package.resolved` (se existir), `Sources/**`, `Tests/**`, `README.md`, `.gitlab-ci.yml`, versão (`NShiftUIVersion` / branch).
2. Diff mental vs `Docs/Harness/*` — o que ficou stale?
3. Atualizar, nesta ordem preferencial:
   - `Architecture.md`
   - `Map.md`
   - `API.md`
   - `Conventions.md`
   - `Decisions.md`
   - `INDEX.md` (só se atalhos mudarem)
4. `AGENTS.md`: curto (≤ ~120 linhas); refresh **apenas** fatos que mudaram (versão, deps, comandos).
5. Preservar bridges:
   - `CLAUDE.md` → `AGENTS.md`
   - `.cursor/skills/update-harness` → `../../Agents/UpdateHarness`
   - `.claude/skills/update-harness` → `../../Agents/UpdateHarness`
   - `.agents/skills/update-harness` → `../../Agents/UpdateHarness`
   - Recriar com `ln -sfn` se quebrados.
6. Nunca inventar APIs; desconhecidos → `Decisions.md`.
7. Não editar `Sources/` / `Tests/` só para “combinar com docs”.
8. **Não commit** a menos que o usuário peça.

## Output contract

Resposta final do remapper deve incluir:

```markdown
## Harness remap changelog
- …
## Symlinks
- CLAUDE.md → … (ok|recreated)
- …/update-harness → Agents/UpdateHarness (ok|recreated)
## Gaps
- (novos ou removidos)
```

Sem placeholders “TODO fill later”. Conteúdo deve refletir o código lido nesta passagem.
