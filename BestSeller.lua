--[[    Filename: BestSeller.lua

        Author  : Smashed - Bladefist
]]--
-- Set up some global stuff

bsVersion = "v"..GetAddOnMetadata("BestSeller", "Version");

bAutoSellActive=0;
bMerchantOpen=0;
iLastItemSold=0;

RFCC="|cffff2020";
JFCC="|cfff0f090";
PFCC="|cffff20ff";
WFCC="|cffffffff";
NFCC="|cffffd200";
DFCC="|cff888888";
GFCC="|cff00ff00";
BFCC="|cff0000ff";
YFCC="|cffffff00";
OFCC="|cffff9900";

ITEM_QUALITY = {};
ITEM_QUALITY[0] = "|cff9d9d9dPoor";
ITEM_QUALITY[1] = "|cffffffffCommon";
ITEM_QUALITY[2] = "|cff1eff00Uncommon";
ITEM_QUALITY[3] = "|cff0070ffRare";
ITEM_QUALITY[4] = "|cffa335eeEpic";
ITEM_QUALITY[5] = "|cffff8000Legendary";
ITEM_QUALITY[6] = "|cffff0000Artifact";
ITEM_QUALITY[7] = "|cfe6cc80Heirloom";

FACTION_STANDING = {};
FACTION_STANDING[0] = "|cffcc0000(can't determine)";
FACTION_STANDING[1] = "|cffcc0000Hated";
FACTION_STANDING[2] = "|cffff0000Hostile";
FACTION_STANDING[3] = "|cfff26000Unfriendly";
FACTION_STANDING[4] = "|cffe4e400Neutral";
FACTION_STANDING[5] = "|cff33ff33Friendly";
FACTION_STANDING[6] = "|cff5fe65dHonored";
FACTION_STANDING[7] = "|cff53e9bcRevered";
FACTION_STANDING[8] = "|cff2ee6e6Exalted";
FACTION_STANDING[9] = "|cffcc0000(can't determine)";

BS_ITEM_SLOT = {};
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

    SLASH_BestSeller1 = "/bestseller";
    SLASH_BestSeller2 = "/bs";
    SlashCmdList["BestSeller"] = function(msg) bsCommandHandler(self,msg); end

    bsRegisterEvent("AUCTION_BIDDER_LIST_UPDATE");
    bsRegisterEvent("AUCTION_HOUSE_CLOSED");
    bsRegisterEvent("AUCTION_HOUSE_DISABLED");
    bsRegisterEvent("AUCTION_HOUSE_SHOW");
    bsRegisterEvent("AUCTION_ITEM_LIST_UPDATE");
    bsRegisterEvent("AUCTION_MULTISELL_FAILURE");
    bsRegisterEvent("AUCTION_MULTISELL_UPDATE");
    bsRegisterEvent("AUCTION_OWNED_LIST_UPDATE");

    bsRegisterEvent("CHAT_MSG_LOOT");

    bsRegisterEvent("MERCHANT_SHOW");
    bsRegisterEvent("MERCHANT_CLOSED");
    bsRegisterEvent("MERCHANT_UPDATE");

    bsRegisterEvent("PLAYER_ENTERING_WORLD");
    bsRegisterEvent("PLAYER_LOGOUT");

    bsRegisterEvent("QUEST_COMPLETE");
    bsRegisterEvent("QUEST_DETAIL");
    bsRegisterEvent("QUEST_PROGRESS");

    bsRegisterEvent("UI_INFO_MESSAGE");
    bsRegisterEvent("UNIT_INVENTORY_CHANGED");
    bsRegisterEvent("UPDATE_CHAT_WINDOWS");

    bsRegisterEvent("VARIABLES_LOADED");

end

function bsNargify(text)
    if(text~=nil) then
        cmd=text;
        for mesg,arg2 in string.gmatch(text, "(.+) (.+)") do text=mesg; arg1=arg2; end
        narg=nil; narg={};
        if(text~=nil) then
            numarg=0;
            for word in string.gmatch(cmd, "%w+") do
                narg[numarg]=strlower(word);
                if(narg[numarg]=="") then narg[numarg]=nil; numarg=numarg-1; end
                numarg=numarg+1;
            end
            return narg,numarg;
        end
    end
end

function bsRound(what, precision)
    return math.floor(what*math.pow(10,precision)+0.5) / math.pow(10,precision)
end

function bsDPrint(a)
    local cf=0;
    if(db) then
        if(db.bsChatFrame==nil) then
            cf=DEFAULT_CHAT_FRAME;
            else
            cf=db.bsChatFrame;
        end

        if(db.BestSellerDebug==1) then
             cf:AddMessage(RFCC.."BSDEBUG>> "..WFCC..a);
        end
    end
