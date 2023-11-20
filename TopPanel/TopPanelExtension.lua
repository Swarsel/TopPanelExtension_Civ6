-- ===========================================================================
-- 元の関数を継承
-- ===========================================================================

TPE_BASE_RefreshYields = RefreshYields;
TPE_BASE_LateInitialize = LateInitialize;

-- ===========================================================================

--====================================================================================================================
--	UI Element Declarations
--====================================================================================================================

--	プレイヤー情報の取得
local iPlayer = Game.GetLocalPlayer()
local localPlayer = Players[iPlayer]

--	トップパネルボタンの定義
local m_AmenityYieldButton = nil
local m_PopulationYieldButton = nil
local m_ProductionYieldButton = nil
local m_LuxuryResourcesTypeYieldButton = nil

--=====================================================================================================
--	プレイヤーが都市を建設済みか判定
--=====================================================================================================

--	function HasPlayerSettled()
--		local pPlayerCities = localPlayer:GetCities()
--		return pPlayerCities:GetCount() > 0
--	end

--=====================================================================================================
--	人口情報
--=====================================================================================================

function RefreshPopulation()
	local ePlayer		:number = Game.GetLocalPlayer();
	local localPlayer	:table= nil;
	if ePlayer ~= -1 then
		localPlayer = Players[ePlayer];
		if localPlayer == nil then
			return;
		end
	else
		return;
	end
	--	都市表示ボタンの生成・更新
	m_PopulationYieldButton = m_PopulationYieldButton or m_YieldButtonSingleManager:GetInstance()
	
	--	プレイヤーの都市情報を取得
	local pPlayerCities = localPlayer:GetCities()
	
	--	総人口
	local pTotalPopulation = 0
	
	--	都市リストテキスト
	local sPopulationListText = ""
	
	--	表示色
	local sTextColorGreen = "[COLOR:StatGoodCS]"
	local sTextColorRed = "[COLOR:ResMilitaryLabelCS]"
	local sTextColorEnd = "[ENDCOLOR]"

	for i, pCity in pPlayerCities:Members() do
	
		--	都市名を取得
		local pCityName = pCity:GetName()
		local addCityNameText = Locale.Lookup(pCityName)..": "
		
		--	都市人口を取得
		local pPopulation = pCity:GetPopulation()
		local addCityPopulationText = " [ICON_Citizen] "..pPopulation
		
		--	総人口を取得
		pTotalPopulation = pTotalPopulation + pPopulation
		
		--	成長率を取得
		local pCityGrowth = pCity:GetGrowth()

		--	余剰食糧および成長率
		local pFoodSurplus = pCityGrowth:GetFoodSurplus()
		local pGrowthModifier = pCityGrowth:GetOverallGrowthModifier()
		local pGrowthModifierPercent = math.floor((pGrowthModifier * 100)+1)
		
		--	余剰食糧の端数を切捨
		if pFoodSurplus ~= 0 then
			pFoodSurplus = math.floor(pFoodSurplus * pGrowthModifier * 10) / 10
		else
			pFoodSurplus = math.floor(pFoodSurplus * pGrowthModifier)
		end

		local addFoodSurplusText = ""
		
		if pFoodSurplus >= 0 then
			addFoodSurplusText = " [ICON_FoodSurplus] +"..pFoodSurplus
		else
			addFoodSurplusText = " [ICON_FoodSurplus] "..sTextColorRed..pFoodSurplus..sTextColorEnd
		end
			
		local addGrowthModifierText = ""
		
		if pGrowthModifierPercent > 99 then
			addGrowthModifierText = " ("..Locale.Lookup("LOC_TPE_TOP_PANEL_POPULATION_GROWTH_RATE").." "..sTextColorGreen..pGrowthModifierPercent.."%"..sTextColorEnd..")"
		else
			addGrowthModifierText = " ("..Locale.Lookup("LOC_TPE_TOP_PANEL_POPULATION_GROWTH_RATE").." "..sTextColorRed..pGrowthModifierPercent.."%"..sTextColorEnd..")"
		end
		
		local addPopulationListText = "[NEWLINE]"..addCityNameText..addCityPopulationText..addFoodSurplusText..addGrowthModifierText
		sPopulationListText = sPopulationListText..addPopulationListText

	end
	
	local sTotalPopulationText = Locale.Lookup("LOC_TPE_TOP_PANEL_TOTAL_POPULATION")..": "..pTotalPopulation
	local sToolTipText = sTotalPopulationText.."[NEWLINE]"..sPopulationListText
	
	m_PopulationYieldButton.YieldPerTurn:SetText(pTotalPopulation)
	m_PopulationYieldButton.YieldBacking:SetToolTipString(sToolTipText)
	m_PopulationYieldButton.YieldPerTurn:SetColorByName("StatNormalCS")
	m_PopulationYieldButton.YieldBacking:SetColorByName("ChatMessage_Whisper")
	m_PopulationYieldButton.YieldIconString:SetText("[ICON_Citizen]")
	m_PopulationYieldButton.YieldButtonStack:CalculateSize()

