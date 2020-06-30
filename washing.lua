-- LOCAL vars
local isWashing = false
local CleaningTime = 6000
-- PROMPT vars
local washing_name = "Washing"
local _control = 0xC7B5340A -- [ENTER]
local active = false

-- PROMPT
local Washinggroup = GetRandomIntInRange(0, 0xffffff)
local Washingprompt
function Washingprompt()
    Citizen.CreateThread(function()
        local str = 'Clean Up'
        local wait = 0
        Washingprompt = Citizen.InvokeNative(0x04F97DE45A519419)
        PromptSetControlAction(Washingprompt, _control)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(Washingprompt, str)
        PromptSetEnabled(Washingprompt, true)
        PromptSetVisible(Washingprompt, true)
        PromptSetHoldMode(Washingprompt, false)
        PromptSetGroup(Washingprompt, Washinggroup)
        PromptRegisterEnd(Washingprompt)
    end)
end

-- MAIN THREAD
Citizen.CreateThread(function()
    while true do
        Wait(1)
        local player = PlayerPedId()
        local pedCoords = GetEntityCoords(PlayerPedId())
        heading = GetEntityHeading(PlayerPedId())
        if IsEntityInWater(player) and not IsPedSwimming(player) and isWashing then
            TaskStartScenarioAtPosition(player, GetHashKey("WORLD_HUMAN_WASH_FACE_BUCKET_GROUND_NO_BUCKET"), pedCoords.x, pedCoords.y, pedCoords.z, heading, CleaningTime, true, false, 0, true)
            Wait(CleaningTime)
                ClearPedEnvDirt(player)
                ClearPedBloodDamage(player)
                ClearPedWetness(player)
                ClearPedDamageDecalByZone(player, 10, "ALL")
            isWashing = false
            active = false
        end
    end
end)

-- PROMPT ACTIVATION
Citizen.CreateThread(function()
    Washingprompt()
    while true do
        Wait(0)
        local player = PlayerPedId()
            if IsEntityInWater(player) and IsPedOnFoot(player) and not IsPedSwimming(player) and not isWashing and not active then
                local WashingGroupName  = CreateVarString(10, 'LITERAL_STRING', washing_name)
                PromptSetActiveGroupThisFrame(Washinggroup, WashingGroupName)
                if IsControlJustReleased(0, _control) then
                    Wait(100)
                    active = true
                end
            else
                active = false
            end
            if active then
                isWashing = true
                Wait(CleaningTime)
            end
    end
end)