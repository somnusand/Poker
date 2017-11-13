
require Tools

defmodule BaseWrite do


	def write_boolean(bin,data) do
		data = case data do
			false ->
				0
			_ ->
				1
			end
	  	<<bin::binary,data::little-integer-size(8)>>
	end

	def write_byte(bin,data) do
	   	<<bin::binary,data::little-integer-size(8)>>
   	end

	def write_int8(bin,data) do
		<<bin::binary,data::little-integer-size(8)>>
	end

	def write_int16(bin,data) do
		<<bin::binary,data::little-integer-size(16)>>
	end

	def write_int32(bin,data) do
		<<bin::binary,data::little-integer-size(32)>>
	end

	def write_int64(bin,data) do
		<<bin::binary,data::little-integer-size(64)>>
	end

	def write_float(bin,data) do
		n = trunc(data * 100)
		write_int32(bin,n)
	end

	def write_single(bin,data) do
		write_float(bin,data)
	end

	def write_string(bin,str) do
		len = byte_size(str)
		#Tools.log({len,str})
		#Tools.log({len,<<str::binary>>})
		<<bin::binary, len::little-integer-size(16), str::binary-size(len)>>
	end

	def write_int(bin,data) do
		write_int32(bin,data)
	end


	def write_array(bin,fun,data) do
		len = length(data)
		bin = write_int16(bin,len)
		List.foldl(data, bin, fn(x, acc) ->
			fun.(acc,x)
		end)
	end

end
