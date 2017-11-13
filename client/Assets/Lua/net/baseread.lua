
local Class = {}


function Class:init_buff(bin,pos)
    self.bin = bin
    self.pos = pos or 1

    --log_bin(bin)
end

function Class:read_boolean()
    local b = string.byte(self.bin,self.pos)
	self.pos = self.pos + 1

    return (b ~= 0)
end

function Class:read_byte()
    local b = string.byte(self.bin,self.pos)
	self.pos = self.pos + 1

    if b >= 128 then
        return (b - 256)
    else
        return b
    end
end

function Class:read_int8()
    local b = string.byte(self.bin,self.pos)
	self.pos = self.pos + 1

    if b >= 128 then
        return (b - 256)
    else
        return b
    end
end

function Class:read_int16()
    local b1 = string.byte(self.bin,self.pos)
    local b2 = string.byte(self.bin,self.pos+1)

	self.pos = self.pos + 2

    local ret = b2 * 256 + b1

    if b2 >= 128 then
        return (ret - (256^2))
    else
        return ret
    end
end

function Class:read_int32()
    local b1 = string.byte(self.bin,self.pos)
    local b2 = string.byte(self.bin,self.pos+1)
    local b3 = string.byte(self.bin,self.pos+2)
    local b4 = string.byte(self.bin,self.pos+3)

	self.pos = self.pos + 4

    local ret = (((b4 * 256 + b3) * 256 + b2) * 256 + b1)

    if b4 >= 128 then
        return (ret - (256^4))
    else
        return ret
    end
end

function Class:read_int64()
    local b1 = string.byte(self.bin,self.pos)
    local b2 = string.byte(self.bin,self.pos+1)
    local b3 = string.byte(self.bin,self.pos+2)
    local b4 = string.byte(self.bin,self.pos+3)
    local b5 = string.byte(self.bin,self.pos+4)
    local b6 = string.byte(self.bin,self.pos+5)
    local b7 = string.byte(self.bin,self.pos+6)
    local b8 = string.byte(self.bin,self.pos+7)
	self.pos = self.pos + 8


    local ret = (((((((b8*256+b7)*256+b6)*256+b5)*256+b4)*256+b3)*256+b2)*256+b1)

    if b8 >= 128 then
        return (ret - (256^8))
    else
        return ret
    end
end

function Class:read_int()
    return self:read_int32()
end

function Class:read_float()
    local n = self:read_int32()
    return n / 100.0
end

function Class:read_single()
    local n = self:read_int32()
    return n / 100.0
end

function Class:read_string()
    local n = self:read_int16()
    if n <= 0 then
        return ""
    else
        local str = string.sub(self.bin,self.pos,self.pos+n-1)
        self.pos = self.pos + n
        return str
    end
end

function Class:read_array(fun)
    local len = self:read_int16()
    local data = {}
    local i = 0
    while i < len do
        table.insert(data,fun(self))
        i = i + 1
    end
    return data
end




return Class
