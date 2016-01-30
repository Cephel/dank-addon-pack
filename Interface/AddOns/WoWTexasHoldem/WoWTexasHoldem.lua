-- WoW Texas Holdem (by Kraize@freeholdemstrategy.com)
-- WoW Texas Holdem (by Kraize@freeholdemstrategy.com)
-- Fork of WoWTexasHoldem version 1.02 (by Thornwind and Density)
-- Ported to addon channel communication by Rena of Nostalrius
-- Feedback www.freeholdemstrategy.com/forum/
-- (c)Kraize@freeholdemstrategy.com 
-- Kudos to the Peter "27" McNeill and Timothy Hancock for writing the original mod and the whole Anzac Team for helping Thornwind test.. and for reminding Thornwind about all the little details he'd have left out.  Bastards.
-- Kudos to Density (Thornwind's copilot) for his work on the hand detection stuff.
-- PLEASE DO NOT FORK/MODIFY/RELEASE your own versions of this without permission from Kraize@freeholdemstrategy.com.  

--Texas Holdem UI Mod for World Of Warcraft
--To Host a game Use: /holdem
--To Join a game Use: /holdem Playername
--Feedback www.freeholdemstrategy.com/forum/
--Give thanks for the mod by adding a link to your site: <a href="http://www.freeholdemstrategy.com/wow_texas_holdem.html">WoW Texas Holdem</a>
--Dealer can rightclick player boxes to get some options up.
--Dealer can set his Chips to 0, to enable "auto dealing".

-- Issues:  * This is not secure.  The "dealer" could cheat to his hearts content by modifying this file.  The clients arnt sent any data they shouldn't have,
--	            but probably could still make a mess of things if they're assholes.  Play with people you trust, not the inevitable Ironforge Gold Farmer spam.
-- 
--			* Blinds arn't controlable, betting isn't incremented properly.  Sometimes hands might get judged wrong.
--			* People joining a table mid hand arn't sent the data to see the flop if its out, or other peoples shown cards. Annoying but superficial.
--			* Dealer disconnecting is GG.

--TODO:		*Adjustable Blinds
--			*Correctly limit betting increments after a raise.  Seems dull for the amount of work required
--			*Sometimes the cards get judged wrong. Take a screenshot and mail it to kraize@freeholdemstrategy.com, along with a description of the problem

--Notes: We don't recommend that you play for real gold.  


-- modes
local test      = nil;
FHS_HOLDEM_version             = "v1.21";
local StuffLoaded =0;
local FHS_DraggingIcon=0;

------------Saved Variables------------------
local FHS_MapIconAngle=0;
local FHS_SetSize=0;
-----------------


local lasttime=0;
local timedelta=0;
local PlayerTurnEndTime=0;
local RandomSeed=0;

local NextRefresh=0; --for player portraits
local FHS_OrginalChatHook;

local FHS_PopupName=""; --for tracking the poped up menu
local FHS_PopupIndex=0;

local GameLevel=0;
local TheButton=1;
local WhosTurn=0;
local HighestBet=0;

local BetSize=20;

local Blinds=0;
local SidePot={};

local RoundCount=0;

local mode

--Single
local CardRank=
{
	"--",
	"Two",
	"Three",
	"Four",
	"Five",
	"Six",
	"Seven",
	"Eight",
	"Nine",
	"Ten",
	"Jack",
	"Queen",
	"King",
	"Ace",
}

--Plural
local CardRanks=
{
	"--",
	"Twos",
	"Threes",
	"Fours",
	"Fives",
	"Sixes",
	"Sevens",
	"Eights",
	"Nines",
	"Tens",
	"Jacks",
	"Queens",
	"Kings",
	"Aces",
}

local CardSuits=
{
	"Clubs","Diamonds","Hearts","Spades"	
}


local Cards = 
{
	{object="FHS_Card_C0",	text="Ace of Clubs",	rank=14,	suit=1},
	{object="FHS_Card_C1",	text="Two of Clubs",	rank=2,		suit=1},
	{object="FHS_Card_C2",	text="Three of Clubs",	rank=3,		suit=1},
	{object="FHS_Card_C3",	text="Four of Clubs",	rank=4,		suit=1},
	{object="FHS_Card_C4",	text="Five of Clubs",	rank=5,		suit=1},
	{object="FHS_Card_C5",	text="Six of Clubs",	rank=6,		suit=1},
	{object="FHS_Card_C6",	text="Seven of Clubs",	rank=7,		suit=1},
	{object="FHS_Card_C7",	text="Eight of Clubs",	rank=8,		suit=1},
	{object="FHS_Card_C8",	text="Nine of Clubs",	rank=9,		suit=1},
	{object="FHS_Card_C9",	text="Ten of Clubs",	rank=10,	suit=1},
	{object="FHS_Card_C10",	text="Jack of Clubs",	rank=11,	suit=1},
	{object="FHS_Card_C11",	text="Queen of Clubs",	rank=12,	suit=1},
	{object="FHS_Card_C12",	text="King of Clubs",	rank=13,	suit=1},

	{object="FHS_Card_D0",	text="Ace of Diamonds",		rank=14,	suit=2},
	{object="FHS_Card_D1",	text="Two of Diamonds",		rank=2,		suit=2},
	{object="FHS_Card_D2",	text="Three of Diamonds",	rank=3,		suit=2},
	{object="FHS_Card_D3",	text="Four of Diamonds",	rank=4,		suit=2},
	{object="FHS_Card_D4",	text="Five of Diamonds",	rank=5,		suit=2},
	{object="FHS_Card_D5",	text="Six of Diamonds",		rank=6,		suit=2},
	{object="FHS_Card_D6",	text="Seven of Diamonds",	rank=7,		suit=2},
	{object="FHS_Card_D7",	text="Eight of Diamonds",	rank=8,		suit=2},
	{object="FHS_Card_D8",	text="Nine of Diamonds",	rank=9,		suit=2},
	{object="FHS_Card_D9",	text="Ten of Diamonds",		rank=10,	suit=2},
	{object="FHS_Card_D10",	text="Jack of Diamonds",	rank=11,	suit=2},
	{object="FHS_Card_D11",	text="Queen of Diamonds",	rank=12,	suit=2},
	{object="FHS_Card_D12",	text="King of Diamonds",	rank=13,	suit=2},

	{object="FHS_Card_H0",	text="Ace of Hearts",	rank=14,	suit=3},
	{object="FHS_Card_H1",	text="Two of Hearts",	rank=2,		suit=3},
	{object="FHS_Card_H2",	text="Three of Hearts",	rank=3,		suit=3},
	{object="FHS_Card_H3",	text="Four of Hearts",	rank=4,		suit=3},
	{object="FHS_Card_H4",	text="Five of Hearts",	rank=5,		suit=3},
	{object="FHS_Card_H5",	text="Six of Hearts",	rank=6,		suit=3},
	{object="FHS_Card_H6",	text="Seven of Hearts",	rank=7,		suit=3},
	{object="FHS_Card_H7",	text="Eight of Hearts",	rank=8,		suit=3},
	{object="FHS_Card_H8",	text="Nine of Hearts",	rank=9,		suit=3},
	{object="FHS_Card_H9",	text="Ten of Hearts",	rank=10,	suit=3},
	{object="FHS_Card_H10",	text="Jack of Hearts",	rank=11,	suit=3},
	{object="FHS_Card_H11",	text="Queen of Hearts",	rank=12,	suit=3},
	{object="FHS_Card_H12",	text="King of Hearts",	rank=13,	suit=3},

	{object="FHS_Card_S0",	text="Ace of Spades",	rank=14,	suit=4},
	{object="FHS_Card_S1",	text="Two of Spades",	rank=2,		suit=4},
	{object="FHS_Card_S2",	text="Three of Spades",	rank=3,		suit=4},
	{object="FHS_Card_S3",	text="Four of Spades",	rank=4,		suit=4},
	{object="FHS_Card_S4",	text="Five of Spades",	rank=5,		suit=4},
	{object="FHS_Card_S5",	text="Six of Spades",	rank=6,		suit=4},
	{object="FHS_Card_S6",	text="Seven of Spades",	rank=7,		suit=4},
	{object="FHS_Card_S7",	text="Eight of Spades",	rank=8,		suit=4},
	{object="FHS_Card_S8",	text="Nine of Spades",	rank=9,		suit=4},
	{object="FHS_Card_S9",	text="Ten of Spades",	rank=10,	suit=4},
	{object="FHS_Card_S10",	text="Jack of Spades",	rank=11,	suit=4},
	{object="FHS_Card_S11",	text="Queen of Spades",	rank=12,	suit=4},
	{object="FHS_Card_S12",	text="King of Spades",	rank=13,	suit=4},
	{object="FHS_Blank_1" },
	{object="FHS_Blank_2" },
	{object="FHS_Blank_3" },
	{object="FHS_Blank_4" },
	{object="FHS_Blank_5" },
	{object="FHS_Blank_6" },
	{object="FHS_Blank_7" },
	{object="FHS_Blank_8" },
	{object="FHS_Blank_9" },
	{object="FHS_Blank_10" },
	{object="FHS_Blank_11" },
	{object="FHS_Blank_12" },
	{object="FHS_Blank_13" },
	{object="FHS_Blank_14" },
	{object="FHS_Blank_15" },
	{object="FHS_Blank_16" },
	{object="FHS_Blank_17" },
	{object="FHS_Blank_18" },
	{object="FHS_Blank_19" },
	{object="FHS_Blank_20" },
	{object="FHS_Blank_21" },
	{object="FHS_Blank_22" },
	{object="FHS_Blank_23" },
}

-- Poker Hands

local HandType =
{
	{text="High Card",		power=0}, --1
	{text="2 of a Kind",	power=1}, --2
	{text="2 Pair",			power=2}, --3
	{text="3 of a Kind",	power=3}, --4
	{text="Straight",		power=4}, --5
	{text="Flush",			power=5}, --6
	{text="Full House",		power=6}, --7
	{text="4 of a Kind",	power=7}, --8
	{text="Flush Straight",	power=8}, --9
	{text="Royal Flush",	power=9}, --10
	{text="nil",power=-1},
}

--Player Seats

local Seats	= {
	{object="FHS_Seat_1",name="",	x=180, y=190,	chips=0,bet=0,status="", seated=0,hole1=0,hole2=0,dealt=0,alpha=1, inout="" },
	{object="FHS_Seat_2",name="",	x=240, y=70,	chips=0,bet=0,status="", seated=0,hole1=0,hole2=0,dealt=0,alpha=1, inout="" },
	{object="FHS_Seat_3",name="",	x=240, y=-60,	chips=0,bet=0,status="", seated=0,hole1=0,hole2=0,dealt=0,alpha=1, inout="" },
	{object="FHS_Seat_4",name="",	x=170, y=-200,	chips=0,bet=0,status="", seated=0,hole1=0,hole2=0,dealt=0,alpha=1, inout="" },
	{object="FHS_Seat_5",name="",	x=-0, y=-230,	chips=0,bet=0,status="", seated=0,hole1=0,hole2=0,dealt=0,alpha=1, inout="" },
	{object="FHS_Seat_6",name="",	x=-170, y=-200,	chips=0,bet=0,status="", seated=0,hole1=0,hole2=0,dealt=0,alpha=1, inout="" },
	{object="FHS_Seat_7",name="",	x=-240, y=-60,	chips=0,bet=0,status="", seated=0,hole1=0,hole2=0,dealt=0,alpha=1, inout="" },
	{object="FHS_Seat_8",name="",	x=-240, y=70,	chips=0,bet=0,status="", seated=0,hole1=0,hole2=0,dealt=0,alpha=1, inout="" },
	{object="FHS_Seat_9",name="",	x=-180, y=190,	chips=0,bet=0,status="", seated=0,hole1=0,hole2=0,dealt=0,alpha=1, inout="" },
}


--Event Table
local EventSpam={};

local LocalSeat=0;
local IsDealer=0;
local DealerName="";

--Shuffle array
local Shuffle={};

--Servers Flop
local DealerFlop={};
local DealerTimer=0;

--Flop as known at any point
local Flop={};

local FlopBlank={}; --Record of blank flop cards

local DealerCard=0;
local CardWidth=80;

local DealerX=0;
local DealerY=250;

local DealerDelay=0.5;
local CardSpeed=3;
local CC=0;
local BlinkOn = 1;

local function IsInGuild(name)
	for i=1, GetNumGuildMembers() do
		if GetGuildRosterInfo(i) == name then
			return true
		end
	end
	return nil
end

function FHSPoker_OnLoad()

	local test;
	
	
		StaticPopupDialogs["FHS_DEALER"] = 
	{
		text = "Do you wish to start Dealing?                                                                   To join a game use /holdem PLAYERNAME",
			button1 = "Start Dealing",
			button2 = "Cancel",
			OnAccept = function()
			FHS_ShowTable();
			FHS_DealerClick();
			end,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1
	};
	

    -- Events
    FHSPoker_registerEvents();
	    
	DEFAULT_CHAT_FRAME:AddMessage("::  WoW Texas Holdem " .. FHS_HOLDEM_version.." a Fork of AnzacHoldem");
	DEFAULT_CHAT_FRAME:AddMessage("::  Use '/holdem' to start a table as the dealer.");
	DEFAULT_CHAT_FRAME:AddMessage("::  Use '/holdem Playername' to join someone elses table.");
	
	-- Initialize Seat Rings
	for j=1,5 do
		--swap the side for a few of them
		name="FHS_Seat_"..j.."_Port";
		obj=getglobal(name)
		obj:SetPoint("CENTER", "FHS_Seat_"..j, "CENTER", -100, 0);
		name="FHS_Seat_"..j.."_PortWho";
		obj=getglobal(name)
		obj:SetPoint("CENTER", "FHS_Seat_"..j, "CENTER", -100, 0);
		name="FHS_Seat_"..j.."_Ring";
		obj=getglobal(name)
		obj:SetPoint("CENTER", "FHS_Seat_"..j, "CENTER", -82, -22);
		name="FHS_Seat_"..j.."_RingSelect";
		obj=getglobal(name)
		obj:SetPoint("CENTER", "FHS_Seat_"..j, "CENTER", -82, -22);

	end;

	for j=6,9 do
		Seats[j].x=Seats[j].x+12;
		PlayerTurnEndTime=GetTime()+(24*60*60*365);
	end;


	FHS_Version:SetText("WoW Texas Holdem "..FHS_HOLDEM_version.." fork of AnzacHoldem v1.02");
	
	-- Assign all Cards their objects
	for key, object in Cards do 
		Cards[key].Fobject=getglobal(Cards[key].object);
		Cards[key].Hobject=getglobal(Cards[key].object.."_H"); --Higher Layer card
		Cards[key].fraction=0;
		Cards[key].fadeout=0;
		Cards[key].fadetime=0;
		Cards[key].x=0;
		Cards[key].y=0;
		Cards[key].startx=0;
		Cards[key].starty=0;
		Cards[key].visible=0;
		Cards[key].high=0;	
	end


	--Turn off all the cards etc
	FHS_ClearTable();

	StuffLoaded=1;

	--FHSPokerFrame:Hide();
	LeaveParty = FHS_LeaveParty
end;

function SeatSlashCommand(msg)

	--Recenter the frame
	FHSPokerFrame:ClearAllPoints();
	FHSPokerFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);

	if (msg=="") then 
		FHS_ShowTable();
		FHS_DealerClick();
		return;
	end;

	FHS_ShowTable();
	msg = strlower(msg)
	msg = strupper(strsub(msg,1,1))..strsub(msg,2)
	SendAddonMessage("HoldemRaid", msg.." FHS_!seat", "RAID")
	SendAddonMessage("HoldemGuild", msg.." FHS_!seat", "GUILD")
	--SendChatMessage("FHS_!seat","WHISPER",nil,msg);	
