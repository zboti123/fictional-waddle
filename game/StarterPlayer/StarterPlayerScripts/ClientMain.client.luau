--!strict
-- Client bootstrap: the only LocalScript. Builds the UI and starts the
-- display-only client systems. All game decisions happen on the server.

local Client = script.Parent:WaitForChild("Client")
local ClientState = require(Client:WaitForChild("ClientState"))
local UIRoot = require(Client:WaitForChild("UIRoot"))
local Hud = require(Client:WaitForChild("Hud"))
local ShopPanel = require(Client:WaitForChild("ShopPanel"))
local NestPanel = require(Client:WaitForChild("NestPanel"))
local Feedback = require(Client:WaitForChild("Feedback"))
local WorldFx = require(Client:WaitForChild("WorldFx"))

local gui = UIRoot.Create()
local shop = ShopPanel.Create(gui)
local nest = NestPanel.Create(gui)

local hud = Hud.Create(gui, {
	OnEggs = function()
		nest.Close()
		shop.Toggle()
	end,
	OnNest = function()
		shop.Close()
		nest.Toggle()
	end,
})

Feedback.Start(gui, hud.GemsLabel)
WorldFx.Start()

-- Start listening last so the first snapshot reaches every UI listener.
ClientState.Start()
