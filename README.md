# Ani Royale Lobby

Lobby-only Roblox foundation for Ani Royale. In this project, "lobby" means the social hub where players party up, open the shop, buy/equip drifters and skins, adjust settings, and view profile stats. This repository is intentionally focused on those lobby hub systems only.

## What Is Included

- Modular server services for player data, currency, store purchases, drifter ownership, skin ownership, settings, party invites, and profile stats for the lobby hub.
- Shared configs for starter data, drifters, skins, store placement, party size, and allowed settings.
- Safe `RemoteFunction` setup under `ReplicatedStorage.Shared.Remotes` for request/response lobby actions, not server broadcasts.
- Temporary black main menu placeholder with a loading assets bar and Play button.
- Lobby camera and fixed lobby spawn support for the Studio `Workspace.LobbyRoom` setup.
- Rojo mapping that preserves unknown Studio instances while syncing source-controlled lobby folders.
- Wally dependency entry for `DataService`, kept behind `PlayerDataService` so the data layer can be swapped later.

## Project Layout

```text
ServerScriptService
└── Server
    ├── Main.server.lua
    └── Services
        ├── PlayerDataService.lua
        ├── CurrencyService.lua
        ├── StoreService.lua
        ├── DrifterService.lua
        ├── SkinService.lua
        ├── SettingsService.lua
        ├── StatsService.lua
        ├── PartyService.lua
        └── LobbySpawnService.lua

StarterPlayer
└── StarterPlayerScripts
    └── Client
        ├── MainMenu.client.lua
        ├── LobbyCamera.client.lua
        └── LobbyMovementLock.client.lua

ReplicatedStorage
├── Packages
└── Shared
    ├── Configs
    │   ├── DataTemplate.lua
    │   ├── DrifterConfig.lua
    │   ├── SkinConfig.lua
    │   ├── StoreConfig.lua
    │   ├── SettingsConfig.lua
    │   └── PartyConfig.lua
    ├── Remotes
    └── Types.lua
```

## Setup

1. Install Wally from <https://wally.run/> or run `rokit install` if using the checked-in Rokit toolchain.
2. Install Rojo from <https://rojo.space/> or use the Rokit-managed Rojo binary.
3. Run `wally install` from this repository to install `DataService` into `Packages`.
4. Run `rojo serve` from this repository.
5. Open Roblox Studio, open the Rojo plugin, and connect to the running Rojo server.
6. Sync safely: the project uses Rojo `$ignoreUnknownInstances` settings so existing Studio-only instances are preserved while lobby code is added.

## Studio Lobby Room Setup

Create these parts in Studio under `Workspace.LobbyRoom` when possible:

- `LobbyCamera`: a part placed where the lobby camera should look from. The client locks the camera to this part while the player is in the lobby.
- `Member1`: a part placed where the first lobby player should stand. The server creates an invisible `LobbySpawnLocation` on top of this part, moves players there, and freezes their movement for the lobby view. `Member1` is safe to use; the number is not a problem. The service also supports `SlotOne` or `Slot1` if you prefer that naming later. You can also put a `StringValue` named `LobbySpawn`, `LobbySlot`, `SpawnSlot`, or `SpawnPoint` inside any spawn part to mark it as the lobby spawn. Direct placement under `Workspace.LobbyRoom.Member1` is still the cleanest setup.

If `LobbyCamera` contains a `StringValue` named `CamPart`, the client will try to use the part named by that value first. If it cannot find that named part, it uses `LobbyCamera` itself.

## Future Client Remote Access

Future client scripts should call request/response `RemoteFunction`s when a player opens the shop, creates/leaves a party, invites lobby players, changes skins, changes settings, or opens their profile. These remotes are not broadcast systems; the server only responds to the requesting player. Client scripts should wait for runtime-created remotes before invoking them:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local RequestGetLobbyData = Remotes:WaitForChild("RequestGetLobbyData")
local RequestBuyDrifter = Remotes:WaitForChild("RequestBuyDrifter")
local RequestSetSetting = Remotes:WaitForChild("RequestSetSetting")
local RequestCreateParty = Remotes:WaitForChild("RequestCreateParty")
local RequestInviteToParty = Remotes:WaitForChild("RequestInviteToParty")
local RequestAcceptPartyInvite = Remotes:WaitForChild("RequestAcceptPartyInvite")
local RequestLeaveParty = Remotes:WaitForChild("RequestLeaveParty")
local RequestGetPartyData = Remotes:WaitForChild("RequestGetPartyData")
local RequestGetProfileStats = Remotes:WaitForChild("RequestGetProfileStats")
```

Clients should only send requested names, player IDs, or setting values, such as `drifterName`, `skinName`, `targetUserId`, `settingName`, and `value`. The server owns all prices, ownership checks, currency edits, equipped skin changes, and stats formatting.

## Studio Test Checklist

- Run `wally install`, then `rojo serve`, then connect Rojo in Roblox Studio.
- Test lobby data with `RequestGetLobbyData:InvokeServer()` and confirm it returns store, settings, equipped drifter, and party data.
- Test buying a drifter with `RequestBuyDrifter:InvokeServer("Naruto")`; the server should decide the real price from `DrifterConfig` and reject the purchase if the player lacks Col or drifter tickets.
- Test changing a setting with `RequestSetSetting:InvokeServer("Music", false)` and confirm invalid setting names or non-boolean values are rejected.
- Test party data with `RequestCreateParty:InvokeServer()`, `RequestInviteToParty:InvokeServer(targetUserId)`, and `RequestGetPartyData:InvokeServer()`.
- Test profile stats with `RequestGetProfileStats:InvokeServer()` and confirm the values are formatted for display.
