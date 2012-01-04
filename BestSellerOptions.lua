--------------------------------------------------------------------------------
-- Best Seller Options


function bsOptions_Toggle()
    if (BSAMFrame:IsShown()) then
        BSAMFrame:Hide();
    else
        BSAMFrame:Show();
    end
end
function bsToggle_AutoRepair()
	db.AutoRepair=BSOptionsFrame_AutoRepair:GetChecked();
	if(db.AutoRepair) then
		bsInform("Auto repair now turned on");
	else
		bsInform("Auto repair now turned off");
	end
end
function bsToggle_GuildFundedRepair()
	db.GuildFundedRepair=BSOptionsFrame_GuildFundedRepair:GetChecked();
	if(db.GuildFundedRepair) then
		bsInform("Guild funded repairs now turned on");
	else
		bsInform("Guild funded repairs now turned off");
	end
end

function bsToggle_Debug()
    if ( db.BestSellerDebug==0) or
       ( not db.BestSellerDebug ) then
        db.BestSellerDebug=1;
        bsInform(" >>>>> BEST SELLER DEBUG TURNED ON");
    else
        db.BestSellerDebug=0;
        bsInform(" >>>>> BEST SELLER DEBUG TURNED OFF");
    end
end
function bsToggle_DebugShowAllEvents()
    if( ( db.DebugAllEvents==false) or
        ( not db.DebugAllEvents )) then
        db.DebugAllEvents=true;
        bsInform(" >>>>> BEST SELLER DEBUG SHOW ALL EVENTS TURNED ON");
    else
        db.DebugAllEvents=false;
        bsInform(" >>>>> BEST SELLER DEBUG SHOW ALL EVENTS TURNED OFF");
    end
end
