
local Class =  {}

function Class:create_room(p)
	self:begin_send()
	self:write_byte(1)
	self:write_int(1)
	self:write_roomparams(p)
	self:end_send()
end

function Class:get_room()
	self:begin_send()
	self:write_byte(1)
	self:write_int(4)
	self:end_send()
end

function Class:enter(room_id)
	self:begin_send()
	self:write_byte(1)
	self:write_int(6)
	self:write_int32(room_id)
	self:end_send()
end

function Class:player_ready()
	self:begin_send()
	self:write_byte(1)
	self:write_int(13)
	self:end_send()
end

function Class:quit()
	self:begin_send()
	self:write_byte(1)
	self:write_int(15)
	self:end_send()
end

function Class:quit_vote_yes()
	self:begin_send()
	self:write_byte(1)
	self:write_int(20)
	self:end_send()
end

function Class:quit_vote_no()
	self:begin_send()
	self:write_byte(1)
	self:write_int(21)
	self:end_send()
end

function Class:start()
	self:begin_send()
	self:write_byte(1)
	self:write_int(22)
	self:end_send()
end

function Class:get_history()
	self:begin_send()
	self:write_byte(1)
	self:write_int(37)
	self:end_send()
end

function Class:cancel_tuoguan()
	self:begin_send()
	self:write_byte(1)
	self:write_int(40)
	self:end_send()
end

function Class:put_cmd(cmd,cards)
	self:begin_send()
	self:write_byte(1)
	self:write_int(42)
	self:write_puttype(cmd)
	self:write_array(Class.write_int32,cards)
	self:end_send()
end

function Class:show_emotion(em)
	self:begin_send()
	self:write_byte(1)
	self:write_int(43)
	self:write_int32(em)
	self:end_send()
end

function Class:voice(url)
	self:begin_send()
	self:write_byte(1)
	self:write_int(45)
	self:write_string(url)
	self:end_send()
end

function Class:show_replay(id)
	self:begin_send()
	self:write_byte(1)
	self:write_int(47)
	self:write_int32(id)
	self:end_send()
end

function Class:get_replay_data(game_id,index)
	self:begin_send()
	self:write_byte(1)
	self:write_int(50)
	self:write_int32(game_id)
	self:write_int32(index)
	self:end_send()
end

function Class:show_txt_msg(str)
	self:begin_send()
	self:write_byte(1)
	self:write_int(52)
	self:write_string(str)
	self:end_send()
end

function Class:get_user_info(id)
	self:begin_send()
	self:write_byte(1)
	self:write_int(54)
	self:write_int32(id)
	self:end_send()
end

function Class:power_up()
	self:begin_send()
	self:write_byte(1)
	self:write_int(56)
	self:end_send()
end

function Class:put_cards(cards,supper)
	self:begin_send()
	self:write_byte(1)
	self:write_int(67)
	self:write_array(Class.write_byte,cards)
	self:write_boolean(supper)
	self:end_send()
end

function Class:write_roomparams(obj)
	self:write_byte(obj.type)
	self:write_byte(obj.round_count)
	self:write_byte(obj.player_count)
	self:write_int32(obj.base_score)
	self:write_int32(obj.ex_param1)
	self:write_int32(obj.ex_param2)
	self:write_int32(obj.ex_param3)
end

function Class:write_playerinfo(obj)
	self:write_string(obj.name)
	self:write_int32(obj.id)
	self:write_byte(obj.sex)
	self:write_string(obj.head)
	self:write_string(obj.ip)
	self:write_boolean(obj.started)
	self:write_boolean(obj.offline)
	self:write_int32(obj.gold)
	self:write_byte(obj.pos)
end

function Class:write_historyscore(obj)
	self:write_int32(obj.id)
	self:write_string(obj.name)
	self:write_int32(obj.score)
	self:write_array(Class.write_byte,obj.values)
end

function Class:write_history(obj)
	self:write_int32(obj.game_id)
	self:write_string(obj.time)
	self:write_int32(obj.round)
	self:write_int32(obj.max_count)
	self:write_int32(obj.room_id)
	self:write_array(Class.write_historyscore,obj.data)
end

function Class:write_hucards(obj)
	self:write_byte(obj.card)
	self:write_array(Class.write_byte,obj.hus)
end

function Class:write_cards(obj)
	self:write_array(Class.write_byte,obj.datas)
end

function Class:write_endplayercards(obj)
	self:write_array(Class.write_byte,obj.cur)
	self:write_array(Class.write_byte,obj.hold)
end

