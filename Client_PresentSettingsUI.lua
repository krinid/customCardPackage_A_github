require("utilities");
require("UI_Events");

function Client_PresentSettingsUI(rootParent)
	--be vigilant of referencing clientGame.Us when it ==nil for spectators, b/c they CAN initiate this function

	local UImain = CreateVert (rootParent).SetFlexibleWidth(1);

    if (Mod.Settings.NukeEnabled == true) then
        CreateLabel(UImain).SetText("[NUKE]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Launch a devastating bomb that inflicts widespread damage on the target territory and nearby areas.");
        CreateLabel(UImain).SetText("Main Territory Damage (%): " .. Mod.Settings.NukeCardMainTerritoryDamage);
        CreateLabel(UImain).SetText("Main Territory Fixed Damage: " .. Mod.Settings.NukeCardMainTerritoryFixedDamage);
        CreateLabel(UImain).SetText("Bordering Territory Damage (%): " .. Mod.Settings.NukeCardConnectedTerritoryDamage);
        CreateLabel(UImain).SetText("Bordering Territory Fixed Damage: " .. Mod.Settings.NukeCardConnectedTerritoryFixedDamage);
        if (Mod.Settings.NukeCardMainTerritoryDamage < 0 or Mod.Settings.NukeCardMainTerritoryFixedDamage < 0 or Mod.Settings.NukeCardConnectedTerritoryDamage < 0 or Mod.Settings.NukeCardConnectedTerritoryFixedDamage < 0) then
            CreateLabel(UImain).SetText("Note: Negative damage values indicate a healing effect.");
        end
        CreateLabel(UImain).SetText("Blast range (levels): " .. Mod.Settings.NukeCardNumLevelsConnectedTerritoriesToSpreadTo);
        CreateLabel(UImain).SetText("Damage reduction with spread (%): " .. Mod.Settings.NukeCardConnectedTerritoriesSpreadDamageDelta);
        CreateLabel(UImain).SetText("Friendly fire (can harm yourself): " .. tostring(Mod.Settings.NukeFriendlyfire));
        CreateLabel(UImain).SetText("Implementation phase: " .. Mod.Settings.NukeImplementationPhase);
        CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.NukeCardPiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.NukeCardStartPieces);
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.NukeCardWeight);
    end

    if (Mod.Settings.PestilenceEnabled == true) then
        CreateLabel(UImain).SetText("\n[PESTILENCE]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Spread a debilitating plague across enemy territories to slowly weaken their forces.");
        CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.PestilenceDuration);
        CreateLabel(UImain).SetText("Strength: " .. Mod.Settings.PestilenceStrength);
        CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.PestilencePiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.PestilenceStartPieces);
        CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.PestilencePiecesPerTurn);
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.PestilenceCardWeight);
    end

    if (Mod.Settings.IsolationEnabled == true) then
        CreateLabel(UImain).SetText("\n[ISOLATION]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Temporarily isolate a territory to disrupt troop movements.");
        CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.IsolationDuration);
        if (Mod.Settings.IsolationDuration == -1) then 
            CreateLabel(UImain).SetText("(-1 indicates that isolation remains permanently)");
        end
        CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.IsolationPiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.IsolationStartPieces);
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.IsolationCardWeight);
    end

    if (Mod.Settings.ShieldEnabled == true) then
        CreateLabel(UImain).SetText("\n[SHIELD]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Deploy a defensive unit that absorbs damage and prevents territory capture.");
        CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.ShieldDuration);
        if (Mod.Settings.ShieldDuration == -1) then 
            CreateLabel(UImain).SetText("(-1 indicates that the shield remains permanently)");
        end
        CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.ShieldPiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.ShieldStartPieces);
        CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.ShieldPiecesPerTurn);
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.ShieldCardWeight);
    end

    if (Mod.Settings.MonolithEnabled == true) then
        CreateLabel(UImain).SetText("\n[MONOLITH]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Erect an immovable monument that prevents enemy capture while leaving resident armies unprotected.");
        CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.MonolithDuration);
        CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.MonolithPiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.MonolithStartPieces);
        CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.MonolithPiecesPerTurn);
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.MonolithCardWeight);
    end

    if (Mod.Settings.NeutralizeEnabled == true) then
        CreateLabel(UImain).SetText("\n[NEUTRALIZE]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Convert an enemy territory to neutral, removing its current owner temporarily.");
        CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.NeutralizeDuration);
        CreateLabel(UImain).SetText("Can use on Commander: " .. tostring(Mod.Settings.NeutralizeCanUseOnCommander));
        CreateLabel(UImain).SetText("Can use on Special Units: " .. tostring(Mod.Settings.NeutralizeCanUseOnSpecials));
        CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.NeutralizePiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.NeutralizeStartPieces);
        CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.NeutralizePiecesPerTurn);
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.NeutralizeCardWeight);
    end

    if (Mod.Settings.DeneutralizeEnabled == true) then
        CreateLabel(UImain).SetText("\n[DENEUTRALIZE]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Reclaim a neutral territory and bring it under your control.");
        CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.DeneutralizePiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.DeneutralizeStartPieces);
        CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.DeneutralizePiecesPerTurn);
        CreateLabel(UImain).SetText("Can use on natural neutrals: " .. tostring(Mod.Settings.DeneutralizeCanUseOnNaturalNeutrals));
        CreateLabel(UImain).SetText("Can use on neutralized territories: " .. tostring(Mod.Settings.DeneutralizeCanUseOnNeutralizedTerritories));
        CreateLabel(UImain).SetText("Can assign to self: " .. tostring(Mod.Settings.DeneutralizeCanAssignToSelf));
        CreateLabel(UImain).SetText("Can assign to another player: " .. tostring(Mod.Settings.DeneutralizeCanAssignToAnotherPlayer));
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.DeneutralizeCardWeight);
    end

    if (Mod.Settings.CardBlockEnabled == true) then
        CreateLabel(UImain).SetText("\n[CARD BLOCK]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Prevent an opponent from playing cards for a short time.");
        CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.CardBlockDuration);
        CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.CardBlockPiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.CardBlockStartPieces);
        CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.CardBlockPiecesPerTurn);
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.CardBlockCardWeight);
    end

    if (Mod.Settings.CardPiecesEnabled == true) then
        CreateLabel(UImain).SetText("\n[CARD PIECES]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Redeem this card to receive additional cards or pieces to bolster your hand.");
        CreateLabel(UImain).SetText("Number of whole cards to grant: " .. Mod.Settings.CardPiecesNumWholeCardsToGrant);
        CreateLabel(UImain).SetText("Number of card pieces to grant: " .. Mod.Settings.CardPiecesNumCardPiecesToGrant);
        CreateLabel(UImain).SetText("Pieces needed to form a whole card: " .. Mod.Settings.CardPiecesPiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.CardPiecesStartPieces);
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.CardPiecesCardWeight);
    end

    if (Mod.Settings.AirstrikeEnabled == true) then
        CreateLabel(UImain).SetText("\n[AIRSTRIKE]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Conduct an aerial assault on any territory, bypassing normal borders.");
        CreateLabel(UImain).SetText("Can target neutrals: " .. tostring(Mod.Settings.AirstrikeCanTargetNeutrals));
        CreateLabel(UImain).SetText("Can target players: " .. tostring(Mod.Settings.AirstrikeCanTargetPlayers));
        CreateLabel(UImain).SetText("Can target fogged territories: " .. tostring(Mod.Settings.AirstrikeCanTargetFoggedTerritories));
        CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.AirstrikePiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.AirstrikeStartPieces);
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.AirstrikeCardWeight);
    end

    if (Mod.Settings.ForestFireEnabled == true) then
        CreateLabel(UImain).SetText("\n[FOREST FIRE]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Ignite a fire that gradually spreads to neighboring territories.");
        CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.ForestFireDuration);
        CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.ForestFirePiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.ForestFireStartPieces);
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.ForestFireCardWeight);
    end

    if (Mod.Settings.EarthquakeEnabled == true) then
        CreateLabel(UImain).SetText("\n[EARTHQUAKE]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Trigger a seismic event that damages multiple territories within a region.");
        CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.EarthquakeDuration);
        CreateLabel(UImain).SetText("Strength: " .. Mod.Settings.EarthquakeStrength);
        CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.EarthquakePiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.EarthquakeStartPieces);
        CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.EarthquakePiecesPerTurn);
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.EarthquakeCardWeight);
    end

    if (Mod.Settings.TornadoEnabled == true) then
        CreateLabel(UImain).SetText("\n[TORNADO]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Summon a fierce tornado to devastate a territory and spread its destructive force.");
        CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.TornadoDuration);
        CreateLabel(UImain).SetText("Strength: " .. Mod.Settings.TornadoStrength);
        CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.TornadoPiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.TornadoStartPieces);
        CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.TornadoPiecesPerTurn);
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.TornadoCardWeight);
    end

    if (Mod.Settings.QuicksandEnabled == true) then
        CreateLabel(UImain).SetText("\n[QUICKSAND]").SetColor(getColourCode("card play heading"));
        CreateLabel(UImain).SetText("Transform a territory into a treacherous quicksand that prevents units from leaving the area.");
        CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.QuicksandDuration);
        CreateLabel(UImain).SetText("Block entry into territory: " .. tostring(Mod.Settings.QuicksandBlockEntryIntoTerritory));
        CreateLabel(UImain).SetText("Block airlifts into territory: " .. tostring(Mod.Settings.QuicksandBlockAirliftsIntoTerritory));
        CreateLabel(UImain).SetText("Block airlifts from territory: " .. tostring(Mod.Settings.QuicksandBlockAirliftsFromTerritory));
        CreateLabel(UImain).SetText("Block exit from territory: " .. tostring(Mod.Settings.QuicksandBlockExitFromTerritory));
        CreateLabel(UImain).SetText("Defend damage modifier: " .. Mod.Settings.QuicksandDefendDamageTakenModifier .."x");
        CreateLabel(UImain).SetText("Attack damage modifier: " .. Mod.Settings.QuicksandAttackDamageGivenModifier .."x");
        CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.QuicksandPiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.QuicksandStartPieces);
        CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.QuicksandPiecesPerTurn);
        CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.QuicksandCardWeight);
    end

