ACTIVE_KEY = "77d53bf8442f88f008741852857eb182"

local res = http_request({
    Url = "https://api.luaw.dev/files/v2/loaders/99d1494b9d9489e4b51416b3b1675baf.lua",
    Method = "GET"
})

loadstring(res.Body)()
