require("UI_Events");
require("utilities");

--used only for testing purposes, this menu has no in-game functional purpose at this point in time
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	--be vigilant of referencing clientGame.Us when it ==nil for spectators, b/c they CAN initiate this function
    Game = game; --global variable to use in other functions in this code 

    if game == nil then 		print('ClientGame is nil'); 	end
	if game.LatestStanding == nil then 		print('ClientGame.LatestStanding is nil'); 	end
	if game.LatestStanding.Cards == nil then 		print('ClientGame.LatestStanding.Cards is nil'); 	end
	if game.Us == nil then 		print('ClientGame.Us is nil'); 	end
	if game.Settings == nil then 		print('ClientGame.Settings is nil'); 	end
	if game.Settings.Cards == nil then 		print('ClientGame.Settings.Cards is nil'); 	end

    MenuWindow = rootParent;
	TopLabel = CreateLabel (MenuWindow).SetFlexibleWidth(1).SetText ("Used for testing purposes only; this will be removed before releasing to public\n\n");
    TopLabel.SetText (TopLabel.GetText() .. ("Server time: "..game.Game.ServerTime));
	if (game.Us~=nil) then --a player in the game
		TopLabel.SetText (TopLabel.GetText() .. "\n\nClient player "..game.Us.ID .."/"..toPlayerName (game.Us.ID, game)..", State: "..tostring(game.Game.Players[game.Us.ID].State).."/"..tostring(WLplayerStates ()[game.Game.Players[game.Us.ID].State]).. ", IsActive: "..tostring(game.Game.Players[game.Us.ID].State == WL.GamePlayerState.Playing).. ", IsHost: "..tostring(game.Us.ID == game.Settings.StartedBy));
	else
		--client local player is a Spectator, don't reference game.Us which ==nil
		TopLabel.SetText (TopLabel.GetText() .. "\n\nClient player is Spectator");
	end

	TopLabel.SetText (TopLabel.GetText() .. ("\n\nGame host: "..game.Settings.StartedBy.."/".. toPlayerName(game.Settings.StartedBy, game)));

	TopLabel.SetText (TopLabel.GetText() .. ("\n\nPlayers in the game:"));
	for k,v in pairs (game.Game.Players) do
		local strPlayerIsHost = "";
		if (k == game.Settings.StartedBy) then strPlayerIsHost = " [HOST]"; end
		TopLabel.SetText (TopLabel.GetText() .. "\nPlayer "..k .."/"..toPlayerName (k, game)..", State: "..tostring(v.State).."/"..tostring(WLplayerStates ()[v.State]).. ", IsActive: "..tostring(game.Game.Players[k].State == WL.GamePlayerState.Playing) .. strPlayerIsHost);
	end

	--[[    Server_GameCustomMessage (Server_GameCustomMessage.lua)
Called whenever your mod calls ClientGame.SendGameCustomMessage. This gives mods a way to communicate between the client and server outside of a turn advancing. Note that if a mod changes Mod.PublicGameData or Mod.PlayerGameData, the clients that can see those changes and have the game open will automatically receive a refresh event with the updated data, so this message can also be used to push data from the server to clients.
Mod security should be applied when working with this Hook
Arguments:
Game: Provides read-only information about the game.
PlayerID: The ID of the player who invoked this call.
payload: The data passed as the payload parameter to SendGameCustomMessage. Must be a lua table.
setReturn: Optionally, a function that sets what data will be returned back to the client. If you wish to return data, pass a table as the sole argument to this function. Not calling this function will result in an empty table being returned.]]

	--this shows all Global Functions! wow
	--[[for i, v in pairs(_G) do
		print(i, v);
	end]]

    showDefinedCards (game);
    showCardBlockData ();
    showIsolationData ();
    showQuicksandData ();
    showEarthquakeData ();
    showPestilenceData ();
	--showNeutralizeData (); --can't do this b/c NeutralizeData is in PrivateGameData --> can't view in Client hook
end

--not actually used; but keep it around as an example of how to use/return data using clientGame.SendGameCustomMessage
function PresentMenuUI_callBack (table)
    for k,v in pairs (table) do
        print ("[C_PMUI] "..k,v);
        CreateLabel (MenuWindow).SetText ("[C_PMUI] "..k.."/"..v);
    end
end

