-- Best Seller Command Line Input Handler
function bsCommandHandler(self,msg)
  narg,numarg=bsNargify(msg)
  sml_dprint(db.Debug,"BestSeller","msg=["..msg.."]")
  sml_dprint(db.Debug,"BestSeller","Number of args: "..tostring(narg))
  if(narg[0] == "testmoney" ) then
	sml_print("BestSeller",format("I have %d gold %d silver %d copper.", bsGetGold(), bsGetSilver(), bsGetCopper() ) )
  end
  if(narg[0] == nil) or
	(narg[0] == "show" ) then
	BSAMFrame:Show()
  end
  if(narg[0] == "hide" ) then
	BSAMFrame:Hide()
  end
  if(narg[0] == "minishow" ) then
	sml_print("BestSeller","Showing mini map button.")
	BSMMButton:Show()
  end
  if(narg[0] == "minihide" ) then

	sml_print("BestSeller","Hiding mini map button.")
	BSMMButton:Hide()
  end
  if(narg[0] == "minireset" ) then
	db.MMX=-80
	db.MMY=-160
	BSMMButton:SetPoint("TOPLEFT", db.MMX, db.MMY)
  end
  if(narg[0] == "help" )
	or ( msg == "?" ) then
	bsShowHelp()
	return
  end
  if (narg[0] == "hoverframeinfo") or (msg=="hfi") then
	local curframe=GetMouseFocus():GetName()
	sml_print("BestSeller",curframe)
  end
  if(narg[0] == "who") then
	SendWho('80')
	SortWho('Guild')
	numWhos, totalCount = GetNumWhoResults()
	sml_dprint(db.Debug,"BestSeller",numWhos.." "..totalCount)
  end
  if(narg[0] == "ssz") then
	local az=MinimapZoneTextButton:GetName()
	sml_dprint(db.Debug,"BestSeller",az)
  end
  if(narg[0] == "debug" ) then
	bsToggle_Debug()
  end
  if(narg[0] == "debugallevents" ) then
	bsToggle_DebugShowAllEvents()
  end
  if(narg[0] == "rs" ) then
	bsRestack()
	return
  end

  if(narg[0] == "abl") then
	sml_print("BestSeller","Auto buy list:")
	sml_print("BestSeller","=====================================================")
	bsABList()
  end
  if(narg[0] == "ict") then
	bsCompareItem(GetInventoryItemLink("player", "HeadSlot"))
  end
  if(narg[0] == "hardexlist") then
	bsTable("BS_DO_NOT_SELL")
  end

  if(narg[0] == "aslist") or
	(narg[0] == "asl") then
	bsASLPopulate()
	BSASLFrame:Show()
  end
  if(narg[0] == "asexlist") then
	asi=1
	sml_print("BestSeller","Auto sell excluded items:")
	for asname,astable in pairs(db.AutoSell["Exclude"]) do
	  sml_print("["..asi.."] "..asname)
	  asi=asi+1
	end
  end
  if(narg[0] == "asremove") then
	sml_print("BestSeller","Removing item "..narg[1].." from sell list")
	asi=1
	for asname,astable in pairs(db.AutoSell["Items"]) do
	  if(tonumber(asi)==tonumber(narg[1])) then
		sml_print("["..asi.."] "..asname.." removed")
		db.AutoSell["Items"][asname]=nil
		return
	  end
	  asi=asi+1
	end
  end
  if(narg[0] == "asexremove") then
	sml_print("BestSeller","Removing item "..narg[1].." from exclude list")
	asi=1
	for asname,astable in pairs(db.AutoSell["Exclude"]) do
	  if(tonumber(asi)==tonumber(narg[1])) then
		sml_print("["..asi.."] "..asname.." removed")
		db.AutoSell["Exclude"][asname]=nil
		return
	  end
	  asi=asi+1
	end
  end
  if(narg[0] == "asadd") then
  end
  if(narg[0] == "asexadd") then
	for what in string.gmatch(msg, "asexadd (.+)") do
	  if(what~=nil) then
		sml_dprint(db.Debug,"BestSeller","what=["..what.."]")
	  end
	end
	db.AutoSell["Exclude"][narg[1]]=true
  end
  if(narg[0] == "aspop") then
	bsASLPopulate()
  end
end
