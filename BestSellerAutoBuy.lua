
function bsAutoBuy()


    if(db.AutoBuy["Active"]~=1) then return; end


local
					itemName,
                    itemLink,
                    itemRarity,
                    itemLevelReq,
                    itemMinLevel,
                    itemType,
                    itemSubType,
                    itemStackCount,
                    itemEquipLoc,
                    itemTexture,
                    itemSellPrice;
    -- bsABList();
    -- local itemName = GetItemInfo(itemLink)	-- becomes nil for uncached items but that's fine, the below check just silently fails

	local numItems = GetMerchantNumItems();

	bsDPrint("Merchant has "..numItems.." items");
	local name, tx, price, qty, num, usable, extcost;

	for i = 1, numItems do

        name, tx, price, qty, num, usable, extcost = GetMerchantItemInfo(i);

        if (name==nil) then name= "name error!"; end
        if (tx==nil) then tx="tx error!"; end
        if (price==nil) then price="price error!"; end
        if (qty==nil) then qty="qty error!"; end
        if (num==nil) then num="num error!"; end
        if (usable==nil) then usable="usable error!"; end
        if (extcost==nil) then extcost="extcost error!"; end

        bsDPrint("Merchant slot ["..i.."] "..
                    "name:"..name..","..
                    --"tx:"..tx..","..
                    "price:"..price..","..
                    "qty:"..qty..","..
                    "num:"..num..","..
                    "usable:"..usable..","..
                    "extcost:"..extcost );

        local mil=GetMerchantItemLink(i);

        if(mil==nil) then mil=""; end

        itemName,
        itemLink,
        itemRarity,
        itemLevelReq,
        itemMinLevel,
        itemType,
        itemSubType,
        itemStackCount,
        itemEquipLoc,
        itemTexture,
        itemSellPrice
        = GetItemInfo(mil);

        if(itemStackCount==nil) then itemStackCount=1; end
        if(itemName==nil) then itemName="(nameerror)"; end

        bsDPrint(itemName.." stacks["..itemStackCount.."]");

        for item,buyamount in pairs (db.AutoBuy["Items"]) do
            local wildcard="";
            local wild=0;
            for wc,_ in string.gmatch(item,"(.+)*") do
                wildcard=wc;
            end
            if(wildcard~="") then
                if string.find(name,wildcard) then
                    wild=1;
                end
            end
            if (name == item) or wild==1 then		-- compares names

                bsDPrint(" WE HAVE MATCH!   >"..item.."> BUY! : WILDCARD: "..wildcard);

                -- determine amount to buy
                -- BUY LIST                 ba

                -- ITEM STACK SIZE          iz
                -- MERCHANT STACK AMOUT     ms
                -- MERCHANT QUANTITY        mq
                -- AMOUNT IN INVENTORY      ia
                -- AMOUNT TO BUY            ab

                local ba=buyamount;
                local iz=itemStackCount;
                local ms=num;
                local mq=qty;
                local ia=GetItemCount(item);
                local ab=0;

                bsDPrint(   "buyamount["..ba.."] "..
                            "itemstacksize["..iz.."] "..
                            "merchantstackamt["..ms.."] "..
                            "merchantquantity["..mq.."] "..
                            "amountowned["..ia.."] "..
                            "amounttobuy["..ab.."] ");

                -- ba 5
                -- iz 20
                -- ms -1
                -- mq 5
                -- ia 1
                -- ab 0

                ab=ba-ia;

                bsDPrint(" AMOUNT TO BUY: "..ab);

                if( ab > 0) then
                    bsInform(OFCC.." 'Best Buy' purchasing "..WFCC..name..OFCC.." x"..WFCC..ab..OFCC.." because it is in your Autobuy list");
                    if(ab>iz) then
                        local wtfz=ab;
                        while wtfz > iz do
                            bsDPrint(" A: Buying: "..iz);
                            BuyMerchantItem(i,iz);
                            wtfz=wtfz-iz;
                        end
                        bsDPrint(" B: Buying: "..wtfz);
                        BuyMerchantItem(i,wtfz);
                    else
                        bsDPrint(" C: Buying: "..ab);
                        BuyMerchantItem(i, ab);
                    end
                end
            end
		end
    end
end