end;

function FHS_SizeClick()
	FHS_SetSize=FHS_SetSize+1;
	if (FHS_SetSize>2) then FHS_SetSize=0; end;


	if (FHS_SetSize==0) then
		FHSPokerFrame:SetScale(1);
	
	end;
	if (FHS_SetSize==1) then
		FHSPokerFrame:SetScale(0.75);
	
	end;
	if (FHS_SetSize==2) then
		FHSPokerFrame:SetScale(0.5);
			
	end;

	FHSPokerFrame:ClearAllPoints();
	FHSPokerFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, 0);

end

function FHS_DealerClick()

	if (IsDealer==1) then
		FHS_StopServer();
	end
	FHS_StartDealer();	
end;

--clear all the cards off the table
function FHS_ClearCards()

	CC=0;
	for key, object in Cards do
		FHS_SetCard(key,DealerX,DealerY,0,0,0,0,0,0);
	end

	Flop={};
	FlopBlank={};
	BlankCard=53;

end


--Clear the table of everything

function FHS_InitializeSeat(j)

	Seats[j].name="";
	Seats[j].HavePort=0;
	Seats[j].seated=0;
	Seats[j].dealt=0;
	Seats[j].status="";
	Seats[j].bet=0;
	Seats[j].hole1=0;
	Seats[j].hole2=0;
	Seats[j].alpha=1;
	Seats[j].inout="IN";
end;

function FHS_ClearTable()
	
	for j=1,9 do
		FHS_InitializeSeat(j);
	end;

	for j=1,9 do
		FHS_UpdateSeat(j);
	end;
	
	

	FHS_ClearCards();
	FHS_SelectPlayerRing(0);
	FHS_StatusText("");
	FHS_Pot_Text:SetText("WoW Texas Hold'em");

	FHS_HideAllButtons();


	FHS_Popup:Hide();
end;


function FHSPoker_registerEvents()
    
    this:RegisterEvent("VARIABLES_LOADED");
    this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("CHAT_MSG_ADDON");
	
    
	--Initialize Commands
	SLASH_FHSPOKER1 = "/holdem";
	

	SlashCmdList["FHSPOKER"] = function(msg)
		SeatSlashCommand(msg);
	end


	--Hook the chatwindow, save the inherited hook 
--[[	if (ChatFrame_OnEvent ~= FHS_ChatFrameHook) then
		-- get chatframe events to allow us to hide chat
		FHS_OrginalChatHook = ChatFrame_OnEvent;
		ChatFrame_OnEvent = FHS_ChatFrameHook;
	end --]]

end

function FHS_ChatFrameHook(event, arg1, arg2)

	-- process and hide chat
	if (arg1 and arg2) then
		-- incoming whisper

		if (event == "CHAT_MSG_WHISPER") then
			FHS_SpamFilter(event,arg1,arg2);

			tab={};
			tab=Split(arg1,"_");
			if (table.getn(tab)>2) then
				if ((tab[1]=="FHS") and (tab[2]==FHS_HOLDEM_version)) then
					return; -- Hide this from the chat window
				end
			end

		end
		if (event =="CHAT_MSG_WHISPER_INFORM") then
			FHS_SpamFilter(event,arg1,arg2);

			tab={};
			tab=Split(arg1,"_");
			if (table.getn(tab)>2) then
				if ((tab[1]=="FHS") and (tab[2]==FHS_HOLDEM_version)) then
					return; -- Hide this from the chat window
				end
			end

		end
	end

	-- call original function to display the chat
--	FHS_OrginalChatHook(event);
end


function FHSPoker_unregisterEvents()
    
    this:UnregisterEvent("VARIABLES_LOADED");
    this:UnregisterEvent("PLAYER_ENTERING_WORLD");
	this:UnregisterEvent("CHAT_MSG_ADDON");
    
--	ChatFrame_OnEvent=FHS_OrginalChatHook;
end


function FHSPoker_OnEvent()
	if arg1 == "HoldemRaid" and not IsInGuild(arg4) or arg1 == "HoldemGuild" then
		local tab={}
		tab=Split(arg2," ")
		if tab[1] == UnitName("player") then
			FHS_ChatFrameHook("CHAT_MSG_WHISPER_INFORM", tab[2], UnitName("player"))
			FHS_ChatFrameHook("CHAT_MSG_WHISPER", tab[2], arg4)
		end
	end
end;



-- Duplicate removal of chat events, and storage for processing by FHS_RunEvents
function FHS_SpamFilter(aevent,aarg1,aarg2)
	
	found=-1;
	
	size=getn(EventSpam);
	for key=1,size do 
	
		if ((EventSpam[key].event==aevent)and(EventSpam[key].arg1==aarg1)and(EventSpam[key].arg2==aarg2)) then
			--duplicate due to multiple chat windows, discard
			found=key;
			break;
		end
	end
		
	if (found==-1) then
		--its unique
		index=size+1;
		EventSpam[index]={event=aevent,arg1=aarg1,arg2=aarg2};
	end;
end;



function FHSPoker_Update(arg1)
	
	--Animation is handled here

	if (StuffLoaded==1) then
--		SetPortraitTexture(FHS_Seat_Port_9, "player");
		local time=GetTime();
	
		--Automatic Dealer
			if (IsDealer==1) then
				if (Seats[LocalSeat].chips==0) then
					FHS_Play:SetText("AutoDealing");
					if ((time>DealerTimer) and (DealerTimer>0)) then
						if (FHS_GetSeatedPlayers()>2) then
							FHS_PlayClick();
							DealerTimer=0;
						end;
					end;
				else
					FHS_Play:SetText("Play");
				end;
			end;

		--


		timedelta=time-lasttime;
		
		if (lasttime==0) then timedelta=0; end -- initialization
		lasttime=time;
	

		for key, object in Cards do 
	
			-- This is nice, just increase fraction until it hits 1
				
			if (Cards[key].fraction<1) then
				Cards[key].fraction=Cards[key].fraction+(timedelta*CardSpeed);
			else
				if (Cards[key].fadeout>0) then  --Track how many ms we've been faded
					Cards[key].fadetime=Cards[key].fadetime+(timedelta*1000);
				end;
			end
		
			if (Cards[key].fraction>1) then
				Cards[key].fraction=1;
			end

			-- And update it
			FHS_DrawCard(key);
		end 


		if (time>NextRefresh) then
			NextRefresh=time+1;
			for j=1,9 do
				FHS_UpdateSeat(j);
			end;
			--DEFAULT_CHAT_FRAME:AddMessage("Tick "..NextRefresh);
			if (WhosTurn>0) then
				FHS_BlinkWhosTurn();
			end;
			FHS_CheckPlayerTime();
		end;

		--Process que'd chat messages
		FHS_RunEvents();

	end
end;

function FHSPoker_MapIconUpdate(arg1)
	
	local time=GetTime();
	if (FHS_DraggingIcon==1) then

		local xpos,ypos = GetCursorPosition();
		local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom();

		xpos = xmin-xpos/Minimap:GetEffectiveScale()+70;
		ypos = ypos/Minimap:GetEffectiveScale()-ymin-70;

		FHS_MapIconAngle = math.deg(math.atan2(ypos,xpos));
		
		FHS_IconPos(FHS_MapIconAngle);
	end
	
	--Process que'd chat messages
	FHS_RunEvents();


	-- Flash if its our go
	FHSPoker_MapIcon:Show();
	FHSPoker_MapIcon:SetAlpha(1);

	
	if ((LocalSeat==WhosTurn)and(LocalSeat>0)) then
		var= (sin(time *400 )+1)/2;
		FHSPoker_MapIcon:SetAlpha(var);
	end;

		--this:UnlockHighlight()
		--this:LockHighlight()
end

function FHS_MapIconClick(arg1)

	if ((IsDealer==0)and(LocalSeat==0)) then
		StaticPopup_Show ("FHS_DEALER");
		return;
	end;

	
	FHS_ShowTable();
end;

function FHS_ShowTable()
	FHSPokerFrame:Show();
end;

function FHS_Dragging(param)
	FHS_DraggingIcon=param;
end;

function FHS_IconPos(angle)
	xpos=cos(angle)*81;
	ypos=sin(angle)*81;
	FHSPoker_MapIconFrame:SetPoint("TOPLEFT","Minimap","TOPLEFT",53-xpos,-55+ypos)
end;


function FHS_CheckPlayerTime()
	if ((GetTime()>PlayerTurnEndTime)and(WhosTurn~=0)) then
		--DEFAULT_CHAT_FRAME:AddMessage("Force Out: "..WhosTurn);	
		FHS_SendMessage("forceout_"..WhosTurn,Seats[WhosTurn].name);

		PlayerTurnEndTime=GetTime()+(24*60*60*365) -- set the time to next year	
	end;

end;

function FHS_BlinkWhosTurn()
	
	if (BlinkOn == 0) then
		BlinkOn = 1;
		if (WhosTurn>0) then
			name="FHS_Seat_"..WhosTurn.."_RingSelect";
			obj=getglobal(name)
			obj:Show();
			name="FHS_Seat_"..WhosTurn.."_Ring";
			obj=getglobal(name)
			obj:Hide();
		end;
	else
		BlinkOn = 0;
		if (WhosTurn>0) then
			name="FHS_Seat_"..WhosTurn.."_RingSelect";
			obj=getglobal(name)
			obj:Hide();
			name="FHS_Seat_"..WhosTurn.."_Ring";
			obj=getglobal(name)
			obj:Show();
		end;
	end;

end;


function FHS_StatusText(text)
	FHS_Status_Text:SetText(text);
end;

function FHS_StatusTextCards()
	
	if (LocalSeat>0) then
		OutText,Handtype,BestCards,Kicker=FHS_FindHandForPlayer(LocalSeat);
		FHS_StatusText(OutText);
	end;
end


function FHS_SetCard(index,dealerx,dealery,x,y,visible,fraction,fadeout,highlayer)

	Cards[index].x=x;
	Cards[index].y=y;
	Cards[index].startx=dealerx;
	Cards[index].starty=dealery;
	Cards[index].fraction=fraction;
	Cards[index].fadetime=0;
	Cards[index].visible=visible;
	Cards[index].fadeout=fadeout;
	Cards[index].Fobject:SetAlpha(1);
	Cards[index].Hobject:SetAlpha(1);
	Cards[index].high=highlayer;
	FHS_DrawCard(index);
end;

function FHS_DrawCard(index)

	local dx;
	local dy;
	local frac;
	local mfrac;

	frac=Cards[index].fraction;
	mfrac=1-frac;
	
	if (frac<0) then
		Cards[index].Fobject:Hide();
		Cards[index].Hobject:Hide();
		return;
	else
 		dx=(Cards[index].startx*mfrac)+(Cards[index].x*frac);
		dy=(Cards[index].starty*mfrac)+(Cards[index].y*frac);
	end

	

	if (Cards[index].visible==1) then
		
		Cards[index].Fobject:SetPoint("CENTER", "FHSPokerFrame", "CENTER", dx+29, dy);
		Cards[index].Hobject:SetPoint("CENTER", "FHSPokerFrame", "CENTER", dx+29, dy);

		if (Cards[index].high==0) then
			Cards[index].Fobject:Show();
			Cards[index].Hobject:Hide();
		else
			Cards[index].Fobject:Hide();
			Cards[index].Hobject:Show();
		end;
		
		if (Cards[index].fadeout>0)and(Cards[index].fadetime>0) then
			delta=Cards[index].fadeout-Cards[index].fadetime;
			if (delta<0) then
				Cards[index].Fobject:Hide();
				Cards[index].Hobject:Hide();
			else
				delta=(delta/Cards[index].fadeout);
				Cards[index].Fobject:SetAlpha(delta);
				Cards[index].Hobject:SetAlpha(delta);
			end;

		end;

	else
		Cards[index].Fobject:SetPoint("CENTER", "FHSPokerFrame", "CENTER", 0, 0);
		Cards[index].Fobject:Hide();
		
		Cards[index].Hobject:SetPoint("CENTER", "FHSPokerFrame", "CENTER", 0, 0);
		Cards[index].Hobject:Hide();
	end


end;


function FHS_UpdateSeat(j)
		
	if (Seats[j].seated==0) then
	
		name="FHS_Seat_"..j.."_Name";
		obj=getglobal(name)
		obj:SetText("");
		
		name="FHS_Seat_"..j.."_Chips";
		obj=getglobal(name)
		obj:SetText("Empty");
		
		name="FHS_Seat_"..j.."_Status";
		obj=getglobal(name)
		obj:SetText("");

		name="FHS_Seat_"..j.."_Port";
		obj=getglobal(name)
		obj:Hide();
		name="FHS_Seat_"..j.."_PortWho";
		obj=getglobal(name)
		obj:Hide();

		name="FHS_Seat_"..j;
		obj=getglobal(name)
		obj:Hide();

	else
		
		name="FHS_Seat_"..j;
		obj=getglobal(name)
		obj:Show();

		obj:SetAlpha(Seats[j].alpha);

		--Texts
		name="FHS_Seat_"..j.."_Name";
		obj=getglobal(name)
		obj:SetText(Seats[j].name);
		
		name="FHS_Seat_"..j.."_Chips";
		obj=getglobal(name)
		obj:SetText("Chips: "..Seats[j].chips);
		
		name="FHS_Seat_"..j.."_Status";
		obj=getglobal(name)
		obj:SetText(Seats[j].status);

		name="FHS_Seat_"..j.."_PortWho";
		obj=getglobal(name)
		obj:Hide();	

		name="FHS_Seat_"..j.."_Port";
		obj=getglobal(name)
		obj:Show();
		--Portrait	
	

		--temp=UnitName("target");
		
		--TargetByName(Seats[j].name);
		

		if ( UnitName("player")==Seats[j].name) then --Visible
			SetPortraitTexture(obj,"player");
			Seats[j].HavePort=1;
			return;
		end

		if ( UnitName("target")==Seats[j].name) then --Visible
			SetPortraitTexture(obj,"target");
			Seats[j].HavePort=1;
			return;
		end

		for n=1,5 do
			if ( UnitName("party"..n)==Seats[j].name) then --Visible
				SetPortraitTexture(obj, "party"..n);
				Seats[j].HavePort=1;
				return;
			end
		end;
		for n=1,40 do
			if ( UnitName("raid"..n)==Seats[j].name) then --Visible
				SetPortraitTexture(obj, "raid"..n);
				Seats[j].HavePort=1;
				return;
			end
		end;
	
		
		if (Seats[j].HavePort==0) then
			name="FHS_Seat_"..j.."_Port";
			obj=getglobal(name)
			obj:Hide();	

			name="FHS_Seat_"..j.."_PortWho";
			obj=getglobal(name)
			obj:Show();	
		end;
		
	end;
