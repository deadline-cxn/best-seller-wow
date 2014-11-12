function bsAutoBuy()
    if(db.AutoBuy["Active"]~=1) then
        return
    end
    local itemName,itemLink,itemRarity,itemLevelReq,itemMinLevel,itemType,itemSubType,itemStackCount,itemEquipLoc,itemTexture,itemSellPrice
    local numItems = GetMerchantNumItems()
    sml_dprint("Merchant has "..numItems.." items")
    local name, tx, price, qty, num, usable, extcost
    for i = 1, numItems do
        name, tx, price, qty, num, usable, extcost = GetMerchantItemInfo(i)
        if (name==nil) then
            name= "name error!"
        end
        if (tx==nil) then
            tx="tx error!"
        end
        if (price==nil) then
            price="price error!"
        end
        if (qty==nil) then
            qty="qty error!"
        end
        if (num==nil) then
            num="num error!"
        end
        if (usable==nil) then
            usable="usable error!"
        end
        if (extcost==nil) then
            extcost="extcost error!"
        end
        sml_dprint( "Merchant slot ["..i.."] ".."name:"..name..",".."price:"..price..",".."qty:"..qty..",".."num:"..num..",".."usable:"..usable..",".."extcost:"..extcost )
        local mil=GetMerchantItemLink(i)
        if(mil==nil) then
            mil=""
        end
        itemName,itemLink,itemRarity,itemLevelReq,itemMinLevel,itemType,itemSubType,itemStackCount,itemEquipLoc,itemTexture,itemSellPrice=GetItemInfo(mil)
        if(itemStackCount==nil) then
            itemStackCount=1
        end
        if(itemName==nil) then
            itemName="(nameerror)"
        end
        sml_dprint(itemName.." stacks["..itemStackCount.."]")
        for item,buyamount in pairs (db.AutoBuy["Items"]) do
            local wildcard=""
            local wild=0
            for wc,_ in string.gmatch(item,"(.+)*") do
                wildcard=wc
            end
            if(wildcard~="") then
                if string.find(name,wildcard) then
                    wild=1
                end
            end
            if (name == item) or wild==1 then
                sml_dprint(" WE HAVE MATCH!   >"..item.."> BUY! : WILDCARD: "..wildcard)
                local ba=buyamount
                local iz=itemStackCount
                local ms=num
                local mq=qty
                local ia=GetItemCount(item)
                local ab=0
                sml_dprint(   "buyamount["..ba.."] ".."itemstacksize["..iz.."] ".."merchantstackamt["..ms.."] ".."merchantquantity["..mq.."] ".."amountowned["..ia.."] ".."amounttobuy["..ab.."] ")
                ab=ba-ia
                sml_dprint(" AMOUNT TO BUY: "..ab)
                if( ab > 0) then
                    sml_inform(OFCC.." 'Best Buy' purchasing "..WFCC..name..OFCC.." x"..WFCC..ab..OFCC.." because it is in your Autobuy list")
                    if(ab>iz) then
                        local wtfz=ab
                        while wtfz > iz do
                            sml_dprint(" A: Buying: "..iz)
                            BuyMerchantItem(i,iz)
                            wtfz=wtfz-iz
                        end
                        sml_dprint(" B: Buying: "..wtfz)
                        BuyMerchantItem(i,wtfz)
                    else
                        sml_dprint(" C: Buying: "..ab)
                        BuyMerchantItem(i, ab)
                    end
                end
            end
        end
    end
end

function bsABList()
    if(db.AutoBuy["Items"]==nil) then
        db.AutoBuy["Items"]= {}
    end
    for item,buyamount in pairs (db.AutoBuy["Items"]) do
        sml_inform("Auto Buy: "..item.. " ("..buyamount..")")
    end
end
function bsABAdd(name,quantity)
    db.AutoBuy["Items"][name]=quantity
end
function bsABRemove(name)
    sml_dprint("REMOVED "..name)
    db.AutoBuy["Items"][name]=nil
end

function bsABLCreateButtons()
    local createFrame = CreateFrame
    local parent      = BSABLFrame
    local button      = createFrame("Button", "BSABLSF_ItemButton1", parent,  "BSABLSFButtonTemplate")
    button:SetID(1)
    button:SetPoint("TOPLEFT","BSABLFrame","TOPLEFT",36,-75)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    for index = 2, 23 do
        button = createFrame( "Button", "BSABLSF_ItemButton"..index, parent, "BSABLSFButtonTemplate")
        button:SetID(index)
        button:SetPoint( "TOPLEFT", "BSABLSF_ItemButton"..(index-1), "BOTTOMLEFT", 0, 1)
        button:RegisterForClicks( "LeftButtonUp", "RightButtonUp")
    end
end

function bsABLPopulate()
    for index = 1,23 do
        local what=getglobal("BSABLSF_ItemButton"..index)
        if (what) then
            what:Hide()
        end
    end
    sml_dprint("ABL Pop")
    BSABLSF.RealResultsSize=bsABLGetNumItems()
    BSABLFrameTitleText:SetText("Auto Buy List "..BSABLSF.RealResultsSize.." items")
    FauxScrollFrame_Update(BSABLSF,BSABLSF.RealResultsSize-1,22,16)
    sml_dprint("BSABLSF.RealResultsSize ["..BSABLSF.RealResultsSize.."]")
    local offset = BSABLSF.offset
    sml_dprint("BSABLSF.offset="..offset)
    local index=1
    local grof=0
    if(db.AutoBuy["Items"]~=nil) then
        for bsaslitem,astable in pairs (db.AutoBuy["Items"]) do
            if(grof<offset) then
                grof=grof+1
            else
                local zbutton=getglobal("BSABLSF_ItemButton"..index)
                if(zbutton~=nil) then
                    zwhat=getglobal("BSABLSF_ItemButton"..index.."_Text")
                    zwhat:SetText(bsaslitem)
                    zwho =getglobal("BSABLSF_ItemButton"..index.."_AmountText")
                    zwho:SetText(astable)
                    zbutton:SetScript("OnClick", (function(self) bsABLButtonPressed(bsaslitem); end))
                    index=index+1
                    zbutton:Show()
                else
                    sml_dprint("ERROR: zbutton==nil BestSelleraAutoBuy.lua Line 150")
                end

            end
        end
    end
end

function bsABLGetNumItems()
    local numitems=0;
    if(db.AutoBuy["Items"]~=nil) then
        for item,_ in pairs (db.AutoBuy["Items"]) do
            numitems=numitems+1
        end
    end
    return numitems
end

function bsABLButtonPressed(index)
    sml_dprint("Autobuy List "..index)
    BSABLFrameAddItemBox:SetText(index)
    BSABLFrameAddItemAmountBox:SetText("1")
    bsABRemove(index)
    bsABLPopulate()
end

function bsABLAddFromFrame()
    if(BSABLFrameAddItemBox:GetText()~="") then
        if(db.AutoBuy["Items"]==nil) then
            db.AutoBuy["Items"]={}
        end
        db.AutoBuy["Items"][BSABLFrameAddItemBox:GetText()] = BSABLFrameAddItemAmountBox:GetText()
        sml_print("Added "..BSABLFrameAddItemBox:GetText().." x "..BSABLFrameAddItemAmountBox:GetText().." to auto buy list")
        bsABLPopulate()
        BSABLFrameAddItemBox:SetText("")
        BSABLFrameAddItemBox:ClearFocus()
    end
end

