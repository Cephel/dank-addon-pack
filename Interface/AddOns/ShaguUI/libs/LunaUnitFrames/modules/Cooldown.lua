if checkAltUF() then return end
local oldCooldownFrame_SetTimer = CooldownFrame_SetTimer
local function LunaCooldownFrame_SetTimer(this, start, duration, enable, rev)
	oldCooldownFrame_SetTimer(this, start, duration, enable)
	if ( start > 0 and duration > 0 and enable > 0) then
		this.reverse = rev;
	end
end
CooldownFrame_SetTimer = LunaCooldownFrame_SetTimer

function CooldownFrame_OnUpdateModel()
	if ( this.stopping == 0 ) then
		local finished = (GetTime() - this.start) / this.duration;
		if ( finished < 1.0 ) then
			if this.reverse then
				finished = 1-finished
			end
			local time = finished * 1000;
			this:SetSequenceTime(0, time);
			return;
		end
		this.stopping = 1;
		this:SetSequence(1);
		this:SetSequenceTime(1, 0);
	else
		this:AdvanceTime();
	end
end