function Class:write_endinfo(obj)
	self:write_int32(obj.type)
	self:write_int32(obj.cur_turn)
	self:write_array(Class.write_int32,obj.ids)
	self:write_array(Class.write_string,obj.names)
	self:write_array(Class.write_int32,obj.hu_scores)
	self:write_array(Class.write_int32,obj.cur_scores)
	self:write_array(Class.write_int32,obj.all_scores)
	self:write_array(Class.write_byte,obj.mas)
	self:write_array(Class.write_byte,obj.macards)
	self:write_array(Class.write_endplayercards,obj.cards)
end

function Class:write_historyex(obj)
	self:write_int32(obj.game_id)
	self:write_string(obj.time)
	self:write_int32(obj.round)
	self:write_int32(obj.max_count)
	self:write_int32(obj.room_id)
	self:write_array(Class.write_string,obj.names)
	self:write_array(Class.write_int32,obj.scores)
end

function Class:write_puttype(obj)
	if obj == "put_peng" then
		self:write_byte(0)
	elseif obj == "put_gang" then
		self:write_byte(1)
	elseif obj == "put_win" then
		self:write_byte(2)
	elseif obj == "put_self_gang" then
		self:write_byte(3)
	elseif obj == "put_card" then
		self:write_byte(4)
	elseif obj == "put_pass" then
		self:write_byte(5)
	elseif obj == "give_up" then
		self:write_byte(6)
	elseif obj == "put_gold" then
		self:write_byte(7)
	elseif obj == "check" then
		self:write_byte(8)
	elseif obj == "show_card" then
		self:write_byte(9)
	else
		self:write_byte(-1)
	end
end

function Class:write_replaydata(obj)
	self:write_array(Class.write_playerinfo,obj.players)
	self:write_roomparams(obj.room_params)
	self:write_array(Class.write_int32,obj.order)
	self:write_int32(obj.game_count)
end

function Class:write_gamedata(obj)
	self:write_array(Class.write_cards,obj.cards)
	self:write_int32(obj.card_count)
	self:write_byte(obj.pi_card)
	self:write_array(Class.write_byte,obj.steps)
end

function Class:write_playercards(obj)
	self:write_int32(obj.id)
	self:write_array(Class.write_byte,obj.cards)
	self:write_boolean(obj.giveup)
	self:write_boolean(obj.showed)
	self:write_int32(obj.gold)
	self:write_int32(obj.ex_gold)
end

function Class:write_playstate(obj)
	if obj == "not_play" then
		self:write_byte(0)
	elseif obj == "playing" then
		self:write_byte(1)
	elseif obj == "give_up" then
		self:write_byte(2)
	else
		self:write_byte(-1)
	end
end

function Class:write_playinfo(obj)
	self:write_int32(obj.id)
	self:write_int32(obj.gold)
	self:write_playstate(obj.state)
	self:write_boolean(obj.showed)
	self:write_array(Class.write_byte,obj.put_count)
end

function Class:write_turnplayerdata(obj)
	self:write_array(Class.write_byte,obj.cards)
	self:write_int32(obj.id)
	self:write_boolean(obj.played)
	self:write_int32(obj.score)
	self:write_int32(obj.all_score)
	self:write_array(Class.write_int32,obj.shots)
	self:write_boolean(obj.shot_all)
	self:write_array(Class.write_byte,obj.daos)
end

function Class:write_turndata(obj)
	self:write_array(Class.write_turnplayerdata,obj.datas)
end

function Class:init()
	self[2] = Class.on_create_ack
	self[3] = Class.on_create_error
	self[5] = Class.on_get_room_ack
	self[7] = Class.on_enter_ack
	self[8] = Class.on_enter_error
	self[9] = Class.on_enter_player
	self[10] = Class.on_quit_player
	self[11] = Class.on_offline_player
	self[12] = Class.on_online_player
	self[14] = Class.on_player_ready_ack
	self[16] = Class.on_quit_room
	self[17] = Class.on_quit_voto
	self[18] = Class.on_quit_voto_end
	self[19] = Class.on_quit_voto_time
	self[23] = Class.on_game_start_error
	self[24] = Class.on_game_start
	self[25] = Class.on_game_order
	self[26] = Class.on_saizhi
	self[27] = Class.on_get_lai
	self[28] = Class.on_turn
	self[29] = Class.on_put_card
	self[30] = Class.on_get_pi
	self[31] = Class.on_wait_action
	self[32] = Class.on_gang
	self[33] = Class.on_peng
	self[34] = Class.on_score
	self[35] = Class.on_hu
	self[36] = Class.on_end_game
	self[38] = Class.on_show_history_ex
	self[39] = Class.on_show_history
	self[41] = Class.on_tuoguan
	self[44] = Class.on_show_emotion_ack
	self[46] = Class.on_voice_ack
	self[48] = Class.on_show_replay_ack
	self[49] = Class.on_show_replay_error
	self[51] = Class.on_get_replay_data_ack
	self[53] = Class.on_show_txt_msg_ack
	self[55] = Class.on_get_user_info_ack
	self[57] = Class.on_power_up_ack
	self[58] = Class.on_put_gold
	self[59] = Class.on_show_card_ack
	self[60] = Class.on_show_card_value
	self[61] = Class.on_giveup_ack
	self[62] = Class.on_check_result
	self[63] = Class.on_win_id
	self[64] = Class.on_turn_id
	self[65] = Class.on_play_info
	self[66] = Class.on_end_games
	self[68] = Class.on_put_cards_ok
	self[69] = Class.on_end_turn
