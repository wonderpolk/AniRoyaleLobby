# Ani Royale Lobby

Roblox lobby-first foundation for a battle royale experience. The project is structured for Rojo so the lobby systems can be developed in source control before adding match gameplay.

## Lobby Scope

- Player spawn flow and lobby state tracking.
- Queue countdown that starts when enough players are present.
- Shared configuration for lobby thresholds and timer values.
- Client HUD that shows player count, queue state, and countdown.

## Project Layout

```text
src/
  client/      LocalScripts that run in StarterPlayerScripts
  server/      Server scripts that run in ServerScriptService
  shared/      Shared ModuleScripts replicated to clients
```

## Getting Started

1. Install [Rojo](https://rojo.space/) if you want to sync the project into Roblox Studio.
2. Run `rojo serve` from this repository.
3. Open Roblox Studio and connect the Rojo plugin.
4. Sync safely: the project uses Rojo `$ignoreUnknownInstances` settings so existing Studio-only instances are preserved while these lobby folders are added.
5. Press Play with multiple test clients to verify the lobby counter and countdown.

## Next Milestones

- Add lobby map props, spawn pads, and interactive NPCs.
- Add party support and queue cancellation.
- Reserve private battle royale servers when the queue countdown completes.
- Add cosmetics, settings, and progression UI.
