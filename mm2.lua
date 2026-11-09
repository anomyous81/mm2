
local Env = getgenv and getgenv() or _G
local ACTIVE_KEY = Env.ACTIVE_KEY or ""

if ACTIVE_KEY == "" then
    warn("[Skider MM2] Set ACTIVE_KEY before running.")
    return
end

local launch = {}
Env.SkiderMM2Loader = launch

local function active()
    return Env.SkiderMM2Loader == launch
end

local function log(stage, message)
    if not active() then return end

    Env.SkiderMM2LoaderStatus = {
        stage = stage,
        message = message or "",
        time = os.clock()
    }

    warn("[Skider MM2 Loader] " .. stage ..
        (message and " | " .. tostring(message) or ""))
end

task.defer(function()
    log("STARTING")

    local deadline = os.clock() + 120

    while active() do
        local players = game:GetService("Players")
        local storage = game:GetService("ReplicatedStorage")
        local player = players.LocalPlayer

        if player
            and player:FindFirstChild("PlayerGui")
            and storage:FindFirstChild("Modules")
            and storage:FindFirstChild("Database")
            and storage:FindFirstChild("Remotes") then
            break
        end

        if os.clock() >= deadline then
            log("ERROR", "Required game objects unavailable")
            return
        end

        task.wait(0.2)
    end

    if not active() then return end

    log("DOWNLOADING")

    local requestFn = http_request or request

    if type(requestFn) ~= "function" then
        log("ERROR", "HTTP unavailable")
        return
    end

    local ok, response = pcall(requestFn, {
        Url = "https://api.luaw.dev/files/v2/loaders/99d1494b9d9489e4b51416b3b1675baf.lua",
        Method = "GET"
    })

    if not active() then return end

    if not ok or type(response) ~= "table"
        or type(response.Body) ~= "string"
        or response.Body == "" then
        log("ERROR", "Download failed")
        return
    end

    local status = tonumber(response.StatusCode)

    if status and (status < 200 or status >= 300) then
        log("ERROR", "HTTP " .. status)
        return
    end

    log("COMPILING")

    local compiled, loader = pcall(loadstring, response.Body)

    if not compiled or type(loader) ~= "function" then
        log("ERROR", tostring(loader))
        return
    end

    if not active() then return end

    log("EXECUTING")

    local started, err = pcall(loader)

    if not started then
        log("ERROR", tostring(err))
        return
    end

    log("LOADER_RETURNED")
end)
