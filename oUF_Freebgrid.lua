local layoutName = "Freebgrid"
local layoutPath = "Interface\\Addons\\oUF_"..layoutName
local mediaPath = layoutPath.."\\media\\"
local fontPath = "Fonts\\"

local texture = mediaPath.."gradient"
local hightlight = mediaPath.."white"
local borderTex = mediaPath.."border"

local backdrop = {
  bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
  insets = {top = -1, left = -1, bottom = -1, right = -1},
}

local font,fontsize = fontPath.."bHEI01B.ttf",12			-- The font and fontSize for Names and Health
local symbols, symbolsSize = mediaPath.."PIZZADUDEBULLETS.ttf", 12	-- The font and fontSize for TagEvents
local symbols1, symbols1Size = mediaPath.."STYLBCC_.ttf", 12		-- The font and fontSize for TagEvents

local height, width = 40,40
local playerClass = select(2, UnitClass("player"))

local reverseColors = false	-- Reverse Units color
local highlight = true		-- MouseOver Highlight?
local debuffhighlight = true	-- use debuffhighlight?
local indicators = true 	-- Class Indicators?
local readycheck = true		-- show ready check?

local vertical = false 		-- Vertical bars?
local manabars = true		-- Mana Bars?
local Licon = true		-- Leader icon?
local ricon = true		-- Raid icon?

local banzai = LibStub("LibBanzai-2.0")

banzai:RegisterCallback(function(aggro, name, ...)
  for i = 1, select("#", ...) do
    local u = select(i, ...)
    local f = oUF.units[u]
    if f then
      if f.Banzai then
	f:Banzai(u, aggro)
      else
	f:UNIT_MAXHEALTH("OnBanzaiUpdate", f.unit)
      end
    end
  end
end)

local function menu(self)
  if(self.unit:match('party')) then
    ToggleDropDownMenu(1, nil, _G['PartyMemberFrame'..self.id..'DropDown'], 'cursor')
  else
    ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
  end
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent",
function(self, event, ...)
  --return self[event](self, ...)
  return self[event]
end
)

local function applyAuraIndicator(self)
  --========= ----- =========--
  self.AuraStatusTL = self.Health:CreateFontString(nil, "OVERLAY")
  self.AuraStatusTL:ClearAllPoints()
  self.AuraStatusTL:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -5, -5)
  self.AuraStatusTL:SetFont(font, 22, "OUTLINE")
  self:Tag(self.AuraStatusTL, oUF.classIndicators[playerClass]["TL"])

  self.AuraStatusTR = self.Health:CreateFontString(nil, "OVERLAY")
  self.AuraStatusTR:ClearAllPoints()
  self.AuraStatusTR:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 5, -5)
  self.AuraStatusTR:SetFont(font, 22, "OUTLINE")
  self:Tag(self.AuraStatusTR, oUF.classIndicators[playerClass]["TR"])

  self.AuraStatusBL = self.Health:CreateFontString(nil, "OVERLAY")
  self.AuraStatusBL:ClearAllPoints()
  self.AuraStatusBL:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", -5, -5)
  self.AuraStatusBL:SetFont(font, 22, "OUTLINE")
  self:Tag(self.AuraStatusBL, oUF.classIndicators[playerClass]["BL"])

  self.AuraStatusBR = self.Health:CreateFontString(nil, "OVERLAY")
  self.AuraStatusBR:ClearAllPoints()
  self.AuraStatusBR:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 7, -3)
  self.AuraStatusBR:SetFont(symbols, symbolsSize, "OUTLINE")
  self:Tag(self.AuraStatusBR, oUF.classIndicators[playerClass]["BR"])
  --========= ----- =========--
end

