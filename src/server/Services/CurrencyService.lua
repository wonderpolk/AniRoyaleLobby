local CurrencyService = {}
CurrencyService.PlayerDataService = nil

function CurrencyService:Init(services)
	self.PlayerDataService = services.PlayerDataService
end

local function isPositiveNumber(amount)
	return type(amount) == "number" and amount > 0 and amount == amount and amount < math.huge
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
		return false, "Not enough " .. key:lower() .. "."
	end

	self.PlayerDataService:Set(player, key, current - amount)
	return true, "Currency spent."
end

function CurrencyService:GetCoins(player)
	return self:_get(player, "Coins")
end

function CurrencyService:AddCoins(player, amount, reason)
	return self:_add(player, "Coins", amount, reason)
end

function CurrencyService:SpendCoins(player, amount, reason)
	return self:_spend(player, "Coins", amount, reason)
end

function CurrencyService:HasCoins(player, amount)
	return isPositiveNumber(amount) and self:GetCoins(player) >= amount
end

function CurrencyService:GetGems(player)
	return self:_get(player, "Gems")
end

function CurrencyService:AddGems(player, amount, reason)
	return self:_add(player, "Gems", amount, reason)
end

function CurrencyService:SpendGems(player, amount, reason)
	return self:_spend(player, "Gems", amount, reason)
end

function CurrencyService:HasGems(player, amount)
	return isPositiveNumber(amount) and self:GetGems(player) >= amount
end

return CurrencyService