end

function Class:on_message()
	local n = self:read_int()
	self[n](self)
end

function Class:on_create_ack()
	local room_id = self:read_int32()
	self.client:room_create_ack(room_id)
end

function Class:on_create_error()
	local error = self:read_string()
	self.client:room_create_error(error)
end

function Class:on_get_room_ack()
	local id = self:read_int32()
	self.client:room_get_room_ack(id)
end

function Class:on_enter_ack()
	local host_id = self:read_int32()
	local rounds = self:read_int32()
	local round_host = self:read_int32()
	local players = self:read_array(Class.read_playerinfo)
	local p = self:read_roomparams()
	self.client:room_enter_ack(host_id,rounds,round_host,players,p)
end

function Class:on_enter_error()
	local error = self:read_string()
	self.client:room_enter_error(error)
end

function Class:on_enter_player()
	local player = self:read_playerinfo()
	self.client:room_enter_player(player)
end

function Class:on_quit_player()
	local id = self:read_int32()
	self.client:room_quit_player(id)
end

function Class:on_offline_player()
	local id = self:read_int32()
	self.client:room_offline_player(id)
end

function Class:on_online_player()
	local id = self:read_int32()
	local ip = self:read_string()
	self.client:room_online_player(id,ip)
end

function Class:on_player_ready_ack()
	local id = self:read_int32()
	self.client:room_player_ready_ack(id)
end

function Class:on_quit_room()
	self.client:room_quit_room()
end

function Class:on_quit_voto()
	local time = self:read_single()
	local ids = self:read_array(Class.read_int32)
	self.client:room_quit_voto(time,ids)
end

function Class:on_quit_voto_end()
	local yes = self:read_boolean()
	self.client:room_quit_voto_end(yes)
end

function Class:on_quit_voto_time()
	local time = self:read_single()
	self.client:room_quit_voto_time(time)
end

function Class:on_game_start_error()
	local err = self:read_string()
	self.client:room_game_start_error(err)
end

function Class:on_game_start()
	local order = self:read_array(Class.read_int32)
	self.client:room_game_start(order)
end

function Class:on_game_order()
	local order = self:read_array(Class.read_int32)
	local his = self:read_history()
	self.client:room_game_order(order,his)
end

function Class:on_saizhi()
	local id = self:read_int32()
	local s1 = self:read_byte()
	local s2 = self:read_byte()
	self.client:room_saizhi(id,s1,s2)
end

function Class:on_get_lai()
	local id = self:read_int32()
	local card = self:read_int32()
	self.client:room_get_lai(id,card)
end

function Class:on_turn()
	local id = self:read_int32()
	local time = self:read_int32()
	local pai = self:read_int32()
	local gangs = self:read_array(Class.read_int32)
	local hus = self:read_array(Class.read_hucards)
	self.client:room_turn(id,time,pai,gangs,hus)
end

function Class:on_put_card()
	local id = self:read_int32()
	local pai = self:read_int32()
	self.client:room_put_card(id,pai)
end

function Class:on_get_pi()
	local id = self:read_int32()
	local pai = self:read_int32()
	self.client:room_get_pi(id,pai)
end

function Class:on_wait_action()
	local peng = self:read_boolean()
	local gang = self:read_boolean()
	local hu = self:read_boolean()
	self.client:room_wait_action(peng,gang,hu)
end

function Class:on_gang()
	local id = self:read_int32()
	local card = self:read_int32()
	local count = self:read_int32()
	self.client:room_gang(id,card,count)
end