local dispellClass
do
  local t = {
    ["PRIEST"] = {
      ["Magic"] = true,
      ["Disease"] = true,
    },
    ["SHAMAN"] = {
      ["Poison"] = true,
      ["Disease"] = true,
      --["Curse"] = true, -- uncomment to enable curses for shamans
    },
    ["PALADIN"] = {
      ["Poison"] = true,
      ["Magic"] = true,
      ["Disease"] = true,
    },
    ["MAGE"] = {
      ["Curse"] = true,
    },
    ["DRUID"] = {
      ["Curse"] = true,
      ["Poison"] = true,
    },
  }
  if t[playerClass] then
    dispellClass = {}
    for k, v in pairs(t[playerClass]) do
      dispellClass[k] = v
    end
    t = nil
  end
end

--[[
local dispellPiority = {
["Magic"] = 4,
["Poison"] = 3,
["Disease"] = 1,
["Curse"] = 2,
}

local name, rank, buffTexture, count, duration, timeLeft, dtype
function f:UNIT_AURA(unit)
if not oUF.units[unit] then return end

local frame = oUF.units[unit]

if not frame.Icon then return end

local current, bTexture, dispell, dispellTexture

for i = 1, 40 do
name, rank, buffTexture, count, dtype, duration, timeLeft = UnitDebuff(unit, i)
if not name then break end

if dispellClass and dispellClass[dtype] then
dispell = dispell or dtype
dispellTexture = dispellTexture or buffTexture
if dispellPiority[dtype] > dispellPiority[dispell] then
dispell = dtype
dispellTexture = buffTexture
end
end

--disable for debuffhilight
local spellID = GetSpellInfo(name)

if debuffs[spellID] then
current = current or spellID
bTexture = bTexture or buffTexture

local prio = debuffs[spellID]
if prio > debuffs[current] then
current = spellID
bTexture = buffTexture
end
end
end

if dispellClass then
if dispell then
if dispellClass[dispell] then
local col = DebuffTypeColor[dispell]
frame.border:Show()
frame.border:SetVertexColor(col.r, col.g, col.b)
frame.Dispell = true
if not bTexture and dispellTexture then
current = dispell
bTexture = dispellTexture
end
end
else
frame.border:SetVertexColor(1, 1, 1)
frame.Dispell = false
frame.border:Hide()
end
end

if current and bTexture then
frame.IconShown = true
frame.Icon:SetTexture(bTexture)
frame.Icon:ShowText()
frame.DebuffTexture = true
else
frame.IconShown = false
frame.DebuffTexture = false
frame.Icon:HideText()
end
end
--]]
-- Target Border
local ChangedTarget = function(self)
  if (UnitInRaid'player' == 1 or GetNumPartyMembers() > 0 ) and UnitIsUnit('target', self.unit) then
    self.TargetBorder:Show()
  else
    self.TargetBorder:Hide()
  end
end

--===========================--
local colors = setmetatable({
  power = setmetatable({
    ['MANA'] = {.31,.45,.63},
    ['RAGE'] = {.69,.31,.31},
    ['FOCUS'] = {.71,.43,.27},
    ['ENERGY'] = {.65,.63,.35},
    ['RUNIC_POWER'] = {0,.8,.9},
  }, {__index = oUF.colors.power}),
  class =setmetatable({
    ["DEATHKNIGHT"] = { 0.77, 0.12, 0.23 },
    ["DRUID"] = { 1.0 , 0.49, 0.04 },
    ["HUNTER"] = { 0.67, 0.83, 0.45 },
    ["MAGE"] = { 0.41, 0.8 , 0.94 },
    ["PALADIN"] = { 0.96, 0.55, 0.73 },
    ["PRIEST"] = { 1.0 , 1.0 , 1.0 },
    ["ROGUE"] = { 1.0 , 0.96, 0.41 },
    ["SHAMAN"] = { 0.14,  0.35,  1.00 },
    ["WARLOCK"] = { 0.58, 0.51, 0.7 },
    ["WARRIOR"] = { 0.78, 0.61, 0.43 },
  }, {__index = oUF.colors.class}),
}, {__index = oUF.colors})

