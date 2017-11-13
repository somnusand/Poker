
local Class =  {}

function Class:register(name,pwd)
	self:begin_send()
	self:write_byte(0)
	self:write_int(1)
	self:write_string(name)
	self:write_string(pwd)
	self:end_send()
end

function Class:login(name,pwd)
	self:begin_send()
	self:write_byte(0)
	self:write_int(4)
	self:write_string(name)
	self:write_string(pwd)
	self:end_send()
end

function Class:ver(id)
	self:begin_send()
	self:write_byte(0)
	self:write_int(7)
	self:write_int32(id)
	self:end_send()
end

function Class:get_file(id,pos)
	self:begin_send()
	self:write_byte(0)
	self:write_int(9)
	self:write_byte(id)
	self:write_int32(pos)
	self:end_send()
end

function Class:get_file_ok(id,pos)
	self:begin_send()
	self:write_byte(0)
	self:write_int(10)
	self:write_byte(id)
	self:write_int32(pos)
	self:end_send()
end

function Class:send_gold(id,gold,check)
	self:begin_send()
	self:write_byte(0)
	self:write_int(12)
	self:write_int32(id)
	self:write_int32(gold)
	self:write_boolean(check)
	self:end_send()
end

function Class:get_gold_list(page,page_count)
	self:begin_send()
	self:write_byte(0)
	self:write_int(16)
	self:write_int32(page)
	self:write_int32(page_count)
	self:end_send()
end

function Class:write_golddata(obj)
	self:write_int32(obj.type)
	self:write_string(obj.src)
	self:write_int32(obj.des)
	self:write_int32(obj.gold)
	self:write_string(obj.time)
end

function Class:init()
	self[2] = Class.on_register_ok
	self[3] = Class.on_register_fail
	self[5] = Class.on_login_ok
	self[6] = Class.on_login_fail
	self[8] = Class.on_ver_ack
	self[11] = Class.on_get_file_ack
	self[13] = Class.on_send_gold_check_ok
	self[14] = Class.on_send_gold_ok
	self[15] = Class.on_send_gold_fail
	self[17] = Class.on_get_gold_list_ack
end

function Class:on_message()
	local n = self:read_int()
	self[n](self)
end

function Class:on_register_ok()
	self.client:account_register_ok()
end

function Class:on_register_fail()
	local error = self:read_string()
	self.client:account_register_fail(error)
end

function Class:on_login_ok()
	self.client:account_login_ok()
end

function Class:on_login_fail()
	local error = self:read_string()
	self.client:account_login_fail(error)
end

function Class:on_ver_ack()
	local type = self:read_int32()
	local url = self:read_string()
	local ver = self:read_array(Class.read_int32)
	self.client:account_ver_ack(type,url,ver)
end

function Class:on_get_file_ack()
	local per = self:read_byte()
	local datas = self:read_string()
	self.client:account_get_file_ack(per,datas)
end

function Class:on_send_gold_check_ok()
	local id = self:read_int32()
	local name = self:read_string()
	local gold = self:read_int32()
	self.client:account_send_gold_check_ok(id,name,gold)
end

function Class:on_send_gold_ok()
	self.client:account_send_gold_ok()
end

function Class:on_send_gold_fail()
	local error = self:read_string()
	self.client:account_send_gold_fail(error)
end

function Class:on_get_gold_list_ack()
	local count = self:read_int32()
	local start_id = self:read_int32()
	local list = self:read_array(Class.read_golddata)
	self.client:account_get_gold_list_ack(count,start_id,list)
end

function Class:read_golddata(obj)
	local r = {}
	r.type = self:read_int32()
	r.src = self:read_string()
	r.des = self:read_int32()
	r.gold = self:read_int32()
	r.time = self:read_string()
	return r
end

return Class
