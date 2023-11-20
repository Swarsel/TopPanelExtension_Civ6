-- ===========================================================================
-- ���̊֐����p��
-- ===========================================================================

TPE_BASE_RefreshYields = RefreshYields;
TPE_BASE_LateInitialize = LateInitialize;

-- ===========================================================================

--====================================================================================================================
--	UI Element Declarations
--====================================================================================================================

--	�v���C���[���̎擾
local iPlayer = Game.GetLocalPlayer()
local localPlayer = Players[iPlayer]

--	�g�b�v�p�l���{�^���̒�`
local m_AmenityYieldButton = nil
local m_PopulationYieldButton = nil
local m_ProductionYieldButton = nil
local m_LuxuryResourcesTypeYieldButton = nil

--=====================================================================================================
--	�v���C���[���s�s�����ݍς݂�����
--=====================================================================================================

--	function HasPlayerSettled()
--		local pPlayerCities = localPlayer:GetCities()
--		return pPlayerCities:GetCount() > 0
--	end

--=====================================================================================================
--	�l�����
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
	--	�s�s�\���{�^���̐����E�X�V
	m_PopulationYieldButton = m_PopulationYieldButton or m_YieldButtonSingleManager:GetInstance()
	
	--	�v���C���[�̓s�s�����擾
	local pPlayerCities = localPlayer:GetCities()
	
	--	���l��
	local pTotalPopulation = 0
	
	--	�s�s���X�g�e�L�X�g
	local sPopulationListText = ""
	
	--	�\���F
	local sTextColorGreen = "[COLOR:StatGoodCS]"
	local sTextColorRed = "[COLOR:ResMilitaryLabelCS]"
	local sTextColorEnd = "[ENDCOLOR]"

	for i, pCity in pPlayerCities:Members() do
	
		--	�s�s�����擾
		local pCityName = pCity:GetName()
		local addCityNameText = Locale.Lookup(pCityName)..": "
		
		--	�s�s�l�����擾
		local pPopulation = pCity:GetPopulation()
		local addCityPopulationText = " [ICON_Citizen] "..pPopulation
		
		--	���l�����擾
		pTotalPopulation = pTotalPopulation + pPopulation
		
		--	���������擾
		local pCityGrowth = pCity:GetGrowth()

		--	�]��H�Ƃ���ѐ�����
		local pFoodSurplus = pCityGrowth:GetFoodSurplus()
		local pGrowthModifier = pCityGrowth:GetOverallGrowthModifier()
		local pGrowthModifierPercent = math.floor((pGrowthModifier * 100)+1)
		
		--	�]��H�Ƃ̒[����؎�
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
--	�s�s���Y���
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
	--	���Y�̓{�^���̍X�V�E����
	m_ProductionYieldButton = m_ProductionYieldButton or m_YieldButtonSingleManager:GetInstance()

	--	�v���C���[�̓s�s�����擾
	local pPlayerCities = localPlayer:GetCities()
	
	--	�����Y��
	local pTotalProduction = 0
	
	--	���Y�̓��X�g�e�L�X�g
	local sProductionListText = ""
	
	for i, pCity in pPlayerCities:Members() do
	
		--	�s�s�����擾
		local pCityName = pCity:GetName()
		local addCityNameText = Locale.Lookup(pCityName)..": "
		
		--	���Y�͂��擾
		local pCityProduction = pCity:GetYield(YieldTypes.PRODUCTION)
		local pCityProductionText = ""
		
		if pCityProduction ~= 0 then
			pCityProductionText = math.floor(pCityProduction * 10) / 10
		else
			pCityProductionText = math.floor(pCityProduction)
		end
		
		local addProductionListText = "[NEWLINE]"..addCityNameText.." [ICON_Production] +"..pCityProductionText
		
		--	�e�L�X�g�ǉ�
		sProductionListText = sProductionListText..addProductionListText

		--	�����Y�͂ɉ��Z
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
--	���K���̕\��
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
	--	���K���\���{�^���̐V�K�����܂��͍X�V
	m_AmenityYieldButton = m_AmenityYieldButton or m_YieldButtonSingleManager:GetInstance()
	
	--	�v���C���[�̓s�s�����擾
	local pPlayerCities = localPlayer:GetCities()
	
	--	���v���K��
	local pTotalNetAmenity = 0
	
	--	���K�����X�g�e�L�X�g
	local sAmenityListText = ""
	
	--	�e�s�s�̉��K�����擾
	for i, pCity in pPlayerCities:Members() do
	
		--	�s�s�����擾
		local pCityName = pCity:GetName()
		local addCityNameText = Locale.Lookup(pCityName)..": "
		
		--	���������擾
		local pCityGrowth = pCity:GetGrowth()
	
		--	�]����K��
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
		
		--	���K���ɂ��Y�o�␳���擾
		local pAmenityModifier = pCityGrowth:GetHappinessNonFoodYieldModifier()

		local addAmenityModifierText = ""
		if pAmenityModifier >= 10 then
			addAmenityModifierText = " ("..Locale.Lookup("LOC_TPE_TOP_PANEL_AMENITIES_TOOLTIP_YIELD").." [COLOR:StatGoodCS]+"..pAmenityModifier.."%[ENDCOLOR])"
		elseif pAmenityModifier >= 0 then
			addAmenityModifierText = " ("..Locale.Lookup("LOC_TPE_TOP_PANEL_AMENITIES_TOOLTIP_YIELD").." +"..pAmenityModifier.."%)"
		else
			addAmenityModifierText = " ("..Locale.Lookup("LOC_TPE_TOP_PANEL_AMENITIES_TOOLTIP_YIELD").." [COLOR:ResMilitaryLabelCS]"..pAmenityModifier.."%[ENDCOLOR])"
		end
		
		--	���K�����X�g�ǋL
		sAmenityListText = sAmenityListText.."[NEWLINE]"..addCityNameText..addNetAmenityText..addAmenityModifierText
	end
	
	--	���ω��K�����v�Z
	local pNetAmenityAverage = 0
	local iCityNumCount = localPlayer:GetCities():GetCount()
	
	if pTotalNetAmenity ~= 0 and iCityNumCount >= 1 then
		pNetAmenityAverage = math.floor( pTotalNetAmenity / iCityNumCount )
	end
	
	--	���K���e�L�X�g
	local sNetAmenityAverageText = ""
	if pNetAmenityAverage > 0 then
		sNetAmenityAverageText = "+"..pNetAmenityAverage
	else
		sNetAmenityAverageText = pNetAmenityAverage
	end
	
	--	�\���F
	local ButtonYieldPerTurnColor = "StatNormalCS"
	if pNetAmenityAverage > 0 then
		ButtonYieldPerTurnColor = "StatGoodCS"
	elseif pNetAmenityAverage < 0 then
		ButtonYieldPerTurnColor = "ResMilitaryLabelCS"
	end
	
	--	�c�[���`�b�v�e�L�X�g
	local sTootTipText = Locale.Lookup("LOC_TPE_TOP_PANEL_TOTAL_AMENITIES", sNetAmenityAverageText).."[NEWLINE]"..sAmenityListText

	--	���K���{�^���̕\��
	m_AmenityYieldButton.YieldPerTurn:SetText(sNetAmenityAverageText)
	m_AmenityYieldButton.YieldBacking:SetToolTipString(sTootTipText)
	m_AmenityYieldButton.YieldPerTurn:SetColorByName(ButtonYieldPerTurnColor)
	m_AmenityYieldButton.YieldBacking:SetColorByName("ChatMessage_Whisper")
	m_AmenityYieldButton.YieldIconString:SetText("[ICON_Amenities]")
	m_AmenityYieldButton.YieldButtonStack:CalculateSize()
	--	m_AmenityYieldButton.Top:SetHide(not HasPlayerSettled())
	
end

--=====================================================================================================
--	�����������X�g�̕\��
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
	--	����������ރ{�^���̐����E�X�V
	m_LuxuryResourcesTypeYieldButton = m_LuxuryResourcesTypeYieldButton or m_YieldButtonSingleManager:GetInstance()
	
	--	�v���C���[�̏��L���������擾
	local pPlayerResources = localPlayer:GetResources()
	
	--	�v���C���[�����L���鍂�������̑���
	local pLuxuryTotalAmount = 0
	
	--	�v���C���[�����L���鍂�������̎��
	local pLuxuryTotalType = 0
	
	--	���������������X�g�e�L�X�g
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
	
	--	���������{�^���̕\��
	m_LuxuryResourcesTypeYieldButton.YieldPerTurn:SetText(sYieldPerTurnText)
	m_LuxuryResourcesTypeYieldButton.YieldBacking:SetToolTipString(sToolTopText)
	m_LuxuryResourcesTypeYieldButton.YieldPerTurn:SetColorByName("StatNormalCS")
	m_LuxuryResourcesTypeYieldButton.YieldBacking:SetColorByName("ChatMessage_Whisper")
	m_LuxuryResourcesTypeYieldButton.YieldIconString:SetText("[ICON_RESOURCE_TOYS]")
	m_LuxuryResourcesTypeYieldButton.YieldButtonStack:CalculateSize()
	
end

--=====================================================================================================
--	�g�b�v�p�l���\���v�f�̏�����
--=====================================================================================================

function RefreshYields()

	--	�Ȋw/����/�M��/���K/�ό�/�O��I�x���̎Y�o�ʂ̕\��������
	TPE_BASE_RefreshYields()
	
	
	--	�l���̕\������
	RefreshPopulation()
	
	--	���Y�͂̕\������
	RefreshProduction()
	
	--	���K���̕\������
	RefreshAmenities()
	
	--	���������̕\������
	RefreshLuxuryResourcesType()
	
	--	���ʂ̌v�Z
	Controls.YieldStack:CalculateSize();
	Controls.StaticInfoStack:CalculateSize();
	Controls.InfoStack:CalculateSize();
	
end

--====================================================================================================================

--	�㏈��
function LateInitialize()
  TPE_BASE_LateInitialize()
end
