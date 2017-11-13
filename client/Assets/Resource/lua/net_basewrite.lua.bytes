

local Class = require "net.baseread"


function Class:begin_send()
    self.bin = ""
end

function Class:end_send()
    --log(self._name)
    --log_bin(self.bin)
    self.net:send(self.bin)
end


function Class:write_boolean(value)
    if value then
        self.bin = self.bin .. string.char(1)
    else
        self.bin = self.bin .. string.char(0)
    end
end

function Class:write_byte(value)
    if not value then
        value = 0
    end
    self.bin = self.bin .. string.char(value)
end

function Class:write_int8(value)
    if not value then
        value = 0
    end
    self.bin = self.bin .. string.char(value)
end

function Class:get_hight_low8(value)
    local NLow = value % 256
    local N = math.floor(value/256)
    return N,NLow
end

function Class:write_int16(value)
    if not value then
        value = 0
    end
    value,low = self:get_hight_low8(value)
    self.bin = self.bin .. string.char(low)
    value,low = self:get_hight_low8(value)
    self.bin = self.bin .. string.char(low)
end

function Class:write_int32(value)
    if not value then
        value = 0
    end
    value,low = self:get_hight_low8(value) --1
    self.bin = self.bin .. string.char(low)
    value,low = self:get_hight_low8(value) --2
    self.bin = self.bin .. string.char(low)
    value,low = self:get_hight_low8(value) --3
    self.bin = self.bin .. string.char(low)
    value,low = self:get_hight_low8(value) --4
    self.bin = self.bin .. string.char(low)

end

function Class:write_int64(value)
    if not value then
        value = 0
    end
    value,low = self:get_hight_low8(value) --1
    self.bin = self.bin .. string.char(low)
    value,low = self:get_hight_low8(value) --2
    self.bin = self.bin .. string.char(low)
    value,low = self:get_hight_low8(value) --3
    self.bin = self.bin .. string.char(low)
    value,low = self:get_hight_low8(value) --4
    self.bin = self.bin .. string.char(low)
    value,low = self:get_hight_low8(value) --5
    self.bin = self.bin .. string.char(low)
    value,low = self:get_hight_low8(value) --6
    self.bin = self.bin .. string.char(low)
    value,low = self:get_hight_low8(value) --7
    self.bin = self.bin .. string.char(low)
    value,low = self:get_hight_low8(value) --8
    self.bin = self.bin .. string.char(low)
end

function Class:write_int(value)
    self:write_int32(value)
end

function Class:write_float(value)
    value = math.floor(value*100)
    self:write_int(value)
end

function Class:write_string(str)
    local n = string.len(str)
    self:write_int16(n)
    self.bin = self.bin .. str
end


function Class:write_array(fun,datas)
    local len = #datas
    self:write_int16(len)

    print(len,_s(datas))
    for _,v in ipairs(datas) do
        fun(self,v)
    end
end


return Class
