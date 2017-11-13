
defmodule Proto.User do
	import BaseWrite, only: :functions
	import BaseRead, only: :functions
	
	def wx_id(id) do
		send_wx_id(self(),id)
	end
	
	def send_wx_id(nil,_) do
		:ok
	end
	def send_wx_id([],_) do
		:ok
	end
	def send_wx_id(list,id) when is_list(list) do
		bin = pack_wx_id(id)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_wx_id(pid,id) do
		bin = pack_wx_id(id)
		send pid,{:client,bin}
	end
	def pack_wx_id(id) do
		bin = write_byte(<<>>,2)
		bin = write_int(bin,4)
		bin = write_string(bin,id)
		bin
	end
	
	def user_info(info) do
		send_user_info(self(),info)
	end
	
	def send_user_info(nil,_) do
		:ok
	end
	def send_user_info([],_) do
		:ok
	end
	def send_user_info(list,info) when is_list(list) do
		bin = pack_user_info(info)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_user_info(pid,info) do
		bin = pack_user_info(info)
		send pid,{:client,bin}
	end
	def pack_user_info(info) do
		bin = write_byte(<<>>,2)
		bin = write_int(bin,5)
		bin = write_userinfo(bin,info)
		bin
	end
	
	def login_error(error) do
		send_login_error(self(),error)
	end
	
	def send_login_error(nil,_) do
		:ok
	end
	def send_login_error([],_) do
		:ok
	end
	def send_login_error(list,error) when is_list(list) do
		bin = pack_login_error(error)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_login_error(pid,error) do
		bin = pack_login_error(error)
		send pid,{:client,bin}
	end
	def pack_login_error(error) do
		bin = write_byte(<<>>,2)
		bin = write_int(bin,6)
		bin = write_string(bin,error)
		bin
	end
	
	def change_card(change_count) do
		send_change_card(self(),change_count)
	end
	
	def send_change_card(nil,_) do
		:ok
	end
	def send_change_card([],_) do
		:ok
	end
	def send_change_card(list,change_count) when is_list(list) do
		bin = pack_change_card(change_count)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_change_card(pid,change_count) do
		bin = pack_change_card(change_count)
		send pid,{:client,bin}
	end
	def pack_change_card(change_count) do
		bin = write_byte(<<>>,2)
		bin = write_int(bin,7)
		bin = write_int32(bin,change_count)
		bin
	end
	
	def heart_ack() do
		send_heart_ack(self())
	end
	
	def send_heart_ack(nil) do
		:ok
	end
	def send_heart_ack([]) do
		:ok
	end
	def send_heart_ack(list) when is_list(list) do
		bin = pack_heart_ack()
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_heart_ack(pid) do
		bin = pack_heart_ack()
		send pid,{:client,bin}
	end
	def pack_heart_ack() do
		bin = write_byte(<<>>,2)
		bin = write_int(bin,9)
		bin
	end
	
	def get_txt_ack(key,data) do
		send_get_txt_ack(self(),key,data)
	end
	
	def send_get_txt_ack(nil,_,_) do
		:ok
	end
	def send_get_txt_ack([],_,_) do
		:ok
	end
	def send_get_txt_ack(list,key,data) when is_list(list) do
		bin = pack_get_txt_ack(key,data)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_get_txt_ack(pid,key,data) do
		bin = pack_get_txt_ack(key,data)
		send pid,{:client,bin}
	end
	def pack_get_txt_ack(key,data) do
		bin = write_byte(<<>>,2)
		bin = write_int(bin,11)
		bin = write_string(bin,key)
		bin = write_string(bin,data)
		bin
	end
	
	def write_userinfo(bin,obj) do
		bin = write_int32(bin,obj.id)
		bin = write_string(bin,obj.name)
		bin = write_int32(bin,obj.card_count)
		bin = write_string(bin,obj.head)
		bin = write_byte(bin,obj.sex)
		bin = write_string(bin,obj.ip)
		bin
	end
	
	def on_message(state,bin) do
		{n,bin} = read_int(bin)
		on_message(state,n,bin)
	end
	
	def on_message(state,1,bin) do
		{id,_bin} = read_int32(bin)
		User.enter(state,id)
	end
	
	def on_message(state,2,bin) do
		{info,_bin} = read_string(bin)
		User.wx_login(state,info)
	end
	
	def on_message(state,3,bin) do
		{id,_bin} = read_string(bin)
		User.wx_id_login(state,id)
	end
	
	def on_message(state,8,_bin) do
		User.heart(state)
	end
	
	def on_message(state,10,bin) do
		{key,_bin} = read_string(bin)
		User.get_txt(state,key)
	end
	
	def read_userinfo(bin) do
		{r_id,bin} = read_int32(bin)
		{r_name,bin} = read_string(bin)
		{r_card_count,bin} = read_int32(bin)
		{r_head,bin} = read_string(bin)
		{r_sex,bin} = read_byte(bin)
		{r_ip,bin} = read_string(bin)
		r = %{
			:id => r_id,
			:name => r_name,
			:card_count => r_card_count,
			:head => r_head,
			:sex => r_sex,
			:ip => r_ip,
		}
		{r,bin}
	end
	
end
