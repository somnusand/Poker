
function log(data)
	print(_s(data))
end

function log_bin(data)
	print(_bs(data))
end


function _s(data,head,name)

	if not head then
		head = ""
	end

	if not name then
		name = "{}"
	elseif type(name) ~= "string" then
		name = tostring(name)
	end

	if data == nil then
		return "\n" .. head .. name .. "[nil]"
	elseif type(data) == "table" then
		local str = "\n" .. head .. tostring(name) .. " ->"
		local nextHead = head .. "    "

		for k,v in pairs(data) do
			str = str .. _s(v,nextHead,k)
		end
		return str
	else
		return "\n" .. head .. name .. "[" .. tostring(data) .. "]"
	end
end

function _bs(data)
	local n = #data
	local str = ""
	for i=1,n do
		str = str .. "." .. string.byte(data,i)
	end
	return str
end

function clone_table( t, depth )
	local ret = {}

	for k,v in pairs(t) do
		if depth and (depth>1) then
			if type(v) == "table" then
				ret[k] = clone_table(v,depth-1)
			else
				ret[k] = v
			end
		else
			ret[k] = v
		end
	end

	return ret
end

function merge_table( t1, t2, deep )
	if deep == nil then
		deep = 1
	elseif deep == 0 then
		return
	end

	for k,v in pairs(t2) do
		if deep == 1 then
			t1[k] =  v
		elseif t1[k] == nil then
			t1[k] =  v
		else
			merge_table(t1[k],v,deep-1)
		end
	end
end

function is_menber(list,data)
	for _,v in ipairs(list) do
		if v == data then
			return true
		end
	end
	return false
end

function format_number(data)
	local low = data % 1
	local str = ""
	if low  ~= 0 then
		data = data - low
		low = math.floor(low*100)
		str = "." .. tostring(low)
	end
	while ( data > 1000) do
		local low = data % 1000
		str =  "," ..  string.format("%03d",low) .. str
		data = data - low
		data = data / 1000
	end
	return (tostring(data)..str)
end


function delete_node(name)
	local obj = UnityEngine.GameObject.Find(name)
	UnityEngine.GameObject.Destroy(obj)
end

function delete_obj(obj)
	UnityEngine.GameObject.Destroy(obj)
end

function string.split(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end

    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end