function showNeutralizeData ()
    CreateLabel (MenuWindow).SetText ("\nNeutralize data:");
    CreateLabel (MenuWindow).SetText ("# records==".. tablelength (Mod.PrivateGameData.NeutralizeData));
    for k,v in pairs (Mod.PrivateGameData.NeutralizeData) do
        printObjectDetails (v,"record", "NeutralizeData");
        CreateLabel (MenuWindow).SetText (tostring(k)..", " ..tostring(v.territory)..", " ..tostring(v.castingPlayer)..", "..tostring(v.impactedTerritoryOwnerID)..", " .. tostring(v.turnNumber_NeutralizationExpires), ", ".. tostring(v.specialUnitID));
    end
	--for reference: local neutralizeDataRecord = {territory=targetTerritoryID, castingPlayer=castingPlayerID, territoryOwner=impactedTerritoryOwnerID, turnNumberToRevert=turnNumber_NeutralizationExpires, specialUnitID=specialUnit_Neutralize.ID};
end

function showEarthquakeData ()
    CreateLabel (MenuWindow).SetText ("\nEarthquake data:");
    CreateLabel (MenuWindow).SetText ("# records==".. tablelength (Mod.PublicGameData.EarthquakeData));
    for k,v in pairs (Mod.PublicGameData.EarthquakeData) do
        printObjectDetails (v,"record", "EarthquakeData");
        CreateLabel (MenuWindow).SetText (tostring(k)..", " ..tostring(v.targetBonus)..", " ..tostring(v.castingPlayer)..", "..tostring(v.turnNumberEarthquakeEnds));
    end
    --for reference: publicGameData.EarthquakeData[targetBonusID] = {targetBonus = targetBonusID, castingPlayer = gameOrder.PlayerID, turnNumberEarthquakeEnds = turnNumber_EarthquakeExpires};
end

function showCardBlockData ()
    CreateLabel (MenuWindow).SetText ("\nCard Block data:");
    CreateLabel (MenuWindow).SetText ("# records==".. tablelength (Mod.PublicGameData.CardBlockData));
    for k,v in pairs (Mod.PublicGameData.CardBlockData) do
        printObjectDetails (v,"record", "CardBlockData");
        CreateLabel (MenuWindow).SetText (k..", " ..v.castingPlayer..", "..v.turnNumberBlockEnds);
        --for reference: local record = {targetPlayer = targetPlayerID, castingPlayer = gameOrder.PlayerID, turnNumberBlockEnds = turnNumber_CardBlockExpires}; --create record to save data on impacted player, casting player & end turn of Card Block impact
    end
end

function showQuicksandData ()
    CreateLabel (MenuWindow).SetText ("\nQuicksand data:");
    CreateLabel (MenuWindow).SetText ("# records==".. tablelength (Mod.PublicGameData.QuicksandData));
    CreateLabel (MenuWindow).SetText ("AttackerDamageTakenModifier: "..Mod.Settings.QuicksandAttackDamageGivenModifier);
    CreateLabel (MenuWindow).SetText ("DefenderDamageTakenModifier: "..Mod.Settings.QuicksandDefendDamageTakenModifier);

	if (tablelength (Mod.PublicGameData.QuicksandData)) == 0 then CreateLabel (MenuWindow).SetText ("QuicksandData is empty"); return; end

    for k,v in pairs (Mod.PublicGameData.QuicksandData) do
        printObjectDetails (v,"record", "QuicksandData");
        CreateLabel (MenuWindow).SetText (k..", " ..tostring (v.territory).."/"..getTerritoryName (v.territory, Game) ..", "..tostring (v.castingPlayer).. ", "..tostring (v.territoryOwner).. ", ".. tostring (v.turnNumberQuicksandEnds) .. ", "..tostring (v.specialUnitID));
        --CreateLabel (MenuWindow).SetText (k..", " ..v.territory.."/"..getTerritoryName (v.territory, game)..", "..v.castingPlayer.. ", "..v.territoryOwner.. ", ".. v.turnNumberQuicksandEnds);
        --for reference: local QuicksandDataRecord = {territory=targetTerritoryID, castingPlayer=castingPlayerID, territoryOwner=impactedTerritoryOwnerID, turnNumberQuicksandEnds=turnNumber_QuicksandExpires, specialUnitID=specialUnit_Quicksand.ID};---&&&
    end
end

function showPestilenceData ()
    CreateLabel (MenuWindow).SetText ("\nPestilence data:");
    CreateLabel (MenuWindow).SetText ("# records==".. tablelength (Mod.PublicGameData.PestilenceData));

	if (tablelength (Mod.PublicGameData.PestilenceData)) == 0 then CreateLabel (MenuWindow).SetText ("PestilenceData is empty"); return; end

    for k,v in pairs (Mod.PublicGameData.PestilenceData) do
        --printObjectDetails (v,"record", "PestilenceData");
        CreateLabel (MenuWindow).SetText ("["..k.."] target " ..v.targetPlayer.."/"..toPlayerName (v.targetPlayer, Game)..", caster "..v.castingPlayer.."/"..toPlayerName (v.castingPlayer, Game)..", warning T"..v.PestilenceWarningTurn..", Start T"..v.PestilenceStartTurn..", End T"..v.PestilenceEndTurn);
		--for reference: publicGameData.PestilenceData [pestilenceTarget_playerID] = {targetPlayer=pestilenceTarget_playerID, castingPlayer=gameOrder.PlayerID, PestilenceWarningTurn=PestilenceWarningTurn, PestilenceStartTurn=PestilenceStartTurn, PestilenceEndTurn=PestilenceEndTurn};

    end