--[[	if (Mod.Settings.PestilenceEnabled == true) then
		CreateLabel(UImain).SetText("\n[PESTILENCE]").SetColor(getColourCode("card play heading"));
		CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.PestilenceDuration);
		CreateLabel(UImain).SetText("Strength: " .. Mod.Settings.PestilenceStrength);
		CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.PestilencePiecesNeeded);
		CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.PestilenceStartPieces);
		CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.PestilencePiecesPerTurn);
		CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.PestilenceCardWeight);
	end

	if (Mod.Settings.IsolationEnabled == true) then
		CreateLabel(UImain).SetText("\n[ISOLATION]").SetColor(getColourCode("card play heading"));
		CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.IsolationDuration);
		if (Mod.Settings.IsolationDuration == -1) then 
			CreateLabel(UImain).SetText("(-1 indicates that isolation remains permanently)");
		end
		CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.IsolationPiecesNeeded);
		CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.IsolationStartPieces);
		CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.IsolationCardWeight);
	end

	if (Mod.Settings.ShieldEnabled == true) then
		CreateLabel(UImain).SetText("\n[SHIELD]").SetColor(getColourCode("card play heading"));
		CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.ShieldDuration);
        if (Mod.Settings.ShieldDuration == -1) then CreateLabel(UImain).SetText("(-1 indicates that the shield remains permanently)"); end
		CreateLabel(UImain).SetText("Number of pieces to divide the card into: ".. Mod.Settings.ShieldPiecesNeeded);
        CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.ShieldStartPieces);
        CreateLabel(UImain).SetText("Minimum pieces awarded per turn: ".. Mod.Settings.ShieldPiecesPerTurn);
        CreateLabel(UImain).SetText("Card weight (how common the card is): ".. Mod.Settings.ShieldCardWeight);
    end

	if (Mod.Settings.MonolithEnabled == true) then
		CreateLabel(UImain).SetText("\n[MONOLITH]").SetColor(getColourCode("card play heading"));
		CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.MonolithDuration);
		CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.MonolithPiecesNeeded);
		CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.MonolithStartPieces);
		CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.MonolithPiecesPerTurn);
		CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.MonolithCardWeight);
	end

	if (Mod.Settings.NeutralizeEnabled == true) then
		CreateLabel(UImain).SetText("\n[NEUTRALIZE]").SetColor(getColourCode("card play heading"));
		CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.NeutralizeDuration);
		CreateLabel(UImain).SetText("Can use on Commander: " .. tostring(Mod.Settings.NeutralizeCanUseOnCommander));
		CreateLabel(UImain).SetText("Can use on Special Units: " .. tostring(Mod.Settings.NeutralizeCanUseOnSpecials));
		CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.NeutralizePiecesNeeded);
		CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.NeutralizeStartPieces);
		CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.NeutralizePiecesPerTurn);
		CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.NeutralizeCardWeight);
	end

	if (Mod.Settings.DeneutralizeEnabled == true) then
		CreateLabel(UImain).SetText("\n[DENEUTRALIZE]").SetColor(getColourCode("card play heading"));
		CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.DeneutralizePiecesNeeded);
		CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.DeneutralizeStartPieces);
		CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.DeneutralizePiecesPerTurn);
		CreateLabel(UImain).SetText("Can use on natural neutrals: " .. tostring(Mod.Settings.DeneutralizeCanUseOnNaturalNeutrals));
		CreateLabel(UImain).SetText("Can use on neutralized territories: " .. tostring(Mod.Settings.DeneutralizeCanUseOnNeutralizedTerritories));
		CreateLabel(UImain).SetText("Can assign to self: " .. tostring(Mod.Settings.DeneutralizeCanAssignToSelf));
		CreateLabel(UImain).SetText("Can assign to another player: " .. tostring(Mod.Settings.DeneutralizeCanAssignToAnotherPlayer));
		CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.DeneutralizeCardWeight);
	end

	if (Mod.Settings.CardBlockEnabled == true) then
		CreateLabel(UImain).SetText("\n[CARD BLOCK]").SetColor(getColourCode("card play heading"));
		CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.CardBlockDuration);
		CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.CardBlockPiecesNeeded);
		CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.CardBlockStartPieces);
		CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.CardBlockPiecesPerTurn);
		CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.CardBlockCardWeight);
	end

	if (Mod.Settings.CardPiecesEnabled == true) then
		CreateLabel(UImain).SetText("\n[CARD PIECES]").SetColor(getColourCode("card play heading"));
		CreateLabel(UImain).SetText("Number of whole cards to grant: " .. Mod.Settings.CardPiecesNumWholeCardsToGrant);
		CreateLabel(UImain).SetText("Number of card pieces to grant: " .. Mod.Settings.CardPiecesNumCardPiecesToGrant);
		CreateLabel(UImain).SetText("Pieces needed to form a whole card: " .. Mod.Settings.CardPiecesPiecesNeeded);
		CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.CardPiecesStartPieces);
		CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.CardPiecesCardWeight);
	end

	if (Mod.Settings.AirstrikeEnabled == true) then
		CreateLabel(UImain).SetText("\n[AIRSTRIKE]").SetColor(getColourCode("card play heading"));
		CreateLabel(UImain).SetText("Can target neutrals: " .. tostring(Mod.Settings.AirstrikeCanTargetNeutrals));
		CreateLabel(UImain).SetText("Can target players: " .. tostring(Mod.Settings.AirstrikeCanTargetPlayers));
		CreateLabel(UImain).SetText("Can target fogged territories: " .. tostring(Mod.Settings.AirstrikeCanTargetFoggedTerritories));
		CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.AirstrikePiecesNeeded);
		CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.AirstrikeStartPieces);
		CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.AirstrikeCardWeight);
	end

	if (Mod.Settings.ForestFireEnabled == true) then
		CreateLabel(UImain).SetText("\n[FOREST FIRE]").SetColor(getColourCode("card play heading"));
		CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.ForestFireDuration);
		CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.ForestFirePiecesNeeded);
		CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.ForestFireStartPieces);
		CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.ForestFireCardWeight);
	end

	if (Mod.Settings.EarthquakeEnabled == true) then
		CreateLabel(UImain).SetText("\n[EARTHQUAKE]").SetColor(getColourCode("card play heading"));
		CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.EarthquakeDuration);
		CreateLabel(UImain).SetText("Strength: " .. Mod.Settings.EarthquakeStrength);
		CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.EarthquakePiecesNeeded);
		CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.EarthquakeStartPieces);
		CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.EarthquakePiecesPerTurn);
		CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.EarthquakeCardWeight);
	end

	if (Mod.Settings.TornadoEnabled == true) then
		CreateLabel(UImain).SetText("\n[TORNADO]").SetColor(getColourCode("card play heading"));
		CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.TornadoDuration);
		CreateLabel(UImain).SetText("Strength: " .. Mod.Settings.TornadoStrength);
		CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.TornadoPiecesNeeded);
		CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.TornadoStartPieces);
		CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.TornadoPiecesPerTurn);
		CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.TornadoCardWeight);
	end

	if (Mod.Settings.QuicksandEnabled == true) then
		CreateLabel(UImain).SetText("\n[QUICKSAND]").SetColor(getColourCode("card play heading"));
		CreateLabel(UImain).SetText("Duration: " .. Mod.Settings.QuicksandDuration);
		CreateLabel(UImain).SetText("Block entry into territory: " .. tostring(Mod.Settings.QuicksandBlockEntryIntoTerritory));
		CreateLabel(UImain).SetText("Block airlifts into territory: " .. tostring(Mod.Settings.QuicksandBlockAirliftsIntoTerritory));
		CreateLabel(UImain).SetText("Block airlifts from territory: " .. tostring(Mod.Settings.QuicksandBlockAirliftsFromTerritory));
		CreateLabel(UImain).SetText("Block exit from territory: " .. tostring(Mod.Settings.QuicksandBlockExitFromTerritory));
		CreateLabel(UImain).SetText("Defend damage modifier: " .. Mod.Settings.QuicksandDefendDamageTakenModifier .."x");
		CreateLabel(UImain).SetText("Attack damage modifier: " .. Mod.Settings.QuicksandAttackDamageGivenModifier .."x");
		CreateLabel(UImain).SetText("Number of pieces to divide the card into: " .. Mod.Settings.QuicksandPiecesNeeded);
		CreateLabel(UImain).SetText("Pieces given to each player at the start: " .. Mod.Settings.QuicksandStartPieces);
		CreateLabel(UImain).SetText("Minimum pieces awarded per turn: " .. Mod.Settings.QuicksandPiecesPerTurn);
		CreateLabel(UImain).SetText("Card weight (how common the card is): " .. Mod.Settings.QuicksandCardWeight);
	end]]
end