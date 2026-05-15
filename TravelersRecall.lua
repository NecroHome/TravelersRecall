--------------------------------------------------
-- DATA
--------------------------------------------------

TravelersRecall = {}
TravelersRecall.Unlocked = {}

--------------------------------------------------
-- SILENT MESSAGE FILTER
--------------------------------------------------

ChatFrame_AddMessageEventFilter(
    "CHAT_MSG_SYSTEM",
    function(_, _, msg)

        if string.find(msg, "TR_") then
            return true
        end

    end
)

--------------------------------------------------
-- WINDOW TOGGLE
--------------------------------------------------

local function ToggleTravelersRecall()

    if TravelersRecallFrame:IsShown() then
        TravelersRecallFrame:Hide()
    else
        TravelersRecallFrame:Show()
    end

end

--------------------------------------------------
-- SLASH COMMAND
--------------------------------------------------

SLASH_TRAVELERSRECALL1 = "/tr"

SlashCmdList["TRAVELERSRECALL"] = function()

    ToggleTravelersRecall()

end

--------------------------------------------------
-- MINIMAP BUTTON
--------------------------------------------------

local minimapButton = CreateFrame(
    "Button",
    "TravelersRecallMinimapButton",
    Minimap
)

minimapButton:SetFrameStrata("MEDIUM")

minimapButton:SetWidth(32)
minimapButton:SetHeight(32)

minimapButton:SetMovable(true)
minimapButton:EnableMouse(true)

minimapButton:RegisterForDrag("LeftButton")
minimapButton:RegisterForClicks("LeftButtonUp")

minimapButton:SetPoint(
    "TOPLEFT",
    Minimap,
    "TOPLEFT",
    -6,
    6
)

--------------------------------------------------
-- ICON
--------------------------------------------------

local minimapIcon = minimapButton:CreateTexture(
    nil,
    "BACKGROUND"
)

minimapIcon:SetTexture(
    "Interface\\Icons\\Spell_Arcane_TeleportStormWind"
)

minimapIcon:SetWidth(17)
minimapIcon:SetHeight(17)

minimapIcon:SetPoint("CENTER", 1, -1)

--------------------------------------------------
-- BORDER
--------------------------------------------------

local minimapBorder = minimapButton:CreateTexture(
    nil,
    "OVERLAY"
)

minimapBorder:SetTexture(
    "Interface\\Minimap\\MiniMap-TrackingBorder"
)

minimapBorder:SetWidth(54)
minimapBorder:SetHeight(54)

minimapBorder:SetPoint("TOPLEFT")

--------------------------------------------------
-- CLICK
--------------------------------------------------

minimapButton:SetScript("OnClick", function()

    ToggleTravelersRecall()

end)

--------------------------------------------------
-- DRAG
--------------------------------------------------

minimapButton:SetScript("OnDragStart", function()

    this:StartMoving()

end)

minimapButton:SetScript("OnDragStop", function()

    this:StopMovingOrSizing()

end)

--------------------------------------------------
-- TOOLTIP
--------------------------------------------------

minimapButton:SetScript("OnEnter", function()

    GameTooltip:SetOwner(this, "ANCHOR_LEFT")

    GameTooltip:AddLine("Traveler's Recall")
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(
        "Left Click to open",
        1,
        1,
        1
    )

    GameTooltip:Show()

end)

minimapButton:SetScript("OnLeave", function()

    GameTooltip:Hide()

end)

--------------------------------------------------
-- CONTENT FRAME
--------------------------------------------------

local content = CreateFrame(
    "Frame",
    "TravelersRecallContentFrame",
    TravelersRecallScrollFrame
)

content:SetWidth(200)
content:SetHeight(1)

TravelersRecallScrollFrame:SetScrollChild(content)

--------------------------------------------------
-- SCROLLBAR
--------------------------------------------------

