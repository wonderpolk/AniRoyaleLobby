local StatsService = {}
StatsService.PlayerDataService = nil

function StatsService:Init(services)
	self.PlayerDataService = services.PlayerDataService
end

local function round(value, decimals)
	local scale = 10 ^ (decimals or 0)
	return math.floor(value * scale + 0.5) / scale
end

function StatsService:GetStats(player)
	return self.PlayerDataService:Get(player, "Stats") or {}
end

function StatsService:GetKD(player)
	local stats = self:GetStats(player)
	local kills = stats.Kills or 0
	local deaths = stats.Deaths or 0

	if deaths == 0 then
		return kills
	end

	return round(kills / deaths, 2)
end

function StatsService:GetAverageDamage(player)
	local stats = self:GetStats(player)
	local matchesPlayed = stats.MatchesPlayed or 0

	if matchesPlayed == 0 then
		return 0
	end

	return round((stats.DamageDealt or 0) / matchesPlayed, 0)
end

function StatsService:GetWinRate(player)
	local stats = self:GetStats(player)
	local matchesPlayed = stats.MatchesPlayed or 0

	if matchesPlayed == 0 then
		return 0
	end

	return round(((stats.Wins or 0) / matchesPlayed) * 100, 1)
end

function StatsService:GetFormattedStats(player)
	local stats = self:GetStats(player)

	return {
		MatchesPlayed = stats.MatchesPlayed or 0,
		Wins = stats.Wins or 0,
		Losses = stats.Losses or 0,
		Kills = stats.Kills or 0,
		Deaths = stats.Deaths or 0,
		Assists = stats.Assists or 0,
		DamageDealt = stats.DamageDealt or 0,
		KD = self:GetKD(player),
		AverageDamage = self:GetAverageDamage(player),
		WinRate = self:GetWinRate(player),
		BestKills = stats.BestKills or 0,
		BestDamage = stats.BestDamage or 0,
	}
end

return StatsService
