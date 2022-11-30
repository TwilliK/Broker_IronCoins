local IronCoins = CreateFrame("frame", "IronCoins")
IronCoins.obj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Broker_IronCoins", {
	type = "data source",
	text = "0",
    label = "Iron Coins",
    icon  = "Interface\\Icons\\inv_misc_coin_09",
    OnClick = function(clickedframe, button)
		if button == "LeftButton" then
			IronCoins.UpdateInfo()
		end
	end,
})

-- Set static variables
local DINGY_IRON_COINS = 980
local ITEM_ORDER = {
	"SLIMY_RING",
	"GLISTENING_RING",
	"EMERALD_RING",
	"DIAMOND_RING",
	"OOZING_AMULET",
	"SPARKLING_AMULET",
	"RUBY_AMULET",
	"OPAL_AMULET",
	"LOCKET_OF_DREAMS",
	"CHAIN_OF_HOPES",
	"CHOKER_OF_NIGHTMARES",
	"WAR_BEADS",
	"GLOWING_IDOL"
}
local ITEMS_TO_FENCE = {
	SLIMY_RING = 112995,
	GLISTENING_RING = 112996,
	EMERALD_RING = 112997,
	DIAMOND_RING = 112998,
	OOZING_AMULET= 113000,
	SPARKLING_AMULET = 113001,
	RUBY_AMULET = 113002,
	OPAL_AMULET = 113003,
	LOCKET_OF_DREAMS = 113004,
	CHAIN_OF_HOPES = 113005,
	CHOKER_OF_NIGHTMARES = 113006,
	WAR_BEADS = 113007,
	GLOWING_IDOL = 113008,
}
local FENCE_VALUE = {
	SLIMY_RING = 2,
	GLISTENING_RING = 3,
	EMERALD_RING = 4,
	DIAMOND_RING = 5,
	OOZING_AMULET= 4,
	SPARKLING_AMULET = 6,
	RUBY_AMULET = 8,
	OPAL_AMULET = 10,
	LOCKET_OF_DREAMS = 6,
	CHAIN_OF_HOPES = 12,
	CHOKER_OF_NIGHTMARES = 18,
	WAR_BEADS = 20,
	GLOWING_IDOL = 20,
}
local ITEM_TEXTURE = {
	SLIMY_RING = 'inv_jewelry_ring_12',
	GLISTENING_RING = 'inv_jewelry_ring_60',
	EMERALD_RING = 'inv_jewelry_ring_08',
	DIAMOND_RING = 'inv_jewelry_ring_94',
	OOZING_AMULET= 'inv_jewelry_necklace_ahnqiraj_03',
	SPARKLING_AMULET = 'inv_jewelry_amulet_02',
	RUBY_AMULET = 'inv_jewelry_necklace_103',
	OPAL_AMULET = 'inv_jewelry_necklace_55',
	LOCKET_OF_DREAMS = 'inv_jewelry_necklace_26',
	CHAIN_OF_HOPES = 'inv_misc_thornnecklace',
	CHOKER_OF_NIGHTMARES = 'inv_jewelry_necklace_33',
	WAR_BEADS = 'inv_jewelry_necklace_02',
	GLOWING_IDOL = 'inv_misc_trinket6oog_idol3',
}
local SECRETIVE_WHISTLE = 113575

-- Set variables
local fluidCoins = 0
local whistleCooldown = 0
local itemCounts = {
	SLIMY_RING = 0,
	GLISTENING_RING = 0,
	EMERALD_RING = 0,
	DIAMOND_RING = 0,
	OOZING_AMULET= 0,
	SPARKLING_AMULET = 0,
	RUBY_AMULET = 0,
	OPAL_AMULET = 0,
	LOCKET_OF_DREAMS = 0,
	CHAIN_OF_HOPES = 0,
	CHOKER_OF_NIGHTMARES = 0,
	WAR_BEADS = 0,
	GLOWING_IDOL = 0,
}


function IronCoins:LootValue()
	fluidCoins = 0
	for iname, itemID in pairs(ITEMS_TO_FENCE) do
		itemCounts[iname] = GetItemCount(itemID,false,false)
		fluidCoins = fluidCoins + (itemCounts[iname] * FENCE_VALUE[iname])
	end
end

function IronCoins:UpdateInfo()
	local coinTable = C_CurrencyInfo.GetCurrencyInfo(DINGY_IRON_COINS);
	local coinInfo = coinTable['name'];
	local currentCoins = coinTable['quantity'];
	-- print(currentCoins .. " coins")
	IronCoins:LootValue()
	IronCoins.obj.text = currentCoins
	if fluidCoins~=0 then
		IronCoins.obj.text = IronCoins.obj.text .. " + " .. fluidCoins
	end
	local whistCDS, whistCD = GetItemCooldown(SECRETIVE_WHISTLE)
	local whistCDEndtime = whistCDS + whistCD
	whistleCooldown = floor(whistCDEndtime - GetTime())
	local whistCDMin = floor(whistleCooldown / 60)
	local whistCDSec = math.fmod(whistleCooldown, 60)
	-- print(whistCDMin .. ":" .. whistCDSec)
	if whistleCooldown>0 then
		IronCoins.obj.text = IronCoins.obj.text .. " | " .. whistCDMin+1 .. "min"
	end
end

-------------
-- TOOLTIP --
-------------

local LibQTip = LibStub('LibQTip-1.0')

function IronCoins.obj:OnEnter()
	local tooltip = LibQTip:Acquire("Broker_IronCoinsTooltip", 3, "LEFT", "LEFT", "RIGHT")
	self.tooltip = tooltip
	local coinTable = C_CurrencyInfo.GetCurrencyInfo(DINGY_IRON_COINS);
	local coinInfo = coinTable['name'];
	local currentCoins = coinTable['quantity'];

	--tooltip:AddHeader('Broker_IronCoins')
	tooltip:AddLine('|TInterface\\Icons\\inv_misc_coin_09:0|t Inital Coins','',currentCoins)
	for k, iname in ipairs(ITEM_ORDER) do
		local quant = itemCounts[iname]
		local val = FENCE_VALUE[iname]
		local sum = quant * val
		local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture = GetItemInfo(ITEMS_TO_FENCE[iname])
		if name == nil then
			-- print(iname.." not in itemcache")
			tooltip:AddLine('|TInterface\\Icons\\'..ITEM_TEXTURE[iname]..':0|t '..iname, quant..' @ '..val..'ea', sum)
		else
			r, g, b, hex = GetItemQualityColor(quality)
			tooltip:AddLine('|T'..texture..':0|t |c'..hex..name, quant..' @ '..val..'ea', sum)
		end
	end
	tooltip:AddLine('|TInterface\\Icons\\inv_misc_coin_09:0|t Projected Gain','',fluidCoins);
	tooltip:AddSeparator();
	tooltip:AddLine('|TInterface\\Icons\\inv_misc_coin_09:0|t Total Coins','',currentCoins+fluidCoins);
	tooltip:SmartAnchorTo(self)
	tooltip:Show()
end

function IronCoins.obj:OnLeave()
	LibQTip:Release(self.tooltip)
	self.tooltip = nil
end
IronCoins:SetScript("OnEvent", function()
	IronCoins:UpdateInfo()
end )

IronCoins:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
IronCoins:RegisterEvent("PLAYER_ENTERING_WORLD")
IronCoins:RegisterEvent("CHAT_MSG_MONEY")
IronCoins:RegisterEvent("BAG_UPDATE")