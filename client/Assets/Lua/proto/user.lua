
local Class =  {}

function Class:enter(id)
	self:begin_send()
	self:write_byte(2)
	self:write_int(1)
	self:write_int32(id)
	self:end_send()
end

function Class:wx_login(info)
	self:begin_send()
	self:write_byte(2)
	self:write_int(2)
	self:write_string(info)
	self:end_send()
end

function Class:wx_id_login(id)
	self:begin_send()
	self:write_byte(2)
	self:write_int(3)
	self:write_string(id)
	self:end_send()
end

function Class:heart()
	self:begin_send()
	self:write_byte(2)
	self:write_int(8)
	self:end_send()
end

function Class:get_txt(key)
	self:begin_send()
	self:write_byte(2)
	self:write_int(10)
	self:write_string(key)
	self:end_send()
end

function Class:write_userinfo(obj)
	self:write_int32(obj.id)
	self:write_string(obj.name)
	self:write_int32(obj.card_count)
	self:write_string(obj.head)
	self:write_byte(obj.sex)
	self:write_string(obj.ip)
end

function Class:init()
	self[4] = Class.on_wx_id
	self[5] = Class.on_user_info
	self[6] = Class.on_login_error
	self[7] = Class.on_change_card
	self[9] = Class.on_heart_ack
	self[11] = Class.on_get_txt_ack
end

function Class:on_message()
	local n = self:read_int()
	self[n](self)
end

function Class:on_wx_id()
	local id = self:read_string()
	self.client:user_wx_id(id)
end

function Class:on_user_info()
	local info = self:read_userinfo()
	self.client:user_user_info(info)
end

function Class:on_login_error()
	local error = self:read_string()
	self.client:user_login_error(error)
end

function Class:on_change_card()
	local change_count = self:read_int32()
	self.client:user_change_card(change_count)
end

function Class:on_heart_ack()
	self.client:user_heart_ack()
end

function Class:on_get_txt_ack()
	local key = self:read_string()
	local data = self:read_string()
	self.client:user_get_txt_ack(key,data)
end

function Class:read_userinfo(obj)
	local r = {}
	r.id = self:read_int32()
	r.name = self:read_string()
	r.card_count = self:read_int32()
	r.head = self:read_string()
	r.sex = self:read_byte()
	r.ip = self:read_string()
	return r
end

return Class