end

function bsPrint(a)
    if(a~=nil) then
        DEFAULT_CHAT_FRAME:AddMessage(a);
    end
end

function bsInform(a)
    if(a~=nil) then
        DEFAULT_CHAT_FRAME:AddMessage(RFCC.."BESTSELLER: "..YFCC..a);
    end
end

function bsTell(player,msg)
    bsMsg(player,msg,"WHISPER");
end

function bsMsg(player,msg,where)
    SendChatMessage(msg, where, GetDefaultLanguage("player"), player);
end

function bsGetLink(item)
    if(item==nil) then return nil; end
	for io,iw,ix in string.gmatch(item,"(.+)item:(.+):(.+)") do link="item:"..iw..":0"; end;
	return link;
end

function bsGetEquippedItem(slot)
	bsPrint(slot);
	slotId,what=GetInventorySlotInfo(slot);
	if(slotId~=nil) then return GetInventoryItemLink("player",slotId);
	end
end

function bsSetDebugWindow()
    -- Determine if a BestSeller Chat Frame is open or not and direct debug output there
    for i = 0,10 do
        name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable =GetChatWindowInfo(i);
        if(name~=nil) then
            if(name=="Best Seller") then
                if(db) then
                    db.bsChatFrame=getglobal("ChatFrame"..i);
                end
            end
        end
    end
    if(db) then
        if(db.bsChatFrame==nil) then
            db.bsChatFrame=DEFAULT_CHAT_FRAME;
        end
    end
end

function bsTable(tbl)
    local x=0;
    jjx=tostring(tbl);
    bsPrint("TABLE: "..jjx);
    if( string.find(jjx,"table:")) then
        x=tbl;
    else
        x=getglobal(tbl);
    end
    if(string.find(tostring(x),"table")) then
        for a,b in pairs(x) do
            if(string.find(tostring(b),"table:")) then
                bsTable(b);
            else
                bsPrint("["..tostring(a).."] "..tostring(b));
            end
        end
    else
        bsPrint(tostring(x));
    end
end

function bsTargetFaction()
    local faction,fname = UnitFactionGroup("target");
    if(faction==nil) then faction="?"; end
    if(fname==nil) then fname="?"; end
    bsDPrint("TARGET FACTION CHECK:");
    bsDPrint("Target faction "..faction..","..fname);
    BSTooltip:ClearLines();
    BSTooltip:SetUnit("target");
    --[[   PvP ? HORDE
           PvP ? ALLIANCE      ]]--
    for floi=1, BSTooltip:NumLines(),1 do
        local amtext=getglobal("BSTooltipTextLeft" .. floi);
        bsDPrint(amtext:GetText());
        for factionIndex = 1, GetNumFactions() do
            name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
            canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex);
            if isHeader == nil then
                if(string.find(amtext:GetText(),name)) then
                    bsDPrint("Target Faction: " .. name .. " ("..FACTION_STANDING[standingId]..")");
                    return standingId;
                end
            end
        end
    end
    return 0;
end

function printSubClasses(...)
  for class = 1, select("#", ...) do
    bsDPrint(select(class, ...).. ":", strjoin(", ", GetAuctionItemSubClasses(class)))
  end
end
-- printSubClasses(GetAuctionItemClasses());

function bsCompareItem(xitem)

    local itemName,
          itemLink,
          itemRarity,
          itemiLevel,
          itemMinLevel,
          itemType,
          itemSubType,
          itemStackCount,
          itemEquipLoc,
          itemTexture,
          itemSellPrice=
          GetItemInfo(xitem);

          if(itemName==nil) then itemName="(nameerror)"; end
          if(itemiLevel==nil) then itemiLevel="(ilevelerror)"; end
          if(itemEquipLoc==nil) then itemEquipLoc=0; end

          bsDPrint("COMPARING ITEM: "..itemName..
                    " (ilevel:"..itemiLevel..
                    ") (equipslot:"..
                    --itemEquipLoc);
                    BS_ITEM_SLOT[itemEquipLoc]..")");

    local charitem=GetInventoryItemLink("player", itemEquipLoc);

    local item2Name,
          item2Link,
          item2Rarity,
          item2iLevel,
          item2MinLevel,
          item2Type,
          item2SubType,
          item2StackCount,
          item2EquipLoc,
          item2Texture,
          item2SellPrice=
          GetItemInfo(charitem);

    bsDPrint("The equipped item for that slot is (ilevel:"..item2iLevel..")");

end

---[EOF]
