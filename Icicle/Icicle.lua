
-------------------------------------------------------------------------------
-- Icicle: Retail-only Nameplate Version
-------------------------------------------------------------------------------
Icicle = LibStub("AceAddon-3.0"):NewAddon("Icicle", "AceEvent-3.0","AceConsole-3.0","AceTimer-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfig       = LibStub("AceConfig-3.0")
local self , Icicle   = Icicle , Icicle

local Icicle_TEXT    = "|cffFF7D0AIcicle|r"
local Icicle_VERSION = " 2.0"
local Icicle_AUTHOR  = " remastered by |cff0070DEbgggwp|r & |cffC41F3BXeqtr|r - Visit EZwow.org"

local Icicledb

-------------------------------------------------------------------------------
-- 1) OnInitialize, AceDB
-------------------------------------------------------------------------------
function Icicle:OnInitialize()
    self.db2 = LibStub("AceDB-3.0"):New("Icicledb", dbDefaults, "Default")
    DEFAULT_CHAT_FRAME:AddMessage(Icicle_TEXT .. Icicle_VERSION .. Icicle_AUTHOR .."  - /Icicle")

    self:RegisterChatCommand("Icicle", "ShowConfig")
    self.db2.RegisterCallback(self, "OnProfileChanged", "ChangeProfile")
    self.db2.RegisterCallback(self, "OnProfileCopied", "ChangeProfile")
    self.db2.RegisterCallback(self, "OnProfileReset", "ChangeProfile")

    Icicledb = self.db2.profile

    -- Basic config UI
    Icicle.options = {
        name = "Icicle",
        desc = "Icons above enemy nameplates showing cooldowns",
        type = 'group',
        icon = [[Interface\Icons\Spell_Nature_ForceOfNature]],
        args = {},
    }
    local bliz_options = CopyTable(Icicle.options)
    bliz_options.args.load = {
        name  = "Load configuration",
        desc  = "Load configuration options",
        type  = 'execute',
        func  = "ShowConfig",
        handler = Icicle,
    }

    LibStub("AceConfig-3.0"):RegisterOptionsTable("Icicle_bliz", bliz_options)
    AceConfigDialog:AddToBlizOptions("Icicle_bliz", "Icicle")
end

function Icicle:OnDisable()
    -- If needed, place cleanup here
end

local function initOptions()
    if Icicle.options.args.general then
        return
    end
    Icicle:OnOptionsCreate()
    for k, v in Icicle:IterateModules() do
        if type(v.OnOptionsCreate) == "function" then
            v:OnOptionsCreate()
        end
    end
    AceConfig:RegisterOptionsTable("Icicle", Icicle.options)
end

function Icicle:ShowConfig()
    initOptions()
    AceConfigDialog:Open("Icicle")
end

function Icicle:ChangeProfile()
    Icicledb = self.db2.profile
    for k,v in Icicle:IterateModules() do
        if type(v.ChangeProfile) == 'function' then
            v:ChangeProfile()
        end
    end
end

function Icicle:AddOption(key, table)
    self.options.args[key] = table
end

