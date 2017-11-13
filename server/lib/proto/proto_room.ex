
defmodule Proto.Room do
	import BaseWrite, only: :functions
	import BaseRead, only: :functions
	
	def create_ack(room_id) do
		send_create_ack(self(),room_id)
	end
	
	def send_create_ack(nil,_) do
		:ok
	end
	def send_create_ack([],_) do
		:ok
	end
	def send_create_ack(list,room_id) when is_list(list) do
		bin = pack_create_ack(room_id)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_create_ack(pid,room_id) do
		bin = pack_create_ack(room_id)
		send pid,{:client,bin}
	end
	def pack_create_ack(room_id) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,2)
		bin = write_int32(bin,room_id)
		bin
	end
	
	def create_error(error) do
		send_create_error(self(),error)
	end
	
	def send_create_error(nil,_) do
		:ok
	end
	def send_create_error([],_) do
		:ok
	end
	def send_create_error(list,error) when is_list(list) do
		bin = pack_create_error(error)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_create_error(pid,error) do
		bin = pack_create_error(error)
		send pid,{:client,bin}
	end
	def pack_create_error(error) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,3)
		bin = write_string(bin,error)
		bin
	end
	
	def get_room_ack(id) do
		send_get_room_ack(self(),id)
	end
	
	def send_get_room_ack(nil,_) do
		:ok
	end
	def send_get_room_ack([],_) do
		:ok
	end
	def send_get_room_ack(list,id) when is_list(list) do
		bin = pack_get_room_ack(id)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_get_room_ack(pid,id) do
		bin = pack_get_room_ack(id)
		send pid,{:client,bin}
	end
	def pack_get_room_ack(id) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,5)
		bin = write_int32(bin,id)
		bin
	end
	
	def enter_ack(host_id,rounds,round_host,players,p) do
		send_enter_ack(self(),host_id,rounds,round_host,players,p)
	end
	
	def send_enter_ack(nil,_,_,_,_,_) do
		:ok
	end
	def send_enter_ack([],_,_,_,_,_) do
		:ok
	end
	def send_enter_ack(list,host_id,rounds,round_host,players,p) when is_list(list) do
		bin = pack_enter_ack(host_id,rounds,round_host,players,p)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_enter_ack(pid,host_id,rounds,round_host,players,p) do
		bin = pack_enter_ack(host_id,rounds,round_host,players,p)
		send pid,{:client,bin}
	end
	def pack_enter_ack(host_id,rounds,round_host,players,p) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,7)
		bin = write_int32(bin,host_id)
		bin = write_int32(bin,rounds)
		bin = write_int32(bin,round_host)
		bin = write_array(bin,&write_playerinfo/2,players)
		bin = write_roomparams(bin,p)
		bin
	end
	
	def enter_error(error) do
		send_enter_error(self(),error)
	end
	
	def send_enter_error(nil,_) do
		:ok
	end
	def send_enter_error([],_) do
		:ok
	end
	def send_enter_error(list,error) when is_list(list) do
		bin = pack_enter_error(error)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_enter_error(pid,error) do
		bin = pack_enter_error(error)
		send pid,{:client,bin}
	end
	def pack_enter_error(error) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,8)
		bin = write_string(bin,error)
		bin
	end
	
	def enter_player(player) do
		send_enter_player(self(),player)
	end
	
	def send_enter_player(nil,_) do
		:ok
	end
	def send_enter_player([],_) do
		:ok
	end
	def send_enter_player(list,player) when is_list(list) do
		bin = pack_enter_player(player)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_enter_player(pid,player) do
		bin = pack_enter_player(player)
		send pid,{:client,bin}
	end
	def pack_enter_player(player) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,9)
		bin = write_playerinfo(bin,player)
		bin
	end
	
	def quit_player(id) do
		send_quit_player(self(),id)
	end
	
	def send_quit_player(nil,_) do
		:ok
	end
	def send_quit_player([],_) do
		:ok
	end
	def send_quit_player(list,id) when is_list(list) do
		bin = pack_quit_player(id)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_quit_player(pid,id) do
		bin = pack_quit_player(id)
		send pid,{:client,bin}
	end
	def pack_quit_player(id) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,10)
		bin = write_int32(bin,id)
		bin
	end
	
	def offline_player(id) do
		send_offline_player(self(),id)
	end
	
	def send_offline_player(nil,_) do
		:ok
	end
	def send_offline_player([],_) do
		:ok
	end
	def send_offline_player(list,id) when is_list(list) do
		bin = pack_offline_player(id)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_offline_player(pid,id) do
		bin = pack_offline_player(id)
		send pid,{:client,bin}
	end
	def pack_offline_player(id) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,11)
		bin = write_int32(bin,id)
		bin
	end
	
	def online_player(id,ip) do
		send_online_player(self(),id,ip)
	end
	
	def send_online_player(nil,_,_) do
		:ok
	end
	def send_online_player([],_,_) do
		:ok
	end
	def send_online_player(list,id,ip) when is_list(list) do
		bin = pack_online_player(id,ip)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_online_player(pid,id,ip) do
		bin = pack_online_player(id,ip)
		send pid,{:client,bin}
	end
	def pack_online_player(id,ip) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,12)
		bin = write_int32(bin,id)
		bin = write_string(bin,ip)
		bin
	end
	
	def player_ready_ack(id) do
		send_player_ready_ack(self(),id)
	end
	
	def send_player_ready_ack(nil,_) do
		:ok
	end
	def send_player_ready_ack([],_) do
		:ok
	end
	def send_player_ready_ack(list,id) when is_list(list) do
		bin = pack_player_ready_ack(id)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_player_ready_ack(pid,id) do
		bin = pack_player_ready_ack(id)
		send pid,{:client,bin}
	end
	def pack_player_ready_ack(id) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,14)
		bin = write_int32(bin,id)
		bin
	end
	
	def quit_room() do
		send_quit_room(self())
	end
	
	def send_quit_room(nil) do
		:ok
	end
	def send_quit_room([]) do
		:ok
	end
	def send_quit_room(list) when is_list(list) do
		bin = pack_quit_room()
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_quit_room(pid) do
		bin = pack_quit_room()
		send pid,{:client,bin}
	end
	def pack_quit_room() do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,16)
		bin
	end
	
	def quit_voto(time,ids) do
		send_quit_voto(self(),time,ids)
	end
	
	def send_quit_voto(nil,_,_) do
		:ok
	end
	def send_quit_voto([],_,_) do
		:ok
	end
	def send_quit_voto(list,time,ids) when is_list(list) do
		bin = pack_quit_voto(time,ids)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_quit_voto(pid,time,ids) do
		bin = pack_quit_voto(time,ids)
		send pid,{:client,bin}
	end
	def pack_quit_voto(time,ids) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,17)
		bin = write_single(bin,time)
		bin = write_array(bin,&write_int32/2,ids)
		bin
	end
	
	def quit_voto_end(yes) do
		send_quit_voto_end(self(),yes)
	end
	
	def send_quit_voto_end(nil,_) do
		:ok
	end
	def send_quit_voto_end([],_) do
		:ok
	end
	def send_quit_voto_end(list,yes) when is_list(list) do
		bin = pack_quit_voto_end(yes)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_quit_voto_end(pid,yes) do
		bin = pack_quit_voto_end(yes)
		send pid,{:client,bin}
	end
	def pack_quit_voto_end(yes) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,18)
		bin = write_boolean(bin,yes)
		bin
	end
	
	def quit_voto_time(time) do
		send_quit_voto_time(self(),time)
	end
	
	def send_quit_voto_time(nil,_) do
		:ok
	end
	def send_quit_voto_time([],_) do
		:ok
	end
	def send_quit_voto_time(list,time) when is_list(list) do
		bin = pack_quit_voto_time(time)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_quit_voto_time(pid,time) do
		bin = pack_quit_voto_time(time)
		send pid,{:client,bin}
	end
	def pack_quit_voto_time(time) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,19)
		bin = write_single(bin,time)
		bin
	end
	
	def game_start_error(err) do
		send_game_start_error(self(),err)
	end
	
	def send_game_start_error(nil,_) do
		:ok
	end
	def send_game_start_error([],_) do
		:ok
	end
	def send_game_start_error(list,err) when is_list(list) do
		bin = pack_game_start_error(err)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_game_start_error(pid,err) do
		bin = pack_game_start_error(err)
		send pid,{:client,bin}
	end
	def pack_game_start_error(err) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,23)
		bin = write_string(bin,err)
		bin
	end
	
	def game_start(order) do
		send_game_start(self(),order)
	end
	
	def send_game_start(nil,_) do
		:ok
	end
	def send_game_start([],_) do
		:ok
	end
	def send_game_start(list,order) when is_list(list) do
		bin = pack_game_start(order)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_game_start(pid,order) do
		bin = pack_game_start(order)
		send pid,{:client,bin}
	end
	def pack_game_start(order) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,24)
		bin = write_array(bin,&write_int32/2,order)
		bin
	end
	
	def game_order(order,his) do
		send_game_order(self(),order,his)
	end
	
	def send_game_order(nil,_,_) do
		:ok
	end
	def send_game_order([],_,_) do
		:ok
	end
	def send_game_order(list,order,his) when is_list(list) do
		bin = pack_game_order(order,his)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_game_order(pid,order,his) do
		bin = pack_game_order(order,his)
		send pid,{:client,bin}
	end
	def pack_game_order(order,his) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,25)
		bin = write_array(bin,&write_int32/2,order)
		bin = write_history(bin,his)
		bin
	end
	
	def saizhi(id,s1,s2) do
		send_saizhi(self(),id,s1,s2)
	end
	
	def send_saizhi(nil,_,_,_) do
		:ok
	end
	def send_saizhi([],_,_,_) do
		:ok
	end
	def send_saizhi(list,id,s1,s2) when is_list(list) do
		bin = pack_saizhi(id,s1,s2)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_saizhi(pid,id,s1,s2) do
		bin = pack_saizhi(id,s1,s2)
		send pid,{:client,bin}
	end
	def pack_saizhi(id,s1,s2) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,26)
		bin = write_int32(bin,id)
		bin = write_byte(bin,s1)
		bin = write_byte(bin,s2)
		bin
	end
	
	def get_lai(id,card) do
		send_get_lai(self(),id,card)
	end
	
	def send_get_lai(nil,_,_) do
		:ok
	end
	def send_get_lai([],_,_) do
		:ok
	end
	def send_get_lai(list,id,card) when is_list(list) do
		bin = pack_get_lai(id,card)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_get_lai(pid,id,card) do
		bin = pack_get_lai(id,card)
		send pid,{:client,bin}
	end
	def pack_get_lai(id,card) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,27)
		bin = write_int32(bin,id)
		bin = write_int32(bin,card)
		bin
	end
	
	def turn(id,time,pai,gangs,hus) do
		send_turn(self(),id,time,pai,gangs,hus)
	end
	
	def send_turn(nil,_,_,_,_,_) do
		:ok
	end
	def send_turn([],_,_,_,_,_) do
		:ok
	end
	def send_turn(list,id,time,pai,gangs,hus) when is_list(list) do
		bin = pack_turn(id,time,pai,gangs,hus)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_turn(pid,id,time,pai,gangs,hus) do
		bin = pack_turn(id,time,pai,gangs,hus)
		send pid,{:client,bin}
	end
	def pack_turn(id,time,pai,gangs,hus) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,28)
		bin = write_int32(bin,id)
		bin = write_int32(bin,time)
		bin = write_int32(bin,pai)
		bin = write_array(bin,&write_int32/2,gangs)
		bin = write_array(bin,&write_hucards/2,hus)
		bin
	end
	
	def put_card(id,pai) do
		send_put_card(self(),id,pai)
	end
	
	def send_put_card(nil,_,_) do
		:ok
	end
	def send_put_card([],_,_) do
		:ok
	end
	def send_put_card(list,id,pai) when is_list(list) do
		bin = pack_put_card(id,pai)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_put_card(pid,id,pai) do
		bin = pack_put_card(id,pai)
		send pid,{:client,bin}
	end
	def pack_put_card(id,pai) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,29)
		bin = write_int32(bin,id)
		bin = write_int32(bin,pai)
		bin
	end
	
	def get_pi(id,pai) do
		send_get_pi(self(),id,pai)
	end
	
	def send_get_pi(nil,_,_) do
		:ok
	end
	def send_get_pi([],_,_) do
		:ok
	end
	def send_get_pi(list,id,pai) when is_list(list) do
		bin = pack_get_pi(id,pai)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_get_pi(pid,id,pai) do
		bin = pack_get_pi(id,pai)
		send pid,{:client,bin}
	end
	def pack_get_pi(id,pai) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,30)
		bin = write_int32(bin,id)
		bin = write_int32(bin,pai)
		bin
	end
	
	def wait_action(peng,gang,hu) do
		send_wait_action(self(),peng,gang,hu)
	end
	
	def send_wait_action(nil,_,_,_) do
		:ok
	end
	def send_wait_action([],_,_,_) do
		:ok
	end
	def send_wait_action(list,peng,gang,hu) when is_list(list) do
		bin = pack_wait_action(peng,gang,hu)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_wait_action(pid,peng,gang,hu) do
		bin = pack_wait_action(peng,gang,hu)
		send pid,{:client,bin}
	end
	def pack_wait_action(peng,gang,hu) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,31)
		bin = write_boolean(bin,peng)
		bin = write_boolean(bin,gang)
		bin = write_boolean(bin,hu)
		bin
	end
	
	def gang(id,card,count) do
		send_gang(self(),id,card,count)
	end
	
	def send_gang(nil,_,_,_) do
		:ok
	end
	def send_gang([],_,_,_) do
		:ok
	end
	def send_gang(list,id,card,count) when is_list(list) do
		bin = pack_gang(id,card,count)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_gang(pid,id,card,count) do
		bin = pack_gang(id,card,count)
		send pid,{:client,bin}
	end
	def pack_gang(id,card,count) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,32)
		bin = write_int32(bin,id)
		bin = write_int32(bin,card)
		bin = write_int32(bin,count)
		bin
	end
	
	def peng(id,card) do
		send_peng(self(),id,card)
	end
	
	def send_peng(nil,_,_) do
		:ok
	end
	def send_peng([],_,_) do
		:ok
	end
	def send_peng(list,id,card) when is_list(list) do
		bin = pack_peng(id,card)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_peng(pid,id,card) do
		bin = pack_peng(id,card)
		send pid,{:client,bin}
	end
	def pack_peng(id,card) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,33)
		bin = write_int32(bin,id)
		bin = write_int32(bin,card)
		bin
	end
	
	def score(id,otherId,score) do
		send_score(self(),id,otherId,score)
	end
	
	def send_score(nil,_,_,_) do
		:ok
	end
	def send_score([],_,_,_) do
		:ok
	end
	def send_score(list,id,otherId,score) when is_list(list) do
		bin = pack_score(id,otherId,score)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_score(pid,id,otherId,score) do
		bin = pack_score(id,otherId,score)
		send pid,{:client,bin}
	end
	def pack_score(id,otherId,score) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,34)
		bin = write_int32(bin,id)
		bin = write_int32(bin,otherId)
		bin = write_int32(bin,score)
		bin
	end
	
	def hu(id,cards) do
		send_hu(self(),id,cards)
	end
	
	def send_hu(nil,_,_) do
		:ok
	end
	def send_hu([],_,_) do
		:ok
	end
	def send_hu(list,id,cards) when is_list(list) do
		bin = pack_hu(id,cards)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_hu(pid,id,cards) do
		bin = pack_hu(id,cards)
		send pid,{:client,bin}
	end
	def pack_hu(id,cards) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,35)
		bin = write_array(bin,&write_int32/2,id)
		bin = write_array(bin,&write_cards/2,cards)
		bin
	end
	
	def end_game(info,his) do
		send_end_game(self(),info,his)
	end
	
	def send_end_game(nil,_,_) do
		:ok
	end
	def send_end_game([],_,_) do
		:ok
	end
	def send_end_game(list,info,his) when is_list(list) do
		bin = pack_end_game(info,his)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_end_game(pid,info,his) do
		bin = pack_end_game(info,his)
		send pid,{:client,bin}
	end
	def pack_end_game(info,his) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,36)
		bin = write_endinfo(bin,info)
		bin = write_history(bin,his)
		bin
	end
	
	def show_history_ex(datas) do
		send_show_history_ex(self(),datas)
	end
	
	def send_show_history_ex(nil,_) do
		:ok
	end
	def send_show_history_ex([],_) do
		:ok
	end
	def send_show_history_ex(list,datas) when is_list(list) do
		bin = pack_show_history_ex(datas)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_show_history_ex(pid,datas) do
		bin = pack_show_history_ex(datas)
		send pid,{:client,bin}
	end
	def pack_show_history_ex(datas) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,38)
		bin = write_array(bin,&write_historyex/2,datas)
		bin
	end
	
	def show_history(his) do
		send_show_history(self(),his)
	end
	
	def send_show_history(nil,_) do
		:ok
	end
	def send_show_history([],_) do
		:ok
	end
	def send_show_history(list,his) when is_list(list) do
		bin = pack_show_history(his)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_show_history(pid,his) do
		bin = pack_show_history(his)
		send pid,{:client,bin}
	end
	def pack_show_history(his) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,39)
		bin = write_history(bin,his)
		bin
	end
	
	def tuoguan() do
		send_tuoguan(self())
	end
	
	def send_tuoguan(nil) do
		:ok
	end
	def send_tuoguan([]) do
		:ok
	end
	def send_tuoguan(list) when is_list(list) do
		bin = pack_tuoguan()
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_tuoguan(pid) do
		bin = pack_tuoguan()
		send pid,{:client,bin}
	end
	def pack_tuoguan() do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,41)
		bin
	end
	
	def show_emotion_ack(id,em) do
		send_show_emotion_ack(self(),id,em)
	end
	
	def send_show_emotion_ack(nil,_,_) do
		:ok
	end
	def send_show_emotion_ack([],_,_) do
		:ok
	end
	def send_show_emotion_ack(list,id,em) when is_list(list) do
		bin = pack_show_emotion_ack(id,em)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_show_emotion_ack(pid,id,em) do
		bin = pack_show_emotion_ack(id,em)
		send pid,{:client,bin}
	end
	def pack_show_emotion_ack(id,em) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,44)
		bin = write_int32(bin,id)
		bin = write_int32(bin,em)
		bin
	end
	
	def voice_ack(id,url) do
		send_voice_ack(self(),id,url)
	end
	
	def send_voice_ack(nil,_,_) do
		:ok
	end
	def send_voice_ack([],_,_) do
		:ok
	end
	def send_voice_ack(list,id,url) when is_list(list) do
		bin = pack_voice_ack(id,url)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_voice_ack(pid,id,url) do
		bin = pack_voice_ack(id,url)
		send pid,{:client,bin}
	end
	def pack_voice_ack(id,url) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,46)
		bin = write_int32(bin,id)
		bin = write_string(bin,url)
		bin
	end
	
	def show_replay_ack(data) do
		send_show_replay_ack(self(),data)
	end
	
	def send_show_replay_ack(nil,_) do
		:ok
	end
	def send_show_replay_ack([],_) do
		:ok
	end
	def send_show_replay_ack(list,data) when is_list(list) do
		bin = pack_show_replay_ack(data)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_show_replay_ack(pid,data) do
		bin = pack_show_replay_ack(data)
		send pid,{:client,bin}
	end
	def pack_show_replay_ack(data) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,48)
		bin = write_replaydata(bin,data)
		bin
	end
	
	def show_replay_error(str) do
		send_show_replay_error(self(),str)
	end
	
	def send_show_replay_error(nil,_) do
		:ok
	end
	def send_show_replay_error([],_) do
		:ok
	end
	def send_show_replay_error(list,str) when is_list(list) do
		bin = pack_show_replay_error(str)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_show_replay_error(pid,str) do
		bin = pack_show_replay_error(str)
		send pid,{:client,bin}
	end
	def pack_show_replay_error(str) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,49)
		bin = write_string(bin,str)
		bin
	end
	
	def get_replay_data_ack(index,data) do
		send_get_replay_data_ack(self(),index,data)
	end
	
	def send_get_replay_data_ack(nil,_,_) do
		:ok
	end
	def send_get_replay_data_ack([],_,_) do
		:ok
	end
	def send_get_replay_data_ack(list,index,data) when is_list(list) do
		bin = pack_get_replay_data_ack(index,data)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_get_replay_data_ack(pid,index,data) do
		bin = pack_get_replay_data_ack(index,data)
		send pid,{:client,bin}
	end
	def pack_get_replay_data_ack(index,data) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,51)
		bin = write_int32(bin,index)
		bin = write_gamedata(bin,data)
		bin
	end
	
	def show_txt_msg_ack(id,str) do
		send_show_txt_msg_ack(self(),id,str)
	end
	
	def send_show_txt_msg_ack(nil,_,_) do
		:ok
	end
	def send_show_txt_msg_ack([],_,_) do
		:ok
	end
	def send_show_txt_msg_ack(list,id,str) when is_list(list) do
		bin = pack_show_txt_msg_ack(id,str)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_show_txt_msg_ack(pid,id,str) do
		bin = pack_show_txt_msg_ack(id,str)
		send pid,{:client,bin}
	end
	def pack_show_txt_msg_ack(id,str) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,53)
		bin = write_int32(bin,id)
		bin = write_string(bin,str)
		bin
	end
	
	def get_user_info_ack(id,name,note,roundCount,winCount,sex,head,code) do
		send_get_user_info_ack(self(),id,name,note,roundCount,winCount,sex,head,code)
	end
	
	def send_get_user_info_ack(nil,_,_,_,_,_,_,_,_) do
		:ok
	end
	def send_get_user_info_ack([],_,_,_,_,_,_,_,_) do
		:ok
	end
	def send_get_user_info_ack(list,id,name,note,roundCount,winCount,sex,head,code) when is_list(list) do
		bin = pack_get_user_info_ack(id,name,note,roundCount,winCount,sex,head,code)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_get_user_info_ack(pid,id,name,note,roundCount,winCount,sex,head,code) do
		bin = pack_get_user_info_ack(id,name,note,roundCount,winCount,sex,head,code)
		send pid,{:client,bin}
	end
	def pack_get_user_info_ack(id,name,note,roundCount,winCount,sex,head,code) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,55)
		bin = write_int32(bin,id)
		bin = write_string(bin,name)
		bin = write_string(bin,note)
		bin = write_int32(bin,roundCount)
		bin = write_int32(bin,winCount)
		bin = write_int32(bin,sex)
		bin = write_string(bin,head)
		bin = write_string(bin,code)
		bin
	end
	
	def power_up_ack(ids,power) do
		send_power_up_ack(self(),ids,power)
	end
	
	def send_power_up_ack(nil,_,_) do
		:ok
	end
	def send_power_up_ack([],_,_) do
		:ok
	end
	def send_power_up_ack(list,ids,power) when is_list(list) do
		bin = pack_power_up_ack(ids,power)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_power_up_ack(pid,ids,power) do
		bin = pack_power_up_ack(ids,power)
		send pid,{:client,bin}
	end
	def pack_power_up_ack(ids,power) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,57)
		bin = write_array(bin,&write_int32/2,ids)
		bin = write_array(bin,&write_byte/2,power)
		bin
	end
	
	def put_gold(id,gold) do
		send_put_gold(self(),id,gold)
	end
	
	def send_put_gold(nil,_,_) do
		:ok
	end
	def send_put_gold([],_,_) do
		:ok
	end
	def send_put_gold(list,id,gold) when is_list(list) do
		bin = pack_put_gold(id,gold)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_put_gold(pid,id,gold) do
		bin = pack_put_gold(id,gold)
		send pid,{:client,bin}
	end
	def pack_put_gold(id,gold) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,58)
		bin = write_int32(bin,id)
		bin = write_int32(bin,gold)
		bin
	end
	
	def show_card_ack(id) do
		send_show_card_ack(self(),id)
	end
	
	def send_show_card_ack(nil,_) do
		:ok
	end
	def send_show_card_ack([],_) do
		:ok
	end
	def send_show_card_ack(list,id) when is_list(list) do
		bin = pack_show_card_ack(id)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_show_card_ack(pid,id) do
		bin = pack_show_card_ack(id)
		send pid,{:client,bin}
	end
	def pack_show_card_ack(id) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,59)
		bin = write_int32(bin,id)
		bin
	end
	
	def show_card_value(cards) do
		send_show_card_value(self(),cards)
	end
	
	def send_show_card_value(nil,_) do
		:ok
	end
	def send_show_card_value([],_) do
		:ok
	end
	def send_show_card_value(list,cards) when is_list(list) do
		bin = pack_show_card_value(cards)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_show_card_value(pid,cards) do
		bin = pack_show_card_value(cards)
		send pid,{:client,bin}
	end
	def pack_show_card_value(cards) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,60)
		bin = write_array(bin,&write_byte/2,cards)
		bin
	end
	
	def giveup_ack(id) do
		send_giveup_ack(self(),id)
	end
	
	def send_giveup_ack(nil,_) do
		:ok
	end
	def send_giveup_ack([],_) do
		:ok
	end
	def send_giveup_ack(list,id) when is_list(list) do
		bin = pack_giveup_ack(id)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_giveup_ack(pid,id) do
		bin = pack_giveup_ack(id)
		send pid,{:client,bin}
	end
	def pack_giveup_ack(id) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,61)
		bin = write_int32(bin,id)
		bin
	end
	
	def check_result(id,other,win) do
		send_check_result(self(),id,other,win)
	end
	
	def send_check_result(nil,_,_,_) do
		:ok
	end
	def send_check_result([],_,_,_) do
		:ok
	end
	def send_check_result(list,id,other,win) when is_list(list) do
		bin = pack_check_result(id,other,win)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_check_result(pid,id,other,win) do
		bin = pack_check_result(id,other,win)
		send pid,{:client,bin}
	end
	def pack_check_result(id,other,win) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,62)
		bin = write_int32(bin,id)
		bin = write_int32(bin,other)
		bin = write_boolean(bin,win)
		bin
	end
	
	def win_id(id,datas) do
		send_win_id(self(),id,datas)
	end
	
	def send_win_id(nil,_,_) do
		:ok
	end
	def send_win_id([],_,_) do
		:ok
	end
	def send_win_id(list,id,datas) when is_list(list) do
		bin = pack_win_id(id,datas)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_win_id(pid,id,datas) do
		bin = pack_win_id(id,datas)
		send pid,{:client,bin}
	end
	def pack_win_id(id,datas) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,63)
		bin = write_array(bin,&write_int32/2,id)
		bin = write_array(bin,&write_playercards/2,datas)
		bin
	end
	
	def turn_id(id,time,round) do
		send_turn_id(self(),id,time,round)
	end
	
	def send_turn_id(nil,_,_,_) do
		:ok
	end
	def send_turn_id([],_,_,_) do
		:ok
	end
	def send_turn_id(list,id,time,round) when is_list(list) do
		bin = pack_turn_id(id,time,round)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_turn_id(pid,id,time,round) do
		bin = pack_turn_id(id,time,round)
		send pid,{:client,bin}
	end
	def pack_turn_id(id,time,round) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,64)
		bin = write_int32(bin,id)
		bin = write_int32(bin,time)
		bin = write_int32(bin,round)
		bin
	end
	
	def play_info(round,base_gold,infos,cards) do
		send_play_info(self(),round,base_gold,infos,cards)
	end
	
	def send_play_info(nil,_,_,_,_) do
		:ok
	end
	def send_play_info([],_,_,_,_) do
		:ok
	end
	def send_play_info(list,round,base_gold,infos,cards) when is_list(list) do
		bin = pack_play_info(round,base_gold,infos,cards)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_play_info(pid,round,base_gold,infos,cards) do
		bin = pack_play_info(round,base_gold,infos,cards)
		send pid,{:client,bin}
	end
	def pack_play_info(round,base_gold,infos,cards) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,65)
		bin = write_int32(bin,round)
		bin = write_int32(bin,base_gold)
		bin = write_array(bin,&write_playinfo/2,infos)
		bin = write_array(bin,&write_byte/2,cards)
		bin
	end
	
	def end_games(his) do
		send_end_games(self(),his)
	end
	
	def send_end_games(nil,_) do
		:ok
	end
	def send_end_games([],_) do
		:ok
	end
	def send_end_games(list,his) when is_list(list) do
		bin = pack_end_games(his)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_end_games(pid,his) do
		bin = pack_end_games(his)
		send pid,{:client,bin}
	end
	def pack_end_games(his) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,66)
		bin = write_history(bin,his)
		bin
	end
	
	def put_cards_ok(id) do
		send_put_cards_ok(self(),id)
	end
	
	def send_put_cards_ok(nil,_) do
		:ok
	end
	def send_put_cards_ok([],_) do
		:ok
	end
	def send_put_cards_ok(list,id) when is_list(list) do
		bin = pack_put_cards_ok(id)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_put_cards_ok(pid,id) do
		bin = pack_put_cards_ok(id)
		send pid,{:client,bin}
	end
	def pack_put_cards_ok(id) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,68)
		bin = write_int32(bin,id)
		bin
	end
	
	def end_turn(data) do
		send_end_turn(self(),data)
	end
	
	def send_end_turn(nil,_) do
		:ok
	end
	def send_end_turn([],_) do
		:ok
	end
	def send_end_turn(list,data) when is_list(list) do
		bin = pack_end_turn(data)
		Enum.each(list,fn(pid)-> send pid,{:client,bin} end)
	end
	def send_end_turn(pid,data) do
		bin = pack_end_turn(data)
		send pid,{:client,bin}
	end
	def pack_end_turn(data) do
		bin = write_byte(<<>>,1)
		bin = write_int(bin,69)
		bin = write_turndata(bin,data)
		bin
	end
	
	def write_roomparams(bin,obj) do
		bin = write_byte(bin,obj.type)
		bin = write_byte(bin,obj.round_count)
		bin = write_byte(bin,obj.player_count)
		bin = write_int32(bin,obj.base_score)
		bin = write_int32(bin,obj.ex_param1)
		bin = write_int32(bin,obj.ex_param2)
		bin = write_int32(bin,obj.ex_param3)
		bin
	end
	
	def write_playerinfo(bin,obj) do
		bin = write_string(bin,obj.name)
		bin = write_int32(bin,obj.id)
		bin = write_byte(bin,obj.sex)
		bin = write_string(bin,obj.head)
		bin = write_string(bin,obj.ip)
		bin = write_boolean(bin,obj.started)
		bin = write_boolean(bin,obj.offline)
		bin = write_int32(bin,obj.gold)
		bin = write_byte(bin,obj.pos)
		bin
	end
	
	def write_historyscore(bin,obj) do
		bin = write_int32(bin,obj.id)
		bin = write_string(bin,obj.name)
		bin = write_int32(bin,obj.score)
		bin = write_array(bin,&write_byte/2,obj.values)
		bin
	end
	
	def write_history(bin,obj) do
		bin = write_int32(bin,obj.game_id)
		bin = write_string(bin,obj.time)
		bin = write_int32(bin,obj.round)
		bin = write_int32(bin,obj.max_count)
		bin = write_int32(bin,obj.room_id)
		bin = write_array(bin,&write_historyscore/2,obj.data)
		bin
	end
	
	def write_hucards(bin,obj) do
		bin = write_byte(bin,obj.card)
		bin = write_array(bin,&write_byte/2,obj.hus)
		bin
	end
	
	def write_cards(bin,obj) do
		bin = write_array(bin,&write_byte/2,obj.datas)
		bin
	end
	
	def write_endplayercards(bin,obj) do
		bin = write_array(bin,&write_byte/2,obj.cur)
		bin = write_array(bin,&write_byte/2,obj.hold)
		bin
	end
	
	def write_endinfo(bin,obj) do
		bin = write_int32(bin,obj.type)
		bin = write_int32(bin,obj.cur_turn)
		bin = write_array(bin,&write_int32/2,obj.ids)
		bin = write_array(bin,&write_string/2,obj.names)
		bin = write_array(bin,&write_int32/2,obj.hu_scores)
		bin = write_array(bin,&write_int32/2,obj.cur_scores)
		bin = write_array(bin,&write_int32/2,obj.all_scores)
		bin = write_array(bin,&write_byte/2,obj.mas)
		bin = write_array(bin,&write_byte/2,obj.macards)
		bin = write_array(bin,&write_endplayercards/2,obj.cards)
		bin
	end
	
	def write_historyex(bin,obj) do
		bin = write_int32(bin,obj.game_id)
		bin = write_string(bin,obj.time)
		bin = write_int32(bin,obj.round)
		bin = write_int32(bin,obj.max_count)
		bin = write_int32(bin,obj.room_id)
		bin = write_array(bin,&write_string/2,obj.names)
		bin = write_array(bin,&write_int32/2,obj.scores)
		bin
	end
	
	def write_puttype(bin,:put_peng) do
		write_byte(bin,0)
	end
	
	def write_puttype(bin,:put_gang) do
		write_byte(bin,1)
	end
	
	def write_puttype(bin,:put_win) do
		write_byte(bin,2)
	end
	
	def write_puttype(bin,:put_self_gang) do
		write_byte(bin,3)
	end
	
	def write_puttype(bin,:put_card) do
		write_byte(bin,4)
	end
	
	def write_puttype(bin,:put_pass) do
		write_byte(bin,5)
	end
	
	def write_puttype(bin,:give_up) do
		write_byte(bin,6)
	end
	
	def write_puttype(bin,:put_gold) do
		write_byte(bin,7)
	end
	
	def write_puttype(bin,:check) do
		write_byte(bin,8)
	end
	
	def write_puttype(bin,:show_card) do
		write_byte(bin,9)
	end
	
	def write_puttype(bin,_) do
		write_byte(bin,-1)
	end
	
	def write_replaydata(bin,obj) do
		bin = write_array(bin,&write_playerinfo/2,obj.players)
		bin = write_roomparams(bin,obj.room_params)
		bin = write_array(bin,&write_int32/2,obj.order)
		bin = write_int32(bin,obj.game_count)
		bin
	end
	
	def write_gamedata(bin,obj) do
		bin = write_array(bin,&write_cards/2,obj.cards)
		bin = write_int32(bin,obj.card_count)
		bin = write_byte(bin,obj.pi_card)
		bin = write_array(bin,&write_byte/2,obj.steps)
		bin
	end
	
	def write_playercards(bin,obj) do
		bin = write_int32(bin,obj.id)
		bin = write_array(bin,&write_byte/2,obj.cards)
		bin = write_boolean(bin,obj.giveup)
		bin = write_boolean(bin,obj.showed)
		bin = write_int32(bin,obj.gold)
		bin = write_int32(bin,obj.ex_gold)
		bin
	end
	
	def write_playstate(bin,:not_play) do
		write_byte(bin,0)
	end
	
	def write_playstate(bin,:playing) do
		write_byte(bin,1)
	end
	
	def write_playstate(bin,:give_up) do
		write_byte(bin,2)
	end
	
	def write_playstate(bin,_) do
		write_byte(bin,-1)
	end
	
	def write_playinfo(bin,obj) do
		bin = write_int32(bin,obj.id)
		bin = write_int32(bin,obj.gold)
		bin = write_playstate(bin,obj.state)
		bin = write_boolean(bin,obj.showed)
		bin = write_array(bin,&write_byte/2,obj.put_count)
		bin
	end
	
	def write_turnplayerdata(bin,obj) do
		bin = write_array(bin,&write_byte/2,obj.cards)
		bin = write_int32(bin,obj.id)
		bin = write_boolean(bin,obj.played)
		bin = write_int32(bin,obj.score)
		bin = write_int32(bin,obj.all_score)
		bin = write_array(bin,&write_int32/2,obj.shots)
		bin = write_boolean(bin,obj.shot_all)
		bin = write_array(bin,&write_byte/2,obj.daos)
		bin
	end
	
	def write_turndata(bin,obj) do
		bin = write_array(bin,&write_turnplayerdata/2,obj.datas)
		bin
	end
	
	def on_message(state,bin) do
		{n,bin} = read_int(bin)
		on_message(state,n,bin)
	end
	
	def on_message(state,1,bin) do
		{p,_bin} = read_roomparams(bin)
		Room.create_room(state,p)
	end
	
	def on_message(state,4,_bin) do
		Room.get_room(state)
	end
	
	def on_message(state,6,bin) do
		{room_id,_bin} = read_int32(bin)
		Room.enter(state,room_id)
	end
	
	def on_message(state,13,_bin) do
		Room.player_ready(state)
	end
	
	def on_message(state,15,_bin) do
		Room.quit(state)
	end
	
	def on_message(state,20,_bin) do
		Room.quit_vote_yes(state)
	end
	
	def on_message(state,21,_bin) do
		Room.quit_vote_no(state)
	end
	
	def on_message(state,22,_bin) do
		Room.start(state)
	end
	
	def on_message(state,37,_bin) do
		Room.get_history(state)
	end
	
	def on_message(state,40,_bin) do
		Room.cancel_tuoguan(state)
	end
	
	def on_message(state,42,bin) do
		{cmd,bin} = read_puttype(bin)
		{cards,_bin}= read_array(bin,&read_int32/1)
		Room.put_cmd(state,cmd,cards)
	end
	
	def on_message(state,43,bin) do
		{em,_bin} = read_int32(bin)
		Room.show_emotion(state,em)
	end
	
	def on_message(state,45,bin) do
		{url,_bin} = read_string(bin)
		Room.voice(state,url)
	end
	
	def on_message(state,47,bin) do
		{id,_bin} = read_int32(bin)
		Room.show_replay(state,id)
	end
	
	def on_message(state,50,bin) do
		{game_id,bin} = read_int32(bin)
		{index,_bin} = read_int32(bin)
		Room.get_replay_data(state,game_id,index)
	end
	
	def on_message(state,52,bin) do
		{str,_bin} = read_string(bin)
		Room.show_txt_msg(state,str)
	end
	
	def on_message(state,54,bin) do
		{id,_bin} = read_int32(bin)
		Room.get_user_info(state,id)
	end
	
	def on_message(state,56,_bin) do
		Room.power_up(state)
	end
	
	def on_message(state,67,bin) do
		{cards,bin}= read_array(bin,&read_byte/1)
		{supper,_bin} = read_boolean(bin)
		Room.put_cards(state,cards,supper)
	end
	
	def read_roomparams(bin) do
		{r_type,bin} = read_byte(bin)
		{r_round_count,bin} = read_byte(bin)
		{r_player_count,bin} = read_byte(bin)
		{r_base_score,bin} = read_int32(bin)
		{r_ex_param1,bin} = read_int32(bin)
		{r_ex_param2,bin} = read_int32(bin)
		{r_ex_param3,bin} = read_int32(bin)
		r = %{
			:type => r_type,
			:round_count => r_round_count,
			:player_count => r_player_count,
			:base_score => r_base_score,
			:ex_param1 => r_ex_param1,
			:ex_param2 => r_ex_param2,
			:ex_param3 => r_ex_param3,
		}
		{r,bin}
	end
	
	def read_playerinfo(bin) do
		{r_name,bin} = read_string(bin)
		{r_id,bin} = read_int32(bin)
		{r_sex,bin} = read_byte(bin)
		{r_head,bin} = read_string(bin)
		{r_ip,bin} = read_string(bin)
		{r_started,bin} = read_boolean(bin)
		{r_offline,bin} = read_boolean(bin)
		{r_gold,bin} = read_int32(bin)
		{r_pos,bin} = read_byte(bin)
		r = %{
			:name => r_name,
			:id => r_id,
			:sex => r_sex,
			:head => r_head,
			:ip => r_ip,
			:started => r_started,
			:offline => r_offline,
			:gold => r_gold,
			:pos => r_pos,
		}
		{r,bin}
	end
	
	def read_historyscore(bin) do
		{r_id,bin} = read_int32(bin)
		{r_name,bin} = read_string(bin)
		{r_score,bin} = read_int32(bin)
		{r_values,bin} = read_array(bin,&read_byte/1)
		r = %{
			:id => r_id,
			:name => r_name,
			:score => r_score,
			:values => r_values,
		}
		{r,bin}
	end
	
	def read_history(bin) do
		{r_game_id,bin} = read_int32(bin)
		{r_time,bin} = read_string(bin)
		{r_round,bin} = read_int32(bin)
		{r_max_count,bin} = read_int32(bin)
		{r_room_id,bin} = read_int32(bin)
		{r_data,bin} = read_array(bin,&read_historyscore/1)
		r = %{
			:game_id => r_game_id,
			:time => r_time,
			:round => r_round,
			:max_count => r_max_count,
			:room_id => r_room_id,
			:data => r_data,
		}
		{r,bin}
	end
	
	def read_hucards(bin) do
		{r_card,bin} = read_byte(bin)
		{r_hus,bin} = read_array(bin,&read_byte/1)
		r = %{
			:card => r_card,
			:hus => r_hus,
		}
		{r,bin}
	end
	
	def read_cards(bin) do
		{r_datas,bin} = read_array(bin,&read_byte/1)
		r = %{
			:datas => r_datas,
		}
		{r,bin}
	end
	
	def read_endplayercards(bin) do
		{r_cur,bin} = read_array(bin,&read_byte/1)
		{r_hold,bin} = read_array(bin,&read_byte/1)
		r = %{
			:cur => r_cur,
			:hold => r_hold,
		}
		{r,bin}
	end
	
	def read_endinfo(bin) do
		{r_type,bin} = read_int32(bin)
		{r_cur_turn,bin} = read_int32(bin)
		{r_ids,bin} = read_array(bin,&read_int32/1)
		{r_names,bin} = read_array(bin,&read_string/1)
		{r_hu_scores,bin} = read_array(bin,&read_int32/1)
		{r_cur_scores,bin} = read_array(bin,&read_int32/1)
		{r_all_scores,bin} = read_array(bin,&read_int32/1)
		{r_mas,bin} = read_array(bin,&read_byte/1)
		{r_macards,bin} = read_array(bin,&read_byte/1)
		{r_cards,bin} = read_array(bin,&read_endplayercards/1)
		r = %{
			:type => r_type,
			:cur_turn => r_cur_turn,
			:ids => r_ids,
			:names => r_names,
			:hu_scores => r_hu_scores,
			:cur_scores => r_cur_scores,
			:all_scores => r_all_scores,
			:mas => r_mas,
			:macards => r_macards,
			:cards => r_cards,
		}
		{r,bin}
	end
	
	def read_historyex(bin) do
		{r_game_id,bin} = read_int32(bin)
		{r_time,bin} = read_string(bin)
		{r_round,bin} = read_int32(bin)
		{r_max_count,bin} = read_int32(bin)
		{r_room_id,bin} = read_int32(bin)
		{r_names,bin} = read_array(bin,&read_string/1)
		{r_scores,bin} = read_array(bin,&read_int32/1)
		r = %{
			:game_id => r_game_id,
			:time => r_time,
			:round => r_round,
			:max_count => r_max_count,
			:room_id => r_room_id,
			:names => r_names,
			:scores => r_scores,
		}
		{r,bin}
	end
	
	def read_puttype(bin) do
		{n,bin} = read_byte(bin)
		r =
		case n do
		0 -> :put_peng
		1 -> :put_gang
		2 -> :put_win
		3 -> :put_self_gang
		4 -> :put_card
		5 -> :put_pass
		6 -> :give_up
		7 -> :put_gold
		8 -> :check
		9 -> :show_card
		_ -> nil
		end
		{r,bin}
	end
	
	def read_replaydata(bin) do
		{r_players,bin} = read_array(bin,&read_playerinfo/1)
		{r_room_params,bin} = read_roomparams(bin)
		{r_order,bin} = read_array(bin,&read_int32/1)
		{r_game_count,bin} = read_int32(bin)
		r = %{
			:players => r_players,
			:room_params => r_room_params,
			:order => r_order,
			:game_count => r_game_count,
		}
		{r,bin}
	end
	
	def read_gamedata(bin) do
		{r_cards,bin} = read_array(bin,&read_cards/1)
		{r_card_count,bin} = read_int32(bin)
		{r_pi_card,bin} = read_byte(bin)
		{r_steps,bin} = read_array(bin,&read_byte/1)
		r = %{
			:cards => r_cards,
			:card_count => r_card_count,
			:pi_card => r_pi_card,
			:steps => r_steps,
		}
		{r,bin}
	end
	
	def read_playercards(bin) do
		{r_id,bin} = read_int32(bin)
		{r_cards,bin} = read_array(bin,&read_byte/1)
		{r_giveup,bin} = read_boolean(bin)
		{r_showed,bin} = read_boolean(bin)
		{r_gold,bin} = read_int32(bin)
		{r_ex_gold,bin} = read_int32(bin)
		r = %{
			:id => r_id,
			:cards => r_cards,
			:giveup => r_giveup,
			:showed => r_showed,
			:gold => r_gold,
			:ex_gold => r_ex_gold,
		}
		{r,bin}
	end
	
	def read_playstate(bin) do
		{n,bin} = read_byte(bin)
		r =
		case n do
		0 -> :not_play
		1 -> :playing
		2 -> :give_up
		_ -> nil
		end
		{r,bin}
	end
	
	def read_playinfo(bin) do
		{r_id,bin} = read_int32(bin)
		{r_gold,bin} = read_int32(bin)
		{r_state,bin} = read_playstate(bin)
		{r_showed,bin} = read_boolean(bin)
		{r_put_count,bin} = read_array(bin,&read_byte/1)
		r = %{
			:id => r_id,
			:gold => r_gold,
			:state => r_state,
			:showed => r_showed,
			:put_count => r_put_count,
		}
		{r,bin}
	end
	
	def read_turnplayerdata(bin) do
		{r_cards,bin} = read_array(bin,&read_byte/1)
		{r_id,bin} = read_int32(bin)
		{r_played,bin} = read_boolean(bin)
		{r_score,bin} = read_int32(bin)
		{r_all_score,bin} = read_int32(bin)
		{r_shots,bin} = read_array(bin,&read_int32/1)
		{r_shot_all,bin} = read_boolean(bin)
		{r_daos,bin} = read_array(bin,&read_byte/1)
		r = %{
			:cards => r_cards,
			:id => r_id,
			:played => r_played,
			:score => r_score,
			:all_score => r_all_score,
			:shots => r_shots,
			:shot_all => r_shot_all,
			:daos => r_daos,
		}
		{r,bin}
	end
	
	def read_turndata(bin) do
		{r_datas,bin} = read_array(bin,&read_turnplayerdata/1)
		r = %{
			:datas => r_datas,
		}
		{r,bin}
	end
	
end