local round = function(x, y)
  return math.floor((x * 10 ^ y)+ 0.5) / 10 ^ y
end

local nameCache = {}
local updateHealth = function(self, event, unit, bar, current, max)
  local def = max - current
  bar:SetValue(current)
  local r, g, b, t
  if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
    local _, class = UnitClass(unit)
    t = colors.class[class]
  elseif(UnitIsPlayer(unit)) then
    local _, class = UnitClass(unit)
    t = colors.class[class]
  else
    -- MainTank target and Party Pet color
    r, g, b = .1, .8, .3
  end
  --[[
  local r, g, b, t
  if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
  r, g, b = .3, .3, .3
  elseif(UnitIsPlayer(unit)) then
  local _, class = UnitClass(unit)
  t = colors.class[class]
  else
  -- MainTank target and Party Pet color
  r, g, b = .1, .8, .3
  end
  --]]
  if(t) then
    r, g, b = t[1], t[2], t[3]
  end

  local per = round(current/max, 100)
  if (UnitIsPlayer(unit)) and (banzai:GetUnitAggroByUnitId(unit)) then
    self.Name:SetVertexColor(1, 0, 0)
  else
    -- Name Color
    self.Name:SetTextColor(r, g, b)
  end

  if(not UnitIsConnected(unit)) then
    --self.Name:SetText('|cffD7BEA5'..'D/C')
    bar.value:SetText('|cffD7BEA5'..'D/C')
    bar.value:SetAlpha(1)

  elseif(UnitIsDead(unit)) then
    --self.Name:SetText('|cffD7BEA5'..'Dead')
    bar.value:SetText('|cffD7BEA5'..'Dead')
    bar.value:SetAlpha(1)

  elseif(UnitIsGhost(unit)) then
    --self.Name:SetText('|cffD7BEA5'..'Ghost')
    bar.value:SetText('|cffD7BEA5'..'Ghost')
    bar.value:SetAlpha(1)
  elseif (per < 0.9) then
    bar.value:SetFormattedText('|cffE2799C'.."-%0.1f",math.floor(def/100)/10)
    bar.value:SetAlpha(1)
  else
    bar.value:SetAlpha(0)
    --[[
    elseif (per > 0.9) then
    self.Name:SetText(UnitName(unit):utf8sub(1, 3))
    else
    self.Name:SetFormattedText("-%0.1f",math.floor(def/100)/10)
    --]]
  end

  if self.Name then
    local name = UnitName(unit) or "Unknown"
    if nameCache[name] then
      self.Name:SetText(nameCache[name])
    else
      local substring
      for length=#name, 1, -1 do
	substring = name:utf8sub(1, length)
	self.Name:SetText(substring)
	if self.Name:GetStringWidth() <= 38 then
	  break
	end
      end
      nameCache[name] = substring
    end
  end

  -- fixing color for dead/dc units
  if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
    bar.bg:SetVertexColor(r, g, b, 0.2)
  else
    bar.bg:SetVertexColor(r, g, b, 1)
  end

  bar.bg:SetVertexColor(r, g, b)

  if(reverseColors)then
    bar:SetStatusBarColor(r, g, b)
  else
    bar:SetStatusBarColor(0, 0, 0)
  end
end

local updatePower = function(self, event, unit, bar, current, max)
  local powerType, powerTypeString = UnitPowerType(unit)

  local perc = round(current/max, 100)
  if (perc < 0.1 and UnitIsConnected(unit) and powerTypeString == 'MANA' and not UnitIsDeadOrGhost(unit)) then
    self.manaborder:Show()
  else
    self.manaborder:Hide()
  end
end

local OnEnter = function(self)
  UnitFrame_OnEnter(self)
  self.Highlight:Show()
end

local OnLeave = function(self)
  UnitFrame_OnLeave(self)
  self.Highlight:Hide()
end