TravelersRecallScrollBar:SetScript(
    "OnValueChanged",
    function()

        TravelersRecallScrollFrame:SetVerticalScroll(
            this:GetValue()
        )

    end
)

TravelersRecallScrollFrame:EnableMouseWheel(true)

TravelersRecallScrollFrame:SetScript(
    "OnMouseWheel",
    function(self, delta)

        local current =
            TravelersRecallScrollBar:GetValue()

        local min, max =
            TravelersRecallScrollBar:GetMinMaxValues()

        if delta > 0 then

            TravelersRecallScrollBar:SetValue(
                math.max(current - 20, min)
            )

        else

            TravelersRecallScrollBar:SetValue(
                math.min(current + 20, max)
            )

        end

    end
)

--------------------------------------------------
-- BUTTONS
--------------------------------------------------

local buttons = {}

local function RefreshLocations()

    for _, button in ipairs(buttons) do

        button:Hide()

    end

    wipe(buttons)

    local index = 0

    for id, data in pairs(TravelersRecall.Unlocked) do

        index = index + 1

        local name = data.name
        local iconPath = data.icon

        local button = CreateFrame(
            "Button",
            "TravelersRecallButton"..id,
            content,
            "UIPanelButtonTemplate"
        )

        button:SetWidth(190)
        button:SetHeight(24)

        button:SetPoint(
            "TOPLEFT",
            content,
            "TOPLEFT",
            30,
            -((index - 1) * 26)
        )

        button:SetText(name)

        --------------------------------------------------
        -- CLICK
        --------------------------------------------------

        button:SetScript("OnClick", function()

            local editBox =
                ChatEdit_ChooseBoxForSend()

            editBox:SetText(
                ".tr teleport "..id
            )

            ChatEdit_SendText(editBox)

            editBox:SetText("")

        end)

        --------------------------------------------------
        -- ICON
        --------------------------------------------------

        local icon = button:CreateTexture(
            nil,
            "ARTWORK"
        )

        icon:SetWidth(16)
        icon:SetHeight(16)

        icon:SetTexture(iconPath)

        icon:SetPoint(
            "RIGHT",
            button,
            "LEFT",
            -4,
            0
        )

        button:SetScript("OnLeave", function()

            GameTooltip:Hide()

        end)

        table.insert(buttons, button)

    end

    --------------------------------------------------
    -- CONTENT HEIGHT
    --------------------------------------------------

    content:SetHeight(index * 26)

    --------------------------------------------------
    -- SCROLLBAR UPDATE
    --------------------------------------------------

    local maxScroll =
        math.max(0, (index * 26) - 420)

    TravelersRecallScrollBar:SetMinMaxValues(
        0,
        maxScroll
    )

end

--------------------------------------------------
-- EVENTS
--------------------------------------------------

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")

eventFrame:SetScript(
    "OnEvent",
    function(_, _, message)

        --------------------------------------------------
        -- LOGIN SYNC
        --------------------------------------------------

        if string.find(message, "TR_LIST:") then

            local _, _, id, name, icon =
                string.find(
                    message,
                    "TR_LIST:(%d+):([^:]+):(.+)"
                )

            TravelersRecall.Unlocked[
                tonumber(id)
            ] =
            {
                name = name,
                icon = icon
            }

            RefreshLocations()

            return

        end

        --------------------------------------------------
        -- NEW UNLOCK
        --------------------------------------------------

        if string.find(message, "TR_UNLOCK:") then

            local _, _, id, name, icon =
                string.find(
                    message,
                    "TR_UNLOCK:(%d+):([^:]+):(.+)"
                )

            TravelersRecall.Unlocked[
                tonumber(id)
            ] =
            {
                name = name,
                icon = icon
            }

            DEFAULT_CHAT_FRAME:AddMessage(
                "|cff00ff00Traveler's Recall:|r "
                .."New location unlocked: "
                ..name
            )

            RefreshLocations()

            return

        end

    end
)