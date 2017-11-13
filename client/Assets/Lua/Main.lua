
local ver = 10
is_debug_version = false


--local ip = "116.62.220.197"
-- local ip = "192.168.2.9"
local ip = "192.168.1.2"
--local ip = "116.62.220.197"
require "base.tools"
require "game.ui_onclick"



UI = require "base.ui"
Sound = require "base.sound"
local Client = require "game.client"


function set_debug()
	--ip = "192.168.3.35"
	--ip = "127.0.0.1"
	ip = "192.168.1.2"
end


--主入口函数。从这里开始lua逻辑
function Main()
	math.randomseed(os.time())

	client = Client.create()

	client:init(ip,8178,function(ok)


		if  ok then
			if GameAPI.GetPlatform() == 1 then
				proto.account:ver(ver+10000)
			else
				proto.account:ver(ver)
			end
			--UI.close_watting()
			--UI.close_all()
			--UIAPI.DeleteUI("main")
	        --UIAPI.CreateUI("main")
		else
			UI.close_watting()
	        local fun_retry = function()
	            client:init()
	        end

	        local fun_quit = function()
				print("fun quit.")
	            UnityEngine.Application.Quit()
	        end

	        UI.msg_box("网络链接失败,重连？",fun_retry,fun_quit)
		end

	end)

end

--场景切换通知
function OnLevelWasLoaded(level)
	Time.timeSinceLevelLoad = 0
end
