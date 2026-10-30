--!strict
-- Server-only list of admin user ids for the live-ops panel. Numeric ids only:
-- usernames can change and be re-registered by someone else.

local AdminConfig = {
	UserIds = {
		1403634211,
	},
}

function AdminConfig.IsAdmin(player: Player): boolean
	return table.find(AdminConfig.UserIds, player.UserId) ~= nil
end

return AdminConfig