end

--=====================================================================================================
--	都市生産情報
--=====================================================================================================

function RefreshProduction()
	local ePlayer		:number = Game.GetLocalPlayer();
	local localPlayer	:table= nil;
	if ePlayer ~= -1 then
		localPlayer = Players[ePlayer];
		if localPlayer == nil then
			return;
		end
	else
		return;
	end
	--	生産力ボタンの更新・生成
	m_ProductionYieldButton = m_ProductionYieldButton or m_YieldButtonSingleManager:GetInstance()

	--	プレイヤーの都市情報を取得
	local pPlayerCities = localPlayer:GetCities()
	
	--	総生産力
	local pTotalProduction = 0
	
	--	生産力リストテキスト
	local sProductionListText = ""
	
	for i, pCity in pPlayerCities:Members() do
	
		--	都市名を取得
		local pCityName = pCity:GetName()
		local addCityNameText = Locale.Lookup(pCityName)..": "
		
		--	生産力を取得
		local pCityProduction = pCity:GetYield(YieldTypes.PRODUCTION)
		local pCityProductionText = ""
		
		if pCityProduction ~= 0 then
			pCityProductionText = math.floor(pCityProduction * 10) / 10
		else
			pCityProductionText = math.floor(pCityProduction)
		end
		
		local addProductionListText = "[NEWLINE]"..addCityNameText.." [ICON_Production] +"..pCityProductionText
		
		--	テキスト追加
		sProductionListText = sProductionListText..addProductionListText

		--	総生産力に加算
		pTotalProduction = pTotalProduction + pCityProduction
	end
	
	local sTotalProduction = ""
	
	if pTotalProduction ~= 0 then
		sTotalProduction = "+"..math.floor(pTotalProduction * 10) / 10
	else
		sTotalProduction = math.floor(pTotalProduction)
	end
	
	local sToolTipText = Locale.Lookup("LOC_TPE_TOP_PANEL_PRODUCTION_YIELD").."[NEWLINE]"..sProductionListText
	
	m_ProductionYieldButton.YieldPerTurn:SetText(sTotalProduction)
	m_ProductionYieldButton.YieldBacking:SetToolTipString(sToolTipText)
	m_ProductionYieldButton.YieldPerTurn:SetColorByName("ResProductionLabelCS")
	m_ProductionYieldButton.YieldBacking:SetColorByName("ChatMessage_Whisper")
	m_ProductionYieldButton.YieldIconString:SetText("[ICON_ProductionLarge]")
	m_ProductionYieldButton.YieldButtonStack:CalculateSize()

end

--=====================================================================================================
--	快適性の表示
--=====================================================================================================