-------------------------------------------------------------------------------
-- 2) Option handlers
-------------------------------------------------------------------------------
local function setOption(info, value)
    local name = info[#info]
    Icicledb[name] = value
end
local function getOption(info)
    local name = info[#info]
    return Icicledb[name]
end

function Icicle:OnOptionsCreate()
    self:AddOption("profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db2))
    self.options.args.profiles.order = -1
    self:AddOption('General', {
        type = 'group',
        name = "General",
        desc = "General Options",
        order = 1,
        args = {
            enableArea = {
                type   = 'group',
                inline = true,
                name   = "General options",
                set    = setOption,
                get    = getOption,
                args   = {
                    all = {
                        type= 'toggle',
                        name= "Enable Everything",
                        desc= "Enables Icicle for BGs, world and arena",
                        order= 1,
                    },
                    arena = {
                        type= 'toggle',
                        name= "Arena",
                        desc= "Enabled in the arena",
                        disabled= function() return Icicledb.all end,
                        order= 2,
                    },
                    battleground = {
                        type= 'toggle',
                        name= "Battleground",
                        desc= "Enable Battleground",
                        disabled= function() return Icicledb.all end,
                        order= 3,
                    },
                    field = {
                        type= 'toggle',
                        name= "World",
                        desc= "Enabled outside Battlegrounds and arenas",
                        disabled= function() return Icicledb.all end,
                        order= 4,
                    },
                    iconsizer = {
                        type = "range",
                        min  = 10,
                        max  = 50,
                        step = 1,
                        name = "Icon Size",
                        desc = "Size of the Icons",
                        order= 5,
                        width= full,
                    },
                    YOffsetter = {
                        type = "range",
                        min  = -100,
                        max  = 100,
                        step = 1,
                        name = "Y Offsets",
                        desc = "Vertical offset from nameplate",
                        order= 7,
                    },
                    XOffsetter = {
                        type = "range",
                        min  = -100,
                        max  = 100,
                        step = 1,
                        name = "X Offsets",
                        desc = "Horizontal offset from nameplate",
                        order= 8,
                    },
                    alpha = {
                        type = "range",
                        min  = 0,
                        max  = 100,
                        step = 1,
                        name = "Opacity",
                        desc = "Changes opacity of Icons.",
                        order= 6
                    },
                    changeAlpha = {
                        type = 'toggle',
                        name = "Dynamic opacity",
                        desc = "Change opacity of Icons when target changes",
                        order= 9
                    },
                    cdShadow = {
                        type= 'toggle',
                        name= "Cooldown shadow",
                        desc= "Toggles cooldown shadow on icons.",
                        order= 10
                    },
                    colorByClass = {
                        type= 'toggle',
                        name= "Color nameplates by class",
                        desc= "Toggles nameplates' color by class",
                        order= 11
                    },
                },
            },
            othersArea = {
                type   = 'group',
                inline = true,
                name   = "Npc Stuff",
                set    = setOption,
                get    = getOption,
                args   = {
                    npcShorterName = {
                        type = "range",
                        min  = 0,
                        max  = 100,
                        step = 1,
                        name = "Max length of NPC name",
                        desc = "Truncates NPC names above nameplate",
                        order= 1,
                    },
                },
            },
        },
    })
end

-------------------------------------------------------------------------------
-- 3) Core tables, frames, etc.
-------------------------------------------------------------------------------
local db = {}           -- Stores cooldown icons by [dbNameString]
local eventcheck = {}
local purgeframe = CreateFrame("Frame")
local count = 0
local width
local UPDATE_RATE = .25
local pvpZone = false

-------------------------------------------------------------------------------
-- TOTEMS array (unchanged)
-------------------------------------------------------------------------------
local totemIDs = {
 8170, 2062, 2484, 2894, 8184, 10537, 10538, 25563, 58737, 58739,
 8227, 8249, 10526, 16387, 25557, 58649, 58652, 58656,
 8181, 10478, 10479, 25560, 58741, 58745,
 8177, 5394, 6375, 6377, 10462, 10463, 25567, 58755, 58756, 58757,
 8190, 10585, 10586, 10587, 25552, 58731, 58734,
 5675, 10495, 10496, 10497, 25570, 58771, 58773, 58774,
 16190, 10595, 10600, 10601, 25574, 58746, 58749,
 3599, 6363, 6364, 6365, 10437, 10438, 25533, 58699, 58703, 58704,
 6495, 5730, 6390, 6391, 6392, 10427, 10428, 25525, 58580, 58581, 58582,
 8071, 8154, 8155, 10406, 10407, 10408, 25508, 25509, 58751, 58753,
 8075, 8160, 8161, 10442, 25361, 25528, 57622, 58643, 30706, 57720, 57721, 57722, 36936,
 8143, 8512, 3738,
}
local totems = {}
for i = 1, #totemIDs do
    local t = select(1, GetSpellInfo(totemIDs[i]))
    if t and not tContains(totems, t) then
        table.insert(totems, t)
    end
end

local function isTotem(name)
    if not name then return false end
    for i = 1, #totems do
        if strfind(name, totems[i]) then
            return true
        end
    end
    return false
end

-------------------------------------------------------------------------------
-- 4) addicons, hideicons
-------------------------------------------------------------------------------
local function addicons(dbNameString, plate)
    local num = #db[dbNameString]
    if num == 0 then return end

    if not width then
        width = plate:GetWidth()
    end

    local size = Icicledb.iconsizer
    for i = 1, num do
        local icon = db[dbNameString][i]
        icon:ClearAllPoints()
        icon:SetWidth(size)
        icon:SetHeight(size)

        if i == 1 then
            icon:SetPoint("TOPLEFT", plate,
                          Icicledb.XOffsetter, size + Icicledb.YOffsetter)
        else
            icon:SetPoint("TOPLEFT", db[dbNameString][i-1], "TOPRIGHT", 2, 0)
        end
    end
end

local function hideicons(dbNameString, plate)
    plate.icicle = 0
    plate.pet    = nil
    plate.npc    = nil

    if db[dbNameString] then
        for i = 1, #db[dbNameString] do
            local icon = db[dbNameString][i]
            icon:Hide()
            icon:SetParent(nil)
            icon.parent = nil
        end
    end
end

-------------------------------------------------------------------------------
-- 5) getIcon, sourcetable
-------------------------------------------------------------------------------
local function getIcon(spellID)
    if IcicleSpellIcons and IcicleSpellIcons[spellID] then
        return IcicleSpellIcons[spellID]
    else
        return select(3, GetSpellInfo(spellID))
    end
