-- Best Seller Command Line Input Handler

function bsCommandHandler(self,msg)
    
    narg,numarg=bsNargify(msg);
    sml_dprint("msg=["..msg.."]");
    sml_dprint("Number of args: "..tostring(narg));
    if(narg[0] == "testmoney" ) then
        sml_print(format("I have %d gold %d silver %d copper.",
        bsGetGold(),
        bsGetSilver(),
        bsGetCopper() ) );
    end
    if(narg[0] == nil) or
        (narg[0] == "show" ) then
        BSAMFrame:Show();
    end
    if(narg[0] == "hide" ) then
        BSAMFrame:Hide();
    end
    if(narg[0] == "minishow" ) then
        sml_inform("Showing mini map button.");
        BSMMButton:Show();
    end
    if(narg[0] == "minihide" ) then
        
        sml_inform("Hiding mini map button.");
        BSMMButton:Hide();
    end
    if(narg[0] == "minireset" ) then
        db.MMX=-80;
        db.MMY=-160;
        BSMMButton:SetPoint("TOPLEFT", db.MMX, db.MMY); --  SetPoint("CENTER", "UIParent", "CENTER",
    end
    if(narg[0] == "help" ) ------ Print Help
        or ( msg == "?" ) then
        bsShowHelp(); return;
    end
    if (narg[0] == "hoverframeinfo") or (msg=="hfi") then -- Display frame information
        local curframe=GetMouseFocus():GetName();
        sml_inform(curframe);
    end
    if(narg[0] == "who") then
        SendWho('80');
        SortWho('Guild');
        numWhos, totalCount = GetNumWhoResults();
        sml_dprint(numWhos.." "..totalCount);
    end
    if(narg[0] == "ssz") then
        local az=MinimapZoneTextButton:GetName();
        sml_dprint(az);
    end
    if(narg[0] == "debug" ) then ------ Toggle Debug Messages
        bsToggle_Debug();
    end
    if(narg[0] == "debugallevents" ) then ------ Toggle All Debug EVENT Messages
        bsToggle_DebugShowAllEvents();
    end
    if(narg[0] == "rs" ) then ------ Restack inventory items
        bsRestack(); return;
    end
    
    if(narg[0] == "abl") then
        sml_inform("Auto buy list:");
        sml_inform("=====================================================");
        bsABList();
    end
    
    if(narg[0] == "ict") then
        
        bsCompareItem(GetInventoryItemLink("player", "HeadSlot"));
        
    end
    
    if(narg[0] == "hardexlist") then
        bsTable("BS_DO_NOT_SELL");
        
    end
    
    if(narg[0] == "aslist") or
        (narg[0] == "asl") then ------ List AutoSell Items
        --[[ asi=1;
        for asname,astable in pairs(db.AutoSell["Items"]) do
            sml_print("["..asi.."] "..asname);
            asi=asi+1;
        end
        ]]--
        bsASLPopulate();
        BSASLFrame:Show();
    end
    if(narg[0] == "asexlist") then ------ List AutoSell Exclude Items
        asi=1;
        sml_print("Auto sell excluded items:");
        for asname,astable in pairs(db.AutoSell["Exclude"]) do
            sml_print("["..asi.."] "..asname);
            asi=asi+1;
        end
    end
    if(narg[0] == "asremove") then ------ Remove AutoSell item from list
        sml_print("Removing item "..narg[1].." from sell list");
        asi=1;
        for asname,astable in pairs(db.AutoSell["Items"]) do
            if(tonumber(asi)==tonumber(narg[1])) then
                sml_print("["..asi.."] "..asname.." removed");
                db.AutoSell["Items"][asname]=nil;
                return;
            end
            asi=asi+1;
        end
    end
    if(narg[0] == "asexremove") then ------ Remove AutoSell Exclude item from list
        sml_print("Removing item "..narg[1].." from exclude list");
        -- db.AutoSell["Exclude"][asname]=nil;
        asi=1;
        for asname,astable in pairs(db.AutoSell["Exclude"]) do
            if(tonumber(asi)==tonumber(narg[1])) then
                sml_print("["..asi.."] "..asname.." removed");
                db.AutoSell["Exclude"][asname]=nil;
                return;
            end
            asi=asi+1;
        end
    end
    if(narg[0] == "asadd") then
        
    end
    if(narg[0] == "asexadd") then
        
        for what in string.gmatch(msg, "asexadd (.+)") do
            if(what~=nil) then
                sml_dprint("what=["..what.."]");
            end
        end
        db.AutoSell["Exclude"][narg[1]]=true;
        
        
    end
    if(narg[0] == "aspop") then ------ Manually Populate AutoSell List Frame
        bsASLPopulate();
    end
    
end