end;


--Courtesy of Daldain

function Split(haystack, char)
	local splut = {};

	if (type(haystack) ~= "string") then return nil end
	if (not haystack) then haystack = "" end
	if (not char) then
		table.insert(splut,haystack);
	else
		for n, c in string.gfind(haystack,"([^%".. char .."]*)(%".. char .."?)") do
			table.insert(splut,n);
			if (c == "") then break end
		end
	end

	return splut;
end


function FHS_StopClient()

	IsDealer=0;
	LocalSeat=0;
	WhosTurn=0;
	DealerName="";
	FHS_ClearTable();
end

old_LeaveParty = LeaveParty
function FHS_LeaveParty()
	if LocalSeat ~= 0 and not IsInGuild(DealerName) then
		if (IsDealer==0) then
			if ((IsDealer==0) and (DealerName=="")) then 
				return; 
			else
				SendAddonMessage("HoldemRaid", DealerName.." FHS_".. FHS_HOLDEM_version.."_".."q_"..LocalSeat, "RAID")
			end
			old_LeaveParty()
			FHS_StopClient();
		else
			if not (IsDealer==0) then
				for j=1,9 do
					if ((j==LocalSeat) or(j == -1) or (Seats[j].seated==0))  then 
						--no good
					else
						SendAddonMessage("HoldemRaid", Seats[j].name.." FHS_".. FHS_HOLDEM_version.."_".."hostquit", "RAID")
						SendAddonMessage("HoldemGuild", Seats[j].name.." FHS_".. FHS_HOLDEM_version.."_".."hostquit", "GUILD")
					end
				end
			end
			old_LeaveParty()
			IsDealer=0;
			LocalSeat=0;
			WhosTurn=0;
	
			FHS_ClearTable();		
		end

		--Hide the buttons cause we're done
		FHS_HideAllButtons();

		FHSPokerFrame:Hide();
	else
		old_LeaveParty()
	end
end

function FHS_QuitClick()

	if (IsDealer==0) then
		FHS_SendMessage("q_"..LocalSeat,DealerName);
		
		FHS_StopClient();
	else
		FHS_StopServer();		
	end

	--Hide the buttons cause we're done
	FHS_HideAllButtons();

	FHSPokerFrame:Hide();
end;

function FHS_SitOutInClick()

	FHS_SitOutIn(LocalSeat);

end;

function FHS_SitOutInClick()

	if (IsDealer==0) then
		if(Seats[LocalSeat].inout=="IN") then
			FHS_FoldClick();
			FHS_SendMessage("inout_"..LocalSeat.."_OUT",DealerName);
			Seats[LocalSeat].inout="OUT";
			FHS_SitOutIn:SetText("I'm Back");
		else			
			FHS_SendMessage("inout_"..LocalSeat.."_IN",DealerName);
			Seats[LocalSeat].inout="IN";
			FHS_SitOutIn:SetText("Sit Out");
		end;
	else
		-- don't let the dealer sit out -- put up a message box to that dealer must play	
		message("Sorry the dealer can not sit out.  Set your chips to Zero to enable auto deal.");	
	end;

end;


function FHS_HideAllButtons()
	FHS_Fold:Hide();
	FHS_Call:Hide();
	FHS_Raise:Hide();
	FHS_Raise_Higher:Hide();
	FHS_Raise_Lower:Hide();
	FHS_AllIn:Hide();
end;


function FHS_FoldClick()

	if (IsDealer==0) then
		
		if (Seats[LocalSeat].dealt==1) then
			FHS_SendMessage("fold_"..LocalSeat,DealerName);
		
			--Server wont tell us we've folded, so we do it ourselves
			Seats[LocalSeat].dealt=0;
						
			FHS_ShowCard(LocalSeat,"Folded");
			FHS_Fold:SetText("Show Cards");
		else
			FHS_SendMessage("showcards_"..LocalSeat.."_"..RoundCount,DealerName);
			FHS_Fold:Hide();
		end;	
	else
		if (Seats[LocalSeat].dealt==1) then		
			--OutText,Handtype,BestCards=FHS_FindHandForPlayer(LocalSeat);
			--Seats[LocalSeat].status="("..OutText..")";
			Seats[LocalSeat].status="Folded";
			
			FHS_FoldPlayer(LocalSeat);
			FHS_Fold:SetText("Show Cards");
		else
			FHS_ShowCard(LocalSeat,"Showing");
			FHS_Fold:Hide();
		end;
	end;
	FHS_UpdateSeat(LocalSeat);
	

	--its no longer our turn, obviously
	FHS_Call:Hide();
	FHS_Raise:Hide();
	FHS_Raise_Higher:Hide();
	FHS_Raise_Lower:Hide();

end;

function FHS_RaiseClick()
	if (LocalSeat==0) then return; end
	
	--Raised
	delta=-1;
	--DEFAULT_CHAT_FRAME:AddMessage("Raise. bet is:"..Seats[LocalSeat].bet.." Highest is:"..HighestBet);


	delta = HighestBet-Seats[LocalSeat].bet;
	-- Make sure we have enough chips
	--DEFAULT_CHAT_FRAME:AddMessage("Betsize:".. BetSize);
	delta = delta + BetSize;

	--All in
	if (HighestBet+BetSize>=Seats[LocalSeat].chips) then
		delta=Seats[LocalSeat].chips;	
	--	DEFAULT_CHAT_FRAME:AddMessage("All In");
	end;
	
	if (IsDealer==0) then
		FHS_SendMessage("call_"..LocalSeat.."_"..delta,DealerName);
	else
		FHS_PlayerAction(LocalSeat,delta);
	end;
end;

function FHS_AllInClick()
	if (LocalSeat==0) then return; end
	
	--Raised
	delta=-1;
	--DEFAULT_CHAT_FRAME:AddMessage("Raise. bet is:"..Seats[LocalSeat].bet.." Highest is:"..HighestBet);

	delta=Seats[LocalSeat].chips;	
	if (delta==0) then return; end;

	if (IsDealer==0) then
		FHS_SendMessage("call_"..LocalSeat.."_"..delta,DealerName);
	else
		FHS_PlayerAction(LocalSeat,delta);
	end;
end;

function FHS_CallClick()
	
	if (LocalSeat==0) then return; end
		
	--Called/Checked
	
	delta=-1;

	--DEFAULT_CHAT_FRAME:AddMessage("Current bet is:"..Seats[LocalSeat].bet.." Highest is:"..HighestBet);
	
	if (Seats[LocalSeat].bet<HighestBet) then
		--We need to make a bet here.
		delta = HighestBet-Seats[LocalSeat].bet;
			
		-- Make sure we have enough chips
		if (delta>Seats[LocalSeat].chips) then
			delta=-1;			
		end; 
	end;
	if (Seats[LocalSeat].bet==HighestBet) then
		--Checked!
		delta=0;
	end;


	--DEFAULT_CHAT_FRAME:AddMessage("delta"..delta.." "..Seats[LocalSeat].bet.." "..HighestBet);
	if (delta>-1) then
		if (IsDealer==0) then
			FHS_SendMessage("call_"..LocalSeat.."_"..delta,DealerName);
		else
			FHS_PlayerAction(LocalSeat,delta);
		end;
	end;
end;


function FHS_StartClient()

	DEFAULT_CHAT_FRAME:AddMessage(DealerName.." has seated you in Seat "..LocalSeat);
	FHS_ClearTable();
	
	if (IsDealer==1) then
		FHS_StopServer();
	end
	
	IsDealer=0;
	FHSPokerFrame:Show();
	FHS_Play:Hide();	
	
end

-- Enable or disable the buttons based on whats going on
function FHS_UpdateWhosTurn()
	

	if (LocalSeat==0) then
		return;
	end;

	--DEFAULT_CHAT_FRAME:AddMessage("It's "..Seats[WhosTurn].name.." turn.");
	FHS_UpdateButtons();

	--Fold Button, available while we still have cards
	if (Seats[LocalSeat].dealt==1) then
		FHS_Fold:SetText("Fold");
		FHS_Fold:Show();
	end;

	FHS_SelectPlayerRing(WhosTurn);

	if (WhosTurn==LocalSeat) then
		--Its our turn!
		FHS_Call:Show();
		FHS_AllIn:Show();
		FHS_Raise:Show();
		FHS_Raise_Higher:Show();
		FHS_Raise_Lower:Show();
		
		Call=1;

		--Set the text based on the action required
		delta = HighestBet-Seats[LocalSeat].bet;
		FHS_Call:SetText("Call "..delta);
		
		--DEFAULT_CHAT_FRAME:AddMessage("Bet Size: "..BetSize);
		--DEFAULT_CHAT_FRAME:AddMessage("Highest Bet: "..HighestBet);
		--DEFAULT_CHAT_FRAME:AddMessage("Chips: "..Seats[LocalSeat].chips);

		if (Seats[LocalSeat].bet==HighestBet) then
			FHS_Call:SetText("Check");
			delta=0;
			Call=0;
		end;

		-- Make sure we have enough chips
		if (Call==1) then
			FHS_Raise:SetText("Call "..delta..", Raise "..BetSize);
		else
			FHS_Raise:SetText("Raise "..BetSize);
		end;


		--if (HighestBet+BetSize>=Seats[LocalSeat].chips) then
		if (BetSize>(Seats[LocalSeat].chips-delta)) then
			delta=-1;			
			if (Call==1) then
				FHS_Raise:SetText("Call All In");
				FHS_Call:Hide();
			else
				FHS_Raise:SetText("All In");
			end;		
		end; 
		

	else
		--Its not our turn!
		FHS_Call:Hide();
		FHS_Raise:Hide();
		FHS_AllIn:Hide();
		FHS_Raise_Higher:Hide();
		FHS_Raise_Lower:Hide();
	end;
end;

function FHS_RaiseChange(dir)

	local CallAmount = 0;
	
	CallAmount = HighestBet-Seats[LocalSeat].bet;
	
	BetSize=BetSize+(dir*20);
	if (BetSize<20) then BetSize=20; end
	--if (HighestBet+BetSize>=Seats[LocalSeat].chips) then 
	if (BetSize>(Seats[LocalSeat].chips-CallAmount)) then
		BetSize=Seats[LocalSeat].chips-CallAmount; 
	end;
	FHS_UpdateWhosTurn();
end;

function FHS_SelectPlayerRing(j)

	--Hide everyones selection
	for r=1,9 do
		name="FHS_Seat_"..r.."_RingSelect";
		obj=getglobal(name)
		obj:Hide();
		name="FHS_Seat_"..r.."_Ring";
		obj=getglobal(name)
		obj:Show();

	end;


	if (j>0) then
		name="FHS_Seat_"..j.."_RingSelect";
		obj=getglobal(name)
		obj:Show();
		obj:SetAlpha(1);
		name="FHS_Seat_"..j.."_Ring";
		obj=getglobal(name)
		obj:Hide();

	end;
end

function FHS_SelectPlayerButton(j)

	--Hide everyones button
	for r=1,9 do
		name="FHS_Seat_"..r.."_Button";
		obj=getglobal(name)
		obj:Hide();

	end;

	if (j>0) then
		name="FHS_Seat_"..j.."_Button";
		obj=getglobal(name)
		obj:Show();

	end;
end


function FHS_UpdateButtons()

	if (LocalSeat==0) then
		return;
	end;

end;