end

local function sourcetable(Name, spellID, spellName)
    if not db[Name] then
        db[Name] = {}
    end

    local texture  = getIcon(spellID)
    local duration = IcicleCds and IcicleCds[spellID]
    if not duration then
        return  -- If we have no duration for this spell, we won't show an icon
    end

    -- check specCds override
    if db[Name].specCds and db[Name].specCds[spellID] then
        duration = db[Name].specCds[spellID]
    end

    local icon = CreateFrame("Frame", nil, UIParent)
    icon.texture = icon:CreateTexture(nil, "ARTWORK")
    icon.texture:SetAllPoints(icon)
    icon.texture:SetTexture(texture)

    icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
    icon.cooldown:SetAllPoints(icon.texture)
    icon.cooldown:SetDrawEdge(true)
    icon.cooldown:SetReverse(true)

    icon.endtime = GetTime() + duration
    icon.name    = spellName
    icon:SetAlpha(Icicledb.alpha / 100)

    -- If interrupt
    if IcicleInterrupts then
        for _, v in ipairs(IcicleInterrupts) do
            if v == spellName then
                local iconBorder = icon:CreateTexture(nil, "OVERLAY")
                iconBorder:SetTexture("Interface\\AddOns\\Icicle\\Border.tga")
                iconBorder:SetVertexColor(1, 0.6, 0.1)
                iconBorder:SetAllPoints(icon)
            end
        end
    end

    icon.cooldown:SetCooldown(GetTime(), duration)

    -- reset logic
    if (spellID == 14185 or spellID == 23989 or spellID == 11958)
       and IcicleReset and IcicleReset[spellID]
    then
        for _, resetSpell in ipairs(IcicleReset[spellID]) do
            for i2 = #db[Name],1,-1 do
                local oldIcon = db[Name][i2]
                if oldIcon.name == resetSpell then
                    if oldIcon:IsVisible() then
                        local f2 = oldIcon.parent
                        if f2 and f2.icicle and f2.icicle ~= 0 then
                            f2.icicle = 0
                        end
                    end
                    oldIcon:Hide()
                    oldIcon:SetParent(nil)
                    oldIcon.parent = nil
                    table.remove(db[Name], i2)
                    count = count - 1
                end
            end
		end
    else
        -- remove existing icon for the same spellName
        for i2 = #db[Name],1,-1 do
            local oldIcon = db[Name][i2]
            if oldIcon.name == spellName then
                if oldIcon:IsVisible() then
                    local f2 = oldIcon.parent
                    if f2 and f2.icicle then
                        f2.icicle = 0
                    end
                end
                oldIcon:Hide()
                oldIcon:SetParent(nil)
                oldIcon.parent = nil
                table.remove(db[Name], i2)
                count = count - 1
            end
        end
    end

    table.insert(db[Name], icon)