function RefreshAmenities()
	local ePlayer		:number = Game.GetLocalPlayer();
	local localPlayer	:table= nil;
	if ePlayer ~= -1 then
		localPlayer = Players[ePlayer];
		if localPlayer == nil then
			return;
		end
	else
		return;
	end
	--	快適性表示ボタンの新規生成または更新
	m_AmenityYieldButton = m_AmenityYieldButton or m_YieldButtonSingleManager:GetInstance()
	
	--	プレイヤーの都市情報を取得
	local pPlayerCities = localPlayer:GetCities()
	
	--	合計快適性
	local pTotalNetAmenity = 0
	
	--	快適性リストテキスト
	local sAmenityListText = ""
	
	--	各都市の快適性を取得
	for i, pCity in pPlayerCities:Members() do
	
		--	都市名を取得
		local pCityName = pCity:GetName()
		local addCityNameText = Locale.Lookup(pCityName)..": "
		
		--	成長率を取得
		local pCityGrowth = pCity:GetGrowth()
	
		--	余剰快適性
		local pNetAmenity = pCityGrowth:GetAmenities() - pCityGrowth:GetAmenitiesNeeded()
		pTotalNetAmenity = pTotalNetAmenity + pNetAmenity
		
		local addNetAmenityText = ""
		if pNetAmenity > 0 then
			addNetAmenityText = " [ICON_Amenities] +"..pNetAmenity
		elseif pNetAmenity == 0 then
			addNetAmenityText = " [ICON_Amenities] "..pNetAmenity
		else
			addNetAmenityText = " [ICON_Amenities] [COLOR:ResMilitaryLabelCS]"..pNetAmenity.."[ENDCOLOR]"
		end
		
		--	快適性による産出補正を取得
		local pAmenityModifier = pCityGrowth:GetHappinessNonFoodYieldModifier()

		local addAmenityModifierText = ""
		if pAmenityModifier >= 10 then
			addAmenityModifierText = " ("..Locale.Lookup("LOC_TPE_TOP_PANEL_AMENITIES_TOOLTIP_YIELD").." [COLOR:StatGoodCS]+"..pAmenityModifier.."%[ENDCOLOR])"
		elseif pAmenityModifier >= 0 then
			addAmenityModifierText = " ("..Locale.Lookup("LOC_TPE_TOP_PANEL_AMENITIES_TOOLTIP_YIELD").." +"..pAmenityModifier.."%)"
		else
			addAmenityModifierText = " ("..Locale.Lookup("LOC_TPE_TOP_PANEL_AMENITIES_TOOLTIP_YIELD").." [COLOR:ResMilitaryLabelCS]"..pAmenityModifier.."%[ENDCOLOR])"
		end
		
		--	快適性リスト追記
		sAmenityListText = sAmenityListText.."[NEWLINE]"..addCityNameText..addNetAmenityText..addAmenityModifierText
	end
	
	--	平均快適性を計算
	local pNetAmenityAverage = 0
	local iCityNumCount = localPlayer:GetCities():GetCount()
	
	if pTotalNetAmenity ~= 0 and iCityNumCount >= 1 then
		pNetAmenityAverage = math.floor( pTotalNetAmenity / iCityNumCount )
	end
	
	--	快適性テキスト
	local sNetAmenityAverageText = ""
	if pNetAmenityAverage > 0 then
		sNetAmenityAverageText = "+"..pNetAmenityAverage
	else
		sNetAmenityAverageText = pNetAmenityAverage
	end
	
	--	表示色
	local ButtonYieldPerTurnColor = "StatNormalCS"
	if pNetAmenityAverage > 0 then
		ButtonYieldPerTurnColor = "StatGoodCS"
	elseif pNetAmenityAverage < 0 then
		ButtonYieldPerTurnColor = "ResMilitaryLabelCS"
	end
	
	--	ツールチップテキスト
	local sTootTipText = Locale.Lookup("LOC_TPE_TOP_PANEL_TOTAL_AMENITIES", sNetAmenityAverageText).."[NEWLINE]"..sAmenityListText

	--	快適性ボタンの表示
	m_AmenityYieldButton.YieldPerTurn:SetText(sNetAmenityAverageText)
	m_AmenityYieldButton.YieldBacking:SetToolTipString(sTootTipText)
	m_AmenityYieldButton.YieldPerTurn:SetColorByName(ButtonYieldPerTurnColor)
	m_AmenityYieldButton.YieldBacking:SetColorByName("ChatMessage_Whisper")
	m_AmenityYieldButton.YieldIconString:SetText("[ICON_Amenities]")
	m_AmenityYieldButton.YieldButtonStack:CalculateSize()
	--	m_AmenityYieldButton.Top:SetHide(not HasPlayerSettled())
	