function FHS_RunEvents()

	--belt them off
	size=getn(EventSpam);
	for key=1,size do 
		--DEFAULT_CHAT_FRAME:AddMessage(EventSpam[key].event..EventSpam[key].arg1 .. " || "..EventSpam[key].arg2);
		
		event=EventSpam[key].event;
		arg1=EventSpam[key].arg1;
		arg2=EventSpam[key].arg2;
		
		if (event=="CHAT_MSG_WHISPER") then
			if (arg1=="FHS_!seat") then

				--player tried to seat themselves.. assume they want to be a dealer
				if (arg2==UnitName("player")) then
					DEFAULT_CHAT_FRAME:AddMessage("Use just /holdem instead");
				else				
					if (IsDealer==1) then 
						--	DEFAULT_CHAT_FRAME:AddMessage(arg2);
						FHS_SendMessage("ping!",arg2);
					end;
				end

			else

				tab={};
				tab=Split(arg1,"_");

				if (table.getn(tab)>2) then
					--DEFAULT_CHAT_FRAME:AddMessage("Tab1: "..tab[1]);
					--DEFAULT_CHAT_FRAME:AddMessage("Tab2: "..tab[2]);
					--DEFAULT_CHAT_FRAME:AddMessage("Tab3: "..tab[3]);
					--check version
					if ((tab[1]=="FHS") and (tab[2]==FHS_HOLDEM_version)) then
						
						if (tab[3]=="pong!") then
							if (IsDealer==1) then
								FHS_SeatPlayer(arg2);
							end;
						end;
						
						if (tab[3]=="ping!") then
						
							--DEFAULT_CHAT_FRAME:AddMessage(DealerName.." "..arg2);
							
							if (IsDealer==0) then
								DealerName=arg2;
								FHS_SendMessage("pong!",arg2);
								DealerName="";

							end;
						end;

				
						if (tab[3]=="NoSeats") then
							--Noseats	
							--DEFAULT_CHAT_FRAME:AddMessage(DealerName.." ".."No Seat For"..arg2);	
						end

						if (tab[3]=="AlreadySeated") then
							--Already Seated.. spammer
							--DEFAULT_CHAT_FRAME:AddMessage(DealerName.." "..arg2.." is already seated");
						end

						if (tab[3]=="seat") then
							--We've Been Seated.. Clear our stats and await further messages
							--DEFAULT_CHAT_FRAME:AddMessage(DealerName.." "..arg2.." has been seated");
							
							LocalSeat=tonumber(tab[4]);
							DealerName=arg2;
							
							FHS_StartClient();
						end
						
						--Player Sits
						if (tab[3]=="s") then
							
							if (IsDealer==0) then
								--Update about a player
								j=tonumber(tab[4])
								Seats[j].seated=1;
								Seats[j].name=tab[5];
								Seats[j].chips=tonumber(tab[6]);
								Seats[j].bet=tonumber(tab[7]);

								FHS_UpdateSeat(j);
								DEFAULT_CHAT_FRAME:AddMessage(DealerName.." sits "..Seats[j].name.." in Seat "..j);
							end
						end

						--Player Status
						if (tab[3]=="st") then
							
							if (IsDealer==0) then
								--Update about a player
								j=tonumber(tab[4])
								
								Seats[j].chips=tonumber(tab[5]);
								Seats[j].bet=tonumber(tab[6]);
								Seats[j].status=tab[7];
								Seats[j].alpha=0.5; --tab[8]

								FHS_UpdateSeat(j);
								FHS_TotalPot();
								
							end
						end
						
						
						--Dealer Button
						if (tab[3]=="b") then
							--DEFAULT_CHAT_FRAME:AddMessage("Tab 4 "..tab[4]);
							if (IsDealer==0) then
								--tab[4] contains the player with the button
								j=tonumber(tab[4])
								
								FHS_SelectPlayerButton(j);
							end
							
						end			
						
						--Player sits in or out
						if (tab[3]=="inout") then
							--DEFAULT_CHAT_FRAME:AddMessage("Tab 4 "..tab[4]);
							--DEFAULT_CHAT_FRAME:AddMessage("Tab 5 "..tab[5]);
							
							j=tonumber(tab[4])
							Seats[j].inout=tab[5];
							
							if (IsDealer==1) then
								-- dealer tells everyone else about the change	
								FHS_BroadCast("inout_"..j.."_"..tab[5],LocalSeat);
								--DEFAULT_CHAT_FRAME:AddMessage("Broadcasting in/out: "..tab[5]);		
							else
								-- everyone who gets the message dims the player	
								--DEFAULT_CHAT_FRAME:AddMessage("receiving in/out: "..tab[5]);	
								Seats[j].alpha=0.5;
								Seats[j].status="Sitting Out";
								FHS_UpdateSeat(j);		
							end; 
							
						end;			
						
						-- Player is forced to sit out (timer)
						if (tab[3]=="forceout") then
							
							if (IsDealer==0) then
								DEFAULT_CHAT_FRAME:AddMessage("You did not act in time.  Press I'm Back to continue playing. ");
								FHS_SitOutInClick();
							end; 
							
						end;
						

						-- Player has Quit the game
						if (tab[3]=="q") then
							--Update about a player
							j=tonumber(tab[4])
							
							if (IsDealer==0) then
								Seats[j].seated=0;
								Seats[j].HavePort=0;
								if (IsPlaying(arg2)==1) then								
									FHS_UpdateSeat(j);
									DEFAULT_CHAT_FRAME:AddMessage(Seats[j].name.." has left the table.");
								end;

								if (j==LocalSeat) then
									
									DEFAULT_CHAT_FRAME:AddMessage("The dealer booted you.");
									FHS_StopClient();
								end
							
							else
								if (IsPlaying(arg2)==1) then								
																
									--Tell the other seats about the change
									FHS_BroadCast("q_"..j,j);
									DEFAULT_CHAT_FRAME:AddMessage(Seats[j].name.." has left the table.");
									Seats[j].seated=0;
									Seats[j].HavePort=0;
									FHS_UpdateSeat(j);
									if (WhosTurn==j) then
										FHS_GoNextPlayersTurn();
									end;
								end;
							end
						end

						-- Host has quit the game
						if (tab[3]=="hostquit") then
							
							if (IsDealer==0) then
								if (Dealer=="") then
								--gah
								else
									DEFAULT_CHAT_FRAME:AddMessage(DealerName.." has quit. GG.");
									FHS_StopClient();
								end;
							end;
						end;						


						-- Hole Cards
						if (tab[3]=="round0") then  --PRE FLOP
							if (IsDealer==0) then
								FHS_HideAllButtons();
								FHS_ClearCards();
							-- end;

								RoundCount=tonumber(tab[4]);
	
								--Clear status text
								for j=1,9 do
									Seats[j].bet=0;
									if(Seats[j].inout=="OUT") then
										Seats[j].status="Sitting Out";
										Seats[j].alpha=0.5;
									else
									    Seats[j].status="";
										Seats[j].alpha=0;
									end;
									FHS_UpdateSeat(j);
								end;
	
								BetSize=20;
								
								FHS_TotalPot();
	
								FHS_StatusText("");
							end;
							
						end;
		
						-- Your hole cards
						if (tab[3]=="hole") then
							if (IsDealer==0) then
								Seats[LocalSeat].hole1=tonumber(tab[4]);
								Seats[LocalSeat].hole2=tonumber(tab[5]);
								
								FHS_SetCard(Seats[LocalSeat].hole2,DealerX,DealerY, Seats[LocalSeat].x-12, Seats[LocalSeat].y+12,1,CC*DealerDelay,0,0);
								CC=CC-1;

								FHS_SetCard(Seats[LocalSeat].hole1,DealerX,DealerY, Seats[LocalSeat].x, Seats[LocalSeat].y,1,CC*DealerDelay,0,1);
								CC=CC-1;

								Seats[LocalSeat].status="Playing";
								Seats[LocalSeat].dealt=1;
								Seats[LocalSeat].alpha=1;
								FHS_UpdateSeat(LocalSeat);
								
								--Fold Button
								FHS_Fold:SetText("Fold");
								FHS_Fold:Show();

								FHS_StatusTextCards();
							end;
						end;
						
						--Other peoples hole cards
						if (tab[3]=="deal") then
							if (IsDealer==0) then
								
								j=tonumber(tab[4])

								FHS_SetCard(BlankCard,DealerX,DealerY, Seats[j].x-12 , Seats[j].y+12,1,CC*DealerDelay,500,0);	BlankCard=BlankCard+1;
								CC=CC-1
								
								FHS_SetCard(BlankCard,DealerX,DealerY, Seats[j].x , Seats[j].y,1,CC*DealerDelay,500,1);BlankCard=BlankCard+1;
								CC=CC-1;

								Seats[j].dealt=1;
								Seats[j].status="Playing";
								Seats[j].alpha=1;
								FHS_UpdateSeat(j);

							end;
						end;

						-- The Tables Flop (blanks)
						-- Note we record what blank cards we used, so we can clean them up when the flop is shown
						if (tab[3]=="flop0") then
							if (IsDealer==0) then
							
								FlopBlank[1]=BlankCard;
								FHS_SetCard(BlankCard,DealerX,DealerY, -CardWidth*2,0,1,CC*DealerDelay,0,0);	BlankCard=BlankCard+1;
								CC=CC-1;
								FlopBlank[2]=BlankCard;
								FHS_SetCard(BlankCard,DealerX,DealerY, -CardWidth*1,0,1,CC*DealerDelay,0,0);	BlankCard=BlankCard+1;
								CC=CC-1;
								FlopBlank[3]=BlankCard;
								FHS_SetCard(BlankCard,DealerX,DealerY, 0           ,0,1,CC*DealerDelay,0,0);	BlankCard=BlankCard+1;
								CC=CC-1;
								
							end;
						end;

						-- The Tables Flop (Real Cards)
						if (tab[3]=="flop1") then
							if (IsDealer==0) then
								
								Flop={};
								Flop[1]=tonumber(tab[4]);
								Flop[2]=tonumber(tab[5]);
								Flop[3]=tonumber(tab[6]);
								
								FHS_SetCard(Flop[1],DealerX,DealerY, -CardWidth*2,0,1,1,0,0);
								FHS_SetCard(Flop[2],DealerX,DealerY, -CardWidth*1,0,1,1,0,0);
								FHS_SetCard(Flop[3],DealerX,DealerY, 0           ,0,1,1,0,0);
								
								--Its possible to get here if they come in late
								if (getn(FlopBlank)>0) then
									FHS_SetCard(FlopBlank[1],0,0,0,0,0,0,0,0);
									FHS_SetCard(FlopBlank[2],0,0,0,0,0,0,0,0);
									FHS_SetCard(FlopBlank[3],0,0,0,0,0,0,0,0);
								end

								FlopBlank={};
								FHS_StatusTextCards();
							end;
						end;
						
						if (tab[3]=="turn") then
							if (IsDealer==0) then
								
								Flop[4]=tonumber(tab[4]);
								--DEFAULT_CHAT_FRAME:AddMessage("turn"..Flop[4]);
								FHS_SetCard(Flop[4],DealerX,DealerY, CardWidth*1,0,1,0,0,0);
								FHS_StatusTextCards();							
							end;
						end;

						if (tab[3]=="river") then
							if (IsDealer==0) then
								Flop[5]=tonumber(tab[4]);
								FHS_SetCard(Flop[5],DealerX,DealerY, CardWidth*2,0,1,0,0,0);
								FHS_StatusTextCards();							
							end;
						end;

						--Normal Showdown.. 1 or more winners cards will be visible
						if (tab[3]=="showdown") then
							--local view
							FHS_Call:Hide();
							FHS_Raise:Hide();
							FHS_AllIn:Hide();
							FHS_Raise_Higher:Hide();
							FHS_Raise_Lower:Hide();

							----- Locally, we might have already folded and still want to flash our cards
							----- Logically, the FHS_Fold button will already be hidden if we've shown already
							FHS_Fold:SetText("Show Cards");
							Seats[LocalSeat].dealt=0;
							---

							FHS_StatusText(tab[5]);

							j=tonumber(tab[4]);
							if (LocalSeat==j) then
								-- you won by default, you are allowed to flash your cards
								Seats[LocalSeat].dealt=0;
								
								FHS_Fold:SetText("Show Cards");
								FHS_Fold:Show();
							end;
						end;


						if (tab[3]=="show") then
							if (IsDealer==0) then
								j=tonumber(tab[6]);
								Seats[j].hole1=tonumber(tab[4]);
								Seats[j].hole2=tonumber(tab[5]);
								
								Seats[j].status=tab[7];
								
								Seats[j].dealt=0;

								--DEFAULT_CHAT_FRAME:AddMessage(Seats[j].hole1..Seats[j].hole2);				
								FHS_SetCard(Seats[j].hole1,DealerX,DealerY, Seats[j].x, Seats[j].y,1,1,0,1);
								FHS_SetCard(Seats[j].hole2,DealerX,DealerY, Seats[j].x-12, Seats[j].y+12,1,1,0,0);

								FHS_UpdateSeat(j);
							end;
						end;
						
						-- Player telling server he folded
						if (tab[3]=="fold") then
							if (IsDealer==1) then	
								j=tonumber(tab[4]);
								if (IsPlaying(arg2)==1) then
									if (Seats[j].dealt==1) then
										FHS_FoldPlayer(j);
									end;
								end
							end;
						end;

						-- Player telling server he actioned ( call, check, raise, all in)
						if (tab[3]=="call") then
							if (IsDealer==1) then	
								j=tonumber(tab[4]);
								if (IsPlaying(arg2)==1) then
									if (Seats[j].dealt==1) then
										FHS_PlayerAction(j,tonumber(tab[5]));
										
									end;
								end
							end;
						end;

						-- Player telling server he wants to flash his cards
						if (tab[3]=="showcards") then
							if (IsDealer==1) then	
								j=tonumber(tab[4]);
								rc=tonumber(tab[5]);
								if (IsPlaying(arg2)==1) then
									if (rc==RoundCount) then --Temporal bug... showcards were hitting on the next round
										
										--OutText,Handtype,BestCards=FHS_FindHandForPlayer(LocalSeat);
										--FHS_ShowCard(j,"("..OutText..")");
										
										FHS_ShowCard(j,"Showing");

									end;
								end
							end;
						end;


						--Server saying whos turn it is
						if (tab[3]=="go") then
							if (IsDealer==0) then
								j=tonumber(tab[4]);
								HighestBet=tonumber(tab[5]);
								WhosTurn=j;
								FHS_UpdateWhosTurn();
								
							end;
						end;

					end
				end
			end
			
		end
	end
	
	--clear it
	if (size>0) then
		EventSpam={};
	end
end

function IsPlaying(name)

	for j=1,9 do
		if (Seats[j].seated==1 and Seats[j].name==name) then
			return 1;
		end;
	end;
	return 0;
end;



function FHS_SendMessage(message,username)

	if ((IsDealer==0) and (DealerName=="")) then 
		return; 
	end
	
	SendAddonMessage("HoldemRaid", username.." FHS_".. FHS_HOLDEM_version.."_"..message, "RAID")
	SendAddonMessage("HoldemGuild", username.." FHS_".. FHS_HOLDEM_version.."_"..message, "GUILD")
--	SendChatMessage("FHS_".. FHS_HOLDEM_version.."_"..message,"WHISPER",nil,username);

end;	

function FHS_PlayClick()

--	FHSPokerFrame:SetScale(0.75);
	if (IsDealer==0) then
		return;
	end;

	if (GameLevel==5) then
		GameLevel=0;
	end;
	if (GameLevel==0) then
		FHS_NextLevel();
	end;
end;



function FHS_NextLevel()
	
	GameLevel=GameLevel+1;
	--DEFAULT_CHAT_FRAME:AddMessage("GL:".. GameLevel);
	
	if (GameLevel==1) then  --Pre Flop
			
		FHS_DealHoleCards();
		
		return;
	end;

	if (GameLevel==2) then
			
	
		FHS_ShowFlopCards();
		return;
	end
	if (GameLevel==3) then
			
	
		FHS_DealTurn();
		return;
	end
	if (GameLevel==4) then
			
	
		FHS_DealRiver();
		return;
	end
	if (GameLevel==5) then
			
	
		FHS_ShowDown();
		return;
	end
end;



-------------   SERVER NETWORKING ---------------------------------



function FHS_StartDealer()
	
	DEFAULT_CHAT_FRAME:AddMessage("You are now a dealer.");
	LocalSeat=1;
	IsDealer=1;
	TheButton=LocalSeat;
	DealerName="";

	FHS_ClearTable();


	Seats[LocalSeat].name=UnitName("player");
	Seats[LocalSeat].seated=1;
	Seats[LocalSeat].chips=500;
	FHS_UpdateSeat(LocalSeat);
	GameLevel=0;
	
	FHSPokerFrame:Show();
	
	FHS_Play:Show();
	
	--Set the initial Blinds
	Blinds=20;	
end;


function FHS_StopServer()

	--bump everyone off
	FHS_BroadCast("hostquit",-1);

	IsDealer=0;
	LocalSeat=0;
	WhosTurn=0;
	
	FHS_ClearTable();
end


function FHS_FoldPlayer(j)

	
	if (IsDealer==0) then return; end;
	
	if (Seats[j].seated==0) then return; end;
	
	if (Seats[j].dealt==0) then return; end;	
	
	
	--FHS_ShowCard(j,"Folded");

	FHS_BroadCast("st_"..j.."_"..Seats[j].chips.."_"..Seats[j].bet.."_Folded_0.5",0);
	
	Seats[j].dealt=0;
	Seats[j].forcedbet=0; --player has had their bet
	Seats[j].alpha=0.5;
	Seats[j].status="Folded";
	FHS_UpdateSeat(j);

	--if it was their turn when they folded, next turn.
	if (WhosTurn==j) then
		FHS_GoNextPlayersTurn();
	else
		--It Wasn't their turn.. but them folding may have ended the game anyway
		if (FHS_GetPlayingPlayers()==1) then
			--Notify the player their turn go canceled
			
			FHS_GoNextPlayersTurn();
		end;
	end;
