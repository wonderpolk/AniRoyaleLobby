local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SkinConfig = require(ReplicatedStorage.Shared.Configs.SkinConfig)

local SkinService = {}
SkinService.PlayerDataService = nil
SkinService.CurrencyService = nil
SkinService.CharacterService = nil

function SkinService:Init(services)
	self.PlayerDataService = services.PlayerDataService
	self.CurrencyService = services.CurrencyService
	self.CharacterService = services.CharacterService
end

function SkinService:OwnsSkin(player, characterName, skinName)
	local ownedSkins = self.PlayerDataService:Get(player, "OwnedSkins") or {}
	return ownedSkins[characterName] and ownedSkins[characterName][skinName] == true
end

function SkinService:BuySkin(player, characterName, skinName)
	local characterSkins = SkinConfig[characterName]
	local skin = characterSkins and characterSkins[skinName]

	if not skin then
		return false, "Skin does not exist."
	end

	if not self.CharacterService:OwnsCharacter(player, characterName) then
		return false, "You do not own this character."
	end

	if self:OwnsSkin(player, characterName, skinName) then
		return false, "Skin already owned."
	end

	local price = skin.Price or 0
	local currency = skin.Currency or "Coins"

	if price > 0 then
		local spent, message
		if currency == "Coins" then
			spent, message = self.CurrencyService:SpendCoins(player, price, "BuySkin:" .. characterName .. ":" .. skinName)
		elseif currency == "Gems" then
			spent, message = self.CurrencyService:SpendGems(player, price, "BuySkin:" .. characterName .. ":" .. skinName)
		else
			return false, "Invalid skin currency."
		end

		if not spent then
			return false, message
		end
	end

	self.PlayerDataService:Update(player, "OwnedSkins", function(ownedSkins)
		ownedSkins = ownedSkins or {}
		ownedSkins[characterName] = ownedSkins[characterName] or {}
		ownedSkins[characterName][skinName] = true
		return ownedSkins
	end)

	return true, "Skin purchased."
end

function SkinService:EquipSkin(player, characterName, skinName)
	local characterSkins = SkinConfig[characterName]
	if not characterSkins or not characterSkins[skinName] then
		return false, "Skin does not exist."
	end

	if not self:OwnsSkin(player, characterName, skinName) then
		return false, "You do not own this skin."
	end

	self.PlayerDataService:Update(player, "EquippedSkins", function(equippedSkins)
		equippedSkins = equippedSkins or {}
		equippedSkins[characterName] = skinName
		return equippedSkins
	end)

	return true, "Skin equipped."
end

function SkinService:GetEquippedSkin(player, characterName)
	local equippedSkins = self.PlayerDataService:Get(player, "EquippedSkins") or {}
	return equippedSkins[characterName]
end

return SkinService
