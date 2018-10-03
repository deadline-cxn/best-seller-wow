-- Best Seller Auto Sell
-- TODO:
-- ALT-LEFT-CLICK (Toggle item onto Auto Sell List)
-- ALT-RIGHT-CLICK (Toggle item onto Exclude List)
-- Shiny preview mode
-- Option to sell only "type" of BOPs
-- Warn if selling items from BS_DO_NOT_SELL list
-- Sell DOWN TO
BS_DO_NOT_SELL={
  ["Hearthstone"]=1,
  ["Philosopher's Stone"]=1,
  ["Bloodsail*"]=1, -- All bloodsail pirate outfit
  ["Gnomeregan Drape"]=1,
  ["Titanium Seal of Dalaran"]=1,
  ["Gnomish Army Knife"]=1,
  ["The Last Relic of Argus"]=1,
  ["Seafood Magnifique Feast"]=1,
  ["Shroud of Cooperation"]=1,
  ["Wrap of Unity"]=1,
  ["Battle Standard of Coordination"]=1,
  ["Standard of Unity"]=1,
  ["Banner of Cooperation"]=1,
  ["Ring of the Kirin Tor"]=1,
  ["Weather-Beaten Fishing Hat"]=1,
  ["Matercraft Kalu'ak Fishing Pole"]=1,
  ["Crashin' Thrashin' Racer*"]=1,
  ["Mushroom Chair"]=1,
  ["Amani Hex Stick"]=1,
  ["Winter*"]=1,
  ["Barov Peasant Caller"]=1,
  ["Barov Servant Caller"]=1,
  ["Kaldorei Wind Chimes"]=1,
  ["Pendant of the Scarab Storm"]=1,
  ["Druid and Priest Statue Set"]=1,
  ["Mylune's Call"]=1,
  ["Signet of Expertise"]=1,
  ["Bones of Transformation"]=1,
  ["Rituals of the New Moon"]=1,
  ["Vile Fumigator's Mask"]=1,
  ["Sulfuras, Hand of Ragnaros"]=1,
  ["Tabard*"]=1,
  ["Wisp Amulet"]=1,
  ["Mark of the Chosen"]=1,
  ["Arrival of the Naaru"]=1,
  ["Grilled Dragon"]=1,
  ["Insignia of the Alliance"]=1,
  ["Captain Sanders' Shirt"]=1,
  ["Ankh"]=1,
  ["Stardust"]=1,
  ["Time-Lost Figurine"]=1,
  ["Obsidian Warbeads"]=1,
  ["Mechanical Yeti"]=1,
  ["Jeweler's Kit"]=1,
  ["Simple Grinder"]=1,
  ["Fishing Pole"]=1,
  ["Mining Pick"]=1,
  ["Moist Towelette"]=1,
  ["Rhea's Last Egg"]=1,
  ["Arcanum*"]=1,
  ["Lovely Black Dress"]=1,
  ["Red Lumberjack Shirt"]=1,
  ["Highborne Soul Mirror"]=1,
}

