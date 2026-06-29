local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SettingsConfig = require(ReplicatedStorage.Shared.Configs.SettingsConfig)

local SettingsService = {}
SettingsService.PlayerDataService = nil

function SettingsService:Init(services)
	self.PlayerDataService = services.PlayerDataService
end

function SettingsService:GetSettings(player)
	return self.PlayerDataService:Get(player, "Settings") or {}
end

function SettingsService:SetSetting(player, settingName, value)
	local settingConfig = SettingsConfig[settingName]
	if not settingConfig then
		return false, "Setting does not exist."
	end

	if typeof(value) ~= settingConfig.Type then
		return false, "Invalid setting value."
	end

	self.PlayerDataService:Update(player, "Settings", function(settings)
		settings = settings or {}
		settings[settingName] = value
		return settings
	end)

	return true, "Setting updated."
end

return SettingsService
