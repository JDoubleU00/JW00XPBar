-- Yes Another XP Bar.

--Config area
local JWBarHeight = 28
local JWBarWidth = 250
local JWBarAnchor = {"CENTER", UIPARENT, "CENTER", 0, -275}
local JWBarPoint = {"CENTER", "JWXPBarFrame","CENTER", 0, 0}
local JWBarTexture = "Interface\\TargetingFrame\\UI-StatusBar"
--local JWBarFont = [[Fonts\FRIZQT__.TTF]]
local JWBarFont = [[Interface\addons\JWXPBar\ROADWAY_.ttf]]
local JWBarFontSize = 15
local JWBarFontFlags = "NONE"
local JWRestColor = { r = 0, g = 0, b = 1 }
local JWXPColor = { r = 0, g = 1, b = 0 }
--local JWFrameType = "StatusBar"
--local JWFrameName = "JWxpBar"
--local JWFrameParent = {UIParent}
--local JWFrameTemplate = "TextStatusBar"

--Beyond here be dragons
function comma_value(n)
  return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()
end

local JWXPBarFrame = CreateFrame("Frame", "JWXPBarFrame", UIParent)
JWXPBarFrame:SetFrameStrata("HIGH")
JWXPBarFrame:SetHeight(JWBarHeight)
JWXPBarFrame:SetWidth(JWBarWidth)
JWXPBarFrame:SetPoint(unpack(JWBarAnchor))
JWXPBarFrame:EnableMouse(true)
JWXPBarFrame:SetMovable(true)
JWXPBarFrame:SetClampedToScreen(true)

--Create Background and Border
local backdrop = JWXPBarFrame:CreateTexture(nil, "BACKGROUND")
backdrop:SetHeight(JWBarHeight)
backdrop:SetWidth(JWBarWidth)
backdrop:SetPoint(unpack(JWBarPoint))
backdrop:SetTexture(JWBarTexture)
backdrop:SetVertexColor(0.1, 0.1, 0.1)
JWXPBarFrame.backdrop = backdrop

--Rested XP Bar
local JWRestBar = CreateFrame("StatusBar", nil, JWXPBarFrame)
JWRestBar:SetHeight(JWBarHeight)
JWRestBar:SetWidth(JWBarWidth)
JWRestBar:SetPoint(unpack(JWBarPoint))
JWRestBar:SetStatusBarTexture(JWBarTexture)
JWRestBar:GetStatusBarTexture():SetHorizTile(false)
JWRestBar:SetStatusBarColor(JWRestColor.r, JWRestColor.g, JWRestColor.b, 1)
JWXPBarFrame.JWRestBar = JWRestBar

--XP Bar
local JWXPBar = CreateFrame("StatusBar", "JWXPBar", JWRestBar)
JWXPBar:SetWidth(JWBarWidth)
JWXPBar:SetHeight(JWBarHeight)
JWXPBar:SetPoint(unpack(JWBarPoint))
JWXPBar:SetStatusBarTexture(JWBarTexture)
JWXPBar:GetStatusBarTexture():SetHorizTile(false)
JWXPBar:SetStatusBarColor(JWXPColor.r, JWXPColor.g, JWXPColor.b, 1)
JWXPBarFrame.JWXPBar = JWXPBar

--Create XP Text
local Text = JWXPBar:CreateFontString("JWxpBarText", "OVERLAY")
Text:SetFont(JWBarFont, JWBarFontSize, JWBarFontFlags)
Text:SetPoint("CENTER", JWXPBar, "CENTER",0,1)
Text:SetAlpha(1)

JWXPBarFrame:SetScript("OnMouseDown", function(self, button)
  if button == "LeftButton" and (IsShiftKeyDown()) and not self.isMoving then
   self:StartMoving();
   self.isMoving = true;
  end
end)

JWXPBarFrame:SetScript("OnMouseUp", function(self, button)
  if button == "LeftButton" and (IsShiftKeyDown()) and self.isMoving then
   self:StopMovingOrSizing();
   self.isMoving = false;
  end
end)
	
local function UpdateStatus()
	local JWCurrXP, JWMaxXP, JWRestXP, JWPercXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion() or 0
	local JWPercXP = floor(JWCurrXP/JWMaxXP*100)

	if UnitLevel("player") == MAX_PLAYER_LEVEL then
		backdrop:Hide()
		JWRestBar:Hide()
		JWXPBar:Hide()
		JWXPBarFrame:Hide()
	else
		JWXPBar:SetMinMaxValues(min(0, JWCurrXP),JWMaxXP)
		JWXPBar:SetValue(JWCurrXP)
		if JWRestXP then
			Text:SetText(format("%s/%s (%s%%|cffb3e1ff+%d%%|r)", comma_value(JWCurrXP), comma_value(JWMaxXP), JWPercXP, JWRestXP/JWMaxXP*100))
			JWRestBar:Show()
			JWRestBar:SetMinMaxValues(0,JWMaxXP)
			if JWCurrXP + JWRestXP > JWMaxXP then
				JWRestBar:SetValue(JWMaxXP)
			else
				JWRestBar:SetValue(JWCurrXP + JWRestXP)
			end
		else
			--JWRestBar:Hide()
			JWRestBar:SetMinMaxValues(0,1)
			JWRestBar:SetValue(0)
			Text:SetText(format("%s/%s (%s%%|cffb3e1ff+%d%%|r)", comma_value(JWCurrXP), comma_value(JWMaxXP), JWPercXP))
		end
	end
end

JWXPBarFrame:RegisterEvent("PLAYER_LEVEL_UP")
JWXPBarFrame:RegisterEvent("PLAYER_XP_UPDATE")
JWXPBarFrame:RegisterEvent("UPDATE_EXHAUSTION")
JWXPBarFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
JWXPBarFrame:SetScript("OnEvent", UpdateStatus)