function Class:on_peng()
	local id = self:read_int32()
	local card = self:read_int32()
	self.client:room_peng(id,card)
end

function Class:on_score()
	local id = self:read_int32()
	local otherId = self:read_int32()
	local score = self:read_int32()
	self.client:room_score(id,otherId,score)
end

function Class:on_hu()
	local id = self:read_array(Class.read_int32)
	local cards = self:read_array(Class.read_cards)
	self.client:room_hu(id,cards)
end

function Class:on_end_game()
	local info = self:read_endinfo()
	local his = self:read_history()
	self.client:room_end_game(info,his)
end

function Class:on_show_history_ex()
	local datas = self:read_array(Class.read_historyex)
	self.client:room_show_history_ex(datas)
end

function Class:on_show_history()
	local his = self:read_history()
	self.client:room_show_history(his)
end

function Class:on_tuoguan()
	self.client:room_tuoguan()
end

function Class:on_show_emotion_ack()
	local id = self:read_int32()
	local em = self:read_int32()
	self.client:room_show_emotion_ack(id,em)
end

function Class:on_voice_ack()
	local id = self:read_int32()
	local url = self:read_string()
	self.client:room_voice_ack(id,url)
end

function Class:on_show_replay_ack()
	local data = self:read_replaydata()
	self.client:room_show_replay_ack(data)
end

function Class:on_show_replay_error()
	local str = self:read_string()
	self.client:room_show_replay_error(str)
end

function Class:on_get_replay_data_ack()
	local index = self:read_int32()
	local data = self:read_gamedata()
	self.client:room_get_replay_data_ack(index,data)
end

function Class:on_show_txt_msg_ack()
	local id = self:read_int32()
	local str = self:read_string()
	self.client:room_show_txt_msg_ack(id,str)
end

function Class:on_get_user_info_ack()
	local id = self:read_int32()
	local name = self:read_string()
	local note = self:read_string()
	local roundCount = self:read_int32()
	local winCount = self:read_int32()
	local sex = self:read_int32()
	local head = self:read_string()
	local code = self:read_string()
	self.client:room_get_user_info_ack(id,name,note,roundCount,winCount,sex,head,code)
end

function Class:on_power_up_ack()
	local ids = self:read_array(Class.read_int32)
	local power = self:read_array(Class.read_byte)
	self.client:room_power_up_ack(ids,power)
end

function Class:on_put_gold()
	local id = self:read_int32()
	local gold = self:read_int32()
	self.client:room_put_gold(id,gold)
end

function Class:on_show_card_ack()
	local id = self:read_int32()
	self.client:room_show_card_ack(id)
end

function Class:on_show_card_value()
	local cards = self:read_array(Class.read_byte)
	self.client:room_show_card_value(cards)
end

function Class:on_giveup_ack()
	local id = self:read_int32()
	self.client:room_giveup_ack(id)
end

function Class:on_check_result()
	local id = self:read_int32()
	local other = self:read_int32()
	local win = self:read_boolean()
	self.client:room_check_result(id,other,win)
end

function Class:on_win_id()
	local id = self:read_array(Class.read_int32)
	local datas = self:read_array(Class.read_playercards)
	self.client:room_win_id(id,datas)
end

function Class:on_turn_id()
	local id = self:read_int32()
	local time = self:read_int32()
	local round = self:read_int32()
	self.client:room_turn_id(id,time,round)
end

function Class:on_play_info()
	local round = self:read_int32()
	local base_gold = self:read_int32()
	local infos = self:read_array(Class.read_playinfo)
	local cards = self:read_array(Class.read_byte)
	self.client:room_play_info(round,base_gold,infos,cards)
end

function Class:on_end_games()
	local his = self:read_history()
	self.client:room_end_games(his)
end

function Class:on_put_cards_ok()
	local id = self:read_int32()
	self.client:room_put_cards_ok(id)
end

function Class:on_end_turn()
	local data = self:read_turndata()
	self.client:room_end_turn(data)
end

function Class:read_roomparams(obj)
	local r = {}
	r.type = self:read_byte()
	r.round_count = self:read_byte()
	r.player_count = self:read_byte()
	r.base_score = self:read_int32()
	r.ex_param1 = self:read_int32()
	r.ex_param2 = self:read_int32()
	r.ex_param3 = self:read_int32()
	return r
end

function Class:read_playerinfo(obj)
	local r = {}
	r.name = self:read_string()
	r.id = self:read_int32()
	r.sex = self:read_byte()
	r.head = self:read_string()
	r.ip = self:read_string()
	r.started = self:read_boolean()
	r.offline = self:read_boolean()
	r.gold = self:read_int32()
	r.pos = self:read_byte()
	return r