end;

function FHS_TotalPot()
	total=0;
	for j=1,9 do
		if (Seats[j].seated==1) then
			total=total+Seats[j].bet;
		end;
	end;
	if (total==0) then
		FHS_Pot_Text:SetText("WoW Texas Hold'em");
	else
		FHS_Pot_Text:SetText("Total Pot: "..total);
	end;

	return total;
end;

--Loop through all seats, add up everyone who has bet less then this
function FHS_SidePot(bet)
	total=0;
	for j=1,9 do
		if (Seats[j].seated==1) then
			r=Seats[j].bet;
			if (r>bet) then r=bet; end;
			total=total+r;
		end;
	end;

	return total;
end;


function FHS_DealHoleCards()
	
	if (IsDealer==0) then
		return;
	end;
	

	--Initialize the shuffle array
	for j=1, 52 do
		Shuffle[j]=j;
	end;

	seed=GetTime()*1000;
	seed=FHS_round(seed,0);
	
	FHS_Shuffle(seed);
	--FHS_FakeShuffle();

	-- Set the dealers card to 1
	DealerCard=1;
	BlankCard=53;

	BetSize=20;
	SidePot={};
	
	-- Clear the dealers visuals
	FHS_ClearCards();

	--Tell everyone Round 0 is beginning
	RoundCount=RoundCount+1;
	FHS_BroadCast("round0_"..RoundCount,-1);

	FHS_StatusText("");

	--Deal out the hole cards
	for index=1,9 do
		
		j=TheButton+index+1;  -- Player after the button gets dealt first
		if (j>9) then j=j-9; end;
		if (j>9) then j=j-9; end;
		
		--Set up a blank hand
		Seats[j].bet=0;
		Seats[j].hole1=0;
		Seats[j].hole2=0;
		Seats[j].forcedbet=0;
		if(Seats[j].inout=="IN") then
			Seats[j].status="";
		else
			Seats[j].status="Sitting Out";
		end;

		--Deal them in
		if ((Seats[j].seated==1)and(Seats[j].chips>0)and(Seats[j].inout=="IN")) then
		
			--If dealing to a player..
			Seats[j].hole1=Shuffle[DealerCard];	DealerCard=DealerCard+1;
			Seats[j].hole2=Shuffle[DealerCard]; DealerCard=DealerCard+1;
			Seats[j].dealt=1;
			Seats[j].bet=0;
			Seats[j].alpha=0.5;
			Seats[j].forcedbet=1;
			Seats[j].status="Playing";


			FHS_UpdateSeat(j); -- local view

			if (j==LocalSeat) then
				
				-- Local Graphics ------------------------------------------
				FHS_SetCard(Seats[LocalSeat].hole2,DealerX,DealerY, Seats[LocalSeat].x-12, Seats[LocalSeat].y+12,1,CC*DealerDelay,0,0);
				CC=CC-1;

				FHS_SetCard(Seats[LocalSeat].hole1,DealerX,DealerY, Seats[LocalSeat].x, Seats[LocalSeat].y,1,CC*DealerDelay,0,1);
				CC=CC-1;
				
				--enable the fold button
				Seats[j].alpha=1;
				FHS_Fold:SetText("Fold");
				FHS_Fold:Show();
				FHS_StatusTextCards();
				------------------------------------------------------------
				
				FHS_BroadCast("deal_"..j,j);
				
				
			else
				-- Local Graphics ------------------------------------------
				FHS_SetCard(BlankCard,DealerX,DealerY, Seats[j].x-12 , Seats[j].y+12,1,CC*DealerDelay,500,0);	BlankCard=BlankCard+1;
				CC=CC-1

				FHS_SetCard(BlankCard,DealerX,DealerY, Seats[j].x , Seats[j].y,1,CC*DealerDelay,500,1);BlankCard=BlankCard+1;
				CC=CC-1;
				
				Seats[j].alpha=1;
				------------------------------------------------------------
				
				FHS_SendMessage("hole_"..Seats[j].hole1 .."_"..Seats[j].hole2,Seats[j].name);
				FHS_BroadCast("deal_"..j,j);
			end;
		else
			if (Seats[j].chips<1) then
				--they're sitting out due to lack of chips
				Seats[j].hole1=0;
				Seats[j].hole2=0;
				Seats[j].dealt=0;
				Seats[j].bet=0;
				Seats[j].forcedbet=0;
				Seats[j].status="";
				FHS_UpdateSeat(j); -- local view
			end;
			if (Seats[j].inout=="OUT") then
				--they're sitting out because they want to 
				Seats[j].hole1=0;
				Seats[j].hole2=0;
				Seats[j].dealt=0;
				Seats[j].bet=0;
				Seats[j].forcedbet=0;
				Seats[j].alpha=0.5;
				Seats[j].status="Sitting Out";
				FHS_UpdateSeat(j); -- local view
			end;

			
		end;	

		
	end



	--Deal out the flop
	
	DealerFlop={};
	DealerFlop[1]=Shuffle[DealerCard]; DealerCard=DealerCard+1;
	DealerFlop[2]=Shuffle[DealerCard]; DealerCard=DealerCard+1;
	DealerFlop[3]=Shuffle[DealerCard]; DealerCard=DealerCard+1;
	DealerFlop[4]=Shuffle[DealerCard]; DealerCard=DealerCard+1;
	DealerFlop[5]=Shuffle[DealerCard]; DealerCard=DealerCard+1;
	

	FHS_BroadCast("flop0",-1);
	Flop={};

	-- Local Graphics ------------------------------------------
	FlopBlank[1]=BlankCard;
	FHS_SetCard(BlankCard,DealerX,DealerY, -CardWidth*2,0,1,CC*DealerDelay,0,0);	BlankCard=BlankCard+1;
	CC=CC-1;
	
	FlopBlank[2]=BlankCard;
	FHS_SetCard(BlankCard,DealerX,DealerY, -CardWidth*1,0,1,CC*DealerDelay,0,0);	BlankCard=BlankCard+1;
	CC=CC-1;
	
	FlopBlank[3]=BlankCard;
	FHS_SetCard(BlankCard,DealerX,DealerY, 0           ,0,1,CC*DealerDelay,0,0);	BlankCard=BlankCard+1;
	CC=CC-1;
	------------------------------------------------------------

	-- set the button
	TheButton=FHS_WhosButtonAfter(TheButton);
	
	--DEFAULT_CHAT_FRAME:AddMessage("The Button "..TheButton);
	FHS_BroadCast("b_"..TheButton,-1);
	FHS_SelectPlayerButton(TheButton);
	
	FHS_SetupBets();
	FHS_PostBlinds();

end;


--let everyone playing have at least 1 turn
function FHS_SetupBets()
	for j=1,9 do
		if ((Seats[j].seated==1) and (Seats[j].dealt==1) and (Seats[j].inout=="IN")) then
			Seats[j].forcedbet=1;
		end;
	end;
end;




function FHS_ShowFlopCards()
	if (IsDealer==0) then
		return;
	end;

	Flop={};

	Flop[1]=DealerFlop[1];
	Flop[2]=DealerFlop[2];
	Flop[3]=DealerFlop[3];

	FHS_BroadCast("flop1_"..Flop[1].."_"..Flop[2].."_"..Flop[3],-1);

	--Local View --------------
	FHS_SetCard(Flop[1],DealerX,DealerY, -CardWidth*2,0,1,1,0,0);
	FHS_SetCard(Flop[2],DealerX,DealerY, -CardWidth*1,0,1,1,0,0);
	FHS_SetCard(Flop[3],DealerX,DealerY, 0           ,0,1,1,0,0);
	
	FHS_SetCard(FlopBlank[1],0,0,0,0,0,0,0,0);
	FHS_SetCard(FlopBlank[2],0,0,0,0,0,0,0,0);
	FHS_SetCard(FlopBlank[3],0,0,0,0,0,0,0,0);	
	
	FHS_StatusTextCards();							
	----------------------

	FHS_SetupBets();
	WhosTurn=TheButton;
	FHS_GoNextPlayersTurn();
end

function FHS_DealTurn()
	if (IsDealer==0) then
		return;
	end;

	Flop[4]=DealerFlop[4];

	FHS_BroadCast("turn_"..Flop[4],-1);

	--Local View --------------
	FHS_SetCard(Flop[4],DealerX,DealerY, CardWidth*1,0,1,0,0,0);
	CC=CC-1;
	FHS_StatusTextCards();							
	---------------------------

	FHS_SetupBets();
	WhosTurn=TheButton;
	FHS_GoNextPlayersTurn();
end

function FHS_DealRiver()

	if (IsDealer==0) then
		return;
	end;

	Flop[5]=DealerFlop[5];

	FHS_BroadCast("river_"..Flop[5],-1);

	--Local View --------------
	FHS_SetCard(Flop[5],DealerX,DealerY, CardWidth*2,0,1,0,0,0);
	CC=CC-1;
	FHS_StatusTextCards();							
	---------------------------

	FHS_SetupBets();
	WhosTurn=TheButton;
	FHS_GoNextPlayersTurn();

end

function FHS_ShowDown()

	if (IsDealer==0) then
		return;
	end;
	
	--Start Timer til next hand
	DealerTimer=GetTime()+5;


	--local view
	FHS_Call:Hide();
	FHS_Raise:Hide();
	FHS_AllIn:Hide();
	FHS_Raise_Higher:Hide();
	FHS_Raise_Lower:Hide();

	--Determine everyones hand
	pot=FHS_TotalPot();
	Winners={};	

	--Ok, well, we work out our sidepots
	--DEFAULT_CHAT_FRAME:AddMessage("SidePots 1: "..getn(SidePot));
	--Correct our sidepots with the last info
	if (getn(SidePot)==0) then
		SidePot[1]={bet=FHS_HighestBet(),pot=FHS_TotalPot()};
	end;

	found=0;
	for j=1,getn(SidePot) do
		if (SidePot[j].bet==FHS_HighestBet()) then
			found=1;
		end;
	end;
	if (found==0) then
		SidePot[getn(SidePot)+1]={bet=FHS_HighestBet(),pot=FHS_TotalPot()};
	end;


--	DEFAULT_CHAT_FRAME:AddMessage("SidePots a: "..getn(SidePot));
    sort(SidePot, function (a,b)
      return (a.pot < b.pot)  end)
	
--	DEFAULT_CHAT_FRAME:AddMessage("SidePots b: "..getn(SidePot));
	
	for j=1,getn(SidePot) do
--		DEFAULT_CHAT_FRAME:AddMessage("in pot: bet:"..SidePot[j].bet.." pot:"..SidePot[j].pot);
	end;

	--fix the pots
	temp={};
	temp[1]=SidePot[1].pot;
	
	for j=2,getn(SidePot) do
		temp[j]=SidePot[j].pot - SidePot[j-1].pot;
	end
	for j=1,getn(SidePot) do
		SidePot[j].pot = temp[j];
	end


	for j=1,getn(SidePot) do
