#### Fix Ruff Integration

I have not been able to get Ruff to work (without terrible ~50s performance on a small file) with my normal LSP
configuration, and it isn't supported by null-ls. At present, I run it using an auto-command which invokes system
rust and then reloads the buffer after normal buffer save, but this seems dangerous and should not be necessary.

#### Strict /lua/plugins Naming Convention

All Lua files in /lua/plugins should be named after a single plugin they configure, rather than generic names like
"completion" or "formatting".
## figure out git worktrees
