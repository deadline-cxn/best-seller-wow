--[[    Filename: BestSeller.lua Author  : Smashed - Bladefist ]]--
bsVersion = "v"..GetAddOnMetadata("BestSeller", "Version")
bAutoSellActive=0
bMerchantOpen=0
iLastItemSold=0
BS_ITEM_SLOT = {}
BS_ITEM_SLOT[0]="HeadSlot"
BS_ITEM_SLOT[1]="NeckSlot"
BS_ITEM_SLOT[2]="ShoulderSlot"
BS_ITEM_SLOT[3]="BackSlot"
BS_ITEM_SLOT[4]="ChestSlot"
BS_ITEM_SLOT[5]="ShirtSlot"
BS_ITEM_SLOT[6]="TabardSlot"
BS_ITEM_SLOT[7]="WristSlot"
BS_ITEM_SLOT[8]="HandsSlot"
BS_ITEM_SLOT[9]="WaistSlot"
BS_ITEM_SLOT[10]="LegsSlot"
BS_ITEM_SLOT[11]="FeetSlot"
BS_ITEM_SLOT[12]="Finger0Slot"
BS_ITEM_SLOT[13]="Finger1Slot"
BS_ITEM_SLOT[14]="Trinket0Slot"
BS_ITEM_SLOT[15]="Trinket1Slot"
BS_ITEM_SLOT[16]="MainHandSlot"
BS_ITEM_SLOT[17]="SecondaryHandSlot"
BS_ITEM_SLOT[18]="RangedSlot"
function bsOnLoad(self)
  SLASH_BestSeller1 = "/bestseller"
  SLASH_BestSeller2 = "/bs"
  SlashCmdList["BestSeller"] = function(msg) bsCommandHandler(self,msg) end
  bsRegisterEvent("AUCTION_BIDDER_LIST_UPDATE")
  bsRegisterEvent("AUCTION_HOUSE_CLOSED")
  bsRegisterEvent("AUCTION_HOUSE_DISABLED")
  bsRegisterEvent("AUCTION_HOUSE_SHOW")
  bsRegisterEvent("AUCTION_ITEM_LIST_UPDATE")
  bsRegisterEvent("AUCTION_MULTISELL_FAILURE")
  bsRegisterEvent("AUCTION_MULTISELL_UPDATE")
  bsRegisterEvent("AUCTION_OWNED_LIST_UPDATE")
  bsRegisterEvent("CHAT_MSG_LOOT")
  bsRegisterEvent("MERCHANT_SHOW")
  bsRegisterEvent("MERCHANT_CLOSED")
  bsRegisterEvent("MERCHANT_UPDATE")
  bsRegisterEvent("PLAYER_ENTERING_WORLD")
  bsRegisterEvent("PLAYER_LOGOUT")
  bsRegisterEvent("QUEST_COMPLETE")
  bsRegisterEvent("QUEST_DETAIL")
  bsRegisterEvent("QUEST_PROGRESS")
  bsRegisterEvent("UI_INFO_MESSAGE")
  bsRegisterEvent("UNIT_INVENTORY_CHANGED")
  bsRegisterEvent("UPDATE_CHAT_WINDOWS")
  bsRegisterEvent("VARIABLES_LOADED")
end
function bsGetLink(item)
  if(item==nil) then
	return nil
  end
  for io,iw,ix in string.gmatch(item,"(.+)item:(.+):(.+)") do
	link="item:"..iw..":0"
  end
  return link
end
function bsGetEquippedItem(slot)
  sml_print(slot)
  slotId,what=GetInventorySlotInfo(slot)
  if(slotId~=nil) then return GetInventoryItemLink("player",slotId)
  end
end
function bsSetDebugWindow()
  for i = 0,10 do
	name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable =GetChatWindowInfo(i)
	if(name~=nil) then
	  if(name=="Best Seller") then
		if(db) then
		  db.bsChatFrame=getglobal("ChatFrame"..i)
		end
	  end
	end
  end
  if(db) then
	if(db.bsChatFrame==nil) then
	  db.bsChatFrame=DEFAULT_CHAT_FRAME
	end
  end
end
function bsTable(tbl)
  local x=0
  jjx=tostring(tbl)
  sml_print("TABLE: "..jjx)
  if( string.find(jjx,"table:")) then
	x=tbl
  else
	x=getglobal(tbl)
  end
  if(string.find(tostring(x),"table")) then
	for a,b in pairs(x) do
	  if(string.find(tostring(b),"table:")) then
		bsTable(b)
	  else
		sml_print("["..tostring(a).."] "..tostring(b))
	  end
	end
  else
	sml_print(tostring(x))
  end
end
function bsTargetFaction()
  local faction,fname = UnitFactionGroup("target")
  if(faction==nil) then
	faction="?"
  end
  if(fname==nil) then
	fname="?"
  end
  sml_dprint("TARGET FACTION CHECK:")
  sml_dprint("Target faction "..faction..","..fname)
  BSTooltip:ClearLines()
  BSTooltip:SetUnit("target")
  for floi=1, BSTooltip:NumLines(),1 do
	local amtext=getglobal("BSTooltipTextLeft" .. floi)
	sml_dprint(amtext:GetText())
	for factionIndex = 1, GetNumFactions() do
	  name,description,standingId,bottomValue,topValue,earnedValue,atWarWith,canToggleAtWar,isHeader,isCollapsed,hasRep,isWatched,isChild=GetFactionInfo(factionIndex)
	  if isHeader == nil then
		if(string.find(amtext:GetText(),name)) then
		  sml_dprint("Target Faction: " .. name .. " ("..FACTION_STANDING[standingId]..")")
		  return standingId
		end
	  end
	end
  end
  return 0
end
function printSubClasses(...)
  for class = 1, select("#", ...) do
	sml_dprint(select(class, ...).. ":", strjoin(", ", GetAuctionItemSubClasses(class)))
  end
end
function bsCompareItem(xitem)
  local itemName,itemLink,itemRarity,itemiLevel,itemMinLevel,itemType,itemSubType,itemStackCount,itemEquipLoc,itemTexture,itemSellPrice=GetItemInfo(xitem)
  if(itemName==nil) then
	itemName="(nameerror)"
  end
  if(itemiLevel==nil) then
	itemiLevel="(ilevelerror)"
  end
  if(itemEquipLoc==nil) then
	itemEquipLoc=0
  end
  sml_dprint("COMPARING ITEM: "..itemName.." (ilevel:"..itemiLevel..") (equipslot:"..BS_ITEM_SLOT[itemEquipLoc]..")")
  local charitem=GetInventoryItemLink("player", itemEquipLoc)
  local item2Name,item2Link,item2Rarity,item2iLevel,item2MinLevel,item2Type,item2SubType,item2StackCount,item2EquipLoc,item2Texture,item2SellPrice=GetItemInfo(charitem)
  sml_dprint("The equipped item for that slot is (ilevel:"..item2iLevel..")")
end
---[EOF]