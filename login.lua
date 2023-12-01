-- example script that demonstrates use of setup() to pass
-- data to and from the threads
-- data to and from the threads

local counter = 1
local threads = {}

local file = io.open("responses.txt", "a")

Account = 10000000000000

function setup(thread)
	thread:set("id", counter)
	table.insert(threads, thread)
	counter = counter + 1
end

function init(args)
	requests = 0
	responses = 0

	wrk.post = "POST"
	local msg = "thread %d created"
	print(msg:format(id))
end

-- 生成一个简单的时间戳UUID
function generateSimpleUUID()
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	return string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
		return string.format("%x", v)
	end)
end

function convertToQueryString(params)
	local queryString = ""

	for key, value in pairs(params) do
		if queryString ~= "" then
			queryString = queryString .. "&"
		end

		queryString = queryString .. urlencode(tostring(key)) .. "=" .. urlencode(tostring(value))
	end

	return queryString
end

function urlencode(str)
	str = string.gsub(str, "\n", "\r\n")
	str = string.gsub(str, "([^%w %-%_%.%~])", function(c)
		return string.format("%%%02X", string.byte(c))
	end)
	str = string.gsub(str, " ", "+")
	return str
end

function request()
	math.randomseed(os.time() * 1000 + math.floor(os.clock() * 1000))
	requests = requests + 1
	wrk.method = "GET"
	local params = {}
	params.com = 1001
	params.task = 1
	params.projectId = 1
	-- 获取当前时间戳
	params.requestTime = os.time() * 1000 + math.floor(os.clock() * 1000)
	params.apkId = 201
	params.apkVer = 1
	params.spId = 0
	params.userId = 0
	params.token = ""
	params.appId = 0
	params.account = math.random(10000000000000, 99999999999999)
	params.regType = "guest"
	params.devType = "windows"
	params.sex = math.random(0, 1)
	params.distinct_id = generateSimpleUUID()

	local returnRequest = "/?" .. convertToQueryString(params)
	-- 打印request 信息
	-- print(wrk.format(nil, returnRequest))
	return wrk.format(nil, returnRequest)
end

function response(status, headers, body)
	responses = responses + 1

	file:write(body .. "\n")
end

function done(summary, latency, requests)
	for index, thread in ipairs(threads) do
		local id = thread:get("id")
		local requests = thread:get("requests")
		local responses = thread:get("responses")
		local msg = "thread %d made %d requests and got %d responses"
		print(msg:format(id, requests, responses))
	end

	file:close()
end