--		DEFAULT_CHAT_FRAME:AddMessage("out pot: bet:"..SidePot[j].bet.." pot:"..SidePot[j].pot);
	end;
    

	if (FHS_GetPlayingPlayers()==1) then
		--Hand fizzled, everyone but one person folded..
		--so we don't tell anyone what he had and do the winner stuff that way.
		
		for j=1,9 do
			--give the winner the chips
			if ((Seats[j].seated==1)and(Seats[j].dealt==1)) then
				Winners[1]=j;
			end;
		end;
		
				
		--------------------------------------------------------------
		for r=1,getn(SidePot) do
			
			winnercount=0;
			for j=1,getn(Winners) do
				if (Seats[Winners[j]].bet>=SidePot[r].bet) then
					winnercount=winnercount+1;
				end;
			end;
								
			if (winnercount>0) then
				pot=FHS_round((SidePot[r].pot) / winnercount,0);
				
			for j=1,getn(Winners) do
					if (Seats[Winners[j]].bet>=SidePot[r].bet) then
						Seats[Winners[j]].chips=Seats[Winners[j]].chips+pot;
						Seats[Winners[j]].dealt=0;
					end;
				end						
			else
				-- There were no winners of this pot, split it and give it back
				winnercount=0;
				for j=1,9 do
					if ((Seats[j].bet>=SidePot[r].bet)and(Seats[j].seated==1)) then
						winnercount=winnercount+1;
					end;
				end;

				for j=1,9 do
					
					pot=FHS_round((SidePot[r].pot) / winnercount,0);
					--Player bet into that 
					if ((Seats[j].seated==1)and(Seats[j].bet>=SidePot[r].bet)) then
						
						Seats[j].chips=Seats[j].chips+pot;
						FHS_BroadCast("st_"..j.."_"..Seats[j].chips.."_"..Seats[j].bet.."_"..Seats[j].status.."_0.5");
					
						FHS_ShowCard(j,pot.." returned");
						Seats[j].dealt=0;

						--Local View
						FHS_UpdateSeat(j);
					end;
				end;
			end;
			
		end;
		--------------------------------------------------------------

		j=Winners[1];
		Seats[j].status="Default";
		FHS_BroadCast("st_"..j.."_"..Seats[j].chips.."_"..Seats[j].bet.."_"..Seats[j].status.."_1");
		text=Seats[j].name.." wins.";
		FHS_BroadCast("showdown_"..j.."_"..text);

		if (j==LocalSeat) then  --dealer won
			Seats[LocalSeat].dealt=0;
			Seats[LocalSeat].alpha=1;
			
			FHS_Fold:SetText("Show Cards");
			FHS_Fold:Show();
		end;

		FHS_StatusText(text);
		return;			
	end;




	for j=1,9 do
		Seats[j].OutText={};
		Seats[j].Handtype={};
		Seats[j].BestCards={};
		Seats[j].Kicker={};

		if (Seats[j].seated==0) then
			Seats[j].dealt=0;
		end;

		if ((Seats[j].dealt==1)and(Seats[j].seated==1)) then
			Seats[j].OutText,Seats[j].Handtype,Seats[j].BestCards,Seats[j].Kicker=FHS_FindHandForPlayer(j);
			
		end;

	end;

	--Work out the "winners"

	-- Best hand is?
	Best=0;
	index=0;
	
	for j=1,9 do
		if (Seats[j].dealt==1) then
			if (Seats[j].Handtype>Best) then
				Best=Seats[j].Handtype;
				index=j;
			end;
		end;
	end;

	--Winners, index who is a contender.  Look at their hand again and determine the winner.

	for j=1,9 do
		if (Seats[j].dealt==1) then
			if (Seats[j].Handtype==Best) then
				Winners[getn(Winners)+1]=j;
			end;
		end;
	end;

	-- More then 1 person has the highest hand 
	if (getn(Winners)>1) then

		--What can occur here is we need to look at what sort of hand it is
		--and start eliminating people
		
		--	"High Card",	
		--	"2 of a Kind",	
		--	"2 Pair",		
		--	"3 of a Kind",	
		--	"Straight",		
		--	"Flush",		
		--	"Full House",	
		--	"4 of a Kind",	
		--	"Flush Straight"
		--	"Royal Flush",	
	
		for j=1,getn(Winners) do
			
			--This is refering to rank only at this point.
			--High card, highest card
			--2 of a kind, highest card
			--2 pair, highest card
			--3 of a Kind, highest card
			
			SuitCheck=0;
			KickerCheck=0;
			Seats[Winners[j]].JudgeCard=FHS_HandHighCard(Seats[Winners[j]].BestCards);
			
						--or(Best==2)or(Best==3)or(Best==4)
			
			--High card
			if (Best==1) then
				
				SuitCheck=0;
				KickerCheck=4;  -- 4 kickers play
			end;

			--2 of a kind
			if (Best==2) then
				
				SuitCheck=0;
				KickerCheck=3;  -- 3 kickers play
			end;

			--2 pair
			if (Best==3) then
				
				SuitCheck=0;
				KickerCheck=1; -- 1 kickers play
			end;
			
			--3 of a kind
			if (Best==4) then
				
				SuitCheck=0;
				KickerCheck=2; -- 2 kickers play

			end;
			
			-- Straight
			if (Best==5) then
				
				KickerCheck=0;
				SuitCheck=0;
			end;
			
			-- "Flush" 
			if (Best==6) then
				
				SuitCheck=0;
				KickerCheck=0;
			end;

			-- "Full house" 
			if (Best==7) then
				
				SuitCheck=0;
				KickerCheck=0;
			end;

			-- 4 of a kind 
			if (Best==8) then
				SuitCheck=0;
				KickerCheck=1;
			end;
			
			-- Flush Straight - Highest Card, Highest Suit
			if (Best==9) then
				SuitCheck=1;
				KickerCheck=0;
			end;
			
			-- Royal Flush 
			if (Best==10) then
				SuitCheck=1;
				KickerCheck=0;
			end;
		
			
		end;
	
		--DEFAULT_CHAT_FRAME:AddMessage("Best: " .. Best .. " SuitCheck:" .. SuitCheck);
		
				
		HighRank=0;
		--Find
		for j=1,getn(Winners) do
			rank=Cards[Seats[Winners[j]].JudgeCard].rank;
			if (rank>HighRank) then
				HighRank=rank;
			end;
		end;
		
		--DEFAULT_CHAT_FRAME:AddMessage("HighRank: " .. HighRank);
		-- Delete
		NewWinners={};
		for j=1,getn(Winners) do
			rank=Cards[Seats[Winners[j]].JudgeCard].rank;
		--	DEFAULT_CHAT_FRAME:AddMessage("rank: ".. rank .. "card:"..Seats[Winners[j]].JudgeCard);
			if (rank==HighRank) then
				NewWinners[getn(NewWinners)+1]=Winners[j];				
			end;
		end;
		Winners=NewWinners;
		
		--for j=1,getn(Winners) do			
		--	DEFAULT_CHAT_FRAME:AddMessage("win: ".. Winners[j]);
		--end;
		

		--Special Case for Full House, 2 Pair.
		if ((Best==3)or(Best==8)) then
			if (getn(Winners)>1) then

				-- If more then 1 player has the same High 3 cards (or pair) check the low pair
				for j=1,getn(Winners) do
					--DEFAULT_CHAT_FRAME:AddMessage("jc: ".. getn(Seats[Winners[j]].BestCards));
					Seats[Winners[j]].JudgeCard=Seats[Winners[j]].BestCards[4];
					SuitCheck=0;					
				end;

				HighRank=0;
				--Find
				for j=1,getn(Winners) do
					rank=Cards[Seats[Winners[j]].JudgeCard].rank;
					if (rank>HighRank) then
						HighRank=rank;
					end;
				end;

				NewWinners={};
				for j=1,getn(Winners) do
					rank=Cards[Seats[Winners[j]].JudgeCard].rank;
					if (rank==HighRank) then
						NewWinners[getn(NewWinners)+1]=Winners[j];				
					end;
				end;

				Winners=NewWinners;
			end;
		end



		--Special Case for kicker checks
		if ((KickerCheck>0)and(getn(Winners)>1)) then

			done=false;
			while done==false do
				HighRank=0;
				--Find
				
				
				for j=1,getn(Winners) do
					Kicker=FHS_HandHighCard( Seats[ Winners[j] ].Kicker );
					rank=Cards[Kicker].rank;
					if (rank>HighRank) then
						HighRank=rank;
					end;
				end;

				NewWinners={};
				for j=1,getn(Winners) do
					Kicker=FHS_HandHighCard(Seats[Winners[j]].Kicker);
					rank=Cards[Kicker].rank;
					if (rank==HighRank) then
						NewWinners[getn(NewWinners)+1]=Winners[j];				
						
						--Remove the high card, continue
						Punt={};
						Punt[1]=FHS_HandHighCard(Seats[Winners[j]].Kicker);
						Seats[Winners[j]].Kicker=FHS_CardListSubtractAfromB(Punt,Seats[Winners[j]].Kicker);
					end;
				end;
				Winners=NewWinners;
			

				if (getn(Seats[Winners[1]].Kicker)==0) then
					done=true;
					--Its a split.
				end;
				if (getn(Winners)==1) then
					done=true;
					--Kicker found
				end;
				
				KickerCheck=KickerCheck-1;
				if (KickerCheck<=0) then
					done=true;  -- we ran out of kickers to consider.
				end;
				

			end;
			
		end



		if ((getn(Winners)>1)and(SuitCheck==1)) then 	--Any winners left now have the same rank, and so its down to suit

			HighSuit=0
		
			-- Find
			for j=1,getn(Winners) do
				suit=Cards[Seats[Winners[j]].JudgeCard].suit;
			
				if (suit>HighSuit) then
					HighSuit=suit;
				end;
			end;

			-- Delete
			NewWinners={};
			for j=1,getn(Winners) do
				suit=Cards[Seats[Winners[j]].JudgeCard].suit;
				if (suit==HighSuit) then
					NewWinners[getn(NewWinners)+1]=Winners[j];	
				end;
			end;
			Winners=NewWinners;

		end;
	end;


	
	if (getn(Winners)>0) then
		--DEFAULT_CHAT_FRAME:AddMessage("newcode");
		--Go through the side pots.
			-- Find out who won a piece of it.
				-- Hand it out

		--Go to next side pot.. subtract the what? exactly?


		if (getn(Winners)==1) then
			text=Seats[ Winners[1] ].name.." wins. "..Seats[Winners[1]].OutText;
		else
			text="Split. "..Seats[Winners[1]].OutText;
		end;
		

		for r=1,getn(SidePot) do
			
			winnercount=0;
			
			for j=1,getn(Winners) do
				if (Seats[Winners[j]].bet>=SidePot[r].bet) then
					winnercount=winnercount+1;
				end;
			end;
							
			if (winnercount>0) then
				pot=FHS_round((SidePot[r].pot) / winnercount,0);
				

				for j=1,getn(Winners) do
					
					if (Seats[Winners[j]].bet>=SidePot[r].bet) then

						--DEFAULT_CHAT_FRAME:AddMessage("win: "..Winners[j].." pot:"..pot.." betted:"..Seats[Winners[j]].bet);
						Seats[Winners[j]].chips=Seats[Winners[j]].chips+pot;
			
						FHS_BroadCast("st_"..Winners[j].."_"..Seats[Winners[j]].chips.."_"..Seats[Winners[j]].bet.."_"..Seats[Winners[j]].status.."_1");
					
						FHS_ShowCard(Winners[j],"Winner!");
						Seats[Winners[j]].dealt=0;

						--Local View
						FHS_UpdateSeat(Winners[j]);
					end;
				end						
				
			else
				-- There were no winners of this pot, split it and give it back
				--DEFAULT_CHAT_FRAME:AddMessage("No winners of: "..SidePot[r].pot);
			
				winnercount=0;
				for j=1,9 do
					if ((Seats[j].bet>=SidePot[r].bet)and(Seats[j].seated==1)) then
						winnercount=winnercount+1;
					end;
				end;

	
				--DEFAULT_CHAT_FRAME:AddMessage("people who bet that much:"..winnercount);
				
				for j=1,9 do
					
					pot=FHS_round((SidePot[r].pot) / winnercount,0);
					--Player bet into that 
					if ((Seats[j].seated==1)and(Seats[j].bet>=SidePot[r].bet)) then
						
						Seats[j].chips=Seats[j].chips+pot;
						--DEFAULT_CHAT_FRAME:AddMessage(j..":"..pot)
						FHS_BroadCast("st_"..j.."_"..Seats[j].chips.."_"..Seats[j].bet.."_"..Seats[j].status.."_0.5");
					
						FHS_ShowCard(j,pot.." returned");
						Seats[j].dealt=0;

						--Local View
						FHS_UpdateSeat(j);
					end;
				end;

			end;
		end;

	else
		text="No Winners. Game Seed = "..RandomSeed;

		--Return their cash
		for j=1,9 do
			if ((Seats[j].seated==1)and(Seats[j].bet>0)) then
				Seats[j].chips=Seats[j].chips+Seats[j].bet;
				FHS_UpdateSeat(j);
				Seats[j].status="";
				FHS_BroadCast("st_"..j.."_"..Seats[j].chips.."_"..Seats[j].bet.."_"..Seats[j].status.."_1");
			end
		end;
	end;

	FHS_BroadCast("showdown_0_"..text);
	FHS_StatusText(text);

	
	for j=1,9 do
		-- If you're still in at this point, you have to show your hand
		if (Seats[j].dealt==1) then
			FHS_ShowCard(j,"Showdown");
		end
	end


	--We may still want to flash our cards, even if we've folded
	FHS_Fold:SetText("Show Cards");
	Seats[LocalSeat].dealt=0;
	-------------------------------------------------

end

function FHS_round( num, idp )
	return tonumber( string.format("%."..idp.."f", num ) )
end


function FHS_ShowCard(j,status)

	if ((Seats[j].seated==1)) then
		
		Seats[j].status=status;
		
		if ((Seats[j].hole1==0)or(Seats[j].hole2==0)) then 
		
			DEFAULT_CHAT_FRAME:AddMessage("Error case");
			return; 
		end;
		
		
		if (IsDealer==1) then
			FHS_BroadCast("show_"..Seats[j].hole1 .."_"..Seats[j].hole2.."_"..j.."_"..status,j);
		end;

		--- Local Graphics
		FHS_SetCard(Seats[j].hole2,DealerX,DealerY, Seats[j].x-12, Seats[j].y+12,1,1,0,0);
		FHS_SetCard(Seats[j].hole1,DealerX,DealerY, Seats[j].x, Seats[j].y,1,1,0,1);

		FHS_UpdateSeat(j);
	end
end



function FHS_BroadCast(message,skip)
	if (IsDealer==0) then
		return;
	end

	for j=1,9 do
		if ((j==LocalSeat) or(j==skip) or (Seats[j].seated==0))  then 
			--no good
		else
			FHS_SendMessage(message,Seats[j].name);
		end
	end

end;




function FHS_Shuffle(seed)

	RandomSeed=seed;
	randomseed(seed);

	--Initialize the shuffle array
	for j=1, 52 do
		Shuffle[j]=j;
	end;

	--Shuffle each card once
	for j=1, 52 do
		newspot=random(52);

		temp=Shuffle[j];
		Shuffle[j]=Shuffle[newspot];
		Shuffle[newspot]=temp;
	end;

	--debug shuffle
	if (0==1) then
		for j=1, 52 do
			DEFAULT_CHAT_FRAME:AddMessage(Shuffle[j]);
		end;
	end;
end


function FHS_FakeShuffle()

	RandomSeed=1;
	Clubs=0;
	Diamonds=13;
	Hearts=13+13;
	Spades=13+13+13;
		

	--Initialize the shuffle array
	for j=1, 52 do
		Shuffle[j]=j;
	end;

	--Shuffle each card once
	for j=1, 52 do
		newspot=random(52);

		temp=Shuffle[j];
		Shuffle[j]=Shuffle[newspot];
		Shuffle[newspot]=temp;
	end;

	Shuffle[1]=11+Diamonds;  --p1
	Shuffle[2]=10+Diamonds;  
	Shuffle[3]=10+Hearts; --flop
	Shuffle[4]=9+Hearts;
	Shuffle[5]=1+Clubs; 
	Shuffle[6]=1+Spades;
	Shuffle[7]=1+Diamonds;
	Shuffle[8]=1+Spades;
	Shuffle[9]=12;


	

end



function FHS_SeatPlayer(name)
	
	found=-1;
	foldplayer=0;
	
	--Try and find the player
	for j=1,9 do
		if (Seats[j].seated==1) and (Seats[j].name==name) then
			found=-2; --player is already seated
			break;
		end
		if (Seats[j].seated==0) then
			found=j;
		end
	end

	if (found==-1) then
		SendAddonMessage("HoldemRaid", name.." FHS_".. FHS_HOLDEM_version .. "_NoSeats", "RAID")
		SendAddonMessage("HoldemGuild", name.." FHS_".. FHS_HOLDEM_version .. "_NoSeats", "GUILD")
		--SendChatMessage("FHS_".. FHS_HOLDEM_version .. "_NoSeats","WHISPER",nil,name);
		return;
	end
	
	if (found==-2) then
		--SendChatMessage("FHS_".. FHS_HOLDEM_version .. "_AlreadySeated","WHISPER",nil,name);
		--Reseat the player.				
			
		--return;
		for j=1,9 do
			if (Seats[j].seated==1) and (Seats[j].name==name) then
				found=j; --player is already seated
				break;
			end
		end
	
		if (Seats[found].dealt==1) then 	
			foldplayer=found;
		end;
	else
		Seats[found].seated=1;
		Seats[found].name=name;
		Seats[found].dealt=0;
		Seats[found].chips=500; --Sit with 500 chips  - eventually will be a dealer option
	end;
	
	FHS_UpdateSeat(found);

	--seat them
	SendAddonMessage("HoldemRaid", name.." FHS_".. FHS_HOLDEM_version .. "_seat_"..found, "RAID")
	SendAddonMessage("HoldemGuild", name.." FHS_".. FHS_HOLDEM_version .. "_seat_"..found, "GUILD")
	--SendChatMessage("FHS_".. FHS_HOLDEM_version .. "_seat_"..found,"WHISPER",nil,name);

	--Tell them about Everyone
	for j=1,9 do
		if (Seats[j].seated==1) then
			FHS_SendMessage("s_"..j.."_"..Seats[j].name.."_"..Seats[j].chips.."_"..Seats[j].bet,name)
		end
	end

	--Tell the other seats about the change
	FHS_BroadCast("s_"..found.."_"..Seats[found].name.."_"..Seats[found].chips.."_"..Seats[found].bet,found);


	if (foldplayer>0) then 
		FHS_FoldPlayer(foldplayer);
	end;



	--  Todo: if we're not on GameLevel==1, we have other things to tell them about
	--		  like blank/flop cards, showdowns, etc