function bsABList() -- Dump Auto Buy List

    if(db.AutoBuy["Items"]==nil) then
        db.AutoBuy["Items"]= {};
    end

    for item,buyamount in pairs (db.AutoBuy["Items"]) do
        bsInform("Auto Buy: "..item.. " ("..buyamount..")");
    end
end

function bsABAdd(name,quantity)
    db.AutoBuy["Items"][name]=quantity;
end

function bsABRemove(name)
    bsDPrint("REMOVED "..name);
    db.AutoBuy["Items"][name]=nil;
end

function bsABLCreateButtons()
    local createFrame = CreateFrame;
    local parent      = BSABLFrame;
    local button      = createFrame("Button", "BSABLSF_ItemButton1", parent,  "BSABLSFButtonTemplate");
    button:SetID(1);
    button:SetPoint("TOPLEFT","BSABLFrame","TOPLEFT",36,-75);
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp");

    for index = 2, 23 do
        --bsDPrint("BUTTON CREATION: "..index);
        button = createFrame( "Button", "BSABLSF_ItemButton"..index, parent, "BSABLSFButtonTemplate");
        button:SetID(index);
        button:SetPoint( "TOPLEFT", "BSABLSF_ItemButton"..(index-1), "BOTTOMLEFT", 0, 1);
        button:RegisterForClicks( "LeftButtonUp", "RightButtonUp");
    end
end

function bsABLPopulate()

    for index = 1,23 do
        local what=getglobal("BSABLSF_ItemButton"..index);
        if (what) then
            what:Hide();
        end
    end
	bsDPrint("ABL Pop");
	BSABLSF.RealResultsSize=bsABLGetNumItems();
	BSABLFrameTitleText:SetText("Auto Buy List "..BSABLSF.RealResultsSize.." items");
	FauxScrollFrame_Update(BSABLSF,BSABLSF.RealResultsSize-1,22,16);
	bsDPrint("BSABLSF.RealResultsSize ["..BSABLSF.RealResultsSize.."]");
	local offset = BSABLSF.offset;
	bsDPrint("BSABLSF.offset="..offset);
    local index=1;
    local grof=0;

    if(db.AutoBuy["Items"]~=nil) then
        for bsaslitem,astable in pairs (db.AutoBuy["Items"]) do
            if(grof<offset) then
                grof=grof+1;
            else
                --bsDPrint("BSABLSF_ItemButton"..index.." RESULT :"..bsaslitem);
                local zbutton=getglobal("BSABLSF_ItemButton"..index);
                if(zbutton~=nil) then
                    zwhat=getglobal("BSABLSF_ItemButton"..index.."_Text");
                    zwhat:SetText(bsaslitem);
                    zwho =getglobal("BSABLSF_ItemButton"..index.."_AmountText");
                    zwho:SetText(astable);
                    zbutton:SetScript("OnClick", (function(self) bsABLButtonPressed(bsaslitem); end));
                    index=index+1;
                    zbutton:Show();
                else
                    bsDPrint("ERROR: zbutton==nil BestSeller.lua Line 178");
                end

            end
        end
    end
end

function bsABLGetNumItems()
	local numitems=0;
	if(db.AutoBuy["Items"]~=nil) then
        for item,_ in pairs (db.AutoBuy["Items"]) do
            numitems=numitems+1;
        end
    end
	return numitems;
end

function bsABLButtonPressed(index)

	bsDPrint("Autobuy List "..index);

    BSABLFrameAddItemBox:SetText(index);
    BSABLFrameAddItemAmountBox:SetText("1");

    bsABRemove(index);
    bsABLPopulate();
end

function bsABLAddFromFrame()
    if(BSABLFrameAddItemBox:GetText()~="") then
        if(db.AutoBuy["Items"]==nil) then
            db.AutoBuy["Items"]={};
        end

        db.AutoBuy["Items"][BSABLFrameAddItemBox:GetText()] =
        BSABLFrameAddItemAmountBox:GetText();
        bsPrint("Added "..BSABLFrameAddItemBox:GetText().." x "..BSABLFrameAddItemAmountBox:GetText().." to auto buy list");
        bsABLPopulate();
        BSABLFrameAddItemBox:SetText("");
        BSABLFrameAddItemBox:ClearFocus();
    end
end

