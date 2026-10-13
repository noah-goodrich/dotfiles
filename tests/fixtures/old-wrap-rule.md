Fixture: verbatim shape of the retired wrap-everything rule (from borg-managed.md).

| Instead of                    | Use                                          |
|-------------------------------|----------------------------------------------|
| `command1 \| command2`        | `bash -c 'command1 \| command2'`             |
| `VAR=val command args`        | `bash -c 'VAR=val command args'`             |
| `cmd1 && cmd2 && cmd3`        | `bash -c 'cmd1 && cmd2 && cmd3'`             |

- `bash -c` is in the global allowlist. Use it for pipelines and compound commands.
- Use `bash -c '...'` for pipelines and compound commands (`|`, `&&`, `;`)