end;



--Returns the next player to take a turn after j.
--It will return j if theres nobody 
function FHS_WhosTurnAfter(j)
	
	for r=1,9 do
		index=j+r;
		if (index>9) then index=index-9; end;
		if (index>9) then index=index-9; end;

		if ((Seats[index].seated==1)and(Seats[index].dealt==1)and(Seats[index].chips>0)and(Seats[index].inout=="IN")) then
			return index;
		end;
	end;

	return j;		
end;

--Returns the next player to take the button
--It will return j if theres nobody 
function FHS_WhosButtonAfter(j)
	
	for r=1,9 do
		index=j+r;
		if (index>9) then index=index-9; end;
		if (index>9) then index=index-9; end;

		if ((Seats[index].seated==1)and(Seats[index].chips>0)and(Seats[index].inout=="IN")) then
			return index;
		end;
	end;

	return j;		
end;


--Returns the next player who needs to bet after j. 
-- You need to bet if you were forced to post blinds, or if you are below the current highest
--It will return 0 if theres nobody 
function FHS_WhosBetAfter(j)
	
	maxbet=FHS_HighestBet();
	--
	for r=1,9 do
		index=j+r;
		if (index>9) then index=index-9; end;
		if (index>9) then index=index-9; end;

		if ((Seats[index].seated==1)and(Seats[index].dealt==1)and(Seats[index].chips>0)) then
		
			if ((Seats[index].bet<maxbet) or (Seats[index].forcedbet==1)) then
				return index;
			end;
		end;
	end;

	return 0;		
end;

function FHS_HighestBet()

	maxbet=0;
	--Find out what the highest bet on the table 
	for r=1,9 do
		if ((Seats[r].seated==1)and(Seats[r].dealt==1)) then
			if (Seats[r].bet>maxbet) then
				maxbet=Seats[r].bet;
			end;
		end
	end;
	return maxbet;
end;

function FHS_GetPlayingPlayers()
	
	j=0;
	for r=1,9 do
		if ((Seats[r].seated==1)and(Seats[r].dealt==1)) then
			j=j+1;
		end;
	end;

	return j;		
end;

function FHS_GetSeatedPlayers()
	
	j=0;
	for r=1,9 do
		if ((Seats[r].seated==1)) then
			j=j+1;
		end;
	end;

	return j;		
end;


function FHS_PostBlinds()
	
	if (IsDealer==0) then 
		return; 
	end;
	
	pc=FHS_GetPlayingPlayers();
	
	NextPlayer=TheButton;

	--If theres just one player, post a blind

	if (pc==1) then
		FHS_PlayerBet(TheButton,Blinds,"Blinds");
		
		NextPlayer=TheButton; --This person goes first
	end;

	if (pc==2) then

		j=FHS_WhosTurnAfter(TheButton);
		FHS_PlayerBet(j,Blinds,"Blinds");

		NextPlayer=TheButton; --person after this goes first
		
		FHS_PlayerBet(TheButton,Blinds * 0.5,"Blinds");
		NextPlayer=FHS_WhosTurnAfter(TheButton);
	end;

	-- We have 3 players or more, so big and little blinds
	if (pc>2) then

		j=FHS_WhosTurnAfter(TheButton);
		FHS_PlayerBet(j,Blinds * 0.5,"Small Blinds");

		j=FHS_WhosTurnAfter(j);
		FHS_PlayerBet(j,Blinds,"Big Blinds" );

		NextPlayer=j; --person after this goes first
	end;

	WhosTurn=NextPlayer;
	FHS_GoNextPlayersTurn();
end;

function FHS_PlayerBet(j,size,status)

	if (IsDealer==0) then 
		return; 
	end;

	--Todo: validity Checks
	Seats[j].chips=Seats[j].chips-size;
	Seats[j].bet=Seats[j].bet+size;
	Seats[j].status=status..": "..Seats[j].bet;	

	
	FHS_BroadCast("st_"..j.."_"..Seats[j].chips.."_"..Seats[j].bet.."_"..Seats[j].status.."_1");

	--local view
	FHS_UpdateSeat(j);
	FHS_TotalPot();
	
	--Pots
	if (Seats[j].chips==0) then
		--Mark the curent pot as a side pot.
		found=0;
		bets=FHS_SidePot(Seats[j].bet);
		for r=1,getn(SidePot) do
			if (SidePot[r].bet==Seats[j].bet) then found=1; end;
		end;
		if (found==0) then 
			--DEFAULT_CHAT_FRAME:AddMessage("new sidepot of "..bets);
			SidePot[getn(SidePot)+1]={bet=Seats[j].bet,pot=bets}; 
		end;
	end;

	--Check the existing sidepots, if our bet is < a sidepot, that sidepot needs to be rebuilt
	for j=1,getn(SidePot) do
	--if (Seats[j].bet<=SidePot[j].bet) then
			SidePot[j].pot=FHS_SidePot(SidePot[j].bet);
	--	end;
	end;


end;

function FHS_GoNextPlayersTurn()

	if (IsDealer==0) then 
		return; 
	end;
	
	WhosTurn=FHS_WhosBetAfter(WhosTurn);


	if (WhosTurn==0) then 
		FHS_NextLevel(); --All betting is satisfied
		return;
	end;

	--Check the number of dealt players left.
	--If theres only one player, clearly he's the winner
	--so end the round
	if (FHS_GetPlayingPlayers()==1) then
		
		if (FHS_GetSeatedPlayers()>1) then  -- If its only the dealer, let him keep playing
		
			FHS_NextLevel();
		
			return;
		end;
	end;



	HighestBet=FHS_HighestBet();
	FHS_BroadCast("go_"..WhosTurn.."_"..HighestBet);

	FHS_UpdateWhosTurn(); --buttons and whatnot

	
	--Start Timer for whos turn it is
	PlayerTurnEndTime=GetTime()+30;
	
	--DEFAULT_CHAT_FRAME:AddMessage(  "--"..GameLevel);
end;


function FHS_PlayerAction(j,delta)

	if (IsDealer==0) then 
		return; 
	end;

	--Todo: make sure its actually their turn
	-- This could occur only when the last player folds right as they make their move
	
	--DEFAULT_CHAT_FRAME:AddMessage("Player action"..j.." :"..delta);
	HighestBet=FHS_HighestBet();
	
	-- Update the players bet, move the turn
	if (delta==0) then
		if (Seats[j].bet==HighestBet) then
			FHS_PlayerBet(j,0,"Checked");
		else
			--Shouldnt ever occur, the player sent a "check" 
			-- when they were not equal to the highest bet
			DEFAULT_CHAT_FRAME:AddMessage("Player Invalid Action"..j..":"..delta);
		end;
	end

	if (delta>0) then
		if (Seats[j].bet+delta==HighestBet) then
			FHS_PlayerBet(j,delta,"Called");
			
		else
			if (Seats[j].bet+delta>=Seats[j].chips) then
				delta=Seats[j].chips;
				FHS_PlayerBet(j,delta,"All In");

			else
				FHS_PlayerBet(j,delta,"Raised");
			end;
		end;
	end;
	
	--Player has had their forced bet.
	Seats[j].forcedbet=0;

	--Next turn
	FHS_GoNextPlayersTurn();
end;




function FHS_PopupMenu(name)
	
	if (IsDealer==0) then 
		return; 
	end;
	--DEFAULT_CHAT_FRAME:AddMessage("popup:"..name);

	obj=getglobal("FHS_Popup")
	obj:SetPoint("CENTER", name, "CENTER", 20, -70);
	FHS_Popup:Show();

	FHS_PopupName=name;
	for j=1,9 do
		if (Seats[j].object==FHS_PopupName) then
			FHS_PopupIndex=j;
			return;
		end;
	end;
end


function FHS_Popup_GiveChipsClick()

	j=FHS_PopupIndex;

	--DEFAULT_CHAT_FRAME:AddMessage("popup:"..name .. Seats[j].name);	
	Seats[j].chips=Seats[j].chips+100;
	FHS_BroadCast("st_"..j.."_"..Seats[j].chips.."_"..Seats[j].bet.."_"..Seats[j].status.."_1",0);
	FHS_UpdateSeat(j);

end;

function FHS_Popup_BootPlayerClick()

	j=FHS_PopupIndex;

	
	if (j==LocalSeat) then
		DEFAULT_CHAT_FRAME:AddMessage("Can't boot the dealer.");	
	else
		--Tell the other seats about the change
		FHS_BroadCast("q_"..j,0);
		DEFAULT_CHAT_FRAME:AddMessage(Seats[j].name.." has left the table.");
		Seats[j].seated=0;
		Seats[j].HavePort=0;
		FHS_UpdateSeat(j);

		FHS_Popup:Hide();

		if (WhosTurn==j) then
			FHS_GoNextPlayersTurn();
		end;

	end;

end;

function FHS_Popup_ClearChipsClick()
	j=FHS_PopupIndex;

	--DEFAULT_CHAT_FRAME:AddMessage("popup:"..name .. Seats[j].name);	
	Seats[j].chips=0;
	FHS_BroadCast("st_"..j.."_"..Seats[j].chips.."_"..Seats[j].bet.."_"..Seats[j].status.."_0.5",0);
	FHS_UpdateSeat(j);
end







------------------------------------------------------------------------

--Takes cards[1..N]  (1 based array)
--Returns   BestCards[1..N]
--          NiceText  eg: "Pair of Twos","Two Pair, Twos and Fours", "Four Aces", "Straight 4 through 8")
--			HandType  eg: "Pair", "Two Pair", "Four of a Kind", "Straight"


function FHS_FindHandForPlayer(j)
	local BestCards={};
	local HType=-1;
	OutText="";
	Kicker={};

	if (Seats[j].dealt==1) then

		InCards={};	
		InCards[1]=Seats[j].hole1;
		InCards[2]=Seats[j].hole2;

		for r=1,getn(Flop) do
			InCards[r+2]=Flop[r];
		end 

		-- ok here is where we work out our best hand that the player has.
		-- this will NOT work out which player has the strongest hand, just construct this players
		-- best hand :p ok - DensitY
		
		-- for now outtext will be set based on handtype		
		BestCards,HType = FHS_FindBestHand(InCards);

		KickerList={};
		KickerList=FHS_CardListSubtractAfromB(BestCards,InCards);
		Kicker=KickerList;
		--Kicker=FHS_HandHighCard(KickerList);
	
		if(HType>0) then
			OutText = HandType[HType].text; -- get text for now.
			
			-- EDIT: hehe haxor time :P
			-- Prettys up the text,  High Card: Ace etc
			
			if(HType==1) then
				OutText = HandType[HType].text..": "..Cards[BestCards[1]].text;
			end;

			--Says what its a pair of
			if(HType==2) then
				rank = Cards[BestCards[1]].rank;
				--	DEFAULT_CHAT_FRAME:AddMessage("rank:"..	rank)	;
				OutText = HandType[HType].text..": "..CardRanks[rank];
			end;

			--Says what Two Pairs of a kind it is
			if(HType==3) then
			
				TempBestCards={}
				TempBestCards=FHS_RemoveSameRankCards(BestCards);
				rank  = Cards[TempBestCards[1]].rank;
				rank2 = Cards[TempBestCards[2]].rank;

				OutText = HandType[HType].text..": "..CardRanks[rank].." and "..CardRanks[rank2];
			end;


			--Says what 3 of a kind it is
			if(HType==4) then
				rank = Cards[BestCards[1]].rank;
				OutText = HandType[HType].text..": "..CardRanks[rank];
			end;

		end;
	end;

		

	return OutText,HType,BestCards,Kicker;
end;

-----------------------------------------------------------------------------------------------------------------
-- DensitY: Hand Finding Code below, Table at the top.
-----------------------------------------------------------------------------------------------------------------

function FHS_FindBestHand(InCards)
	local BestCards={};
	local HType=-1; -- 1 means no hand	
	
	-- Check for Royal Flush
	BestCards = FHS_Hand_IsRoyalFlush(InCards);
	if(getn(BestCards)>0) then
		-- Found, lets store and throw out.
		HType=10;
		return BestCards,HType;
	end;	
	
	-- Check for Flush Straight
	BestCards = FHS_Hand_IsFlushStraight(InCards);					  
	if(getn(BestCards)>0) then
		-- Found, lets store and throw out.
		HType=9;
		return BestCards,HType;
	end;
	
	-- Check for Four of a Kind
	BestCards = FHS_Hand_IsFourOfKind(InCards);
	if(getn(BestCards)>0) then
		HType=8;
		return BestCards,HType;
	end;

	-- Check for Full House	
	BestCards = FHS_Hand_IsFullHouse(InCards);
	if(getn(BestCards)>0) then
		-- Found, lets store and throw out.
		HType=7;
		return BestCards,HType;
	end;
	
	-- Check for Flush
	BestCards = FHS_Hand_IsFlush(InCards);
	if(getn(BestCards)>0) then
		-- Found, lets store and throw out.
		HType=6;
		return BestCards,HType;
	end;
	
	-- Check for Straight
	BestCards = FHS_Hand_IsStraight(InCards);
	if(getn(BestCards)>0) then
		-- Found, lets store and throw out.
		HType=5;
		return BestCards,HType;
	end;
	
	-- Check Three of a kind
	BestCards = FHS_Hand_IsThreeOfKind(InCards);
	if(getn(BestCards)>0) then
		-- Found, lets store and throw out.
		HType=4;
		return BestCards,HType;
	end;	
		
	-- Check for Two Pairs
	BestCards = FHS_HandIsTwoPair(InCards);
	if(getn(BestCards)>0) then
		-- Found, lets store and throw out.
		HType=3;
		return BestCards,HType;
	end;
		
	-- Check for 2 of a kind
	BestCards = FHS_HandIsTwoOfKind(InCards);
	if(getn(BestCards)>0) then
		-- Found, lets store and throw out.
		HType=2;
		return BestCards,HType;
	end;

	-- Get the player's highest card, their hand is not looking good.
	BestCards[1] = FHS_HandHighCard(InCards);
	if(getn(BestCards)>0) then	
		HType=1;	
		return BestCards,HType;
	end;	

	return BestCards,HType; -- this'll all be empty data, technically should never get here.
end

-----------------------------------------------------------------------------------------------------------------
-- PlayersHand finding Functions
-----------------------------------------------------------------------------------------------------------------

