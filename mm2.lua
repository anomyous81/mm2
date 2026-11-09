
local Env = getgenv and getgenv() or _G
local ACTIVE_KEY = Env.ACTIVE_KEY or ""

if ACTIVE_KEY == "" then
    warn("[Skider MM2] Set ACTIVE_KEY before running.")
    return
end

if Env.SkiderMM2LoaderRunning then
    warn("[Skider MM2] Loader already running.")
    return
end

Env.SkiderMM2LoaderRunning = true

local launch = {}
Env.SkiderMM2Loader = launch

local function log(stage, message)
    Env.SkiderMM2LoaderStatus = {
        stage = stage,
        message = message or "",
        time = os.clock()
    }
    warn("[Skider MM2 Loader] " .. stage ..
        (message and (" | " .. tostring(message)) or ""))
end

local function active()
    return Env.SkiderMM2Loader == launch
end

local function finish()
    if active() then
        Env.SkiderMM2LoaderRunning = false
    end
end

task.defer(function()
    local ok, err = xpcall(function()
        log("WAITING_GAME")

        local deadline = os.clock() + 180
        local stableSince

        while active() do
            local ready = false

            if game:IsLoaded() then
                local players = game:GetService("Players")
                local storage = game:GetService("ReplicatedStorage")
                local player = players.LocalPlayer

                if player then
                    local gui = player:FindFirstChild("PlayerGui")

                    ready = gui ~= nil
                        and player:FindFirstChild("PlayerScripts") ~= nil
                        and storage:FindFirstChild("Modules") ~= nil
                        and storage:FindFirstChild("Database") ~= nil
                        and storage:FindFirstChild("Remotes") ~= nil
                        and player:GetAttribute("DataLoaded") == true
                        and player:GetAttribute("ClientLoaded") == true
                end
            end

            if ready then
                stableSince = stableSince or os.clock()

                if os.clock() - stableSince >= 1.5 then
                    break
                end
            else
                stableSince = nil
            end

            if os.clock() >= deadline then
                log("TIMEOUT", "Game readiness timeout")
                return
            end

            task.wait(0.25)
        end

        if not active() then return end

        log("GAME_READY")

        local requestFn = http_request or request

        if type(requestFn) ~= "function" then
            log("ERROR", "HTTP request unavailable")
            return
        end

        log("DOWNLOADING")

        local success, response = pcall(requestFn, {
            Url = "https://api.luaw.dev/files/v2/loaders/99d1494b9d9489e4b51416b3b1675baf.lua",
            Method = "GET"
        })

        if not active() then return end

        if not success or type(response) ~= "table"
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
            log("ERROR", "Invalid Lua source")
            return
        end

        if not active() then return end

        log("EXECUTING")

        local started, runtimeError = pcall(loader)

        if not started then
            log("ERROR", tostring(runtimeError))
            return
        end

        log("LOADER_RETURNED")

        local boot = Env.SkiderMM2BootStatus

        if type(boot) == "table" then
            log("MAIN_BOOT", tostring(boot.stage))
        end
    end, debug.traceback)

    if not ok then
        log("FATAL", tostring(err))
    end

    finish()
end)