-- Style
local func = function(self, unit)
  self.colors = colors
  --[[
  self:EnableMouse(true)
  self:SetScript("OnEnter", OnEnter)
  self:SetScript("OnLeave", OnLeave)
  self:RegisterForClicks"anyup"
  self:SetAttribute("*type2", "menu")
  --]]
  self.menu = menu
  self.colors = colors
  self:RegisterForClicks('AnyUp')
  self:SetScript('OnEnter', UnitFrame_OnEnter)
  self:SetScript('OnLeave', UnitFrame_OnLeave)

  self:SetAttribute('*type2', 'menu')
  self:SetAttribute('initial-height', 20)
  self:SetAttribute('initial-width', 180)

  self:SetBackdrop({bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=], insets = {top = -1, left = -1, bottom = -1, right = -1}})
  self:SetBackdropColor(0, 0, 0)

  -- Health
  local hp = CreateFrame"StatusBar"
  hp:SetStatusBarTexture(texture)
  if(reverseColors)then
    hp:SetAlpha(1)
  else
    hp:SetAlpha(0.8)
  end
  hp.frequentUpdates = true
  if(manabars)then
    if(vertical)then
      hp:SetWidth(width*.93)
      hp:SetOrientation("VERTICAL")
      hp:SetParent(self)
      hp:SetPoint"TOP"
      hp:SetPoint"BOTTOM"
      hp:SetPoint"LEFT"
    else
      hp:SetHeight(height*.93)
      hp:SetParent(self)
      hp:SetPoint"LEFT"
      hp:SetPoint"RIGHT"
      hp:SetPoint"TOP"
    end
  else
    if(vertical)then
      hp:SetWidth(width)
      hp:SetOrientation("VERTICAL")
      hp:SetParent(self)
      hp:SetPoint"TOPLEFT"
      hp:SetPoint"BOTTOMRIGHT"
    else
      hp:SetParent(self)
      hp:SetPoint"TOPLEFT"
      hp:SetPoint"BOTTOMRIGHT"
    end
  end

  local hpbg = hp:CreateTexture(nil, "BORDER")
  hpbg:SetAllPoints(hp)
  hpbg:SetTexture(texture)
  if(reverseColors)then
    hpbg:SetAlpha(0.3)
  else
    hpbg:SetAlpha(1)
  end

  -- Backdrop
  self:SetBackdrop(backdrop)
  self:SetBackdropColor(0, 0, 0)

  -- Health Text
  local hpp = hp:CreateFontString(nil, "OVERLAY")
  hpp:SetFont(font, fontsize)
  hpp:SetShadowOffset(1,-1)
  hpp:SetPoint("CENTER", 0, -8)
  hpp:SetJustifyH("CENTER")

  hp.bg = hpbg
  hp.value = hpp
  self.Health = hp
  self.OverrideUpdateHealth = updateHealth

  -- PowerBars
  if(manabars)then
    local pp = CreateFrame"StatusBar"
    pp:SetStatusBarTexture(texture)
    pp.colorPower = true
    pp.frequentUpdates = true

    if(vertical)then
      pp:SetWidth(width*.05)
      pp:SetOrientation("VERTICAL")
      pp:SetParent(self)
      pp:SetPoint"TOP"
      pp:SetPoint"BOTTOM"
      pp:SetPoint"RIGHT"
    else
      pp:SetHeight(height*.05)
      pp:SetParent(self)
      pp:SetPoint"LEFT"
      pp:SetPoint"RIGHT"
      pp:SetPoint"BOTTOM"
    end

    local ppbg = pp:CreateTexture(nil, "BORDER")
    ppbg:SetAllPoints(pp)
    ppbg:SetTexture(texture)
    ppbg.multiplier = .3
    pp.bg = ppbg

    self.Power = pp
    self.PostUpdatePower = updatePower
  end

  -- Highlight
  if(highlight)then
    local hl = hp:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(self)
    hl:SetTexture(hightlight)
    hl:SetVertexColor(1,1,1,.1)
    hl:SetBlendMode("ADD")
    hl:Hide()
    self.Highlight = hl
  end

  -- Range Alpha/SpellRange
  if(IsAddOnLoaded('oUF_SpellRange')) then
    self.SpellRange = true
    self.inRangeAlpha = 1.0 -- Frame alpha when in range
    self.outsideRangeAlpha = 0.5 -- Frame alpha when out of range
  else
    if(not unit) then
      self.Range = true
      self.inRangeAlpha = 1
      self.outsideRangeAlpha = .5
    end
  end

  -- Name
  local name = hp:CreateFontString(nil, "OVERLAY")
  name:SetPoint("CENTER", 0, 6)
  name:SetJustifyH("CENTER")
  name:SetFont(font, fontsize)
  name:SetShadowOffset(1.25, -1.25)
  name:SetTextColor(1,1,1,1)

  self.Name = name

  local manaborder = self:CreateTexture(nil, "OVERLAY")
  manaborder:SetPoint("LEFT", self, "LEFT", -5, 0)
  manaborder:SetPoint("RIGHT", self, "RIGHT", 5, 0)
  manaborder:SetPoint("TOP", self, "TOP", 0, 5)
  manaborder:SetPoint("BOTTOM", self, "BOTTOM", 0, -5)
  manaborder:SetTexture(borderTex)
  manaborder:Hide()
  manaborder:SetVertexColor(0, .1, .9, .8)
  self.manaborder = manaborder

  tBorder = self:CreateTexture(nil, "OVERLAY")
  tBorder:SetPoint("LEFT", self, "LEFT", -6, 0)
  tBorder:SetPoint("RIGHT", self, "RIGHT", 6, 0)
  tBorder:SetPoint("TOP", self, "TOP", 0, 6)
  tBorder:SetPoint("BOTTOM", self, "BOTTOM", 0, -6)
  tBorder:SetTexture(borderTex)
  tBorder:Hide()
  tBorder:SetVertexColor(.8, .8, .8, .8)
  self.TargetBorder = tBorder

  --==========--
  --  ICONS   --
  --==========--
  -- Dispel Icons
  --[[
  local icon = hp:CreateTexture(nil, "OVERLAY")
  icon:SetPoint("CENTER")
  icon:SetHeight(18)
  icon:SetWidth(18)
  icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  icon:Hide()
  icon.ShowText = function(s)
  self.Name:Hide()
  s:Show()
  end
  icon.HideText = function(s)
  self.Name:Show()
  s:Hide()
  end
  self.Icon = icon
  --]]
  local border = self:CreateTexture(nil, "OVERLAY")
  border:SetPoint("LEFT", self, "LEFT", -5, 0)
  border:SetPoint("RIGHT", self, "RIGHT", 5, 0)
  border:SetPoint("TOP", self, "TOP", 0, 5)
  border:SetPoint("BOTTOM", self, "BOTTOM", 0, -5)
  border:SetTexture(borderTex)
  border:Hide()
  border:SetVertexColor(1, 1, 1)
  self.border = border

  -- debuffhilight
  if (debuffhighlight and IsAddOnLoaded('oUF_DebuffHighlight')) then
    local dbh = hp:CreateTexture(nil, "OVERLAY")
    dbh:SetWidth(20)
    dbh:SetHeight(20)
    dbh:SetPoint("CENTER", self, "CENTER",0 ,-8)
    self.DebuffHighlight = dbh
    self.DebuffHighlightAlpha = .8
    self.DebuffHighlightUseTexture = true
  end

  -- Leader Icon
  if(Licon)then
    self.Leader = self.Health:CreateTexture(nil, "OVERLAY")
    self.Leader:SetPoint("TOPLEFT", self, -5, 8)
    self.Leader:SetHeight(16)
    self.Leader:SetWidth(16)

    self.Assistant = self.Health:CreateTexture(nil, "OVERLAY")
    self.Assistant:SetPoint("TOPLEFT", self, -5, 8)
    self.Assistant:SetHeight(16)
    self.Assistant:SetWidth(16)
    -- masterlootrt
    self.MasterLooter = self.Health:CreateTexture(nil, 'OVERLAY')
    self.MasterLooter:SetPoint('TOPLEFT', self, 10, 9)
    self.MasterLooter:SetHeight(16)
    self.MasterLooter:SetWidth(16)
  end

  -- Raid Icon
  if(ricon)then
    self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
    self.RaidIcon:SetPoint("TOPRIGHT", self, 5, 10)
    self.RaidIcon:SetHeight(16)
    self.RaidIcon:SetWidth(16)
  end

  -- ReadyCheck
  if ((readycheck) and (IsAddOnLoaded('oUF_ReadyCheck'))) then
    self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
    self.ReadyCheck:SetPoint("CENTER", self, 0, -10)
    self.ReadyCheck:SetHeight(16)
    self.ReadyCheck:SetWidth(16)
    self.ReadyCheck.delayTime = 8
    self.ReadyCheck.fadeTime = 2
  end

  if not(self:GetAttribute('unitsuffix') == 'target')then
    if(indicators)then
      applyAuraIndicator(self)
    end

    self.applyHealComm = true
  end

  self:RegisterEvent('PLAYER_TARGET_CHANGED', ChangedTarget)
  f:RegisterEvent("UNIT_AURA")

  self:SetAttribute('initial-height', height)
  self:SetAttribute('initial-width', width)

  return self
