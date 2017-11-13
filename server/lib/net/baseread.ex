
defmodule BaseRead do
	def read_boolean(bin) do
		<<data, bin::binary>> = bin
		ret =  data != 0
		{ret,bin}
	end

	def read_byte(bin) do
		<<data::little-integer-size(8), bin::binary>> = bin
		{data,bin}
	end

	def read_int8(bin) do
		<<data::little-integer-size(8), bin::binary>> = bin
		{data,bin}
	end

	def read_int16(bin) do
		<<data::little-integer-size(16), bin::binary>> = bin
		{data,bin}
	end

	def read_int32(bin) do
		<<data::little-integer-size(32), bin::binary>> = bin
		{data,bin}
	end

	def read_int64(bin) do
		<<data::little-integer-size(64), bin::binary>> = bin
		{data,bin}
	end

	def read_string(bin) do
		{len,bin} = read_int16(bin)
		<<str::binary-size(len), bin::binary>> = bin
		{str,bin}
	end

	def read_float(bin) do
		{n,bin} = read_int32(bin)
		{n/100,bin}
	end

	def read_single(bin) do
		read_float(bin)
	end

	def read_int(bin) do
		read_int32(bin)
	end

	def read_array(bin,fun) do
		{n,bin} = read_int16(bin)
		read_array_n(bin,fun,n)
	end

	def read_array_n(bin,fun,n) do
		read_array_n(bin,fun,n,[])
	end

	def read_array_n(bin,_,0,array) do
		{array,bin}
	end

	def read_array_n(bin,fun,n,array) do
		{r,bin} = fun.(bin)
		read_array_n(bin,fun,n-1,array++[r])
	end

	def test() do
		{[a],b} = read_array(<<1,0,0,0,1,0,0,0>>,&read_int/1)
		IO.puts(trunc(a))
		IO.puts(b)
	end
end