end

--=====================================================================================================
--	高級資源リストの表示
--=====================================================================================================

function RefreshLuxuryResourcesType()
	local ePlayer		:number = Game.GetLocalPlayer();
	local localPlayer	:table= nil;
	if ePlayer ~= -1 then
		localPlayer = Players[ePlayer];
		if localPlayer == nil then
			return;
		end
	else
		return;
	end
	--	高級資源種類ボタンの生成・更新
	m_LuxuryResourcesTypeYieldButton = m_LuxuryResourcesTypeYieldButton or m_YieldButtonSingleManager:GetInstance()
	
	--	プレイヤーの所有資源情報を取得
	local pPlayerResources = localPlayer:GetResources()
	
	--	プレイヤーが所有する高級資源の総数
	local pLuxuryTotalAmount = 0
	
	--	プレイヤーが所有する高級資源の種類
	local pLuxuryTotalType = 0
	
	--	高級資源資源リストテキスト
	local sLuxuryResourceListText = ""
	
	for resource in GameInfo.Resources() do
		if resource.ResourceClassType ~= nil and resource.ResourceClassType == "RESOURCECLASS_LUXURY" then
			local amount = pPlayerResources:GetResourceAmount(resource.ResourceType)
			if (amount > 0) then
				local addLuxuryResourceText = "[NEWLINE][ICON_"..resource.ResourceType.."] "..Locale.Lookup(resource.Name).." "..amount
				sLuxuryResourceListText = sLuxuryResourceListText..addLuxuryResourceText
				pLuxuryTotalAmount = pLuxuryTotalAmount + amount
				pLuxuryTotalType = pLuxuryTotalType + 1
			end
		end
	end
	
	local sYieldPerTurnText = pLuxuryTotalAmount.."/"..pLuxuryTotalType
	local sToolTopText = Locale.Lookup("LOC_TPE_TOP_PANEL_LUXURY_RESOURCES", pLuxuryTotalAmount, pLuxuryTotalType).."[NEWLINE]"..sLuxuryResourceListText
	
	--	高級資源ボタンの表示
	m_LuxuryResourcesTypeYieldButton.YieldPerTurn:SetText(sYieldPerTurnText)
	m_LuxuryResourcesTypeYieldButton.YieldBacking:SetToolTipString(sToolTopText)
	m_LuxuryResourcesTypeYieldButton.YieldPerTurn:SetColorByName("StatNormalCS")
	m_LuxuryResourcesTypeYieldButton.YieldBacking:SetColorByName("ChatMessage_Whisper")
	m_LuxuryResourcesTypeYieldButton.YieldIconString:SetText("[ICON_RESOURCE_TOYS]")
	m_LuxuryResourcesTypeYieldButton.YieldButtonStack:CalculateSize()
	
end

--=====================================================================================================
--	トップパネル表示要素の初期化
--=====================================================================================================

function RefreshYields()

	--	科学/文化/信仰/金銭/観光/外交的支持の産出量の表示を処理
	TPE_BASE_RefreshYields()
	
	
	--	人口の表示処理
	RefreshPopulation()
	
	--	生産力の表示処理
	RefreshProduction()
	
	--	快適性の表示処理
	RefreshAmenities()
	
	--	高級資源の表示処理
	RefreshLuxuryResourcesType()
	
	--	情報量の計算
	Controls.YieldStack:CalculateSize();
	Controls.StaticInfoStack:CalculateSize();
	Controls.InfoStack:CalculateSize();
	
end

--====================================================================================================================

--	後処理
function LateInitialize()
  TPE_BASE_LateInitialize()
end