function bsAutoSell()
  if(db.AutoSell==nil) then return; end
  if(db.AutoSell["Active"]==false) then return; end
  -- local itemName,itemLink,itemRarity,itemLevelReq,itemMinLevel,itemType,itemSubType,itemStackCount,itemEquipLoc,itemTexture,itemSellPrice
  local exclude=0
  local floi=0
  local isfood=0
  local ifoodrange=0
  local itotalgold=0
  local dosoulbound=0
  local dofood=0
  local ttext=""
  local tiLevel="0"
  local iLevel=0
  local safecount=0
  local wildcard=""
  local bDoSell=0
  local bIsSoulbound=0
  local bIsQuestItem=0
  local bIsRecipe=0
  local bHasFoodBuf=0
  local d1msg=""
  local d2msg=""
  local exclude
  local thiswildcard

  for bag = 0,4,1 do
	for slot = 1, GetContainerNumSlots(bag), 1 do
	  d1msg=""
	  d2msg=""
	  local name = GetContainerItemLink(bag,slot)
	  if(name~=nil) then
		bDoSell=0
		bIsQuestItem=0
		bIsSoulbound=0
		bHasFoodBuf=0
		bIsRecipe=0
		itemCount=GetItemCount(name)
		local itemName,itemLink,itemRarity,itemLevelReq,itemMinLevel,itemType,itemSubType,itemStackCount,itemEquipLoc,itemTexture,itemSellPrice=GetItemInfo(name)
		if(itemType==nil) then
		  itemType="unknown"
		end
		if(itemSubType==nil) then
		  itemSubType="none"
		end
		if(itemSellPrice==nil) then
		  itemSellPrice=0
		end
		--sml_print("BestSeller","ITEM"..name.."  type["..itemType.."] subtype["..itemSubType.."] sellprice["..itemSellPrice.."] Rarity["..itemRarity.."]")
        sml_dprint(db.Debug,"BestSeller","ITEM:"..name.." -> type:"..itemType.." -> subtype:"..itemSubType.." -> "..itemSellPrice)
		if(itemSellPrice==0) then
		  itemSellPrice=nil
		end
		if (itemSellPrice ~= nil ) then
		  BSTooltip:ClearLines()
		  local thname, thlink = GetItemInfo(name)
		  BSTooltip:SetHyperlink(thlink)
		  for floi=1, BSTooltip:NumLines(),1 do
			local amtext=getglobal("BSTooltipTextLeft" .. floi)
			for tiLevel in string.gmatch(amtext:GetText(), "Item Level (.+)") do
			  iLevel=tiLevel
			end
			if(string.find(amtext:GetText(),"Recipe:")) then
			  bIsRecipe=1
			end
			if(string.find(amtext:GetText(),"well fed")) then
			  bHasFoodBuf=1
			end
			if(amtext:GetText()=="Binds when picked up") then
			  if(floi==2) then
				bIsSoulbound=1
			  end
			end
		  end
		  if(bIsRecipe==1) then
			bHasFoodBuf=0
		  end
		  bIsQuestItem=0
		  if (itemType=="Quest") or
			(bsIsQuestItem(itemName)==1) then
			bIsQuestItem=1
		  end
		  if(db.AutoSell["Safe"]==1) then
			if(safecount>11) then
			  d1msg="SAFE MODE: Sold 12 items and now stopping"
			  bAutoSellActive=0
			  return
			end
		  end
		  exclude=0
		  thiswildcard=""
		  for item,_ in pairs (db.AutoSell["Exclude"]) do
			for what in string.gmatch(item, "(.+)*") do
			  if(what~=nil) then
				wildcard=what
				if(string.find(itemName,wildcard)) then
				  thiswildcard=wildcard
				  exclude=1
				end
			  end
			end
		  end
		  for item,_ in pairs (db.AutoSell["Exclude"]) do
			if(itemName==item) then
			  exclude=1
			end
		  end
		  thiswildcard=""
		  for item,_ in pairs (BS_DO_NOT_SELL) do
			for what in string.gmatch(item, "(.+)*") do
			  if(what~=nil) then
				wildcard=what
				if(string.find(itemName,wildcard)) then
				  thiswildcard=wildcard
				  d1msg=""
				  d2msg=OFCC..itemName..JFCC.." (hard exclude table)"..RFCC.." (not sold)"
				  exclude=1
				end
			  end
			end
		  end
		  for item,_ in pairs (BS_DO_NOT_SELL) do
			if(itemName==item) then
			  d1msg=""
			  d2msg=OFCC..itemName..JFCC.." (hard exclude table)"..RFCC.." (not sold)"
			  exclude=1
			end
		  end
		  if(exclude==1) then
			if(thiswildcard~="") then
			  thiswildcard=" (wildcard "..thiswildcard..")"
			end
			d2msg=OFCC..itemName..PFCC.." "..thiswildcard.." (found in exclude list) "..RFCC.."(not sold) "
		  else
			if(bIsQuestItem==1) then
			  if(itemType=="Quest") then
				d2msg=OFCC..itemName..GFCC.." (quest item) "..RFCC.."(not sold)"
			  else
				d1msg=OFCC..itemName..GFCC.." (item needed for quest) "..RFCC.."(not sold)"
			  end
			elseif (itemSellPrice==0) then
			  d2msg=OFCC..itemName..BFCC.." (no sell price)"..RFCC.." (not sold)"
			else
			  wildcard=""
			  if (itemRarity==0) then -- Sell Grey Items but exclude specific items
				bDoSell=1
			  else
				if(db.AutoSell["GreyOnly"]~=1) then
				  if(db.AutoSell["Remember"]==1) then
					for item,_ in pairs (db.AutoSell["Items"]) do
					  wildcard=""
					  for what in string.gmatch(item,"(.+)*") do
						if(what~=nil) then
						  wildcard=what
						end
					  end
					  if(wildcard~="") then
						if(string.find(itemName,wildcard)) then
						  d1msg="Sold: "..itemName.. " because it is in your Auto Sell List (wildcard "..wildcard..")"
						  bDoSell=1
						end
					  end
					end
					for item,_ in pairs (db.AutoSell["Items"]) do
					  if( itemName == item) then
						d1msg="Sold: "..item.. " because it is in your Auto Sell List"
						bDoSell=1
					  end
					end
				  end
				  if(db.AutoSell["Soulbound"]==1) then
					if(bIsSoulbound==1) then
					  if(tonumber(iLevel)     >     tonumber(db.AutoSell["SoulboundLow"])) then
						if(tonumber(iLevel) <     tonumber(db.AutoSell["SoulboundHigh"])) then
						  if(itemRarity<=db.AutoSell["SoulboundQuality"]) then
							d1msg="Sold: "..OFCC..itemName..YFCC.." because it is soulbound between level "..
							db.AutoSell["SoulboundLow"].." and "..db.AutoSell["SoulboundHigh"]
							bDoSell=1
						  end
						end
					  end
					end
				  end
				  if(db.AutoSell["LowFoods"]==1) then
					ifoodrange=UnitLevel("player")-itemMinLevel
					isfood=0
					for wtf in string.gmatch(itemSubType,"Food(.+)") do
					  isfood=1
					end
					if(isfood==1) then
					  dofood=0
					  if  (itemMinLevel==70) or
						(itemMinLevel==60) then
						if (ifoodrange>5) then
						  dofood=1
						end
					  else
						if (ifoodrange>10) then
						  dofood=1
						end
					  end
					  if(dofood==1) then
						if(bHasFoodBuf==0) then
						  d1msg="Sold: "..OFCC..itemName..YFCC.." (outleveled food or drink item)"
						  bDoSell=1
						else
						  if(db.AutoSell["BufFoods"]==1) then
							bDoSell=1
							d1msg="Sold: "..OFCC..itemName..YFCC.." (outleveled food or drink item with buf)"
						  else
							d2msg=OFCC..itemName..JFCC.." (buff food)"..RFCC.." (not sold)"
						  end
						end
					  end
					end
				  end
				end
			  end
			end
		  end
		end
		if
          (itemType=="Trade Goods") or
		  (itemType=="Gem") or
		  (itemType=="Quest") or
		  (itemType=="Recipe") 
		  --(itemType=="Consumable")
          then
		  d1msg=""
		  d2msg=OFCC..itemName..JFCC.." (excluded item based on type)"..RFCC.." (not sold)"
		  bDoSell=0
		end
		if(bDoSell==1) then
		  bsRecentAutoSold[itemName]=1
		  UseContainerItem(bag,slot)
		  itotalgold=itotalgold+(itemSellPrice*itemCount)
		  safecount=safecount+1
		end
		if(db.AutoSell["Detail"]==1) then
		  if(d1msg~="") then
			sml_print("BestSeller",d1msg)
		  end
		end
		if(db.AutoSell["DetailAll"]==1) then
		  if(bDoSell==0) then
			if(d2msg~="") then
			  sml_print("BestSeller",d2msg)
			end
		  end
		end
	  end
	end
  end
  if (itotalgold>0) then
	sml_print("BestSeller","Total money earned for auto selling items "..GetCoinText(itotalgold))
  end
