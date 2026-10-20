ACTIVE_KEY = "77d53bf8442f88f008741852857eb182"

local res = http_request({
    Url = "https://api.luaw.dev/files/v2/loaders/6mss1famhjy2gasnw5w481j8b9yr42ji.lua",
    Method = "GET"
})

loadstring(res.Body)()
