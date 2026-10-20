ACTIVE_KEY = "a67b8d5f0e52c0d5803b901073e1ab06"

local res = http_request({
    Url = "https://api.luaw.dev/files/v2/loaders/6mss1famhjy2gasnw5w481j8b9yr42ji.lua",
    Method = "GET"
})

loadstring(res.Body)()