end

function showIsolationData ()
    CreateLabel (MenuWindow).SetText ("\nIsolation data:");
    CreateLabel (MenuWindow).SetText ("# records==".. tablelength (Mod.PublicGameData.IsolationData));

	CreateLabel (MenuWindow).SetText ("Quicksanded territories:");
    if (tablelength (Mod.PublicGameData.IsolationData)) == 0 then CreateLabel (MenuWindow).SetText ("IsolationData is empty"); return; end

    for k,v in pairs (Mod.PublicGameData.IsolationData) do
        printObjectDetails (v,"record", "IsolationData");
        --CreateLabel (MenuWindow).SetText (k..", " ..v.territory.."/".."?"..", "..v.castingPlayer.. ", "..v.territoryOwner.. ", ".. v.turnNumberIsolationEnds);
        CreateLabel (MenuWindow).SetText (k..", " ..v.territory.."/"..getTerritoryName (v.territory, Game)..", "..v.castingPlayer.. ", "..v.territoryOwner.. ", ".. v.turnNumberIsolationEnds);
        --for reference: local IsolationDataRecord = {territory=targetTerritoryID, castingPlayer=castingPlayerID, territoryOwner=impactedTerritoryOwnerID, turnNumberIsolationEnds=turnNumber_IsolationExpires, specialUnitID=specialUnit_Isolation.ID};---&&&
    end
end

function showDefinedCards (game)
    --print ("[PresentMenuUI] CARD OVERVIEW");
    --game.SendGameCustomMessage ("[waiting for server response]", {action="initialize_CardData"}, PresentMenuUI_callBack);

    local cards = getDefinedCardList (game);
    local CardPiecesCardID = Mod.PublicGameData.CardData.CardPiecesCardID;

    local strText = "";
    for k,v in pairs (cards) do
        strText = strText .. "\n"..v.." / ["..k.."]";
    end
    strText = TopLabel.GetText() .. "\n\nDEFINED CARDS:"..strText .. "\n\nCardPieceCardID=="..CardPiecesCardID;
    TopLabel.SetText (strText.."\n");
end



