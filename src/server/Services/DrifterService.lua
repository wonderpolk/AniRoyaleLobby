local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DrifterConfig = require(ReplicatedStorage.Shared.Configs.DrifterConfig)

local DrifterService = {}
DrifterService.PlayerDataService = nil
DrifterService.CurrencyService = nil

function DrifterService:Init(services)
	self.PlayerDataService = services.PlayerDataService
	self.CurrencyService = services.CurrencyService
end

function DrifterService:OwnsDrifter(player, drifterName)
	local ownedDrifters = self.PlayerDataService:Get(player, "OwnedDrifters") or {}
	return ownedDrifters[drifterName] == true
end

function DrifterService:BuyDrifter(player, drifterName)
	local drifter = DrifterConfig[drifterName]
	if not drifter then
		return false, "Drifter does not exist."
	end

	if self:OwnsDrifter(player, drifterName) then
		return false, "Drifter already owned."
	end

	local price = drifter.Price or 0
	local currency = drifter.Currency or "Col"

	if price > 0 then
		local spent, message
		if currency == "Col" then
			spent, message = self.CurrencyService:SpendCol(player, price, "BuyDrifter:" .. drifterName)
		elseif currency == "SeedShards" then
			spent, message = self.CurrencyService:SpendSeedShards(player, price, "BuyDrifter:" .. drifterName)
		elseif currency == "DrifterTickets" then
			spent, message = self.CurrencyService:SpendDrifterTickets(player, price, "BuyDrifter:" .. drifterName)
		else
			return false, "Invalid drifter currency."
		end

		if not spent then
			return false, message
		end
	end

	self.PlayerDataService:Update(player, "OwnedDrifters", function(ownedDrifters)
		ownedDrifters = ownedDrifters or {}
		ownedDrifters[drifterName] = true
		return ownedDrifters
	end)

	return true, "Drifter purchased."
end

function DrifterService:EquipDrifter(player, drifterName)
	if not DrifterConfig[drifterName] then
		return false, "Drifter does not exist."
	end

	if not self:OwnsDrifter(player, drifterName) then
		return false, "You do not own this drifter."
	end

	self.PlayerDataService:Set(player, "EquippedDrifter", drifterName)
	return true, "Drifter equipped."
end

function DrifterService:GetEquippedDrifter(player)
	return self.PlayerDataService:Get(player, "EquippedDrifter")
end

return DrifterService
