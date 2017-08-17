-- Yes Another XP Bar.
--Config area
local JWBarHeight = 28
local JWBarWidth = 250
local JWBarAnchor = {"CENTER", UIPARENT, "CENTER", 0, -275}
local JWBarPoint = {"TOP", "JWBackdrop","TOP", 0, 0}
local JWBarbgTexture = [[Interface\addons\JW00XPBar\fer2.tga]]
local JWBarTexture = "Interface\\TargetingFrame\\UI-StatusBar"
local JWBarFont = [[Fonts\FRIZQT__.TTF]]
local JWBarFontSize = 14
local JWBarFontFlags = "NONE"
--local JWFrameType = "StatusBar"
--local JWFrameName = "JWxpBar"
--local JWFrameParent = {UIParent}
--local JWFrameTemplate = "TextStatusBar"

--Beyond here be dragons
function comma_value(n) -- credit http://richard.warburton.it seems to work OK.
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end
--[[
function CreateBar ()
	CreateFrame(JWFrameType, JWFrameName, JWFrameAnchor, JWFrameType)
end
--]]
--Create Background and Border
local backdrop = CreateFrame("Frame", "JWBackdrop", UIParent)
backdrop:SetHeight(JWBarHeight)
backdrop:SetWidth(JWBarWidth)
backdrop:SetPoint(unpack(JWBarAnchor))
backdrop:SetBackdrop({
	bgFile = JWbarbgTexture, 
	edgeFile = JWbarbgTexture, 
	tile = false, tileSize = 0, edgeSize = 1, 
	insets = { left = -1, right = -1, top = -1, bottom = -1}
})
backdrop:SetBackdropColor(0, 0, 0)
backdrop:SetBackdropBorderColor(.2, .2, .2, 0)
backdrop:EnableMouse(true)
backdrop:SetMovable(true)
backdrop:SetClampedToScreen(true)

--Rested XP Bar
local JWRestedxpBar = CreateFrame("StatusBar", "JWRestedxpBar", backdrop, "TextStatusBar")
JWRestedxpBar:SetHeight(JWBarHeight)
JWRestedxpBar:SetWidth(JWBarWidth)
JWRestedxpBar:SetPoint(unpack(JWBarPoint))
--JWRestedxpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
JWRestedxpBar:SetStatusBarTexture(JWBarTexture)
JWRestedxpBar:GetStatusBarTexture():SetHorizTile(false)
JWRestedxpBar:SetStatusBarColor(0,0,1,1)
JWRestedxpBar:Hide()

--XP Bar
local JWBar = CreateFrame("StatusBar", "JWBar", JWRestedxpBar, "TextStatusBar")
JWBar:SetWidth(JWBarWidth)
JWBar:SetHeight(JWBarHeight)
JWBar:SetPoint(unpack(JWBarPoint))
JWBar:SetStatusBarTexture(JWBarTexture)
JWBar:GetStatusBarTexture():SetHorizTile(false)
JWBar:SetStatusBarColor(0,1,0,1)

--Create frame used for mouseover, clicks, and text
local mouseFrame = CreateFrame("Frame", "JWmouseFrame", JWBar)
mouseFrame:SetAllPoints(backdrop)
--mouseFrame:SetPoint(unpack(JWBarPoint))

--Create XP Text
local Text = mouseFrame:CreateFontString("JWxpBarText", "OVERLAY")
--Text:SetFont("Fonts\\FRIZQT__.TTF",14,"NONE")
Text:SetFont(JWBarFont, JWBarFontSize, JWBarFontFlags)
Text:SetPoint("CENTER", mouseFrame, "CENTER",0,1)
Text:SetAlpha(1)

--Set Frame levels this seems to make the XP bar and Rested XP bar display properly.
backdrop:SetFrameLevel(3)
JWRestedxpBar:SetFrameLevel(1)
JWBar:SetFrameLevel(2)
mouseFrame:SetFrameLevel(3)

backdrop:SetScript("OnMouseDown", function(self, button)
  if button == "LeftButton" and (IsShiftKeyDown()) and not self.isMoving then
   self:StartMoving();
   self.isMoving = true;
  end
end)

backdrop:SetScript("OnMouseUp", function(self, button)
  if button == "LeftButton" and (IsShiftKeyDown()) and self.isMoving then
   self:StopMovingOrSizing();
   self.isMoving = false;
  end
end)
	
local function UpdateStatus()
	local JWBarCurrXP = UnitXP("player")
	local JWBarMaxXP = UnitXPMax("player")
	local JWBarRestXP = GetXPExhaustion() or 0
	local JWBarPercXP = floor(JWBarCurrXP/JWBarMaxXP*100)

	if UnitLevel("player") == MAX_PLAYER_LEVEL then
		backdrop:Hide()
		JWRestedxpBar:Hide()
		JWBar:Hide()
		mouseFrame:Hide()
	else
		JWBar:SetMinMaxValues(min(0, JWBarCurrXP),JWBarMaxXP)
		JWBar:SetValue(JWBarCurrXP)

		if JWBarRestXP then
			Text:SetText(format("%s/%s (%s%%|cffb3e1ff+%d%%|r)", comma_value(JWBarCurrXP), comma_value(JWBarMaxXP), JWBarPercXP, JWBarRestXP/JWBarMaxXP*100))
			JWRestedxpBar:Show()
			JWRestedxpBar:SetMinMaxValues(0,JWBarMaxXP)
			JWRestedxpBar:SetValue(JWBarCurrXP + JWBarRestXP)
		else
			JWRestedxpBar:Hide()
			Text:SetText(format("%s/%s (%s%%|cffb3e1ff+%d%%|r)", comma_value(JWBarCurrXP), comma_value(JWBarMaxXP), JWBarPercXP))
		end
	end
end

local frame = CreateFrame("Frame",nil,UIParent)
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("UPDATE_EXHAUSTION")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", UpdateStatus)