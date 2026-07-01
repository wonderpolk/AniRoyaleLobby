local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterConfig = require(ReplicatedStorage.Shared.Configs.CharacterConfig)

local CharacterService = {}
CharacterService.PlayerDataService = nil
CharacterService.CurrencyService = nil

function CharacterService:Init(services)
	self.PlayerDataService = services.PlayerDataService
	self.CurrencyService = services.CurrencyService
end

function CharacterService:OwnsCharacter(player, characterName)
	local ownedCharacters = self.PlayerDataService:Get(player, "OwnedCharacters") or {}
	return ownedCharacters[characterName] == true
end

function CharacterService:BuyCharacter(player, characterName)
	local character = CharacterConfig[characterName]
	if not character then
		return false, "Character does not exist."
	end

	if self:OwnsCharacter(player, characterName) then
		return false, "Character already owned."
	end

	local price = character.Price or 0
	local currency = character.Currency or "Col"

	if price > 0 then
		local spent, message
		if currency == "Col" then
			spent, message = self.CurrencyService:SpendCol(player, price, "BuyCharacter:" .. characterName)
		elseif currency == "SeedShards" then
			spent, message = self.CurrencyService:SpendSeedShards(player, price, "BuyCharacter:" .. characterName)
		else
			return false, "Invalid character currency."
		end

		if not spent then
			return false, message
		end
	end

	self.PlayerDataService:Update(player, "OwnedCharacters", function(ownedCharacters)
		ownedCharacters = ownedCharacters or {}
		ownedCharacters[characterName] = true
		return ownedCharacters
	end)

	return true, "Character purchased."
end

function CharacterService:EquipCharacter(player, characterName)
	if not CharacterConfig[characterName] then
		return false, "Character does not exist."
	end

	if not self:OwnsCharacter(player, characterName) then
		return false, "You do not own this character."
	end

	self.PlayerDataService:Set(player, "EquippedCharacter", characterName)
	return true, "Character equipped."
end

function CharacterService:GetEquippedCharacter(player)
	return self.PlayerDataService:Get(player, "EquippedCharacter")
end

return CharacterService
