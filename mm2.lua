local ACTIVE_KEY = (getgenv and getgenv().ACTIVE_KEY) or ""

if ACTIVE_KEY == "" then
    warn("Thiếu key! Hãy đặt getgenv().ACTIVE_KEY = \"your key\" trước khi chạy loader.")
    return
end

task.spawn(function()
    local ok, res = pcall(http_request, {
        Url = "https://api.luaw.dev/files/v2/loaders/99d1494b9d9489e4b51416b3b1675baf.lua",
        Method = "GET"
    })

    if not ok or not res or not res.Body then
        warn("Không tải được loader, kiểm tra lại mạng hoặc key.")
        return
    end

    loadstring(res.Body)()
end)
