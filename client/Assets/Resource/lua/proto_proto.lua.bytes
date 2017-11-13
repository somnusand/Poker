
local Class ={}
function Class.create(net, client)
	local obj ={}
	Class.__index = Class
	setmetatable(obj, Class)
	obj.account = net:create_proto("account",client)
	obj.room = net:create_proto("room",client)
	obj.user = net:create_proto("user",client)
	return obj
end
function Class:on_message(data)
	local n = string.byte(data,1)
	local mod
	if (n==0) then
		mod = self.account
	local n = string.byte(data,1)
	local mod
	elseif  (n==1) then
		mod = self.room
	local n = string.byte(data,1)
	local mod
	elseif  (n==2) then
		mod = self.user
	end
	mod:init_buff(data,2)
	mod:on_message()
end

return Class
