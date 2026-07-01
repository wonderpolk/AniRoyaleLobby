local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PartyConfig = require(ReplicatedStorage.Shared.Configs.PartyConfig)

local PartyService = {}
PartyService.Parties = {}
PartyService.PlayerParties = {}
PartyService.PendingInvites = {}

function PartyService:Init()
	Players.PlayerRemoving:Connect(function(player)
		self:LeaveParty(player)
		self.PendingInvites[player] = nil

		for invitedPlayer, invites in pairs(self.PendingInvites) do
			invites[player] = nil
			if next(invites) == nil then
				self.PendingInvites[invitedPlayer] = nil
			end
		end
	end)
end

function PartyService:_makeParty(leader)
	local party = {
		Leader = leader,
		Members = { leader },
	}

	self.Parties[leader] = party
	self.PlayerParties[leader] = party
	return party
end

function PartyService:_removeMember(party, player)
	for index, member in ipairs(party.Members) do
		if member == player then
			table.remove(party.Members, index)
			break
		end
	end

	self.PlayerParties[player] = nil
end

function PartyService:_disbandParty(party)
	for _, member in ipairs(party.Members) do
		self.PlayerParties[member] = nil
	end

	self.Parties[party.Leader] = nil
end

function PartyService:CreateParty(player)
	if self.PlayerParties[player] then
		return false, "You are already in a party."
	end

	self:_makeParty(player)
	return true, "Party created."
end

function PartyService:GetParty(player)
	return self.PlayerParties[player]
end

function PartyService:InvitePlayer(player, targetPlayer)
	if not targetPlayer or targetPlayer.Parent ~= Players then
		return false, "Player is not in this lobby."
	end

	if player == targetPlayer then
		return false, "You cannot invite yourself."
	end

	local party = self.PlayerParties[player] or self:_makeParty(player)
	if party.Leader ~= player then
		return false, "Only the party leader can invite players."
	end

	if self.PlayerParties[targetPlayer] then
		return false, "Player is already in a party."
	end

	if #party.Members >= PartyConfig.MaxMembers then
		return false, "Party is full."
	end

	self.PendingInvites[targetPlayer] = self.PendingInvites[targetPlayer] or {}
	self.PendingInvites[targetPlayer][player] = true

	return true, "Party invite sent."
end

function PartyService:AcceptInvite(player, leaderPlayer)
	local invites = self.PendingInvites[player]
	if not invites or not invites[leaderPlayer] then
		return false, "Invite not found."
	end

	local party = self.PlayerParties[leaderPlayer]
	if not party or party.Leader ~= leaderPlayer then
		invites[leaderPlayer] = nil
		return false, "Party no longer exists."
	end

	if self.PlayerParties[player] then
		return false, "Leave your current party first."
	end

	if #party.Members >= PartyConfig.MaxMembers then
		return false, "Party is full."
	end

	table.insert(party.Members, player)
	self.PlayerParties[player] = party
	invites[leaderPlayer] = nil

	if next(invites) == nil then
		self.PendingInvites[player] = nil
	end

	return true, "Joined party."
end

function PartyService:LeaveParty(player)
	local party = self.PlayerParties[player]
	if not party then
		return false, "You are not in a party."
	end

	self:_removeMember(party, player)

	if #party.Members == 0 then
		self.Parties[party.Leader] = nil
		return true, "Party left."
	end

	if party.Leader == player then
		self.Parties[player] = nil
		party.Leader = party.Members[1]
		self.Parties[party.Leader] = party
	end

	return true, "Party left."
end

function PartyService:GetPartyData(player)
	local party = self.PlayerParties[player]
	local partyData = nil

	if party then
		local members = {}
		for _, member in ipairs(party.Members) do
			table.insert(members, {
				UserId = member.UserId,
				Name = member.Name,
				DisplayName = member.DisplayName,
				IsLeader = member == party.Leader,
			})
		end

		partyData = {
			LeaderUserId = party.Leader.UserId,
			LeaderName = party.Leader.Name,
			MaxMembers = PartyConfig.MaxMembers,
			Members = members,
		}
	end

	local pendingInvites = {}
	local invites = self.PendingInvites[player]
	if invites then
		for leaderPlayer, _ in pairs(invites) do
			if leaderPlayer.Parent == Players then
				table.insert(pendingInvites, {
					LeaderUserId = leaderPlayer.UserId,
					LeaderName = leaderPlayer.Name,
					LeaderDisplayName = leaderPlayer.DisplayName,
				})
			end
		end
	end

	return {
		Party = partyData,
		PendingInvites = pendingInvites,
	}
end

return PartyService
