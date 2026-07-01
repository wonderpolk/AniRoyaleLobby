# Ani Royale Lobby

Lobby-only Roblox foundation for Ani Royale. In this project, "lobby" means the social hub where players party up, open the shop, buy/equip characters and skins, adjust settings, and view profile stats. This repository is intentionally focused on those lobby hub systems only.

## What Is Included

- Modular server services for player data, currency, store purchases, character ownership, skin ownership, settings, and profile stats for the lobby hub.
- Shared configs for starter data, characters, skins, store placement, and allowed settings.
- Safe UI-ready `RemoteFunction` setup under `ReplicatedStorage.Shared.Remotes` for request/response UI actions, not server broadcasts.
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
        ├── CharacterService.lua
        ├── SkinService.lua
        ├── SettingsService.lua
        └── StatsService.lua

ReplicatedStorage
├── Packages
└── Shared
    ├── Configs
    │   ├── DataTemplate.lua
    │   ├── CharacterConfig.lua
    │   ├── SkinConfig.lua
    │   ├── StoreConfig.lua
    │   └── SettingsConfig.lua
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

## Future UI Remote Access

Lobby UI should call request/response `RemoteFunction`s when a player opens the shop, changes skins, changes settings, or opens their profile. These remotes are not broadcast systems; the server only responds to the requesting player. The UI should wait for runtime-created remotes before invoking them:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local RequestGetLobbyData = Remotes:WaitForChild("RequestGetLobbyData")
local RequestBuyCharacter = Remotes:WaitForChild("RequestBuyCharacter")
local RequestSetSetting = Remotes:WaitForChild("RequestSetSetting")
local RequestGetProfileStats = Remotes:WaitForChild("RequestGetProfileStats")
```

Clients should only send requested names or setting values, such as `characterName`, `skinName`, `settingName`, and `value`. The server owns all prices, ownership checks, currency edits, equipped skin changes, and stats formatting.

## Studio Test Checklist

- Run `wally install`, then `rojo serve`, then connect Rojo in Roblox Studio.
- Test lobby data with `RequestGetLobbyData:InvokeServer()` and confirm it returns store, settings, and equipped character data.
- Test buying a character with `RequestBuyCharacter:InvokeServer("Naruto")`; the server should decide the real price from `CharacterConfig` and reject the purchase if the player lacks coins.
- Test changing a setting with `RequestSetSetting:InvokeServer("Music", false)` and confirm invalid setting names or non-boolean values are rejected.
- Test profile stats with `RequestGetProfileStats:InvokeServer()` and confirm the values are formatted for UI display.

## Not Built Yet

Combat, damage, stamina, abilities, queues, teleporting, battle royale rounds, live matches, and live match stat tracking are intentionally not included yet. Party-up support can be added as a lobby-only service later without adding queues or match launch logic.