end

-------------------------------------------------------------------------------
-- 6) Purge expired icons
-------------------------------------------------------------------------------
local onpurge = 0
local function uppurge(self, elapsed)
    onpurge = onpurge + elapsed
    if onpurge >= UPDATE_RATE then
        onpurge = 0
        if count == 0 then
            -- wipe(db) if you want, but optional
        end
        for name, iconsTable in pairs(db) do
            for i = #iconsTable,1,-1 do
                local c = iconsTable[i]
                if c.endtime < GetTime() then
                    if c:IsVisible() then
                        local f2 = c.parent
                        if f2 and f2.icicle then
                            f2.icicle = 0
                        end
                    end
                    c:Hide()
                    c:SetParent(nil)
                    c.parent = nil
                    table.remove(iconsTable, i)
                    count = count - 1
                end
            end
        end
    end
end
purgeframe:SetScript("OnUpdate", uppurge)

local function RefreshPlateIcons(name)
    -- Loop all current nameplates
    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
        local unit = plate.namePlateUnitToken
        if unit then
            -- Match your same “pet => plus sign” logic:
            local isPet = (not UnitIsPlayer(unit))
            local plateName = UnitName(unit)
            if plateName then
                if not isPet then
                    plateName = plateName .. "+"
                end
                if plateName == name then
                    -- This is the correct plate for that name
                    addicons(name, plate)
                    for i = 1, #db[name] do
                        local icon = db[name][i]
                        icon:SetParent(plate)
                        icon.parent = plate
                        icon:Show()
                        if not Icicledb.cdShadow then
                            icon:SetFrameLevel(1)
                            icon.cooldown:SetFrameLevel(0)
                        end
                    end
                    plate.icicleName = name
                    plate.icicle = #db[name]
                    break
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
-- 7) Combat log & zone detection
-------------------------------------------------------------------------------
local IcicleEvent = {}