end
function bsWasAutoSold(item)
  for x,y in pairs(bsRecentAutoSold) do
	if(x==item) then
	  if(y==1) then
		return 1
	  end
	end
  end
  return 0
end
function bsIsQuestItem(bsitem)
  local numEntries, numQuests = GetNumQuestLogEntries()
  sml_dprint(db.Debug,"BestSeller","isQuestItem: numEntries:"..numEntries.." numQuests:"..numQuests)
  for bsqu=1,numQuests do
	bsnlb=GetNumQuestLeaderBoards(bsqu)
	for bslb=1,bsnlb do
	  local bstxt,bstyp,bsfin = GetQuestLogLeaderBoard(bslb,bsqu)
	  if(bstyp=="item") then
		if(bstxt==nil) then
		  txt="(bstxt nil)"
		end

		if(bstyp==nil) then
		  type="(bstyp nil)"
		end
		if(bsfin==nil) then
		  fin="(bsfin nil)"
		end
		for bsit,_ in string.gmatch(bstxt,"(.+):(.+)") do
		  sml_dprint(db.Debug,"BestSeller","QUEST ITEM >> "..bsitem.." <<"..bsit.." "..bstyp)
		  if(bsitem==bsit) then
			sml_dprint(db.Debug,"BestSeller","QUEST ITEM >> "..bsitem.." <<"..bsit.." << A MATCH!")
			return 1
		  end
		end
	  end
	end
  end
  return 0