function FHS_HandHighCard(InCards)
	local StrongCards={};
	local KindFound=0;
	local CurrentHigh=-1;
	local CurrentHighIndex=0;

	local lastsuit=-1;
	
	-- just find the highest rank card.	
	for i=1,getn(InCards) do
		if(Cards[InCards[i]].rank > CurrentHigh) then
			CurrentHigh=Cards[InCards[i]].rank;
			lastsuit=Cards[InCards[i]].suit;
			CurrentHighIndex=InCards[i];
		end;
		-- if the card is the same, check the suit.
		if(Cards[InCards[i]].rank == CurrentHigh) and (Cards[InCards[i]].suit > lastsuit) then
			CurrentHigh=Cards[InCards[i]].rank;
			lastsuit=Cards[InCards[i]].suit;
			CurrentHighIndex=InCards[i];		
		end;		
	end;
		
	
	return CurrentHighIndex;
end;

function FHS_Hand_IsRoyalFlush(InCards)	
	local StrongCards={};	
	
	StrongCards = FindFlush(InCards,1);
	
	--if(getn(StrongCards)>=1) then -- debug
	--	DEFAULT_CHAT_FRAME:AddMessage("Royal Flush")		
	--	KindFound=1;
	-- end	
	
	return StrongCards;
end

function FHS_Hand_IsFlushStraight(InCards)
	local StrongCards={};

	StrongCards = FindStraight(InCards,1)

	--if(getn(StrongCards)>=1) then -- debug
	--	DEFAULT_CHAT_FRAME:AddMessage("Flush Straight")		
	--	KindFound=1;
	--end	
	
	return StrongCards; 
end

function FHS_Hand_IsFourOfKind(InCards)
	local StrongCards={};

	StrongCards = FindOfKind(InCards,0,4);
		
	--if(getn(StrongCards)>=1) then -- debug
	--	DEFAULT_CHAT_FRAME:AddMessage("4 of a Kind found")		
	--	KindFound=1;
	--end;
	return StrongCards; 
end

function FHS_Hand_IsFullHouse(InCards)
	local StrongCards={};
	local BottomFloor={};
	local TopFloor={};


	-- find our 3 of a kind first
	BottomFloor = FindOfKind(InCards,0,3);
	
			
	if(getn(BottomFloor)>0) then
		-- 3 of a kind found, lets get our 2 of a kind for the full house.
		TopFloor = FindOfKind(InCards,Cards[BottomFloor[1]].rank,2);	
	end;
	
	if(getn(BottomFloor)>0) and (getn(TopFloor)>0) then
		-- Store in StrongCards list if both pairs have been found.
		for j=1,getn(BottomFloor) do
			StrongCards[getn(StrongCards)+1] = BottomFloor[j];
		end;
		for j=1,getn(TopFloor) do
			StrongCards[getn(StrongCards)+1] = TopFloor[j];
		end;
	end;	

	--if(getn(StrongCards)>=1) then -- debug
	--	DEFAULT_CHAT_FRAME:AddMessage("Full House")		
	--	KindFound=1;
	--end;
	
	return StrongCards; 
end

function FHS_Hand_IsFlush(InCards)
	local StrongCards={};
	
	StrongCards = FindFlush(InCards,0);
	
	--if(getn(StrongCards)>=1) then -- debug
	--	DEFAULT_CHAT_FRAME:AddMessage("Flush")		
	--	KindFound=1;
	--end;
	
	return StrongCards; 
end

function FHS_Hand_IsStraight(InCards)
	local StrongCards={};

	StrongCards = FindStraight(InCards,0)

	--if(getn(StrongCards)>=1) then -- debug
	--	DEFAULT_CHAT_FRAME:AddMessage("Straight")		
	--	KindFound=1;
	--end	
	
	return StrongCards; 
end

function FHS_Hand_IsThreeOfKind(InCards)
	local StrongCards={};

	StrongCards = FindOfKind(InCards,0,3);
		
	--if(getn(StrongCards)>=1) then -- debug
	--	DEFAULT_CHAT_FRAME:AddMessage("3 of a Kind found")		
	--	KindFound=1;
	--end;
	
	return StrongCards; 
end


function FHS_HandIsTwoPair(InCards)
	local StrongCards={};
	local FirstTwo={};
	local SecondTwo={};
	
	-- find 2 pairs, first 2 found will be the strongest rank cards.
	FirstTwo = FindOfKind(InCards,0,2);	
	if(getn(FirstTwo)>0) then
		-- First pair found, lets find second pair.
		SecondTwo = FindOfKind(InCards,Cards[FirstTwo[1]].rank,2);
	end;
	
	if(getn(FirstTwo)>0) and (getn(SecondTwo)>0) then
		-- Store in StrongCards list if both pairs have been found.
		for j=1,getn(FirstTwo) do
			StrongCards[getn(StrongCards)+1] = FirstTwo[j];
		end;
		for j=1,getn(SecondTwo) do
			StrongCards[getn(StrongCards)+1] = SecondTwo[j];
		end;
	end;

	--if(getn(StrongCards)>=1) then
	--	DEFAULT_CHAT_FRAME:AddMessage("2 Pair found")		
	--	KindFound=1;
	--end;
	
	return StrongCards; 
end


function FHS_HandIsTwoOfKind(InCards)
	local StrongCards={};

	StrongCards = FindOfKind(InCards,0,2);
		
	--if(getn(StrongCards)>=1) then -- debug
	--	DEFAULT_CHAT_FRAME:AddMessage("2 of a Kind found")		
	--	KindFound=1;
	--end;
	
	return StrongCards;
end

-----------------------------------------------------------------------------------------------------------------
-- Hand finding Functions - Utilities
-----------------------------------------------------------------------------------------------------------------

-- Name: FindOfKind(Cards,excluder,Num) - used for 2 of a kind, 3 of a kind,4 of a kind, full house checks.
--		Cards = Array of Cards
--		excluder = rank of card we don't wanna take into consideration (full house check), left as zero if we want to check all.
--		num = the number we wanna find
-- Returns: On Sucess	- Array of card index numbers. (ie Cards[array[1]].text = card).
--			On Fail		- returns nothing getn(return) will be zero.
-- Example: Finding Full house
--			BottomFloor = FindOfKind(InCards,0,3);
--			TopFloor	= FindOfKind(InCards,Cards[BottomFloor[1]].rank,2);

-- 28/06/2006: Tested, hopefully bugfree - DensitY
function FindOfKind(InCards,excluder,Num)
	local rankchecked={};	-- list of ranks we've already checked
	local highest_rank=0;	-- highest rank excluding excluder rank.
	local ListedCards={};	-- Final listed cards to be thrown out.
	local TargetMeet=0;		-- 1 if we reach our goal.
	local size=getn(InCards);
	local foundlist={}		-- Current list of found cards. Gets copied as we can have 2 lots of found stuff in here.
	
	-- Check against Listed Ranks that have passed the test
	function RankChecked(list,rank) -- no longer required
		local checked=1;
		local size=getn(list);
		
		for i=1,size do
			if(list[i] == rank) then
				checked=0;
			end;
		end;		
		return checked;
	end;	

	-- Verify List of cards found
	function VerifyList(list,rank) -- DEBUG.
		local result=1;
		
		for i=1,getn(list) do
			if(Cards[list[i]].rank~=rank) then
				--DEFAULT_CHAT_FRAME:AddMessage("hand found but cards don't match up");
				result=0;
			end;			
		end;		
		return result; -- return zero on fail.
	end;
	
	-- spagetti meatballs. Having only just had a 2 second look at syntaxing in Lua, I'm gonna be pissed if this has some 
	-- nice STL like abilities that can cut down this generic C style crap.
	for j=1,size do
		-- Clear list.
		foundlist={};
		for i=1,size do
			if(j~=i) then					
				if(Cards[InCards[j]].rank == Cards[InCards[i]].rank)and(Cards[InCards[j]].rank~=excluder) then						
					foundlist[getn(foundlist)+1]=InCards[i];						
					if((getn(foundlist)+1)>=Num) then -- +1
						--foundlist[getn(foundlist)+1]=InCards[j];							
						if(VerifyList(foundlist,Cards[InCards[j]].rank)>0) then -- DEBUG.
							rankchecked[getn(rankchecked)+1]=Cards[InCards[j]].rank; -- store rank with Num amount found in hand
							TargetMeet=1; -- set to 1 because we have 1 set, regardless of number of sets we find.
						end;							
					end;						
				end;
			end;
		end;									
	end;		
	
	if(TargetMeet > 0) then 
		-- find highest rank'ed found (if we find 2x of what you are looking for, this automatically excludes the excluder).
		for j=1,getn(rankchecked) do
			if(rankchecked[j]>highest_rank) then
				highest_rank=rankchecked[j];
			end;
		end;		
		-- if our target is met, copy everything over to our outgoing table.	
		for j=1,size do
			if(Cards[InCards[j]].rank==highest_rank) then
				ListedCards[getn(ListedCards)+1] = InCards[j];
			end;
		end;
		
		-- DEBUG CHECKER:
		--if(getn(ListedCards)~=Num) then
			-- FUCK!
		--end;
		-- END DEBUG CHECKER
	end;
		
	-- return result (could be empty, check result via getn() function).
	return ListedCards; 
end;

-- Name: FindStraight(InCards,flush) - Finds straight or flush stragith
--				InCards - Array of cards to check
--				flush - set to 0 or 1, 1 denoting we are checking for a flush straight only.
-- Returns:	On Success, will return list of cards
--			On Fail, returns empty array (getn to check if greater then zero)

-- 29/06/2006: Tested, hopefully bugfree - DensitY
function FindStraight(InCards,flush)
	local ListedCards={};
	local templist={};
	local SortedCardList={};
	local SequanceList={};
	local suit=0;
	local LastRank=0;
	local RunCount=1;
	
	-- Card sorter, from lowest rank to highest
	-- Yes this is a bubble sort, which is slow, but this is a card game so who cares :p
	function CardBSort(array)		
		local temp=0;
		local size=getn(array);
		
		for i=1,size do
			for j=1,size do
				if(Cards[array[i]].rank<Cards[array[j]].rank) then
					temp=array[i]; array[i]=array[j]; array[j]=temp;
				end;
			end;
		end;
		
		return array;
	end;

	if(getn(InCards)<5) then
		-- Fail, can't make a straight without at least 5 cards.
		return ListedCards;
	end;

	-- Sort cards from lowest to highest rank.
	for i=1,getn(InCards) do
		templist[getn(templist)+1]=InCards[i];
	end;
	SortedCardList = CardBSort(templist); -- not sure if lua treats this as a reference or just a copy into the call-function stack space
										  -- so just being safe.
	
	-- DEBUG sorter.
	--for i=1,getn(SortedCardList) do
	--	DEFAULT_CHAT_FRAME:AddMessage(Cards[SortedCardList[i]].rank)
	--end;
	
	-- Test, at least 5 must be in sequance, no wrapping!
	LastRank=Cards[SortedCardList[1]].rank;
	
	-- Ace low is a straight, but no wrapping
	if (LastRank==2) then
		if (Cards[SortedCardList[getn(SortedCardList)]].rank==14) then  --highest card is an ace
			SequanceList[getn(SequanceList)+1]=SortedCardList[getn(SortedCardList)];		
			RunCount=2;
		end;
	end;
	
	SequanceList[getn(SequanceList)+1]=SortedCardList[1];
	for j=2,getn(SortedCardList) do		
		
		dif=(Cards[SortedCardList[j]].rank-LastRank);
		if ((dif==0)or(dif==1)) then
			if (dif==1) then RunCount=RunCount+1;end;
					
		else
			--reset
			RunCount=1; SequanceList={};
		end;
		
	
		LastRank=Cards[SortedCardList[j]].rank;
		SequanceList[getn(SequanceList)+1]=SortedCardList[j];
		if(RunCount>=5) then
			break; -- hack: get out.
		end;
	end;		
	if(RunCount>=5) then
		-- we have a straight.
		for j=1,getn(SequanceList) do
			ListedCards[getn(ListedCards)+1]=SequanceList[j];
		end;
	end;

	-- Do flush check if required and if straight is already present.
	if(flush>0) and (getn(ListedCards)>0) then
	

		return FindFlush(ListedCards,0);

	end;
	
	return ListedCards;
end;

-- Name: FindFlush(InCards) - finds out if a hand contains a flush.
--				InCards - Array of Cards.
--				royal - set > 0 to check for royal flush
-- Returns: On Sucess, will return list of cards
--			On Fail, returns empty array.

-- 28/06/2006: Tested, hopefully bugfree - DensitY
function FindFlush(InCards,royal)
	local ListedCards={}; -- cards involved!
	local TestSuit=0;
	local SuitCount=1;
	local FoundFlush=-1;
	
	if(getn(InCards)<5) then
		-- Fail, need 5 cards
		return ListedCards;
	end;
	
	for j=1,getn(InCards) do
		SuitCount=1; 
		TestSuit=Cards[InCards[j]].suit;
		for i=1,getn(InCards) do
			if(i~=j) and (Cards[InCards[i]].suit==TestSuit) then
				SuitCount=SuitCount+1;	
			end;
			if(SuitCount>=5) then
				FoundFlush = TestSuit; -- Careful, zero is a valid suit				
			end;
		end;		
		if(FoundFlush>-1) then
			break;
		end;
	end;
	
	-- found, store in listed cards.
	if(FoundFlush~=-1) then
		for j=1,getn(InCards) do
			if(Cards[InCards[j]].suit==FoundFlush) then
				ListedCards[getn(ListedCards)+1] = InCards[j];
			end;
		end;
	end;
	
	-- Check for Royal Flush if set!
	if (royal>0)and(getn(ListedCards)>0) then
		-- All cards must be Between 10 and Ace (or rank 9 and 14).
		-- if this fails we'll return nothing, else the lucky player has the strongest
		-- hand in the game.
		for j=1,getn(ListedCards) do
			if(Cards[ListedCards[j]].rank<=9) then
				ListedCards={};
				return ListedCards;
			end;
		end;
	end;
	
	return ListedCards;
end;

--Takes a list of cards
--Returns the card list with any duplicates removed

function FHS_RemoveSameRankCards(ListedCards)


	res={}
	
	for j=1,getn(ListedCards) do
		
		found=-1;
		for r=1,getn(res) do
			if (Cards[res[r]].rank==Cards[ListedCards[j]].rank) then
				found=1;
			end
		end;
		if (found==-1) then res[getn(res)+1]=ListedCards[j]; end
	end;
	
	return res;
end;
-- check if card 1 is stronger then card2
function FHS_GreaterThen(card1,card2)
	local isgreater=0;

	if(Cards[card1].rank == Cards[card2].rank) and (Cards[card1].suit>Cards[card2].suit) then
		isgreater=1;		
	else 
		if(Cards[Card1].rank > Cards[card2].rank) then
			isgreater=1;
		end
	end;
	
	return isgreater;
end;


function FHS_CardListSubtractAfromB(a,b)

	c={};
	
	for j=1,getn(b) do
	
		found=0;
		for r=1,getn(a) do
			if (a[r]==b[j]) then 
				found=1;
				break;
			end;
		end;
		if (found==0) then 
			c[getn(c)+1]=b[j];
		end;
	end;		
	return c;
end;