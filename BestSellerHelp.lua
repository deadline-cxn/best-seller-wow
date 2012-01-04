------------------------------------[BestSeller HELP]

function bsShowHelp(msg)
    bsPrint(JFCC.."------------------------------------------------------------------------");
    bsPrint(JFCC.."Best Seller "..bsVersion.." by Smashed / Bladefist --- Help:");
    bsPrint(JFCC.."/bs show (or hide)..........shows or hides interface");
    bsPrint(JFCC.."/bs minishow (or minihide)..displays minimap button");
    bsPrint(JFCC.."/bs rs...............restack items in backpacks");
    bsPrint(JFCC.."/bs aslist...........lists items that are on your Auto Sell list");
    bsPrint(JFCC.."/bs asremove #.......removes an item from the auto sell list");
    bsPrint(JFCC.."/bs asadd <item>.....adds an item (by name) to the auto sell list");
    bsPrint(JFCC.."/bs asthresh <#>.....sets threshold for auto sell "..RFCC.."(USE WITH CAUTION!!!)");
    bsPrint(JFCC.."             Where # is one of the following:");
    bsPrint(JFCC.."              "..DFCC.."0=Poor"..WFCC.." 1=Normal"..GFCC.." 2=Uncommon"..BFCC.." 3=Rare"..PFCC.." 4=Epic"..OFCC.." 5=Legendary");
    bsPrint(JFCC.."              Example: /bs asthresh 2 (will auto sell all Uncommon (GREEN) and lower items)");
    bsPrint(JFCC.."/bs aselist..........lists items to be excluded from auto sell");
    bsPrint(JFCC.."/bs aseremove #......removes an item from the auto sell exclusion list");
    bsPrint(JFCC.."/bs aseadd <item>....adds an item (by name) to the auto sell exclusion list");
    bsPrint(JFCC.."------------------------------------------------------------------------");
end