end
function bsMakeShiny()

end
function bsSellOneItem(name)

end
function bsRemoveSellItem(itemName)
  if(db.AutoSell["Items"][itemName]~=nil) then
	sml_print("BestSeller","Removed ["..itemName.."] from sell list")
	db.AutoSell["Items"][itemName]=nil
  end
end
function bsAddSellItem(inlink)
  if(inlink~=nil) then
	local itemName, itemLink, itemRarity, itemLevelReq, itemType, itemSubType, itemStackCount = GetItemInfo(inlink)
	if(itemRarity>0) then
	  if(db.AutoSell["Items"][itemName]==1) then
	  else
		sml_print("BestSeller","Added ["..itemName.."] to sell list")
		db.AutoSell["Items"][itemName] = 1
	  end
	end
  end
end
function bsRemoveExcludeItem(itemName)
  if(db.AutoSell["Exclude"][itemName]~=nil) then
	sml_print("BestSeller","Removed ["..itemName.."] from sell EXCLUDE list")
	db.AutoSell["Exclude"][itemName]=nil
  end
end
function bsAddExcludeItem(inlink)
  if(inlink~=nil) then
	local itemName, itemLink, itemRarity, itemLevelReq, itemType, itemSubType, itemStackCount = GetItemInfo(inlink)
	sml_dprint(db.Debug,"BestSeller","ITEM EXCLUDE: "..itemName)
	if(db.AutoSell["Exclude"][itemName]==1) then
	else
	  sml_print("BestSeller","Added ["..itemName.."] to EXCLUDE list")
	  db.AutoSell["Exclude"][itemName] = 1
	end
  end
end
function bsASLCreateButtons()
  local createFrame = CreateFrame
  local parent      = BSASLFrame
  local button      = createFrame("Button", "BSASLSF_ItemButton1", parent,  "BSASLSFButtonTemplate")
  button:SetID(1)
  button:SetPoint("TOPLEFT","BSASLFrame","TOPLEFT",36,-75)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  for index = 2, 23 do
	button = createFrame( "Button", "BSASLSF_ItemButton"..index, parent, "BSASLSFButtonTemplate")
	button:SetID(index)
	button:SetPoint( "TOPLEFT", "BSASLSF_ItemButton"..(index-1), "BOTTOMLEFT", 0, 1)
	button:RegisterForClicks( "LeftButtonUp", "RightButtonUp")
  end
end
function bsASLPopulate()
  for index = 1,23 do
	getglobal("BSASLSF_ItemButton"..index):Hide()
  end
  sml_dprint(db.Debug,"BestSeller","ASL Pop")
  BSASLSF.RealResultsSize=bsASLGetNumItems()
  BSASLFrameTitleText:SetText("Auto Sell List "..BSASLSF.RealResultsSize.." items")
  FauxScrollFrame_Update(BSASLSF,BSASLSF.RealResultsSize-1,22,16)
  sml_dprint(db.Debug,"BestSeller","BSASLSF.RealResultsSize ["..BSASLSF.RealResultsSize.."]")
  local offset = BSASLSF.offset
  sml_dprint(db.Debug,"BestSeller","BSASLSF.offset="..offset)
  local index=1
  local grof=0
  for bsaslitem,astable in pairs (db.AutoSell["Items"]) do
	if(grof<offset) then
	  grof=grof+1
	else
	  sml_dprint(db.Debug,"BestSeller","BSASLSF_ItemButton"..index.." RESULT :"..bsaslitem)
	  local zbutton=getglobal("BSASLSF_ItemButton"..index)
	  if(zbutton~=nil) then
		zwhat=getglobal("BSASLSF_ItemButton"..index.."_Text")
		zwhat:SetText(bsaslitem)
		zbutton:SetScript("OnClick", (function(self) bsASLButtonPressed(bsaslitem); end))
		index=index+1
		zbutton:Show()
	  else
		sml_dprint(db.Debug,"BestSeller","ERROR: zbutton==nil BestSellerAutoSell.lua 443")
	  end
	end
  end