function IcicleEvent.COMBAT_LOG_EVENT_UNFILTERED(event, ...)
    local _, currentZoneType = IsInInstance()
    local _, eventType, _, srcName, srcFlags, _, _, _, spellID, spellName = ...

    if not ( Icicledb.all
          or (Icicledb.arena        and currentZoneType=="arena")
          or (Icicledb.battleground and currentZoneType=="pvp")
          or (Icicledb.field        and not pvpZone) )
    then
        return
    end

    local Name = ""

    ------------------------------------------------------------------------
    -- Exactly replicate your old “isPet => no plus, else => plus” logic
    ------------------------------------------------------------------------
    if bit.band(srcFlags, COMBATLOG_OBJECT_CONTROL_PLAYER)~=0
       and bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_HOSTILE)~=0
    then
        local isPet = (bit.band(srcFlags, COMBATLOG_OBJECT_TYPE_PET) ~= 0)
        Name = strmatch(srcName, "[^%p]+") or srcName
        if not isPet then
            Name = Name .. "+"
        end

        if not db[Name] then
            db[Name]     = {}
            db[Name].pet = isPet
        end

        -- If you have spec detection logic or pvpZone logic,
        -- replicate it here if needed.
        if icicleSpecSpellList and icicleSpecSpellList[spellID] then
            db[Name].specCds = icicleSpecSpecificCds[icicleSpecSpellList[spellID]]
        end
    end

    -- If it’s a known cooldown in your IcicleCds table
    if IcicleCds[spellID]
       and bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_HOSTILE)~=0
    then
        if (eventType=="SPELL_CAST_SUCCESS"
         or eventType=="SPELL_AURA_APPLIED"
         or eventType=="SPELL_MISSED"
         or eventType=="SPELL_SUMMON")
        then
            local isPet = (bit.band(srcFlags, COMBATLOG_OBJECT_TYPE_PET) ~= 0)
            local usedName = strmatch(srcName, "[^%p]+") or srcName
            if not isPet then
                usedName = usedName .. "+"
            end

            if not eventcheck[usedName] then
                eventcheck[usedName] = {}
            end
            if (not eventcheck[usedName][spellName]
             or GetTime() >= (eventcheck[usedName][spellName]+1))
            then
                count = count + 1
                sourcetable(usedName, spellID, spellName)
                eventcheck[usedName][spellName] = GetTime()
				RefreshPlateIcons(usedName)
            end
        end
    end
end

function IcicleEvent.PLAYER_ENTERING_WORLD(event, ...)
    wipe(eventcheck)
    count = 0
    for _, icons in pairs(db) do
        for _, icon in ipairs(icons) do
            icon:Hide()
        end
    end
    wipe(db)

    local _, instanceType = IsInInstance()
    pvpZone = (instanceType=="arena" or instanceType=="pvp")
end

function IcicleEvent.VARIABLES_LOADED(event, ...)
    if not Icicledb.colorByClassInitialized
       and GetCVar("ShowClassColorInNameplate")=="0"
    then
        Icicledb.colorByClass = false
        SetCVar("ShowClassColorInNameplate", 1, "hi")
    end
end

local IcicleCore = CreateFrame("Frame")
IcicleCore:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
IcicleCore:RegisterEvent("PLAYER_ENTERING_WORLD")
IcicleCore:RegisterEvent("VARIABLES_LOADED")
IcicleCore:SetScript("OnEvent", function(_, event, ...)
    IcicleEvent[event](IcicleEvent, ...)
end)



-------------------------------------------------------------------------------
-- 8) Retail Nameplate Event Handling
-------------------------------------------------------------------------------
local retailFrame = CreateFrame("Frame", "IcicleRetailNameplates")
retailFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
retailFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

retailFrame:SetScript("OnEvent", function(self, event, unit)
	-- print("DEBUG: Got EVENT =", event, "UNIT =", unit)
    if event == "NAME_PLATE_UNIT_ADDED" then
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate then
            --------------------------------------------------------------------
            -- The same logic: If not a pet => name.."+"
            -- In modern WoW, you can do: if not UnitIsPlayer(unit), or do a more advanced check.
            --------------------------------------------------------------------
            local isPet = (not UnitIsPlayer(unit))  -- if it’s not a player => treat as “pet or NPC”
            local name  = UnitName(unit)
            if name then
                if not isPet then
                    name = name .. "+"
                end

                if db[name] and #db[name] > 0 then
                    addicons(name, plate)
                    -- Now parent them to the plate
                    for i=1, #db[name] do
                        local icon = db[name][i]
                        icon:SetParent(plate)
                        icon.parent = plate
                        icon:Show()

                        if not Icicledb.cdShadow then
                            icon:SetFrameLevel(1)
                            icon.cooldown:SetFrameLevel(0)
                        end
                    end
                    plate.icicleName = name
                    plate.icicle    = #db[name]
                end
            end

    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local plate = C_NamePlate.GetNamePlateForUnit(unit)
        if plate and plate.icicleName then
            hideicons(plate.icicleName, plate)
            plate.icicleName = nil
        end
    end
	end
end)
