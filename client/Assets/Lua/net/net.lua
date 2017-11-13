local Socket = require("socket")
local Proto = require("proto.proto")

local basewrite = require("net.basewrite")

local Class = {}

function Class:create()
    local obj = {}

    --Class.__index = Class
    --setmetatable(obj,Class)

    for k,v in pairs(Class) do
        obj[k] = v
    end

    return obj
end

function Class:create_proto(mod,client)
    local proto = require("proto."..mod)

    local obj = require("proto."..mod)

    for k,v in pairs(proto) do
        obj[k] = v
    end

    for k,v in pairs(basewrite) do
        obj[k] = v
    end

    --basewrite.__index = basewrite
    --setmetatable(obj,basewrite)


    obj.net = self
    obj.client = client

    obj:init()

    return obj
end

function Class:connect(ip,port,client)

    self:close()




    self.proto = Proto.create(self,client)
    -- for global server
    proto = self.proto



    --  heart
    self.heart_time = 0
    self.pause_time = 0


    local addrinfo, err = Socket.dns.getaddrinfo(ip)

    local is_ipv6 = false
    local addr = ip
    if addrinfo then
        for i, alt in ipairs(addrinfo) do
            addr = alt.addr
            if alt.family == "inet6" then
                is_ipv6 = true
                break
            end
        end
    else
        print(err)
    end


    if is_ipv6 then
        self.sock = Socket.tcp6()
    else
        self.sock = Socket.tcp()
    end

    self.sock:settimeout(5)
    local ret,err = self.sock:connect(addr, port)

	if ret then
		print "connectted to server"
        self.sock:settimeout(0)
		return true
	else
        print(err)
        print("connectted to server faile", ip, tostring(port))
		return false
	end


end

function  Class:send(bin)
	local len = #bin

	local n1 =  len / 256
	local n2 =  len % 256

	bin = string.char(n1,n2) .. bin

	if self.sock and (self.pause_time <= 0) then
		self.sock:send(bin)
	end
end

function Class:set_event_disconnect(fun)
	self.on_disconnect = fun
end

function Class:update(dt)
    if self.pause_time and self.pause_time > 0 then
        self.pause_time = self.pause_time - dt
        return true
    end

	if self.sock then
        if self.heart_time  then
            if self.heart_time < 5 then
                self.heart_time = self.heart_time + dt

                if self.heart_time > 5 then
                    proto.user:heart()
                    -- print("heart")
                end
            else
                self.heart_time = self.heart_time + dt
                if self.heart_time > 10 then
                    if self.on_disconnect then
                        self.on_disconnect()
                    end
                    self.sock = nil
                    return false
                end
            end
        end

		local response, receive_status

		if self.pack_len then
		 	response, receive_status = self.sock:receive(self.pack_len)
		else
		 	response, receive_status = self.sock:receive(2)
		end

        if receive_status ~= "closed" then
            if response then
                --print( self.pack_len )
                --print( _bs(response ) )

                if self.heart_time  then
                    if self.heart_time > 5 then
                        self.heart_time = 0
                    end
                end

               	if self.pack_len then
                    self.pack_len = nil
                	self:do_response(response)
                else
                	self.pack_len = string.byte(response,1) * 256 + string.byte(response,2)
                end

                -- if self.pause_time <= 0 then
                --     return self:update(0)
                -- end
            end
        else
            --print("disconnectted")
        	if self.on_disconnect then
        		self.on_disconnect()
        	end
            self.sock = nil
            return false
        end
	end

    return true
end

function  Class:do_response(data)

    --log_bin(data)

    self.proto:on_message(data)
end

function Class:close()
	if self.timer then
		self.timer:Stop()
		self.time = nil
	end

	if self.sock then
		self.sock:close()
		self.sock = nil
	end
	self.temp_data = nil
	self.pack_len = nil
end


function Class:new()
	local o = {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function Class:destroy()
	self:close()
end

return Class
