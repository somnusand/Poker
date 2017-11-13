
defmodule Proto.Account do
	import BaseWrite, only: :functions
	import BaseRead, only: :functions
	
	def register_ok() do
		send_register_ok(self())
	end
	
	def send_register_ok(nil) do
		:ok
	end
	def send_register_ok([]) do
		:ok
	end
	def send_register_ok(list) when is_list(list) do
		bin = pack_register_ok()
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_register_ok(pid) do
		bin = pack_register_ok()
		send pid,{:client,bin}
	end
	def pack_register_ok() do
		bin = write_byte(<<>>,0)
		bin = write_int(bin,2)
		bin
	end
	
	def register_fail(error) do
		send_register_fail(self(),error)
	end
	
	def send_register_fail(nil,_) do
		:ok
	end
	def send_register_fail([],_) do
		:ok
	end
	def send_register_fail(list,error) when is_list(list) do
		bin = pack_register_fail(error)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_register_fail(pid,error) do
		bin = pack_register_fail(error)
		send pid,{:client,bin}
	end
	def pack_register_fail(error) do
		bin = write_byte(<<>>,0)
		bin = write_int(bin,3)
		bin = write_string(bin,error)
		bin
	end
	
	def login_ok() do
		send_login_ok(self())
	end
	
	def send_login_ok(nil) do
		:ok
	end
	def send_login_ok([]) do
		:ok
	end
	def send_login_ok(list) when is_list(list) do
		bin = pack_login_ok()
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_login_ok(pid) do
		bin = pack_login_ok()
		send pid,{:client,bin}
	end
	def pack_login_ok() do
		bin = write_byte(<<>>,0)
		bin = write_int(bin,5)
		bin
	end
	
	def login_fail(error) do
		send_login_fail(self(),error)
	end
	
	def send_login_fail(nil,_) do
		:ok
	end
	def send_login_fail([],_) do
		:ok
	end
	def send_login_fail(list,error) when is_list(list) do
		bin = pack_login_fail(error)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_login_fail(pid,error) do
		bin = pack_login_fail(error)
		send pid,{:client,bin}
	end
	def pack_login_fail(error) do
		bin = write_byte(<<>>,0)
		bin = write_int(bin,6)
		bin = write_string(bin,error)
		bin
	end
	
	def ver_ack(type,url,ver) do
		send_ver_ack(self(),type,url,ver)
	end
	
	def send_ver_ack(nil,_,_,_) do
		:ok
	end
	def send_ver_ack([],_,_,_) do
		:ok
	end
	def send_ver_ack(list,type,url,ver) when is_list(list) do
		bin = pack_ver_ack(type,url,ver)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_ver_ack(pid,type,url,ver) do
		bin = pack_ver_ack(type,url,ver)
		send pid,{:client,bin}
	end
	def pack_ver_ack(type,url,ver) do
		bin = write_byte(<<>>,0)
		bin = write_int(bin,8)
		bin = write_int32(bin,type)
		bin = write_string(bin,url)
		bin = write_array(bin,&write_int32/2,ver)
		bin
	end
	
	def get_file_ack(per,datas) do
		send_get_file_ack(self(),per,datas)
	end
	
	def send_get_file_ack(nil,_,_) do
		:ok
	end
	def send_get_file_ack([],_,_) do
		:ok
	end
	def send_get_file_ack(list,per,datas) when is_list(list) do
		bin = pack_get_file_ack(per,datas)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_get_file_ack(pid,per,datas) do
		bin = pack_get_file_ack(per,datas)
		send pid,{:client,bin}
	end
	def pack_get_file_ack(per,datas) do
		bin = write_byte(<<>>,0)
		bin = write_int(bin,11)
		bin = write_byte(bin,per)
		bin = write_string(bin,datas)
		bin
	end
	
	def send_gold_check_ok(id,name,gold) do
		send_send_gold_check_ok(self(),id,name,gold)
	end
	
	def send_send_gold_check_ok(nil,_,_,_) do
		:ok
	end
	def send_send_gold_check_ok([],_,_,_) do
		:ok
	end
	def send_send_gold_check_ok(list,id,name,gold) when is_list(list) do
		bin = pack_send_gold_check_ok(id,name,gold)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_send_gold_check_ok(pid,id,name,gold) do
		bin = pack_send_gold_check_ok(id,name,gold)
		send pid,{:client,bin}
	end
	def pack_send_gold_check_ok(id,name,gold) do
		bin = write_byte(<<>>,0)
		bin = write_int(bin,13)
		bin = write_int32(bin,id)
		bin = write_string(bin,name)
		bin = write_int32(bin,gold)
		bin
	end
	
	def send_gold_ok() do
		send_send_gold_ok(self())
	end
	
	def send_send_gold_ok(nil) do
		:ok
	end
	def send_send_gold_ok([]) do
		:ok
	end
	def send_send_gold_ok(list) when is_list(list) do
		bin = pack_send_gold_ok()
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_send_gold_ok(pid) do
		bin = pack_send_gold_ok()
		send pid,{:client,bin}
	end
	def pack_send_gold_ok() do
		bin = write_byte(<<>>,0)
		bin = write_int(bin,14)
		bin
	end
	
	def send_gold_fail(error) do
		send_send_gold_fail(self(),error)
	end
	
	def send_send_gold_fail(nil,_) do
		:ok
	end
	def send_send_gold_fail([],_) do
		:ok
	end
	def send_send_gold_fail(list,error) when is_list(list) do
		bin = pack_send_gold_fail(error)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_send_gold_fail(pid,error) do
		bin = pack_send_gold_fail(error)
		send pid,{:client,bin}
	end
	def pack_send_gold_fail(error) do
		bin = write_byte(<<>>,0)
		bin = write_int(bin,15)
		bin = write_string(bin,error)
		bin
	end
	
	def get_gold_list_ack(count,start_id,list) do
		send_get_gold_list_ack(self(),count,start_id,list)
	end
	
	def send_get_gold_list_ack(nil,_,_,_) do
		:ok
	end
	def send_get_gold_list_ack([],_,_,_) do
		:ok
	end
	def send_get_gold_list_ack(list,count,start_id,list) when is_list(list) do
		bin = pack_get_gold_list_ack(count,start_id,list)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_get_gold_list_ack(pid,count,start_id,list) do
		bin = pack_get_gold_list_ack(count,start_id,list)
		send pid,{:client,bin}
	end
	def pack_get_gold_list_ack(count,start_id,list) do
		bin = write_byte(<<>>,0)
		bin = write_int(bin,17)
		bin = write_int32(bin,count)
		bin = write_int32(bin,start_id)
		bin = write_array(bin,&write_golddata/2,list)
		bin
	end
	
	def write_golddata(bin,obj) do
		bin = write_int32(bin,obj.type)
		bin = write_string(bin,obj.src)
		bin = write_int32(bin,obj.des)
		bin = write_int32(bin,obj.gold)
		bin = write_string(bin,obj.time)
		bin
	end
	
	def on_message(state,bin) do
		{n,bin} = read_int(bin)
		on_message(state,n,bin)
	end
	
	def on_message(state,1,bin) do
		{name,bin} = read_string(bin)
		{pwd,_bin} = read_string(bin)
		Account.register(state,name,pwd)
	end
	
	def on_message(state,4,bin) do
		{name,bin} = read_string(bin)
		{pwd,_bin} = read_string(bin)
		Account.login(state,name,pwd)
	end
	
	def on_message(state,7,bin) do
		{id,_bin} = read_int32(bin)
		Account.ver(state,id)
	end
	
	def on_message(state,9,bin) do
		{id,bin} = read_byte(bin)
		{pos,_bin} = read_int32(bin)
		Account.get_file(state,id,pos)
	end
	
	def on_message(state,10,bin) do
		{id,bin} = read_byte(bin)
		{pos,_bin} = read_int32(bin)
		Account.get_file_ok(state,id,pos)
	end
	
	def on_message(state,12,bin) do
		{id,bin} = read_int32(bin)
		{gold,bin} = read_int32(bin)
		{check,_bin} = read_boolean(bin)
		Account.send_gold(state,id,gold,check)
	end
	
	def on_message(state,16,bin) do
		{page,bin} = read_int32(bin)
		{page_count,_bin} = read_int32(bin)
		Account.get_gold_list(state,page,page_count)
	end
	
	def read_golddata(bin) do
		{r_type,bin} = read_int32(bin)
		{r_src,bin} = read_string(bin)
		{r_des,bin} = read_int32(bin)
		{r_gold,bin} = read_int32(bin)
		{r_time,bin} = read_string(bin)
		r = %{
			:type => r_type,
			:src => r_src,
			:des => r_des,
			:gold => r_gold,
			:time => r_time,
		}
		{r,bin}
	end
	
end