end

function Class:read_historyscore(obj)
	local r = {}
	r.id = self:read_int32()
	r.name = self:read_string()
	r.score = self:read_int32()
	r.values = self:read_array(Class.read_byte)
	return r
end

function Class:read_history(obj)
	local r = {}
	r.game_id = self:read_int32()
	r.time = self:read_string()
	r.round = self:read_int32()
	r.max_count = self:read_int32()
	r.room_id = self:read_int32()
	r.data = self:read_array(Class.read_historyscore)
	return r
end

function Class:read_hucards(obj)
	local r = {}
	r.card = self:read_byte()
	r.hus = self:read_array(Class.read_byte)
	return r
end

function Class:read_cards(obj)
	local r = {}
	r.datas = self:read_array(Class.read_byte)
	return r
end

function Class:read_endplayercards(obj)
	local r = {}
	r.cur = self:read_array(Class.read_byte)
	r.hold = self:read_array(Class.read_byte)
	return r
end

function Class:read_endinfo(obj)
	local r = {}
	r.type = self:read_int32()
	r.cur_turn = self:read_int32()
	r.ids = self:read_array(Class.read_int32)
	r.names = self:read_array(Class.read_string)
	r.hu_scores = self:read_array(Class.read_int32)
	r.cur_scores = self:read_array(Class.read_int32)
	r.all_scores = self:read_array(Class.read_int32)
	r.mas = self:read_array(Class.read_byte)
	r.macards = self:read_array(Class.read_byte)
	r.cards = self:read_array(Class.read_endplayercards)
	return r
end

function Class:read_historyex(obj)
	local r = {}
	r.game_id = self:read_int32()
	r.time = self:read_string()
	r.round = self:read_int32()
	r.max_count = self:read_int32()
	r.room_id = self:read_int32()
	r.names = self:read_array(Class.read_string)
	r.scores = self:read_array(Class.read_int32)
	return r
end

function Class:read_puttype(obj)
	local n = self:read_byte()
	local r
	if n == 0 then
		r = "put_peng"
	elseif n == 1 then
		r = "put_gang"
	elseif n == 2 then
		r = "put_win"
	elseif n == 3 then
		r = "put_self_gang"
	elseif n == 4 then
		r = "put_card"
	elseif n == 5 then
		r = "put_pass"
	elseif n == 6 then
		r = "give_up"
	elseif n == 7 then
		r = "put_gold"
	elseif n == 8 then
		r = "check"
	elseif n == 9 then
		r = "show_card"
	else
		r = nil
	end
	return r
end

function Class:read_replaydata(obj)
	local r = {}
	r.players = self:read_array(Class.read_playerinfo)
	r.room_params = self:read_roomparams()
	r.order = self:read_array(Class.read_int32)
	r.game_count = self:read_int32()
	return r
end

function Class:read_gamedata(obj)
	local r = {}
	r.cards = self:read_array(Class.read_cards)
	r.card_count = self:read_int32()
	r.pi_card = self:read_byte()
	r.steps = self:read_array(Class.read_byte)
	return r
end

function Class:read_playercards(obj)
	local r = {}
	r.id = self:read_int32()
	r.cards = self:read_array(Class.read_byte)
	r.giveup = self:read_boolean()
	r.showed = self:read_boolean()
	r.gold = self:read_int32()
	r.ex_gold = self:read_int32()
	return r
end

function Class:read_playstate(obj)
	local n = self:read_byte()
	local r
	if n == 0 then
		r = "not_play"
	elseif n == 1 then
		r = "playing"
	elseif n == 2 then
		r = "give_up"
	else
		r = nil
	end
	return r
end

function Class:read_playinfo(obj)
	local r = {}
	r.id = self:read_int32()
	r.gold = self:read_int32()
	r.state = self:read_playstate()
	r.showed = self:read_boolean()
	r.put_count = self:read_array(Class.read_byte)
	return r
end

function Class:read_turnplayerdata(obj)
	local r = {}
	r.cards = self:read_array(Class.read_byte)
	r.id = self:read_int32()
	r.played = self:read_boolean()
	r.score = self:read_int32()
	r.all_score = self:read_int32()
	r.shots = self:read_array(Class.read_int32)
	r.shot_all = self:read_boolean()
	r.daos = self:read_array(Class.read_byte)
	return r
end

function Class:read_turndata(obj)
	local r = {}
	r.datas = self:read_array(Class.read_turnplayerdata)
	return r
end

return Class
