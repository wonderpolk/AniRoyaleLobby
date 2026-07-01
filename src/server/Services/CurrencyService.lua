local CurrencyService = {}
CurrencyService.PlayerDataService = nil

function CurrencyService:Init(services)
	self.PlayerDataService = services.PlayerDataService
end

local function isPositiveNumber(amount)
	return type(amount) == "number" and amount > 0 and amount == amount and amount < math.huge
end

local function getCurrencyDisplayName(key)
	if key == "SeedShards" then
		return "seed shards"
	end

	return string.lower(key)
end

function CurrencyService:_get(player, key)
	return self.PlayerDataService:Get(player, key) or 0
end

function CurrencyService:_add(player, key, amount)
	if not isPositiveNumber(amount) then
		return false, "Invalid amount."
	end

	self.PlayerDataService:Update(player, key, function(current)
		return (current or 0) + amount
	end)

	return true, "Currency added."
end

function CurrencyService:_spend(player, key, amount)
	if not isPositiveNumber(amount) then
		return false, "Invalid amount."
	end

	local current = self:_get(player, key)
	if current < amount then
		return false, "Not enough " .. getCurrencyDisplayName(key) .. "."
	end

	self.PlayerDataService:Set(player, key, current - amount)
	return true, "Currency spent."
end

function CurrencyService:GetCol(player)
	return self:_get(player, "Col")
end

function CurrencyService:AddCol(player, amount, reason)
	return self:_add(player, "Col", amount, reason)
end

function CurrencyService:SpendCol(player, amount, reason)
	return self:_spend(player, "Col", amount, reason)
end

function CurrencyService:HasCol(player, amount)
	return isPositiveNumber(amount) and self:GetCol(player) >= amount
end

function CurrencyService:GetSeedShards(player)
	return self:_get(player, "SeedShards")
end

function CurrencyService:AddSeedShards(player, amount, reason)
	return self:_add(player, "SeedShards", amount, reason)
end

function CurrencyService:SpendSeedShards(player, amount, reason)
	return self:_spend(player, "SeedShards", amount, reason)
end

function CurrencyService:HasSeedShards(player, amount)
	return isPositiveNumber(amount) and self:GetSeedShards(player) >= amount
end

return CurrencyService
