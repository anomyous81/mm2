local Env = getgenv and getgenv() or _G
local ACTIVE_KEY = Env.ACTIVE_KEY or ""

if ACTIVE_KEY == "" then
    warn("[Skider MM2] Set ACTIVE_KEY before running.")
    return
end

local launch = {}
Env.SkiderMM2Loader = launch

task.defer(function()
    local deadline = os.clock() + 180
    local stableSince

    repeat
        if Env.SkiderMM2Loader ~= launch then return end

        local ready = false

        if game:IsLoaded() then
            local player = game:GetService("Players").LocalPlayer
            local storage = game:GetService("ReplicatedStorage")

            ready = player
                and player:FindFirstChild("PlayerGui")
                and player:FindFirstChild("PlayerScripts")
                and storage:FindFirstChild("Modules")
                and storage:FindFirstChild("Database")
                and storage:FindFirstChild("Remotes")
        end

        if ready then
            stableSince = stableSince or os.clock()
            if os.clock() - stableSince >= 1 then break end
        else
            stableSince = nil
        end

        if os.clock() >= deadline then
            warn("[Skider MM2] Game loading timed out.")
            return
        end

        task.wait(0.25)
    until false

    local requestFn = http_request or request

    if type(requestFn) ~= "function" then
        warn("[Skider MM2] HTTP request is unavailable.")
        return
    end

    local ok, response = pcall(requestFn, {
        Url = "https://api.luaw.dev/files/v2/loaders/99d1494b9d9489e4b51416b3b1675baf.lua",
        Method = "GET",
    })

    if Env.SkiderMM2Loader ~= launch then return end

    if not ok or type(response) ~= "table"
        or type(response.Body) ~= "string" or response.Body == "" then
        warn("[Skider MM2] Failed to download loader.")
        return
    end

    local status = tonumber(response.StatusCode)

    if status and (status < 200 or status >= 300) then
        warn("[Skider MM2] Loader HTTP " .. status)
        return
    end

    local loader = loadstring(response.Body)

    if type(loader) ~= "function" then
        warn("[Skider MM2] Invalid loader response.")
        return
    end

    local started = pcall(loader)

    if not started then
        warn("[Skider MM2] Loader execution failed.")
    end
end)
