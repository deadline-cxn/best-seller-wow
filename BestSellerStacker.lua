
---------------------------------------------------------------------------------------

function JGoBag(bag)
	if (bag==0) then PutItemInBackpack(); end
	if (bag==1) then PutItemInBag(20); end
	if (bag==2) then PutItemInBag(21); end
	if (bag==3) then PutItemInBag(22); end
	if (bag==4) then PutItemInBag(23); end
end

function JGetSlot(itemZ,bag)
	for slot=1,20
	do
		iHi=GetContainerItemLink(bag,slot);
		if(iHi~=nil) then
			if(iHi==itemZ) then
				return slot;
			end
		end
	end
	return nil;
end
function JRestack()
    local bag = 0;
    local ibag = 0;
    local slot = 0;
	local islot = 0;
	local tbag = 0;
	local tslot = 0;

	for bag = 0,4
	do
		tbag=bag;
		for slot = 1,20
		do
			tslot = slot;
			iHi = GetContainerItemLink(bag,slot);
			if(iHi==nil) then iHi="wot";
			else
				link=Jelly_GetLink(iHi);
                if(link ~=nil) then

                    itemName,
                    itemLink,
                    itemRarity,
                    itemLevelReq,
                    itemType,
                    itemSubType,
                    itemStackCount = GetItemInfo(link);

				    duh,
                    count,
                    d2,
                    quality,
                    uread = GetContainerItemInfo(bag,slot);

				    if (count == itemStackCount) then

				    else
					    for ibag = 0,4
					    do
						    for islot = 1,30
						    do
							    if(ibag==bag) and (islot==slot) then

							    else
								    if(GetContainerItemLink(ibag,islot)==iHi) then

                                        link=Jelly_GetLink(iHi);
                                        if(link ~= nil) then

                                            itemName,
                                            itemLink,
                                            itemRarity,
                                            itemLevelReq,
                                            itemMinLevel,
                                            itemType,
                                            itemSubType,
                                            itemStackCount,
                                            itemEquipLoc,
                                            itemTexture = GetItemInfo(link);

									        duh,
                                            count,
                                            d2,
                                            quality,
                                            uread = GetContainerItemInfo(ibag,islot);

									        if(count==itemStackCount) then

									        else
										        JTPrint("Combined item "..itemName);
										        PickupContainerItem(bag,slot);
										        JGoBag(ibag);

										        jork=Jelly_GetSlot(ibag,islot);
										        if(jork~=nil) then
											    PickupContainerItem(ibag,islot);
											        JGoBag(bag);
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
		end
	end

	JTPrint("restacked your items.");

	return false;
end