end
function bsASLGetNumItems()
  if(db.AutoSell==nil) then
	db.AutoSell={}
  end
  if(db.AutoSell["Items"]==nil) then
	db.AutoSell["Items"]={}
  end
  local numitems = 0
  for item,_ in pairs (db.AutoSell["Items"]) do
	numitems=numitems+1
  end
  return numitems
end
function bsASLButtonPressed(index)
  sml_dprint(db.Debug,"BestSeller","Auto Sell List "..index)
  bsRemoveSellItem(index)
  bsASLPopulate()
end
function bsASLEditBoxAdd()
  if(BSASLFrameAddItemBox:GetText()~="") then
	db.AutoSell["Items"][BSASLFrameAddItemBox:GetText()] = 1
	sml_print("BestSeller","Added "..BSASLFrameAddItemBox:GetText().." to auto sell list")
	bsASLPopulate()
	BSASLFrameAddItemBox:SetText("")
	BSASLFrameAddItemBox:ClearFocus()
  end
end
function bsEXLCreateButtons()
  local createFrame = CreateFrame
  local parent      = BSEXLFrame
  local button      = createFrame("Button", "BSEXLSF_ItemButton1", parent,  "BSASLSFButtonTemplate")
  button:SetID(1)
  button:SetPoint("TOPLEFT","BSEXLFrame","TOPLEFT",36,-75)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  for index = 2, 23 do
	button = createFrame( "Button", "BSEXLSF_ItemButton"..index, parent, "BSASLSFButtonTemplate")
	button:SetID(index)
	button:SetPoint( "TOPLEFT", "BSEXLSF_ItemButton"..(index-1), "BOTTOMLEFT", 0, 1)
	button:RegisterForClicks( "LeftButtonUp", "RightButtonUp")
  end
end
function bsEXLPopulate()
  for index = 1,23 do
	local what=getglobal("BSEXLSF_ItemButton"..index)
	if (what) then
	  what:Hide()
	end
  end
  sml_dprint(db.Debug,"BestSeller","EXL Pop")
  BSEXLSF.RealResultsSize=bsEXLGetNumItems()
  BSEXLFrameTitleText:SetText("Auto Sell Exclude List "..BSEXLSF.RealResultsSize.." items")
  FauxScrollFrame_Update(BSEXLSF,BSEXLSF.RealResultsSize-1,22,16)
  sml_dprint(db.Debug,"BestSeller","BSEXLSF.RealResultsSize ["..BSEXLSF.RealResultsSize.."]")
  local offset = BSEXLSF.offset
  sml_dprint(db.Debug,"BestSeller","BSEXLSF.offset="..offset)
  local index=1
  local grof=0
  for bsaslitem,astable in pairs (db.AutoSell["Exclude"]) do
	if(grof<offset) then
	  grof=grof+1
	else
	  sml_dprint(db.Debug,"BestSeller","BSEXLSF_ItemButton"..index.." RESULT :"..bsaslitem)
	  local zbutton=getglobal("BSEXLSF_ItemButton"..index)
	  if(zbutton~=nil) then
		zwhat=getglobal("BSEXLSF_ItemButton"..index.."_Text")
		zwhat:SetText(bsaslitem)
		zbutton:SetScript("OnClick", (function(self) bsEXLButtonPressed(bsaslitem); end))
		index=index+1
		zbutton:Show()
	  else
		sml_dprint(db.Debug,"BestSeller","ERROR: zbutton==nil BestSellerAutoSell.lua Line 518")
	  end
	end
  end
end
function bsEXLGetNumItems()
  local numitems=0
  for item,_ in pairs (db.AutoSell["Exclude"]) do
	numitems=numitems+1
  end
  return numitems
end
function bsEXLButtonPressed(index)
  sml_dprint(db.Debug,"BestSeller","Exclude List "..index)
  bsRemoveExcludeItem(index)
  bsEXLPopulate()
end
function bsEXLEditBoxAdd()
  if(BSEXLFrameAddItemBox:GetText()~="") then
	db.AutoSell["Exclude"][BSEXLFrameAddItemBox:GetText()] = 1
	sml_print("BestSeller","Added "..BSEXLFrameAddItemBox:GetText().." to exclude list")
	bsEXLPopulate()
	BSEXLFrameAddItemBox:SetText("")
	BSEXLFrameAddItemBox:ClearFocus()
  end
end
