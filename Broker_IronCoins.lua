local IronCoins = CreateFrame("frame")
IronCoins.obj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Broker_IronCoins", {
	type = "data source",
	text = "0",
    label = "Iron Coins",
    icon  = "Interface\\Icons\\inv_misc_coin_09"
})

-- Set static variables
local DINGY_IRON_COINS = 980
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

IronCoins:SetScript("OnEvent", function()
	local coinInfo, currentCoins = GetCurrencyInfo(DINGY_IRON_COINS);
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
end)

IronCoins:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
IronCoins:RegisterEvent("PLAYER_ENTERING_WORLD")
IronCoins:RegisterEvent("CHAT_MSG_MONEY")
IronCoins:RegisterEvent("BAG_UPDATE")