
local Net = require("net.net")

local Class  =  require("game.clienthandle")


function Class.create()
    local obj = {}

    Class.__index = Class,
    setmetatable(obj,Class)

    local setting = Sound

    setting.vibrate = GameAPI.LoadInt("s_vibrate",100)
    setting.music = GameAPI.LoadInt("s_music",100)
    setting.effect = GameAPI.LoadInt("s_effect",100)

    obj.setting = setting

    obj.updateHandle = UpdateBeat:Add(obj.update,obj)

    return obj
end

function Class:init(ip,port,fun)
    if ip then
        self.ip = ip
    else
        ip = self.ip
    end

    if port then
        self.port = port
    else
        port = self.port
    end

    if fun then
        self.fun = fun
    else
        fun = self.fun
    end

    self:clear()

    UI.show_watting()

    self.net = nil
    local net = Net.create()
    local ret = net:connect(ip,port,self)

    if ret then
        self.net = net
    end
    fun(ret)
end

function Class:update(ip,port)
    if self.net then
        if self.net:update(Time.deltaTime) == false then
            print("disconnetted")
            self.fun(false)
            self.net = nil            
        end
    end
end

function Class:pause_net_cmd(time)
    if self.net then
        self.net.pause_time = time
    end
end

function Class:resume_net_cmd()
    if self.net then
        self.net.pause_time = 0
    end
end

function Class:clear(ip,port)
    --if self.updateHandle then
    --    UpdateBeat:remove(self.update,self)
    --    self.updateHandle = nil
    --end
end

function Class:destroy()
    self:clear()
    if self.updateHandle then
        UpdateBeat:remove(self.update,self)
        self.updateHandle = nil
    end
end


return Class