end

oUF:RegisterStyle("Freebgrid", func)

oUF:SetActiveStyle"Freebgrid"

local party = oUF:Spawn('header', 'oUF_Party')
party:SetPoint('RIGHT', UIParent, -5, 125)
party:SetManyAttributes('showParty', true,
'showPlayer', true,
'point', 'LEFT', -- Remove to grow vertically
'xOffset', 5)

--[[ Disable pet bar
party:SetAttribute("template", "oUF_Freebpets")
--]]

local raid = {}
for i = 1, 8 do
  local raidg = oUF:Spawn('header', 'oUF_Raid'..i)
  raidg:SetManyAttributes('groupFilter', tostring(i),
  'showRaid', true,
  'point', 'LEFT', -- Remove to grow vertically
  'xOffset', 5
  )
  table.insert(raid, raidg)
  if(i == 1) then
    raidg:SetPoint('RIGHT', UIParent, -5, 125)
  else
    -- raidg:SetPoint('BOTTOMLEFT', raid[i-1], 'TOPLEFT', 0, 5)
    raidg:SetPoint('TOPLEFT', raid[i-1], 'BOTTOMLEFT', 0, -5)
  end
end

--[[
local tank = oUF:Spawn('header', 'oUF_MainTank')
--tank:SetPoint('LEFT', UIParent, 5, 100)
tank:SetPoint('LEFT', UIParent, 0,0)
tank:SetManyAttributes('showRaid', true,
'groupFilter', 'MAINTANK',
'yOffset', -5)
tank:SetAttribute("template", "oUF_FreebMtargets")
--]]
local partyToggle = CreateFrame('Frame')

partyToggle:RegisterEvent('PLAYER_LOGIN')
partyToggle:RegisterEvent('RAID_ROSTER_UPDATE')
partyToggle:RegisterEvent('PARTY_LEADER_CHANGED')
partyToggle:RegisterEvent('PARTY_MEMBERS_CHANGED')
partyToggle:SetScript('OnEvent', function(self)
  if(InCombatLockdown()) then
    self:RegisterEvent('PLAYER_REGEN_ENABLED')
  else
    self:UnregisterEvent('PLAYER_REGEN_ENABLED')
    if(UnitInRaid("player")) then
      party:Hide()
      for i,v in ipairs(raid) do v:Show() end
      -- tank:Show() --tank:Show() to enable MTs
    else
      party:Show()
      for i,v in ipairs(raid) do v:Hide() end
    end
  end
end)
