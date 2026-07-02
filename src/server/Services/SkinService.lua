local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SkinConfig = require(ReplicatedStorage.Shared.Configs.SkinConfig)

local SkinService = {}
SkinService.PlayerDataService = nil
SkinService.CurrencyService = nil
SkinService.DrifterService = nil

function SkinService:Init(services)
	self.PlayerDataService = services.PlayerDataService
	self.CurrencyService = services.CurrencyService
	self.DrifterService = services.DrifterService
end

function SkinService:OwnsSkin(player, drifterName, skinName)
	local ownedSkins = self.PlayerDataService:Get(player, "OwnedSkins") or {}
	return ownedSkins[drifterName] and ownedSkins[drifterName][skinName] == true
end

function SkinService:BuySkin(player, drifterName, skinName)
	local drifterSkins = SkinConfig[drifterName]
	local skin = drifterSkins and drifterSkins[skinName]

	if not skin then
		return false, "Skin does not exist."
	end

	if not self.DrifterService:OwnsDrifter(player, drifterName) then
		return false, "You do not own this drifter."
	end

	if self:OwnsSkin(player, drifterName, skinName) then
		return false, "Skin already owned."
	end

	local price = skin.Price or 0
	local currency = skin.Currency or "Col"

	if price > 0 then
		local spent, message
		if currency == "Col" then
			spent, message = self.CurrencyService:SpendCol(player, price, "BuySkin:" .. drifterName .. ":" .. skinName)
		elseif currency == "SeedShards" then
			spent, message = self.CurrencyService:SpendSeedShards(player, price, "BuySkin:" .. drifterName .. ":" .. skinName)
		elseif currency == "DrifterTickets" then
			spent, message = self.CurrencyService:SpendDrifterTickets(player, price, "BuySkin:" .. drifterName .. ":" .. skinName)
		else
			return false, "Invalid skin currency."
		end

		if not spent then
			return false, message
		end
	end

	self.PlayerDataService:Update(player, "OwnedSkins", function(ownedSkins)
		ownedSkins = ownedSkins or {}
		ownedSkins[drifterName] = ownedSkins[drifterName] or {}
		ownedSkins[drifterName][skinName] = true
		return ownedSkins
	end)

	return true, "Skin purchased."
end

function SkinService:EquipSkin(player, drifterName, skinName)
	local drifterSkins = SkinConfig[drifterName]
	if not drifterSkins or not drifterSkins[skinName] then
		return false, "Skin does not exist."
	end

	if not self:OwnsSkin(player, drifterName, skinName) then
		return false, "You do not own this skin."
	end

	self.PlayerDataService:Update(player, "EquippedSkins", function(equippedSkins)
		equippedSkins = equippedSkins or {}
		equippedSkins[drifterName] = skinName
		return equippedSkins
	end)

	return true, "Skin equipped."
end

function SkinService:GetEquippedSkin(player, drifterName)
	local equippedSkins = self.PlayerDataService:Get(player, "EquippedSkins") or {}
	return equippedSkins[drifterName]
end

return SkinService
