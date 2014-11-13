-- Best Seller Event Handler
bsRecentAutoSold={}
function bsRegisterEvent(event)
  if( event ~= nil ) then
	BSFrame:RegisterEvent(event)
  end
end
lastitembuyback=0
function bsOnEvent(self, event, ...)
  bsSetDebugWindow()
  local arg1, arg2 = ...
  local nnames, nnum
  narg=sml_nargify(arg1)
  if (db) then
    if (db.DebugAllEvents) then
      sml_dprint(db.Debug,"BestSeller"," BEST SELLER EVENT ["..event.."]")
    end
  end
  if (event == "VARIABLES_LOADED") then
	if( not BestSellerDatabase ) then
	  BestSellerDatabase={}
	end
	if( not BestSellerDatabase[GetRealmName()] ) then
	  BestSellerDatabase[GetRealmName()]={}
	end
	if( not BestSellerDatabase[GetRealmName()][UnitName("player")] ) then
	  BestSellerDatabase[GetRealmName()][UnitName("player")]={}
	end
 	db = BestSellerDatabase[GetRealmName()][UnitName("player")]
	if(db) then  --- set up default values
	  if(db.BestSellerDebug==nil) then
		db.BestSellerDebug = 0
	  end
      db["Version"]	  = BestSeller_Version
      db["Name"]	  = UnitName("player")
      db["Server"]	  = GetRealmName()
      db["Locale"]	  = GetLocale()
      db["Race"],
      db["RaceEn"]    =UnitRace("player")
      db["Class"],
      db["ClassEn"]   =UnitClass("player")
      db["FactionEn"],
      db["Faction"]   =UnitFactionGroup("player")
      if(db.Enabled==nil)                 then db.Enabled = 1 end
      if(db.AutoRepair==nil)              then db.AutoRepair = 0 end
      if(db.GuildFundedRepair==nil)       then db.GuildFundedRepair = 0 end
      if(db.AutoSell==nil)                then db.AutoSell = {} end
      if(db.AutoSell["Active"]==nil)      then db.AutoSell["Active"]=0 end
      if(db.AutoSell["Safe"]==nil)        then db.AutoSell["Safe"]=0 end
      if(db.AutoSell["GreyOnly"]==nil)    then db.AutoSell["GreyOnly"]=0 end
      if(db.AutoSell["Remember"]==nil)    then db.AutoSell["Remember"]=0 end
      if(db.AutoSell["Soulbound"]==nil)   then db.AutoSell["Soulbound"] = 0 end
      if(db.AutoSell["LowFoods"]==nil)    then db.AutoSell["LowFoods"] = 0 end
      if(db.AutoSell["Items"]==nil)       then db.AutoSell["Items"] = {} end
      if(db.AutoSell["Exclude"]==nil)     then db.AutoSell["Exclude"] = {} end
      if(db.AutoBuy==nil)                 then db.AutoBuy = {} end
      if(db.AutoBuy["Active"]==nil)       then db.AutoBuy["Active"]=0 end
      if(db.Count==nil)                   then db.Count = {} end
	  if(db.HideMinimapIcon==nil)		  then db.HideMinimapIcon = {} end
	  if(db.HideMinimapIcon["Hide"]==nil) then db.HideMinimapIcon["Hide"]=0 end
    end
    rpxpmsg=1
    rpxpsession=0
    sml_print("BestSeller",bsVersion.." by Smashed (Bladefist - Alliance) loaded. For help type "..YFCC.."/bs help")
    BSAMFramePanel1CheckAutoSell:SetChecked(db.AutoSell["Active"])
    BSAMFramePanel1CheckSafe:SetChecked(db.AutoSell["Safe"])
    BSAMFramePanel1CheckGreyOnly:SetChecked(db.AutoSell["GreyOnly"])
    BSAMFramePanel1CheckMem:SetChecked(db.AutoSell["Remember"])
    BSAMFramePanel1CheckAddMem:SetChecked(db.AutoSell["AddASL"])
    BSAMFramePanel1CheckDetail:SetChecked(db.AutoSell["Detail"])
    BSAMFramePanel1CheckLowFoods:SetChecked(db.AutoSell["LowFoods"])
	BSMMButton:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", (db.MMX or 512), (db.MMY or 384))
	BSAMFramePanel1CheckHideMinimapIcon:SetChecked(db.HideMinimapIcon["Hide"])
	if(db.HideMinimapIcon["Hide"]==1) then BSMMButton:Hide() end
    BSAMFramePanel1CheckSoulbound:SetChecked(db.AutoSell["Soulbound"])
    if(db.AutoSell["SoulboundQuality"]==nil) then db.AutoSell["SoulboundQuality"]=0 end
    if(db.AutoSell["SoulboundQuality"]~=nil) then
      UIDropDownMenu_SetSelectedValue(BSAMFramePanel1ComboBox1,db.AutoSell["SoulboundQuality"])
      BSAMFramePanel1ComboBox1Text:SetText(smldb.ITEM_QUALITY[db.AutoSell["SoulboundQuality"]])
    end
    if(db.AutoSell["SoulboundLow"]==nil) then db.AutoSell["SoulboundLow"]=2 end
    BSAMFramePanel1SoulboundLow:SetText(db.AutoSell["SoulboundLow"])
    if(db.AutoSell["SoulboundHigh"]==nil) then db.AutoSell["SoulboundHigh"]=74 end
    BSAMFramePanel1SoulboundHigh:SetText(db.AutoSell["SoulboundHigh"])
    BSAMFramePanel1CheckSellBOPAutoDungeon:SetChecked(db.AutoSell["BOPDungeon"])
    BSAMFramePanel1CheckQuestHigh:SetChecked(db.QuestHigh)
    BSAMFramePanel1CheckQuestComplete:SetChecked(db.QuestComplete)
    BSAMFramePanel1CheckQuestLevelCheck:SetChecked(db.QuestCheckiLevel)
    BSAMFramePanel2CheckAutoBuy:SetChecked(db.AutoBuy["Active"])
    BSAMFramePanel3CheckAutoRepair:SetChecked(db.AutoRepair)
    BSAMFramePanel3CheckGuildFundedRepair:SetChecked(db.GuildFundedRepair)
    BSAMFramePanel3CheckReputationCheck:SetChecked(db.ReputationRepair)
    if(db.RepairReputation~=nil) then
      UIDropDownMenu_SetSelectedValue(BSAMFramePanel3ComboReputation,db.RepairReputation)
      BSAMFramePanel3ComboReputationText:SetText(smldb.FACTION_STANDING[db.RepairReputation])
    end
    db.bsChatFrame=DEFAULT_CHAT_FRAME
    bsASLCreateButtons()
    bsEXLCreateButtons()
    bsABLCreateButtons()
  end
  --[UPDATE_CHAT_WINDOWS]---------------------------------------------------
  if ( event == "UPDATE_CHAT_WINDOWS" ) then

  end
  --[PLAYER_LOGOUT]---------------------------------------------------------
  if ( event == "PLAYER_LOGOUT" ) then
    db.AutoSell["BOE"]=nil
    db.AutoSell["BOEQuality"]=nil
    db.AutoSell["BOELow"]=nil
    db.AutoSell["BOEHigh"]=nil
    db.bsChatFrame = nil
    db.WTF=nil
    db.MMX, db.MMY = BSMMButton:GetCenter()
  end
  --[UPDATE_CHAT_WINDOWS]---------------------------------------------------
  if ( event == "CHAT_MSG_LOOT" ) then
    local nnames
    for dditem,ddnum in string.gmatch(arg1,"You receive loot: (\[.+\])(%d)") do
      if ( dditem == nil ) then dditem="(error)" end
      if ( ddnum == nil ) then ddnum=1 end
      sml_dprint(db.Debug,"BestSeller",arg1.." TURNS INTO:")
      sml_dprint(db.Debug,"BestSeller",dditem..","..ddnum)
      nnum=ddnum
      nnames=GetItemInfo(dditem)
    end
    if ( nnames ~= nil ) then
      ncount=GetItemCount( nnames )+nnum
      if(ncount>0) then
		sml_print("BestSeller","COUNTING "..nnames..":"..ncount)
      end
    end
  end
  if ( event == "UNIT_INVENTORY_CHANGED" ) then
  end
  if ( event == "QUEST_DETAIL" ) then
    if( db.QuestAccept == 1 ) then
      AcceptQuest()
    end
  end
  if ( event == "QUEST_PROGRESS" ) then
	--[[ if(db.QuestComplete==1) then
		local complete_button= _G["QuestFrameCompleteQuestButton"]
			if(complete_button) then
				complete_button:Click()
            --CompleteQuest()
            end
        end
	]]--
  end
  if (event=="QUEST_COMPLETE") then
	local high, high_index = 0, 0
	local getlink=nil
	local equippedhigher=0
	local ilvl=0
	local islot=0
	local price=0
	local equippedlink=nil
	local equippedilvl=0
	local thelink=nil
    if(db.QuestHigh==1) then
      sml_print("BestSeller","Number of quest rewards:"..GetNumQuestChoices())
	  for x=1,GetNumQuestChoices() do
        thelink=GetQuestItemLink("choice",x)
        if(thelink) then
          price = select(11, GetItemInfo(thelink))
		  ilvl  = select(4, GetItemInfo(thelink))
		  islot = select(9, GetItemInfo(thelink))
		  equippedlink = GetInventoryItemLink("player", islot)
		  equippedilvl = 0
		  if(equippedlink) then
			equippedilvl = select( 4, GetItemInfo(equippedlink))
		  end
		  if(ilvl > equippedilvl) then
			equippedhigher=1
		  end
          if price > high then
			high, high_index = price, x
			getlink = thelink
          end
        end
	  end
	  local button = _G["QuestInfoItem"..high_index]
      if button then
		sml_print("BestSeller","Auto selected "..getlink.." as highest vendor value quest reward.")
		button:Click()
	  end
	  if(db.QuestComplete==1) then
		if(equippedhigher==0) then
		  local complete_button= _G["QuestFrameCompleteQuestButton"]
		  if(complete_button) then
			complete_button:Click()
		  end
		  sml_print("BestSeller","Completed quest automatically based on your settings.")
		else
		  sml_print("BestSeller","Quest not completed automatically because there is a higher level item available as quest reward.")
		end
	  end
	end
  end
  if (event == "MERCHANT_SHOW") then
	local whatfact=bsTargetFaction()
	if(whatfact==nil) then whatfact=0; end
	if(db.ReputationRepair==nil) then db.ReputationRepair=0; end
	local dorepair=1
	bMerchantOpen=1
	bAutoSellActive=1
	bsAutoSell()
	bAutoSellActive=0
	if(CanMerchantRepair()) then
	  if(db.AutoRepair==1) then
		if(db.ReputationRepair==1) then
		  if(db.RepairReputation>whatfact) then
			dorepair=0
			sml_print("BestSeller",YFCC.."Your reputation with the merchant's faction: "..smldb.FACTION_STANDING[whatfact]..RFCC.." (AUTOREPAIR NO)")
		  else
			sml_print("BestSeller",YFCC.."Your reputation with the merchant's faction: "..smldb.FACTION_STANDING[whatfact]..GFCC.." (AUTOREPAIR YES)")
		  end
		end
		if(dorepair==1) then
		  local repairAllCost, canRepair = GetRepairAllCost()
		  if(repairAllCost==nil) then
			repairAllCost=0
		  end
		  if(repairAllCost>0) then
			if(db.GuildFundedRepair~=1) then
			  db.GuildFundedRepair=0
			end
			RepairAllItems(db.GuildFundedRepair)
			if(db.GuildFundedRepair==1) then
			  sml_print("BestSeller","All items repaired using guild funds. Total cost "..GetCoinText(repairAllCost))
			else
			  sml_print("BestSeller","All items repaired using personal funds. Total cost "..GetCoinText(repairAllCost))
			end
		  end
		end
	  end
	end
	bsAutoBuy()
  end
  if (event == "MERCHANT_CLOSED") then
	bMerchantOpen=0
	bsRecentAutoSold=nil
	bsRecentAutoSold={}
  end
  if (event == "MERCHANT_UPDATE") then
	local numitms=GetNumBuybackItems()
	sml_dprint(db.Debug,"BestSeller","Num Buyback Items:"..numitms)
	local sitem=GetBuybackItemLink(GetNumBuybackItems())
	if(bAutoSellActive==0) then
	  local curframe
	  if(GetMouseFocus():GetName()~=nil)
		then curframe=GetMouseFocus():GetName()
		if(curframe~=nil) then
		  sml_dprint(db.Debug,"BestSeller","curframe:"..curframe)
		end
	  end
	  if(curframe==nil)
		then curframe=""
	  end
	  if(string.find(curframe,"Merchant")) then
		if (iLastItemSold~=nil) then
		  sml_dprint(db.Debug,"BestSeller",">>> NOT SELLING, BUYING BACK >>> "..GetItemInfo(iLastItemSold))
		end
		if(iLastItemSold~=nil) then
		  bsRemoveSellItem(GetItemInfo(iLastItemSold))
		end
	  else
		if(sitem~=nil) then
		  if(bsWasAutoSold(GetItemInfo(sitem))==1) then
			sml_dprint(db.Debug,"BestSeller",sitem.." was auto sold, not adding to list")
		  else
			if(db.AutoSell["AddASL"]==1) then
			  bsAddSellItem(sitem)
			end
		  end
		end
	  end
	end
  end
  iLastItemSold=GetBuybackItemLink(GetNumBuybackItems())
end