--[[
card data:
846: 18 cards total
846: [PresentMenuUI] CARD OVERVIEW
846: [PresentMenuUI] CARD OVERVIEW
846: 1
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFDA9
846:   [readablekeys_value] key#==1:: key==FriendlyDescription:: value==Play this card to gain an extra 5 armies
846:   [readablekeys_value] key#==2:: key==CardID:: value==1
846:   [readablekeys_value] key#==3:: key==IsStoredInActiveOrders:: value==false
846:   [readablekeys_value] key#==4:: key==ActiveOrderDuration:: value==-1
846:   [readablekeys_value] key#==5:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==6:: key==Description:: value==In 3 pieces for 5 armies (minimum 1 piece per turn, starts with 8 pieces)
846:   [readablekeys_value] key#==7:: key==Mode:: value==0
846:   [readablekeys_value] key#==8:: key==FixedArmies:: value==5
846:   [readablekeys_value] key#==9:: key==ProgressivePercentage:: value==0
846:   [readablekeys_value] key#==10:: key==ID:: value==1
846:   [readablekeys_value] key#==11:: key==NumPieces:: value==3
846:   [readablekeys_value] key#==12:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==13:: key==InitialPieces:: value==8
846:   [readablekeys_value] key#==14:: key==Weight:: value==1
846:   [readablekeys_value] key#==15:: key==proxyType:: value==CardGameReinforcement
846:   [readablekeys_value] key#==16:: key==readonly:: value==true
846:   [readablekeys_table] key#==17:: key==readableKeys:: value=={  1 = FriendlyDescription,  2 = CardID,  3 = IsStoredInActiveOrders,  4 = ActiveOrderDuration,  5 = ActiveCardExpireBehavior,  6 = Description,  7 = Mode,  8 = FixedArmies,  9 = ProgressivePercentage,  10 = ID,  11 = NumPieces,  12 = MinimumPiecesPerTurn,  13 = InitialPieces,  14 = Weight,  15 = proxyType,  16 = readonly,  17 = readableKeys,  18 = writableKeys,}
846:   [readablekeys_table] key#==18:: key==writableKeys:: value=={  1 = Mode,  2 = FixedArmies,  3 = ProgressivePercentage,  4 = NumPieces,  5 = MinimumPiecesPerTurn,  6 = InitialPieces,  7 = Weight,}
846:   [writablekeys_value] key#==1:: key==Mode:: value==0
846:   [writablekeys_value] key#==2:: key==FixedArmies:: value==5
846:   [writablekeys_value] key#==3:: key==ProgressivePercentage:: value==0
846:   [writablekeys_value] key#==4:: key==NumPieces:: value==3
846:   [writablekeys_value] key#==5:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==6:: key==InitialPieces:: value==8
846:   [writablekeys_value] key#==7:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221749
846: 1000013	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFDB9
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Start a forest fire that spreads each turn
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==10
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000013
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==true
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 20 pieces Start a forest fire that spreads each turn (minimum 1 piece per turn, starts with 111 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Forest Fire
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Start a forest fire that spreads each turn
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==forest fire_130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==10
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000013
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==20
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==111
846:   [readablekeys_value] key#==17:: key==Weight:: value==1
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Forest Fire
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Start a forest fire that spreads each turn
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==forest fire_130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==10
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==20
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==111
846:   [writablekeys_value] key#==9:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221750
846: 1000012	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFDC9
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Launch an attack on a territory that you don't need to border
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==-1
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000012
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==false
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 19 pieces Launch an attack on a territory that you don't need to border (minimum 1 piece per turn, starts with 110 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Airstrike
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Launch an attack on a territory that you don't need to border
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==airstrike_130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==-1
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000012
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==19
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==110
846:   [readablekeys_value] key#==17:: key==Weight:: value==1
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Airstrike
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Launch an attack on a territory that you don't need to border
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==airstrike_130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==-1
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==19
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==110
846:   [writablekeys_value] key#==9:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221751
846: 1000011	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFDD9
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Take ownership of a neutral territory. This can be done on either natural neutral territories, or territories that were Neutralized (used a Neutralize card).
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==-1
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000011
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==false
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 14 pieces Take ownership of a neutral territory. This can be done on either natural neutral territories, or territories that were Neutralized (used a Neutralize card). (minimum 1 piece per turn, starts with 105 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Deneutralize
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Take ownership of a neutral territory. This can be done on either natural neutral territories, or territories that were Neutralized (used a Neutralize card).
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==deneutralize_greenback2_130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==-1
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000011
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==14
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==105
846:   [readablekeys_value] key#==17:: key==Weight:: value==1
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Deneutralize
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Take ownership of a neutral territory. This can be done on either natural neutral territories, or territories that were Neutralized (used a Neutralize card).
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==deneutralize_greenback2_130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==-1
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==14
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==105
846:   [writablekeys_value] key#==9:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221752
846: 1000010	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFDE9
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Turn a territory owned by a player to neutral for 3 turns. If it is still neutral at that time, it will revert ownership to the prior owner.

Territories with commanders or other special units can be targeted.
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==3
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000010
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==true
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 13 pieces Turn a territory owned by a player to neutral for 3 turns. If it is still neutral at that time, it will revert ownership to the prior owner.

Territories with commanders or other special units can be targeted. (minimum 1 piece per turn, starts with 114 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Neutralize
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Turn a territory owned by a player to neutral for 3 turns. If it is still neutral at that time, it will revert ownership to the prior owner.

Territories with commanders or other special units can be targeted.
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==neutralize_greyback2_130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==3
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000010
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==13
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==114
846:   [readablekeys_value] key#==17:: key==Weight:: value==1
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Neutralize
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Turn a territory owned by a player to neutral for 3 turns. If it is still neutral at that time, it will revert ownership to the prior owner.

Territories with commanders or other special units can be targeted.
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==neutralize_greyback2_130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==3
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==13
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==114
846:   [writablekeys_value] key#==9:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221753
846: 6
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFDF9
846:   [readablekeys_value] key#==1:: key==FriendlyDescription:: value==Play this card to do a one-time transfer between any two of your territories.
846:   [readablekeys_value] key#==2:: key==CardID:: value==6
846:   [readablekeys_value] key#==3:: key==IsStoredInActiveOrders:: value==false
846:   [readablekeys_value] key#==4:: key==ActiveOrderDuration:: value==-1
846:   [readablekeys_value] key#==5:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==6:: key==Description:: value==In 5 pieces (minimum 1 piece per turn, starts with 8 pieces)
846:   [readablekeys_value] key#==7:: key==ID:: value==6
846:   [readablekeys_value] key#==8:: key==NumPieces:: value==5
846:   [readablekeys_value] key#==9:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==10:: key==InitialPieces:: value==8
846:   [readablekeys_value] key#==11:: key==Weight:: value==1
846:   [readablekeys_value] key#==12:: key==proxyType:: value==CardGameAirlift
846:   [readablekeys_value] key#==13:: key==readonly:: value==true
846:   [readablekeys_table] key#==14:: key==readableKeys:: value=={  1 = FriendlyDescription,  2 = CardID,  3 = IsStoredInActiveOrders,  4 = ActiveOrderDuration,  5 = ActiveCardExpireBehavior,  6 = Description,  7 = ID,  8 = NumPieces,  9 = MinimumPiecesPerTurn,  10 = InitialPieces,  11 = Weight,  12 = proxyType,  13 = readonly,  14 = readableKeys,  15 = writableKeys,}
846:   [readablekeys_table] key#==15:: key==writableKeys:: value=={  1 = NumPieces,  2 = MinimumPiecesPerTurn,  3 = InitialPieces,  4 = Weight,}
846:   [writablekeys_value] key#==1:: key==NumPieces:: value==5
846:   [writablekeys_value] key#==2:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==3:: key==InitialPieces:: value==8
846:   [writablekeys_value] key#==4:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221754
846: 1000009	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFE09
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Receive whole cards and/or card pieces of a card of your choice.
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==-1
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000009
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==false
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 10 pieces Receive whole cards and/or card pieces of a card of your choice. (minimum 1 piece per turn, starts with 202 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Card Piece
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Receive whole cards and/or card pieces of a card of your choice.
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==Card Pieces_greenback_130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==-1
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000009
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==10
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==202
846:   [readablekeys_value] key#==17:: key==Weight:: value==1
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Card Piece
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Receive whole cards and/or card pieces of a card of your choice.
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==Card Pieces_greenback_130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==-1
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==10
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==202
846:   [writablekeys_value] key#==9:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221755
846: 7
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFE19
846:   [readablekeys_value] key#==1:: key==FriendlyDescription:: value==Play this card to give one of your territories and all armies on it to another player.  Most useful with teams.
846:   [readablekeys_value] key#==2:: key==CardID:: value==7
846:   [readablekeys_value] key#==3:: key==IsStoredInActiveOrders:: value==false
846:   [readablekeys_value] key#==4:: key==ActiveOrderDuration:: value==-1
846:   [readablekeys_value] key#==5:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==6:: key==Description:: value==In 9 pieces (minimum 1 piece per turn, starts with 90 pieces)
846:   [readablekeys_value] key#==7:: key==ID:: value==7
846:   [readablekeys_value] key#==8:: key==NumPieces:: value==9
846:   [readablekeys_value] key#==9:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==10:: key==InitialPieces:: value==90
846:   [readablekeys_value] key#==11:: key==Weight:: value==1
846:   [readablekeys_value] key#==12:: key==proxyType:: value==CardGameGift
846:   [readablekeys_value] key#==13:: key==readonly:: value==true
846:   [readablekeys_table] key#==14:: key==readableKeys:: value=={  1 = FriendlyDescription,  2 = CardID,  3 = IsStoredInActiveOrders,  4 = ActiveOrderDuration,  5 = ActiveCardExpireBehavior,  6 = Description,  7 = ID,  8 = NumPieces,  9 = MinimumPiecesPerTurn,  10 = InitialPieces,  11 = Weight,  12 = proxyType,  13 = readonly,  14 = readableKeys,  15 = writableKeys,}
846:   [readablekeys_table] key#==15:: key==writableKeys:: value=={  1 = NumPieces,  2 = MinimumPiecesPerTurn,  3 = InitialPieces,  4 = Weight,}
846:   [writablekeys_value] key#==1:: key==NumPieces:: value==9
846:   [writablekeys_value] key#==2:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==3:: key==InitialPieces:: value==90
846:   [writablekeys_value] key#==4:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221756
846: 1000008	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFE29
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Create a special unit that does no damage but cannot be killed. Monoliths last 3 turns before expiring.
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==3
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000008
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==true
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 10 pieces Create a special unit that does no damage but cannot be killed. Monoliths last 3 turns before expiring. (minimum 1 piece per turn, weight is 12, starts with 135 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Monolith
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Create a special unit that does no damage but cannot be killed. Monoliths last 3 turns before expiring.
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==monolith v2 130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==3
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000008
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==10
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==135
846:   [readablekeys_value] key#==17:: key==Weight:: value==12
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Monolith
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Create a special unit that does no damage but cannot be killed. Monoliths last 3 turns before expiring.
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==monolith v2 130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==3
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==10
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==135
846:   [writablekeys_value] key#==9:: key==Weight:: value==12
846: [base_value] key==__proxyID:: value==221757
846: 1000007	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFE39
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Transform a territory into quicksand for 9 turns.

Attacks and transfers into the territory can still occur, but none can be executed from the territory while quicksand remains active. Units caught in quicksand also do 0.100000001490116% less damage to attackers, and sustain 0.100000001490116% more damage when attacked.
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==9
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000007
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==true
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 18 pieces Transform a territory into quicksand for 9 turns.

Attacks and transfers into the territory can still occur, but none can be executed from the territory while quicksand remains active. Units caught in quicksand also do 0.100000001490116% less damage to attackers, and sustain 0.100000001490116% more damage when attacked. (minimum 1 piece per turn, starts with 109 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Quicksand
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Transform a territory into quicksand for 9 turns.

Attacks and transfers into the territory can still occur, but none can be executed from the territory while quicksand remains active. Units caught in quicksand also do 0.100000001490116% less damage to attackers, and sustain 0.100000001490116% more damage when attacked.
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==quicksand_130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==9
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000007
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==18
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==109
846:   [readablekeys_value] key#==17:: key==Weight:: value==1
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Quicksand
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Transform a territory into quicksand for 9 turns.

Attacks and transfers into the territory can still occur, but none can be executed from the territory while quicksand remains active. Units caught in quicksand also do 0.100000001490116% less damage to attackers, and sustain 0.100000001490116% more damage when attacked.
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==quicksand_130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==9
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==18
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==109
846:   [writablekeys_value] key#==9:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221758
846: 1000006	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFE49
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Cause a tornado to develop on a territory, causing 10 damage for 3 turns.
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==3
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000006
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==true
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 10 pieces Cause a tornado to develop on a territory, causing 10 damage for 3 turns. (minimum 1 piece per turn, starts with 203 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Tornado
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Cause a tornado to develop on a territory, causing 10 damage for 3 turns.
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==tornado_130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==3
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000006
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==10
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==203
846:   [readablekeys_value] key#==17:: key==Weight:: value==1
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Tornado
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Cause a tornado to develop on a territory, causing 10 damage for 3 turns.
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==tornado_130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==3
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==10
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==203
846:   [writablekeys_value] key#==9:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221759
846: 1000005	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFE59
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Cause an earthquake that ravages all territories owned by a target player for 3 turns. 
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==3
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000005
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==true
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 10 pieces Cause an earthquake that ravages all territories owned by a target player for 3 turns.  (minimum 1 piece per turn, starts with 201 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Earthquake
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Cause an earthquake that ravages all territories owned by a target player for 3 turns. 
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==earthquake_130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==3
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000005
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==10
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==201
846:   [readablekeys_value] key#==17:: key==Weight:: value==1
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Earthquake
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Cause an earthquake that ravages all territories owned by a target player for 3 turns. 
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==earthquake_130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==3
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==10
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==201
846:   [writablekeys_value] key#==9:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221760
846: 1000004	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFE69
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Block an opponent from playing cards for 5 turns.
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==5
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000004
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==true
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 15 pieces Block an opponent from playing cards for 5 turns. (minimum 1 piece per turn, starts with 106 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Card Block
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Block an opponent from playing cards for 5 turns.
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==Card Block_blueback_130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==5
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000004
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==15
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==106
846:   [readablekeys_value] key#==17:: key==Weight:: value==1
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Card Block
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Block an opponent from playing cards for 5 turns.
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==Card Block_blueback_130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==5
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==15
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==106
846:   [writablekeys_value] key#==9:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221761
846: 12
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFE79
846:   [readablekeys_value] key#==1:: key==MultiplyPercentage:: value==400%
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Play this card to change one of your territories to a neutral and multiply its armies by 400% at the end of your turn.
846:   [readablekeys_value] key#==3:: key==CardID:: value==12
846:   [readablekeys_value] key#==4:: key==IsStoredInActiveOrders:: value==false
846:   [readablekeys_value] key#==5:: key==ActiveOrderDuration:: value==-1
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 8 pieces to multiply armies by 400% (minimum 1 piece per turn, starts with 80 pieces)
846:   [readablekeys_value] key#==8:: key==MultiplyAmount:: value==4
846:   [readablekeys_value] key#==9:: key==ID:: value==12
846:   [readablekeys_value] key#==10:: key==NumPieces:: value==8
846:   [readablekeys_value] key#==11:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==12:: key==InitialPieces:: value==80
846:   [readablekeys_value] key#==13:: key==Weight:: value==1
846:   [readablekeys_value] key#==14:: key==proxyType:: value==CardGameBlockade
846:   [readablekeys_value] key#==15:: key==readonly:: value==true
846:   [readablekeys_table] key#==16:: key==readableKeys:: value=={  1 = MultiplyPercentage,  2 = FriendlyDescription,  3 = CardID,  4 = IsStoredInActiveOrders,  5 = ActiveOrderDuration,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = MultiplyAmount,  9 = ID,  10 = NumPieces,  11 = MinimumPiecesPerTurn,  12 = InitialPieces,  13 = Weight,  14 = proxyType,  15 = readonly,  16 = readableKeys,  17 = writableKeys,}
846:   [readablekeys_table] key#==17:: key==writableKeys:: value=={  1 = MultiplyAmount,  2 = NumPieces,  3 = MinimumPiecesPerTurn,  4 = InitialPieces,  5 = Weight,}
846:   [writablekeys_value] key#==1:: key==MultiplyAmount:: value==4
846:   [writablekeys_value] key#==2:: key==NumPieces:: value==8
846:   [writablekeys_value] key#==3:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==4:: key==InitialPieces:: value==80
846:   [writablekeys_value] key#==5:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221762
846: 1000003	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFE89
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Create a special unit that does no damage but has low combat order, preventing capture temporarily. Shields last 1 turn before expiring.
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==1
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000003
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==true
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 10 pieces Create a special unit that does no damage but has low combat order, preventing capture temporarily. Shields last 1 turn before expiring. (minimum 1 piece per turn, starts with 137 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Shield
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Create a special unit that does no damage but has low combat order, preventing capture temporarily. Shields last 1 turn before expiring.
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==shield_130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==1
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000003
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==10
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==137
846:   [readablekeys_value] key#==17:: key==Weight:: value==1
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Shield
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Create a special unit that does no damage but has low combat order, preventing capture temporarily. Shields last 1 turn before expiring.
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==shield_130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==1
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==10
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==137
846:   [writablekeys_value] key#==9:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221763
846: 1000002	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFE99
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Isolate a territory for 7 turns.

No units can attack or transfer to or from the territory during this duration.
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==7
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000002
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==true
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 12 pieces Isolate a territory for 7 turns.

No units can attack or transfer to or from the territory during this duration. (minimum 1 piece per turn, starts with 103 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Isolation
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Isolate a territory for 7 turns.

No units can attack or transfer to or from the territory during this duration.
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==isolation_130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==7
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000002
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==12
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==103
846:   [readablekeys_value] key#==17:: key==Weight:: value==1
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Isolation
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Isolate a territory for 7 turns.

No units can attack or transfer to or from the territory during this duration.
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==isolation_130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==7
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==12
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==103
846:   [writablekeys_value] key#==9:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221764
846: 1000001	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFEA9
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Invoke pestilence on another player, reducing each of their territories by 5 units for 1 turn.

If a territory is reduced to 0 armies, it will turn neutral.

Special units are not affected by Pestilence, and will prevent a territory from turning to neutral.
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==1
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000001
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==true
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 11 pieces Invoke pestilence on another player, reducing each of their territories by 5 units for 1 turn.

If a territory is reduced to 0 armies, it will turn neutral.

Special units are not affected by Pestilence, and will prevent a territory from turning to neutral. (minimum 1 piece per turn, starts with 102 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Pestilence
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Invoke pestilence on another player, reducing each of their territories by 5 units for 1 turn.

If a territory is reduced to 0 armies, it will turn neutral.

Special units are not affected by Pestilence, and will prevent a territory from turning to neutral.
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==pestilence_130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==1
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000001
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==11
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==102
846:   [readablekeys_value] key#==17:: key==Weight:: value==1
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Pestilence
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Invoke pestilence on another player, reducing each of their territories by 5 units for 1 turn.

If a territory is reduced to 0 armies, it will turn neutral.

Special units are not affected by Pestilence, and will prevent a territory from turning to neutral.
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==pestilence_130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==1
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==11
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==102
846:   [writablekeys_value] key#==9:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221765
846: 1000000	custom card
846: [cards] object=card def, tablelength==1::
846: [proactive display attempt] value==table: 001AFEB9
846:   [readablekeys_value] key#==1:: key==ModID:: value==846
846:   [readablekeys_value] key#==2:: key==FriendlyDescription:: value==Launch a nuke on any territory on the map. You do not need to border the territory, nor do you need visibility to the territory.

The epicenter (targeted territory) will sustain 100% + 3 fixed damage.

Directly bordering territories will sustain 50% + 3 fixed damage, and the effect will continue outward for an additional 2 territories, reducing in amount by 25% each time.

Friendly Fire is enabled, so you will damage yourself if you own one of the impacted territories.

Damage from a nuke occurs during the BombCards phase of a turn.
846:   [readablekeys_value] key#==3:: key==ActiveOrderDuration:: value==-1
846:   [readablekeys_value] key#==4:: key==CardID:: value==1000000
846:   [readablekeys_value] key#==5:: key==IsStoredInActiveOrders:: value==false
846:   [readablekeys_value] key#==6:: key==ActiveCardExpireBehavior:: value==0
846:   [readablekeys_value] key#==7:: key==Description:: value==In 10 pieces Launch a nuke on any territory on the map. You do not need to border the territory, nor do you need visibility to the territory.

The epicenter (targeted territory) will sustain 100% + 3 fixed damage.

Directly bordering territories will sustain 50% + 3 fixed damage, and the effect will continue outward for an additional 2 territories, reducing in amount by 25% each time.

Friendly Fire is enabled, so you will damage yourself if you own one of the impacted territories.

Damage from a nuke occurs during the BombCards phase of a turn. (minimum 1 piece per turn, starts with 101 pieces)
846:   [readablekeys_value] key#==8:: key==Name:: value==Nuke
846:   [readablekeys_value] key#==9:: key==CustomCardDescription:: value==Launch a nuke on any territory on the map. You do not need to border the territory, nor do you need visibility to the territory.

The epicenter (targeted territory) will sustain 100% + 3 fixed damage.

Directly bordering territories will sustain 50% + 3 fixed damage, and the effect will continue outward for an additional 2 territories, reducing in amount by 25% each time.

Friendly Fire is enabled, so you will damage yourself if you own one of the impacted territories.

Damage from a nuke occurs during the BombCards phase of a turn.
846:   [readablekeys_value] key#==10:: key==ImageFilename:: value==nuke_card_image_130x180.png
846:   [readablekeys_value] key#==11:: key==ActiveDuration:: value==-1
846:   [readablekeys_value] key#==12:: key==ExpireBehavior:: value==1
846:   [readablekeys_value] key#==13:: key==ID:: value==1000000
846:   [readablekeys_value] key#==14:: key==NumPieces:: value==10
846:   [readablekeys_value] key#==15:: key==MinimumPiecesPerTurn:: value==1
846:   [readablekeys_value] key#==16:: key==InitialPieces:: value==101
846:   [readablekeys_value] key#==17:: key==Weight:: value==1
846:   [readablekeys_value] key#==18:: key==proxyType:: value==CardGameCustom
846:   [readablekeys_value] key#==19:: key==readonly:: value==true
846:   [readablekeys_table] key#==20:: key==readableKeys:: value=={  1 = ModID,  2 = FriendlyDescription,  3 = ActiveOrderDuration,  4 = CardID,  5 = IsStoredInActiveOrders,  6 = ActiveCardExpireBehavior,  7 = Description,  8 = Name,  9 = CustomCardDescription,  10 = ImageFilename,  11 = ActiveDuration,  12 = ExpireBehavior,  13 = ID,  14 = NumPieces,  15 = MinimumPiecesPerTurn,  16 = InitialPieces,  17 = Weight,  18 = proxyType,  19 = readonly,  20 = readableKeys,  21 = writableKeys,}
846:   [readablekeys_table] key#==21:: key==writableKeys:: value=={  1 = Name,  2 = CustomCardDescription,  3 = ImageFilename,  4 = ActiveDuration,  5 = ExpireBehavior,  6 = NumPieces,  7 = MinimumPiecesPerTurn,  8 = InitialPieces,  9 = Weight,}
846:   [writablekeys_value] key#==1:: key==Name:: value==Nuke
846:   [writablekeys_value] key#==2:: key==CustomCardDescription:: value==Launch a nuke on any territory on the map. You do not need to border the territory, nor do you need visibility to the territory.

The epicenter (targeted territory) will sustain 100% + 3 fixed damage.

Directly bordering territories will sustain 50% + 3 fixed damage, and the effect will continue outward for an additional 2 territories, reducing in amount by 25% each time.

Friendly Fire is enabled, so you will damage yourself if you own one of the impacted territories.

Damage from a nuke occurs during the BombCards phase of a turn.
846:   [writablekeys_value] key#==3:: key==ImageFilename:: value==nuke_card_image_130x180.png
846:   [writablekeys_value] key#==4:: key==ActiveDuration:: value==-1
846:   [writablekeys_value] key#==5:: key==ExpireBehavior:: value==1
846:   [writablekeys_value] key#==6:: key==NumPieces:: value==10
846:   [writablekeys_value] key#==7:: key==MinimumPiecesPerTurn:: value==1
846:   [writablekeys_value] key#==8:: key==InitialPieces:: value==101
846:   [writablekeys_value] key#==9:: key==Weight:: value==1
846: [base_value] key==__proxyID:: value==221766
846: 18 cards total
846: [all cards] object=game.Settings.Cards, tablelength==18::
846: [proactive display attempt] value==table: 001AFECE
846: [invalid/empty object] object=={}  [empty table]
]]