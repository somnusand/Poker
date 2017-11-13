local Class = {res = "BiJiPanel"}

function Class:set_pai_ex(t, path, node)
	if node == nil then
		node = self.cur_node
	end
	
	local child
	if type(path) == "string" then
		child = node:FindChild(path)
	else
		child = node:GetChild(path)
	end
	
	if child then
		UIAPI.SetPaiEx(child, t)
	end
end

function Class:init()
	self.em_msg = {"什么烂牌，真是红颜多薄命", "有种我们谁也别看牌，一直跟到底", "你敢下我就敢跟，别以为我会怕你", "做人不要太强，胆子小就别跟了", "别想了果断点，跟我全压了吧", "快点吧，我等的花都谢了", "别赢了就想走呀，我们决战到天亮", "我要走了，下次玩吧", "今天心情好，赢了真不好", "今天的运气太差了，我是认栽了"}
	
	Sound:play_music("paiju")
	
	game_ui = self

	self:clear_all()
end

function Class:destroy()
	game_ui = nil
end

function Class:turn_id(id, time, round)
	print("turn_id", id)
end

function Class:play_player_effect(index, effect, ex_pic, color)
	if ex_pic then
		if color then
			local node = self:effect_image(effect, ex_pic, self.players[index].effect)
			UIAPI.SetPaiEx(node, color)
		else
			self:effect_image(effect, ex_pic, self.players[index].effect)
		end
	else
		self:effect(effect, self.players[index].effect)
	end
end

function Class:is_self_turn()
	return(self.self_id == self.turn_id)
end

function Class:find_next_playing_player()
	local count = - 1
	for k, v in pairs(self.infos) do
		if count == 0 then
			if v.state ~= "not_play" and v.state ~= "give_up" then
				count = 1
				break
			else
			end
		end
		if id == v.id then
			count = 0
		end
	end
end

function Class:clear_all()
	print("clear_all")

end

function game_click_tuoguan()
	proto.room.cancel_tuoguan()
	self:enable(false, self.btn_tuo)
end

function game_click_show_result()
	print("show_result")
	game_ui:show_result()
end

function game_click_quit()
	--UI.show_watting()
	if not game_ui.started then
		if game_ui.self_id == game_ui.host_id then
			local fun_retry = function()
				print("jiesantuichu  ")
				proto.room:quit()
			end
			
			local fun_quit = function()
			end
			
			UI.msg_box("牌局未开始\n房主解散房间钻石退还", fun_retry, fun_quit)
		else
			print("tuichu")
			proto.room:quit()
		end
	else
		if game_ui.history then
			if game_ui.history.round >= game_ui.history.max_count then
				proto.room:quit()
				return
			end
		end
		
		proto.room:quit_vote_yes()
	end
end

function Class:update_voto(dt)
	--print("update_voto")
	if self.vote_node == nil then
		return
	end
	if self.vote_time == nil then
		return
	end
	
	self.vote_time = self.vote_time - dt
	
	if self.vote_time < 0 then
		self.vote_time = 0
	end
	--print(self.vote_time,dt)
	local n = math.floor(self.vote_time)
	
	UI:text_child("倒计时：" .. tostring(n) .. "秒", "Timer", self.vote_node)
end

function Class:quit_voto(time, ids)
	if not self.vote_node then
		self.vote_node = UI.show_temp("Vote")
	end
	
	local yes = #ids
	self.vote_ids = ids
	self.vote_time = time
	
	local voted = false
	for _, v in ipairs(ids) do
		if v == self.self_id then
			voted = true
		end
	end
	
	if voted then
		UI:enable_child(false, "BtnYes", self.vote_node)
		UI:enable_child(false, "BtnNo", self.vote_node)
	else
		UI:enable_child(true, "BtnYes", self.vote_node)
		UI:enable_child(true, "BtnNo", self.vote_node)
	end
	
	UI:enable_child(false, "BtnOk", self.vote_node)
	
	if game_ui.order then
		UI:text_child("同意：" .. tostring(yes) .. "/" .. #game_ui.order, "NoteYes", self.vote_node)
	elseif game_ui.infos then
		UI:text_child("同意：" .. tostring(yes) .. "/" .. #game_ui.infos, "NoteYes", self.vote_node)
	else
		UI:text_child("同意：" .. tostring(yes) .. "/4", "NoteYes", self.vote_node)
	end
	
	UI:enable_child(true, "Timer", self.vote_node)
	
	--UI:text_child("反对："..tostring(#no),"NoteNo",game_ui.vote_node)
end

function Class:quit_voto_time(time)
	UI.msg_box(tostring(time) .. "秒后才能，\n再次投票退出！")
end

function Class:quit_voto_end(yes)
	if not self.vote_node then
		self.vote_node = UI.show_temp("Vote")
	end
	
	if yes then
		local fun = function()
			UI.close_watting()
			UI.close_all()
			UI.create("main_ui")
			self.vote_node = nil
		end
		UI:button_child(fun, "BtnOk", self.vote_node)
		
		UI:text_child("全部同意 游戏结束", "NoteYes", self.vote_node)
	else
		local fun = function()
			self.vote_node = nil
		end
		UI:button_child(fun, "BtnOk", self.vote_node)
		UI:text_child("有人反对 游戏继续", "NoteYes", self.vote_node)
	end
	
	UI:enable_child(true, "BtnOk", self.vote_node)
	
	UI:enable_child(false, "BtnYes", self.vote_node)
	UI:enable_child(false, "BtnNo", self.vote_node)
	
	UI:enable_child(false, "Timer", self.vote_node)
	--UI:enable_child(false,"NoteYes",self.vote_node)
	--UI:enable_child(false,"NoteNo",self.vote_node)
	UI:enable_child(true, "BtnOk", self.vote_node)
end

function game_click_vote_yes()
	proto.room:quit_vote_yes()
	UI:enable_child(false, "BtnYes", game_ui.vote_node)
	UI:enable_child(false, "BtnNo", game_ui.vote_node)
end

function game_click_vote_no()
	proto.room:quit_vote_no()
	UI:enable_child(false, "BtnYes", game_ui.vote_node)
	UI:enable_child(false, "BtnNo", game_ui.vote_node)
end

function game_click_dis()
	UI.show_watting()
	proto.room:quit()
end

function game_click_friend()
	local type
	local pay
	if game_ui.room_params.type == 0 then
		type = "炸金花"
	else
		type = "炸金花"
	end
	
	if game_ui.room_params.player_count == 0 then
		pay = "房主付费"
	else
		pay = "每人付费"
	end
	local str = string.format("share,炸金花,打开游戏，输入房间号(%d)，大战(%d)局，%d人玩法,%s", client.room_id, game_ui.room_params.round_count, game_ui.room_params.ex_param2, game_url)
	print(str)
	GameAPI.CallFun(str)
end

function game_click_start()
	if game_ui.temp_result then
		UI.destroy_temp(game_ui.temp_result)
		game_ui.temp_result = nil
	end
	
	if game_ui.history then
		if game_ui.history.round >= game_ui.room_params.round_count then
			show_history(true)
			return
		end
	end
	
	proto.room:start()
	click_auto_cancel()
end

-- message
function Class:tuoguan()
	self:enable(true, self.btn_tuo)
end

function Class:show_txt_msg_ack(id, msg)
	local index = self:get_playersCount_byid(id) - 1
	-- local index = self.id_order[id] - 1
	local temp = UI.show_temp(string.format("Chat_%d", index))
	self:text_child(msg, "Chat/Text", temp)
end

function Class:set_em_txt(node)
	for i, v in ipairs(self.em_msg) do
		self:text_child(v, i - 1, node)
	end
end

function Class:show_emotion_ack(id, em)
	print(em)
	if em >= 50 then
		em = em - 50 + 1
		if self.infos[id].sex == 1 then
			Sound:play_sound(string.format("boy_fix_msg_%d", em))
		else
			Sound:play_sound(string.format("girl_fix_msg_%d", em))
		end
		self:show_txt_msg_ack(id, self.em_msg[em])
	else
		local index = self.id_order[id]
		UIAPI.DeletetAllChild(self.players[index].em_effect)
		local node = UIAPI.CreateChild(self.players[index].em_effect, "effect/emotion", false)
		UIAPI.SetEmImage(node:FindChild("Image"), em)
	end
end

--进入响应
--     id: x.id,
--     name: x.name,
--     sex: x.sex,
--     head: x.head,
--     ip: x.ip,
--     started: x.started,
--     offline: x.off_line,
--     pos: x.pos,
--     gold: x.gold,
function Class:enter_ack(host_id, rounds, round_host, infos, room_params)
	print("enter_ack")
	
	self:enable(true, self.btn_friend)
	self:enable(true, self.btn_start)
	
	self.host_id = host_id
	self.infos = infos
	self.room_params = room_params
	print(room_params.ex_param2 .. "房间人数上限")
	
	print(rounds .. "当前局数")
	self.room_round_count = rounds
	self:dis_game_count(self.room_round_count)
	
	self.id_order = {}
	
	for i, v in ipairs(infos) do
		print(v.id)
		print(v.pos)
		if v.id == client.user_info.id then
			self.self_pos = v.pos
		end
	end
	
	self.id_order = {}
	for i, v in ipairs(infos) do
		print(v.pos)
		print(self.self_pos)
		if self.room_params.ex_param2 == 3 then
			if(self.sit_count + v.pos - self.self_pos) % self.sit_count + 1 >= 3 then
				if self:CheckHas(self.id_order, 4) then
					self.id_order[v.id] = 2
				else
					self.id_order[v.id] = 4
				end
			else
				self.id_order[v.id] = 1 +(self.sit_count + v.pos - self.self_pos) % self.sit_count
			end
		else
			self.id_order[v.id] = 1 +(self.sit_count + v.pos - self.self_pos) % self.sit_count
		end
		
	end
	print(_s(self.id_order))
	
	self.infos = {}
	for i, v in ipairs(infos) do
		local index = self.id_order[v.id]
		self.infos[v.id] = v
		print(index)
		self:enable(true, self.players[index].name)
		self:enable(true, self.players[index].pic)
		self:text(v.name, self.players[index].name)
		self:image(v.head, self.players[index].pic:FindChild("Mask/Image"))
		
		self:enable(v.offline, self.players[index].offline)
		self:enable(true, self.players[index].scoreTxt)
		self:enable(true, self.players[index].scoreBg)
		if host_id == v.id then
			self:enable(true, self.players[index].room_host)
		end
		-- print(v.id)
		if round_host == v.id then
			-- local ind=self:get_playersCount_byid(v.id)
			self:enable(true, self.players[index].room_zhuang)
		end
		
		self:enable(v.started, self.players[index].ok)
		self.players[index].score = v.gold
		self.players[index].old_score = v.gold
		self:text(self.players[i].score, self.players[i].scoreTxt)
		self.players[index].id = v.id
		-- self.players[n].hasgiveup
	end
	if round_host == 0 then
		self:enable(true, self.players[self.id_order[self.host_id]].room_zhuang)
	end
	
	self:text_child("房间" .. tostring(client.room_id), "RoomInfo/ID")
end

function Class:CheckHas(tb, value)
	local has = false
	for k, v in pairs(tb) do
		if value == v then
			has = true
		end
	end
	return has
end

function Class:start_voice(id)
	if self.voice_effect then
		self:destroy_temp(self.voice_effect)
		self.voice_effect = nil
	end
	local index = self.id_order[id]
	-- self.voice_effect = self:effect("Speek",self.players[index].effect)
	self.voice_effect = self:effect("Speek", self.players[index].speaking)
end

-- infos.state
-- not_play,
-- playing,
-- give_up,
--新玩家进入
function Class:enter_player(info)
	-- id: player.id,
	-- name: player.name,
	-- sex: player.sex,
	-- head: player.head,
	-- ip: player.ip,
	-- started: player.started,
	-- offline: player.off_line,
	-- pos: player.pos,
	-- gold: player.gold
	print("enter_player")
	info.state = "not_play"
	
	print(info.pos)
	print(self.self_pos)
	-- if self.room_params.ex_param2 == 3 then
	-- 	if(self.sit_count + v.pos - self.self_pos) % self.sit_count + 1 > 2 then
	-- 		n = 4
	-- 	end
	-- else
	-- 	n = 1 +(self.sit_count + v.pos - self.self_pos) % self.sit_count
	-- end
	if self.room_params.ex_param2 == 3 then
		if(self.sit_count + info.pos - self.self_pos) % self.sit_count + 1 >= 3 then
			if self:CheckHas(self.id_order, 4) then
				n = 2
			else
				n = 4
			end
		else
			n = 1 +(self.sit_count + info.pos - self.self_pos) % self.sit_count
		end
	else
		n = 1 +(self.sit_count + info.pos - self.self_pos) % self.sit_count
	end
	
	
	
	-- n = 1 +(self.sit_count + info.pos - self.self_pos) % self.sit_count
	self:enable(true, self.players[n].name)
	self:enable(true, self.players[n].pic)
	self:text(info.name, self.players[n].name)
	self:image(info.head, self.players[n].pic:FindChild("Mask/Image"))
	
	self:enable(info.started, self.players[n].ok)
	
	self:enable(info.offline, self.players[n].offline)
	
	self:enable(true, self.players[n].scoreTxt)
	self:enable(true, self.players[n].scoreBg)
	self:enable(false, self.players[n].room_host)
	self:enable(false, self.players[n].room_zhuang)
	
	self.players[n].score = info.gold
	self.players[n].old_score = info.gold
	self:text(self.players[n].score, self.players[n].scoreTxt)
	
	self.players[n].id = info.id
	self.infos[info.id] = info
	self.id_order[info.id] = n
	-- for k, v in pairs(self.infos[info.id]) do
	-- 	print(k, v)
	-- end
end

function Class:quit_player(id)
	if self.infos[id] then
		local n = self.id_order[id]
		self:enable(false, self.players[n].name)
		self:enable(false, self.players[n].pic)
		self:enable(false, self.players[n].ok)
		self:enable(false, self.players[n].offline)
		self:enable(false, self.players[n].scoreTxt)
		self:enable(false, self.players[n].scoreBg)
		self:enable(false, self.players[n].room_host)
		self:enable(false, self.players[n].room_zhuang)
		
		self.infos[id] = nil
		self.id_order[id] = nil
	end
end

function Class:dis_game_count(count)
	if not count then
		count = 1
	end
	-- self:text_child(string.format("%d/%d局",count,self.room_params.round_count),"RoomInfo/GameCount")
	self:text(count .. "/" .. self.room_params.round_count, self.GameCount)
end


function Class:game_start(order, show_start)
	self:clear_all()
	
	self.order = order
	if show_start then
		self:effect("Start")
	end
	self.room_round_count = self.room_round_count + 1
	self:dis_game_count(self.room_round_count)
	
	self.started = true
	
	self:enable(false, self.btn_dis)
	--self:enable(false,self.btn_quit)
	self:enable(false, self.btn_friend)
	self:enable(false, self.btn_start)
	
	for n = 1, self.sit_count do
		self:enable(false, self.players[n].ok)
	end
	
	for k, v in pairs(self.infos) do
		v.state = "not_play"
	end
	for i, v in ipairs(order) do
		local n = self.id_order[v]
		
		self.infos[v].base_x = 1
		
		self:enable(false, self.players[n].ok)
		
		-- self.players[n].old_Score = self.players[n].score
		-- self.players[n].score = self.players[n].score - 1
		-- self:text(self.players[n].score, self.players[n].scoreTxt)
		-- self.players[n].cur_score=-1
		self.infos[v].state = "playing"
	end
	print("start...\n")
end

function Class:set_card_value(t, value)
	-- print("set_card_value   " .. value)
	if value == 0 then
		self:image("纸牌_55", t)
	elseif value == - 1 then
		self:image("纸牌_56", t)
	elseif value == - 2 then
		self:image("纸牌_57", t)
	else
		--print(value,n,hua,pai)
		local hua =(value - 1) % 4
		local pai = 1 +((value - hua - 1) / 4)
		if pai == 13 then
			pai = 0
		end
		
		local n = hua * 13 + pai + 1
		
		if n < 10 then
			self:image("纸牌_0" .. n, t)
		else
			self:image("纸牌_" .. n, t)
		end
	end
end

-- max3 gameplay
-- cmd for buttons
function cmd_show()
	print("cmd_show")
	proto.room:put_cmd("show_card", {})
end

function cmd_put()
	-- print(game_ui.base_put)
	print(game_ui.base_put)
	proto.room:put_cmd("put_gold", {game_ui.base_put})
end

function cmd_giveup()
	proto.room:put_cmd("give_up", {}) --
end

function click_up_put(count)
	-- print(count)
	print("click_up_put")
	local ch_count = 0
	-- game_ui.base_put = tonumber(ch_count)
	proto.room:put_cmd("put_gold", {ch_count})
end

function cmd_check_card(count)
	print(count)
	-- if game_ui.showed then
	--     print("看牌")
	proto.room:put_cmd("check", {game_ui.players[tonumber(count)].id})
	-- else
	--     print("没看")
	proto.room:put_cmd("check", {game_ui.players[tonumber(count)].id})
	-- end
end

-- return
-- infos
-- public int id
-- public int gold
-- public PlayState state
-- public bool showed
-- public byte[] put_count
-- round
-- base_gold
--round,state.base_count,info,cards
function Class:play_info(round, base_gold, infos, cards)
	print("play_info")
	print(_s(infos))
	print(_s(round))
	print(_s(base_gold))
	print(_s(cards))
	self:enable(false, self.btn_dis)
	self:enable(false, self.btn_friend)
	self:enable(false, self.btn_start)
	
	self.started = true
	
	for n = 1, self.sit_count do
		self:enable(false, self.players[n].ok)
	end
	
	print(#infos)
	for i, v in ipairs(infos) do
		
		local index = self:get_playersCount_byid(v.id)
		self.players[index].score = v.gold
		self.players[index].old_Score = v.gold
		local n_score = v.gold
		local t = game_ui.players[index].scoreTxt
		self:text(n_score, t)
		self.infos[v.id].state = v.state
		
		-- for a, b in pairs(v.put_count) do
		-- 	game_ui.players[index].score = game_ui.players[index].score - b
		-- end
		-- self:text(game_ui.players[index].score, game_ui.players[index].scoreTxt)
		local id = v.id
		-- local n = self.id_order[id]
		local n = self:get_playersCount_byid(v.id)
	end
	
	print(#cards)
	print(_s(cards))
	-- self:Fastfapai(cards)
	self:show_card_value(cards)
end

function Class:get_playersCount_byid(id)
	for x = 1, 6 do
		if self.players[x].id == id then
			return x
		end
	end
end

function Class:show_card_ack(id)
	
end

--收到自己牌数据
function Class:show_card_value(cards)
	print("show_card_value")
	self:fapaiAction(cards)
	self.current_cards = cards
	self.default_cards = cards
	
end

function Class:put_gold(id, gold)
	print("player " .. id .. " put " .. gold .. "     " .. self.infos[id].base_x)
	-- if self.infos[id].base_x==1 and gold==0 then
	-- 	self.base_put=1
	-- elseif self.infos[id].base_x==2 and gold==0 then
	-- 	self.base_put=0
	-- end
	-- if gold > tonumber(self.base_put) then
	--     self.base_put = gold
	--     game_ui:play_sound(id,"jiazhu",1)
	-- else
	-- 	game_ui:play_sound(id,"genzhu",1)
	-- end
	local putgold_number = 0
	if gold == 0 then
		if self.infos[id].base_x == 1 then
			putgold_number = 1
			self.base_put = 1
			game_ui:play_sound(id, "genzhu", 1)
		elseif self.infos[id].base_x == 2 then
			putgold_number = 1
			self.base_put = 0
			game_ui:play_sound(id, "genzhu", 1)
		end
	else
		if gold > tonumber(self.base_put) then
			self.base_put = gold
			putgold_number = gold * self.infos[id].base_x
			game_ui:play_sound(id, "jiazhu", 1)
		else
			putgold_number = gold * self.infos[id].base_x
			game_ui:play_sound(id, "genzhu", 1)
		end
	end
	
	local n = self:get_playersCount_byid(id)
	self.players[self.id_order[id]].score = self.players[self.id_order[id]].score - putgold_number
	self.players[self.id_order[id]].cur_score = self.players[self.id_order[id]].cur_score - putgold_number
	local score = self.players[self.id_order[id]].score
	local scoretxt = self.players[self.id_order[id]].scoreTxt
	self:text(score, scoretxt)
end

function Class:giveup_ack(id)
	print("player " .. id .. " giveup")
	game_ui:play_sound(id, "fangqi", 1)
	self.players[self.id_order[id]].hasgiveup = true
	self.infos[id].state = "give_up"
end

function Class:check_result(id, id2, value)
	print("check:" .. id .. " " .. id2 .. " win:" .. tostring(value))
	game_ui:play_sound(id, "bipai", 1)
	local vsicon = GameAPI.Create2Dimage("VSeffect")
	vsicon.transform.parent = game_ui.vsPanel.transform
	vsicon.transform.localPosition = Vector3(0, 0, 0)
	vsicon.transform.localScale = Vector3(1, 1, 1)
	
	local name_1 = UI:find_child("id_1/name", vsicon.transform)
	local head_1 = UI:find_child("id_1/head", vsicon.transform)
	local name_2 = UI:find_child("id_2/name", vsicon.transform)
	local head_2 = UI:find_child("id_2/head", vsicon.transform)
	
	self:text(self.infos[id].name, name_1)
	self:image(self.infos[id].head, head_1)
	self:text(self.infos[id2].name, name_2)
	self:image(self.infos[id2].head, head_2)
	
	-- self.players[self.id_order[id]].cur_score=self.players[self.id_order[id]].cur_score-self.base_put*self.infos[id].base_x
	Sound:play_sound("vsEffect")
	self:delay(
	2,
	function()
		if value then
			self.infos[id2].state = "check_failed"
		else
			self.infos[id].state = "check_failed"
		end
	end
	)
end

function Class:win_id(ids, datas)
	for i, v in ipairs(datas) do
		local n = self.id_order[v.id]
		local cards = v.cards
		
		local giveup = v.giveup
		if giveup then
			for i = 1, 3 do
				self:set_card_value(self.players[n].cards[i], - 2)
			end
		else
			for i = 1, 3 do
				self:set_card_value(self.players[n].cards[i], cards[i + 1])
			end
		end
		
		self.players[self.id_order[v.id]].score = self.players[self.id_order[v.id]].old_Score + v.ex_gold + v.gold
		self.players[self.id_order[v.id]].old_Score = self.players[self.id_order[v.id]].score
		self:text(self.players[self.id_order[v.id]].score, self.players[self.id_order[v.id]].scoreTxt)
	end
	
	
	for i = 1, 4 do
		self:enable(false, self.players[i].room_zhuang)
	end
	
	local winCount = #ids
	
	self:enable(true, self.players[self.id_order[ids[1]]].room_zhuang)
	self:delay(3, function()
		self:show_result(ids, datas)
		self:enable(true, self.btn_start)
	end)
end

function Class:end_games(his)
	self.zongjiesuan_his = his
	-- client:room_show_history(his,quit)
end

-- end max3 gameplay
function Class:set_time(index)
	if self.time_index and self.turn[self.time_index] then
		self.turn[self.time_index]:SetActive(false)
	end
	
	self.time_index = index
	if index then
		self.turn[index]:SetActive(true)
	end
	
	if index == nil and self.num_1 then
		self:enable(false, self.num_1)
		self:enable(false, self.num_2)
	end
end

function Class:set_time_dis()
	local n = self.n
	
	if n < 0 then
		n = 0
	end
	
	local n1 = math.floor(n / 10)
	local n2 = n % 10
	
	if self.num_1 then
		self:number_image(n1, self.num_1)
		self:number_image(n2, self.num_2)
	end
end

function Class:has_four(cards, card)
	local n = 0
	for _, v in pairs(cards) do
		if v == card then
			n = n + 1
		end
	end
	
	return n
end

function Class:play_sound(id, sound, rnd)
	local head
	if self.infos[id].sex == 1 then
		head = "boy_"
	else
		head = "girl_"
	end
	sound = head .. sound
	
	if rnd then
		sound = sound .. string.format("_%d", math.random(rnd) - 1)
	end
	-- print(self.infos[id].sex,sound)
	Sound:play_sound(sound)
end

function Class:add_score(id, score)
	local index = self.id_order[id]
	self.players[index].score = self.players[index].score + score
end

function Class:set_score(id, score)
	local index = self.id_order[id]
	self.players[index].score = score
end

function Class:set_his_score(his)
	if his.data then
		for _, v in pairs(his.data) do
			self:set_score(v.id, v.score)
			-- body...
		end
	end
end

-- function Class:show_score_anim()
-- 	for k, v in pairs( self.cur_add_score ) do
-- 		if v~=0 then
-- 			local ani=UI.show_temp("ScoreAnim_"..k)
-- 			if v>0 then
-- 				self:text_child("+"..tostring(v),"ScoreAnim_"..k,ani)
-- 			else
-- 				self:text_child(tostring(v),"ScoreAnim_"..k,ani)
-- 			end
-- 		end
-- 	end
-- 	self.cur_add_score={}
-- end
function Class:room_score(id, otherId, score)
	if otherId == 0 then
		local s = 0
		for k, _ in pairs(self.id_order) do
			self:add_score(k, - score)
			s = s + score
		end
		self:add_score(id, s)
	else
		self:add_score(id, score)
		self:add_score(otherId, - score)
	end
end

function Class:update(dt)
	self:update_voto(self.dt)
	
	self:update_replay()
end

function Class:room_player_ready_ack(id)
	local n = self.id_order[id]
	self:enable(true, self.players[n].ok)
end

function click_auto()
	game_ui:enable(false, game_ui.btn_auto)
	game_ui:enable(true, game_ui.btn_auto_c)
	game_ui.auto = true
end

function click_auto_cancel()
	game_ui:enable(true, game_ui.btn_auto)
	game_ui:enable(false, game_ui.btn_auto_c)
	game_ui.auto = false
end

-- replay
function replay_play()
	print(game_ui.replay_doing)
	
	if game_ui.replay_doing then
		return
	end
	
	Time.timeScale = 1
	if not game_ui.replay_cur_data then
		game_ui:set_replay_data()
	else
		game_ui.replay_doing = true
	end
	
	game_ui:replay_enable_btn()
end

function replay_pause()
	if not game_ui.replay_doing then
		return
	end
	game_ui.replay_doing = false
	Time.timeScale = 0
	game_ui:replay_enable_btn()
end

function replay_step(step)
	if game_ui.replay_cur_data then
		if game_ui.replay_doing then
			replay_pause()
		end
		game_ui:clear_delay()
		game_ui:fast_step(step)
	end
end

function replay_next()
	game_ui:clear_delay()
	
	if game_ui.replay_cur >= game_ui.replay_game_count then
		return
	end
	game_ui.replay_cur = game_ui.replay_cur + 1
	game_ui.replay_cur_data = nil
	
	game_ui.replay_doing = false
	replay_play()
end

function replay_prev()
	game_ui:clear_delay()
	
	if game_ui.replay_cur <= 1 then
		return
	end
	game_ui.replay_cur = game_ui.replay_cur - 1
	game_ui.replay_cur_data = nil
	
	game_ui.replay_doing = false
	replay_play()
end

function quit_replay()
	UI.close_watting()
	UI.close_all()
	UI.create("main_ui")
end

function Class:init_replay(game_id, data)
	self.show_pai = true
	
	self:enter_ack(0, data.players, data.room_params)
	
	self.replay_game_id = game_id
	self.replay_order = data.order
	self.replay_game_count = data.game_count
	self.replay_cur = 1
	
	self.replay_data = {}
	
	self:enable_child(false, "Panel")
	self.replay_node = UI.show_temp("Replay")
	
	game_ui:replay_enable_btn()
end

function Class:replay_enable_btn()
	print(self.replay_cur, self.replay_game_count)
	if self.replay_cur >= self.replay_game_count then
		self:image_color_child({128, 128, 128}, "Next", self.replay_node)
	else
		self:image_color_child({255, 255, 255}, "Next", self.replay_node)
	end
	
	if self.replay_cur <= 1 then
		self:image_color_child({128, 128, 128}, "Prev", self.replay_node)
	else
		self:image_color_child({255, 255, 255}, "Prev", self.replay_node)
	end
	
	if self.replay_doing then
		self:image_color_child({128, 128, 128}, "Play", self.replay_node)
		self:image_color_child({255, 255, 255}, "Pause", self.replay_node)
	else
		self:image_color_child({128, 128, 128}, "Pause", self.replay_node)
		self:image_color_child({255, 255, 255}, "Play", self.replay_node)
	end
end

function Class:set_replay_data(id, data)
	if data then
		local steps = data.steps
		local len = #steps
		
		local new_steps = {}
		for i = 1, len do
			new_steps[i] = steps[len - i + 1]
		end
		
		data.steps = new_steps
		game_ui.replay_data[id] = data
	end
	game_ui.replay_cur_data = game_ui.replay_data[game_ui.replay_cur]
	
	if game_ui.replay_cur_data then
		self:clear_delay()
		
		local count = #game_ui.replay_cur_data.steps / 2
		self:slider_child(0, "Step", self.replay_node)
		self:slider_count_child(count, "Step", self.replay_node)
		
		game_ui.replay_doing = true
		game_ui.replay_cur_step = 1
		game_ui.replay_wait_time = 1
		
		local cards = {}
		
		for i, v in ipairs(game_ui.replay_cur_data.cards) do
			local id = self.replay_order[i]
			
			local data_new = {}
			
			for k, m in pairs(v.datas) do
				data_new[k] = m
			end
			
			cards[i] = {id = id, cur = data_new, hold = {}, old = {}, cheng = 0}
		end
		
		local round_host_id = game_ui:get_replay_round_host_id()
		
		game_ui:re_enter(0, round_host_id, game_ui.replay_order, cards, game_ui.replay_cur_data.card_count, game_ui.replay_cur_data.pi_card, {round = game_ui.replay_cur})
		
		game_ui:replay_enable_btn()
	else
		UI.show_watting()
		proto.room:get_replay_data(game_ui.replay_game_id, game_ui.replay_cur)
	end
end

function Class:get_replay_round_host_id()
	local ind = self.replay_cur_data.steps[1 + 1]
	ind = ind % 16
	return self.replay_order[ind]
end

function Class:update_replay()
	if self.replay_doing then
		if self.replay_wait_time then
			self.replay_wait_time = self.replay_wait_time - self.dt
		else
			self.replay_wait_time = 0
		end
		
		if self.replay_wait_time <= 0 and self.replay_cur_step < #self.replay_cur_data.steps then
			local ind = self.replay_cur_data.steps[self.replay_cur_step + 1]
			local cmd = math.floor(ind / 16)
			ind = ind % 16
			local card = self.replay_cur_data.steps[self.replay_cur_step]
			
			local id = self.replay_order[ind]
			
			print(ind, cmd, id, card)
			
			if cmd == 0 then
				local turn_flag = 0
				
				if self.replay_cur_step > 1 then
					local last_ind = self.replay_cur_data.steps[self.replay_cur_step + 1 - 2]
					local last_cmd = math.floor(last_ind / 16)
					last_ind = last_ind % 16
					local last_card = self.replay_cur_data.steps[self.replay_cur_step - 2]
					if last_cmd == 3 then
						turn_flag = 1
					elseif(last_cmd == 1) and(last_card == self.card_lai) then
						turn_flag = 1
					end
				end
				self:turn_player(id, turn_flag, card, {})
				self.replay_wait_time = 1
			elseif cmd == 1 then
				self:put_card(id, card)
				self.replay_wait_time = 1
			elseif cmd == 2 then
				self:room_peng(id, card)
				self:turn_player(id, 0, 0, {})
				self.replay_wait_time = 1
			elseif cmd == 3 then
				local count = 0
				for k, v in pairs(self.cards[id].cur) do
					if v == card then
						count = count + 1
					end
				end
				self:room_gang(id, card, count)
				self:turn_player(id, 0, 0, {})
				self.replay_wait_time = 1
			elseif cmd == 4 then
				local win_cards = {}
				for i, p_id in ipairs(self.order) do
					local cards = {}
					for i, v in ipairs(self.cards[p_id].cur) do
						cards[i] = v
					end
					
					if self.cards[p_id].cur[0] then
						table.insert(cards, 1, self.cards[p_id].cur[0])
					end
					
					win_cards[i] = {datas = cards}
				end
				self:room_hu({id}, win_cards)
				
				self.replay_cur_step = #self.replay_cur_data.steps - 1
				self.replay_wait_time = 0
			end
			
			self.replay_cur_step = self.replay_cur_step + 2
			
			local step =(self.replay_cur_step - 1) / 2
			self:slider_child(step, "Step", self.replay_node)
		end
	end
end

function Class:fast_step(step)
	local cards = {}
	for i, v in ipairs(game_ui.replay_cur_data.cards) do
		local id = self.replay_order[i]
		
		local data_new = {}
		
		for k, m in pairs(v.datas) do
			data_new[k] = m
		end
		
		cards[i] = {id = id, cur = data_new, hold = {}, old = {}, cheng = 0}
	end
	
	local round_host_id = self:get_replay_round_host_id()
	self:re_enter(0, round_host_id, self.replay_order, cards, self.replay_cur_data.card_count, self.replay_cur_data.pi_card, {round = game_ui.replay_cur})
	
	self.not_anim = true
	
	self.replay_cur_step = 1
	local hu_game = false
	for i = 1, step do
		local ind = self.replay_cur_data.steps[self.replay_cur_step + 1]
		local cmd = math.floor(ind / 16)
		ind = ind % 16
		local card = self.replay_cur_data.steps[self.replay_cur_step]
		
		local id = self.replay_order[ind]
		
		--print(ind,cmd,id,card)
		if cmd == 0 then
			if card > 0 then
				self.cards[id].cur[0] = card
				self.card_count = self.card_count - 1
			end
		elseif cmd == 1 then
			self:remove_card(id, card)
			local index = self.id_order[id]
			table.insert(self.cards[id].old, card)
			self.cur_player_id = id
		elseif cmd == 2 then
			self:remove_card(id, card, 2)
			local hold_cards = self.cards[id].hold
			local len = #hold_cards
			table.insert(hold_cards, card)
			table.insert(hold_cards, card)
			table.insert(hold_cards, card)
			table.insert(hold_cards, 0)
			
			self:del_cur_old()
		elseif cmd == 3 then
			local count = 0
			for k, v in pairs(self.cards[id].cur) do
				if v == card then
					count = count + 1
				end
			end
			self:room_gang(id, card, count)
		elseif cmd == 4 then
			local win_cards = {}
			for i, p_id in ipairs(self.order) do
				local cards = {}
				for i, v in ipairs(self.cards[p_id].cur) do
					cards[i] = v
				end
				
				if self.cards[p_id].cur[0] then
					table.insert(cards, 1, self.cards[p_id].cur[0])
				end
				
				win_cards[i] = {datas = cards}
			end
			self:room_hu({id}, win_cards)
			hu_game = true
			break
		end
		
		self.replay_cur_step = self.replay_cur_step + 2
	end
	
	self:draw_cards(hu_game)
	self:sub_card_count(0)
	
	self.not_anim = false
	
	self.replay_wait_time = 1
end

-- for 3d
function Class:delete_all_child(node)
	local n = 0
	local null_count = 0
	while true do
		local v = node[n]
		if v then
			UnityEngine.GameObject.Destroy(v)
			null_count = 0
		else
			null_count = null_count + 1
			if null_count >= 3 then
				print(n)
				return
			end
		end
		n = n + 1
	end
end

function Class:hide_all_child(node)
	for _, v in pairs(node) do
		v:SetActive(false)
	end
end

function UserInfo(n)
	print("UserInfo")
	local id = game_ui.players[n].id
	proto.room:get_user_info(id)
end

--收回所有牌
function getBackCards()
	delete_dao("1")
	delete_dao("2")
	delete_dao("3")
	game_ui:set_hold_cards()
	game_ui:show_xianggongTip(false)
	game_ui:flush_hand_card_grid()
end

--点击出牌
function on_click_chupai()
	local cards = {}
	for k, v in pairs(game_ui.dao1Cards) do
		table.insert(cards, game_ui.default_cards[v])
	end
	for k, v in pairs(game_ui.dao2Cards) do
		table.insert(cards, game_ui.default_cards[v])
	end
	for k, v in pairs(game_ui.dao3Cards) do
		table.insert(cards, game_ui.default_cards[v])
	end
	proto.room:put_cards(cards, false)
	print(_s(cards))
	
	game_ui:enable(false, game_ui.btn_shouhui)
	game_ui:enable(false, game_ui.baipaiPanel)
	game_ui:enable(false, game_ui.daoPanel)
	game_ui:enable(false, game_ui.ButtonList)
	game_ui:enable(false, game_ui.btn_autoBai)
	game_ui:enable(false, game_ui.AutoList)
end

function Class:set_hold_cards()
	-- body
	for k, v in pairs(self.default_cards) do
		local t = self.baipaiPanel:FindChild("Image_" .. k)
		self:enable(true, t)
		local hua =(v - 1) % 4
		local pai = 1 +((v - hua - 1) / 4)
		if pai == 13 then
			pai = 0
		end
		local n = hua * 13 + pai + 1
		if n < 10 then
			self:image("纸牌_0" .. n, t)
		else
			self:image("纸牌_" .. n, t)
		end
	end
end

--进入摆牌阶段
function Class:enableBaipai()
	self:enable(true, self.daoPanel)
	delete_dao("1")
	delete_dao("2")
	delete_dao("3")
	self:enable(true, self.ButtonList)
	for k, v in pairs(self.id_order) do
		self:enable(true, self.players[v].baipai)
	end
	for i = 2, 4 do
		self:enable(false, self:find_child("Player" .. i .. "/cardPanel"))
	end
	for k, v in pairs(self.id_order) do
		self:enable(true, self.players[v].dao_1)
		self:enable(true, self.players[v].dao_2)
		self:enable(true, self.players[v].dao_3)
	end
	
	self:show_btnlist()
	self:enable(true, self.btn_autoBai)
	self:show_xianggongTip(false)
	self:compute_autoBaipai()
end

--选择一键摆牌  显示
function click_autoBai()
	if game_ui.showAutobaipai then
		getBackCards()
		game_ui.showAutobaipai = false
		game_ui:enable(true, game_ui.ButtonList)
		game_ui:enable(false, game_ui.AutoList)
		
	else
		getBackCards()
		game_ui.showAutobaipai = true
		game_ui:enable(false, game_ui.ButtonList)
		game_ui:enable(true, game_ui.AutoList)
		game_ui:setAutoResult(game_ui.autoResult)
	end
	
end

--计算一键摆牌结果
function Class:compute_autoBaipai()
	local autoResult = {}
	local cards = {}
	
	local autoDao0 = {}
	local autoDao1 = {}
	local autoDao2 = {}
	local autoDao3 = {}
	local count1 = 0
	local count2 = 0
	local count3 = 0
	self.autoResult = {}
	for i = 1, 3 do
		
		for k, v in pairs(self.default_cards) do
			table.insert(cards, v)
		end
		autoDao3, count3, max3 = self:auto_cardtypecheck(cards, i)
		print(count3, max3)
		self:removeTbFromTb(cards, autoDao3)
		autoDao2, count2, max2 = self:auto_cardtypecheck(cards, 1)
		print(count2, max2)
		self:removeTbFromTb(cards, autoDao2)
		autoDao1, count1, max1 = self:auto_cardtypecheck(cards, 1)
		print(count1, max1)
		self:removeTbFromTb(cards, autoDao1)
		autoDao0 = cards
		if count3 < count2 then
			local value = count2
			count2 = count3
			count3 = value
			autoDao2, autoDao3 = self:exchangeTb(autoDao2, autoDao3)
			local m = max2
			max2 = max3
			max3 = m
		end
		if count3 == count2 then
			if max3 < max2 then
				local value = count2
				count2 = count3
				count3 = value
				autoDao2, autoDao3 = self:exchangeTb(autoDao2, autoDao3)
				local m = max2
				max2 = max3
				max3 = m
			end
		end
		if count2 < count1 then
			local value = count2
			count2 = count1
			count1 = value
			autoDao1, autoDao2 = self:exchangeTb(autoDao1, autoDao2)
			local m = max1
			max1 = max2
			max2 = m
		end
		if count2 == count1 then
			if max2 < max1 then
				local value = count2
				count2 = count1
				count1 = value
				autoDao1, autoDao2 = self:exchangeTb(autoDao1, autoDao2)
				local m = max1
				max1 = max2
				max2 = m
			end
		end
		print(count3, max3)
		print(count2, max2)
		print(count1, max1)
		-- if count3 >= count2 and count2 >= count1 then
		print(_s(autoDao1))
		-- autoResult[i] = {count1, count2, count3, autoDao1, autoDao2, autoDao3, autoDao0}
		if #autoDao1 < 3 then
			for i = 1, 3 - #autoDao1 do
				table.insert(autoDao1, autoDao0[1])
				removeValueFromTb(autoDao0[1], autoDao0)
			end
		end
		if #autoDao2 < 5 then
			for i = 1, 5 - #autoDao2 do
				table.insert(autoDao2, autoDao0[1])
				removeValueFromTb(autoDao0[1], autoDao0)
			end
		end
		if #autoDao3 < 5 then
			for i = 1, 5 - #autoDao3 do
				table.insert(autoDao3, autoDao0[1])
				removeValueFromTb(autoDao0[1], autoDao0)
			end
		end
		self.autoResult[i] = {count1, count2, count3, autoDao1, autoDao2, autoDao3}
	end
	print(_s(self.autoResult))
end

function Class:exchangeTb(tb1, tb2)
	local arr = {}
	for k, v in pairs(tb1) do
		arr[k] = v
	end
	tb1 = {}
	for k, v in pairs(tb2) do
		tb1[k] = v
	end
	tb2 = {}
	for k, v in pairs(arr) do
		tb2[k] = v
	end
	return tb1, tb2
end

function Class:setAutoResult(autoResult)
	for i = 1, 3 do
		-- autoResult[i]
		GameAPI.Set2DImage(self.AutoList:FindChild("Btn_" .. i .. "/Image" .. 1), "Type_" .. self.autoResult[i] [1])
		GameAPI.Set2DImage(self.AutoList:FindChild("Btn_" .. i .. "/Image" .. 2), "Type_" .. self.autoResult[i] [2])
		GameAPI.Set2DImage(self.AutoList:FindChild("Btn_" .. i .. "/Image" .. 3), "Type_" .. self.autoResult[i] [3])
	end
end

function Class:removeTbFromTb(tb1, tb2)
	for k, v in pairs(tb2) do
		removeValueFromTb(v, tb1)
	end
end

--选择一键摆牌 某个牌型
function select_autoCount(n)
	if n == "1" then
		game_ui:auto_setDaos(1)
	elseif n == "2" then
		game_ui:auto_setDaos(2)
	elseif n == "3" then
		game_ui:auto_setDaos(3)
	end
end

--
function Class:auto_setDaos(n)
	print(_s(self.autoResult))
	self.dao1Cards = {}
	
	for k, v in pairs(self.autoResult[n] [4]) do
		print(v)
		table.insert(self.dao1Cards, self:findIndexBycard(v))
	end
	game_ui:removeFromCur(self.dao1Cards)
	self.dao2Cards = {}
	for k, v in pairs(self.autoResult[n] [5]) do
		print(v)
		table.insert(self.dao2Cards, self:findIndexBycard(v))
	end
	game_ui:removeFromCur(self.dao2Cards)
	self.dao3Cards = {}
	for k, v in pairs(self.autoResult[n] [6]) do
		print(v)
		table.insert(self.dao3Cards, self:findIndexBycard(v))
	end
	game_ui:removeFromCur(self.dao3Cards)
	print(_s(self.dao1Cards))
	print(_s(self.dao2Cards))
	print(_s(self.dao3Cards))
	self:flush_dao_cards(self.dao1Cards, self.dao2Cards, self.dao3Cards)
end

function Class:auto_cardtypecheck(cards, n)
	local typeCount = 1
	local arr8 = self:check_Tongshun(cards)
	if #arr8 > 0 then
		typeCount = typeCount + 1
		if typeCount > n then
			local count = math.random(#arr8)
			local showArr = arr8[count]
			local resultCards = {showArr[1], showArr[2], showArr[3], showArr[4], showArr[5]}
			local max = self:getMaxCard(resultCards)
			return resultCards, 8, max
		end
	end
	local arr7 = self:check_Zhadan(cards)
	if #arr7 > 0 then
		typeCount = typeCount + 1
		if typeCount > n then
			local count = math.random(#arr7)
			local showArr = arr7[count]
			local resultCards = {showArr[1], showArr[2], showArr[3], showArr[4]}
			local max = self:getMaxCard(resultCards)
			return resultCards, 7, max
		end
	end
	local arr6 = self:check_Hulu(cards)
	if #arr6 > 0 then
		typeCount = typeCount + 1
		if typeCount > n then
			local count = math.random(#arr6)
			local showArr = arr6[count]
			local showArr1 = showArr[1]
			local count2 = math.random(#showArr[2])
			local showArr2 = showArr[2] [count2]
			local resultCards = {showArr1[1], showArr1[2], showArr1[3], showArr2[1], showArr2[2]}
			local max = self:getMaxCard(resultCards)
			return resultCards, 6, max
		end
	end
	local arr5 = self:check_Tonghua(cards)
	if #arr5 > 0 then
		typeCount = typeCount + 1
		if typeCount > n then
			local count = math.random(#arr5)
			local showArr = arr5[count]
			local resultCards = {showArr[1], showArr[2], showArr[3], showArr[4], showArr[5]}
			local max = self:getMaxCard(resultCards)
			return resultCards, 5, max
		end
	end
	local arr4 = self:check_Shunzi(cards)
	if #arr4 > 0 then
		typeCount = typeCount + 1
		if typeCount > n then
			local count = math.random(#arr4)
			local showArr = arr4[count]
			local resultCards = {showArr[1], showArr[2], showArr[3], showArr[4], showArr[5]}
			local max = self:getMaxCard(resultCards)
			if self:shunziMaxSpecial(resultCards) then
				max = 14
			end
			return resultCards, 4, max
		end
	end
	local arr3 = self:check_Santiao(cards)
	if #arr3 > 0 then
		typeCount = typeCount + 1
		if typeCount > n then
			local count = math.random(#arr3)
			local showArr = arr3[count]
			local resultCards = {showArr[1], showArr[2], showArr[3]}
			local max = self:getMaxCard(resultCards)
			return resultCards, 3, max
		end
	end
	local arr2 = self:check_Liangdui(cards)
	if #arr2 > 0 then
		typeCount = typeCount + 1
		if typeCount > n then
			local count1 = math.random(#arr2)
			local count2 = - 1
			
			local n = math.random(#arr2)
			while(n == count1)
			do
				n = math.random(#arr2)
			end
			count2 = n
			print(count2)
			if count2 < count1 then
				local n = count2
				count2 = count1
				count1 = n
			end
			local showArr1 = arr2[count1]
			local showArr2 = arr2[count2]
			local resultCards = {showArr1[1], showArr1[2], showArr2[1], showArr2[2]}
			local max = self:getMaxCard(resultCards)
			return resultCards, 2, max
		end
	end
	local arr1 = self:check_Duizi(cards)
	if #arr1 > 0 then
		typeCount = typeCount + 1
		if typeCount > n then
			local count = math.random(#arr1)
			local showArr = arr1[count]
			local resultCards = {showArr[1], showArr[2]}
			local max = self:getMaxCard(resultCards)
			return resultCards, 1, max
		end
	end
	local max0 = self:getMaxCard(cards)
	return {}, 0, max0
end

--10 J Q K A 顺子特殊处理 max当做14
function Class:shunziMaxSpecial(cards)
	table.sort(cards)
	local isspecial = true
	for i = 1, 5 do
		local pai, hua = math.modf((cards[i] - 1) / 4)
		if not pai == i + 7 then
			isspecial = false
			return isspecial
		end
	end
	return isspecial
end

--控制显示部分btnList
function Class:show_btnlist()
	self:cardTypeCheck(self.current_cards)
end

--XX 按钮 清除一道牌
function delete_dao(n)
	print(type(n))
	local temp = game_ui.daoPanel:FindChild("dao_" .. n)
	local count = 5
	if n == "1" then
		count = 3
	end
	for i = 1, count do
		game_ui:enable(false, temp:GetChild(i - 1))
	end
	game_ui:enable(false, game_ui.daoPanel:FindChild("Button_" .. n))
	if n == "1" then
		game_ui:backCardsToCur(game_ui.dao1Cards)
		game_ui.dao1Cards = {}
	elseif n == "2" then
		game_ui:backCardsToCur(game_ui.dao2Cards)
		game_ui.dao2Cards = {}
	elseif n == "3" then
		game_ui:backCardsToCur(game_ui.dao3Cards)
		game_ui.dao3Cards = {}
	end
	print(_s(game_ui.clickUpCards))
	game_ui:show_xianggongTip(false)
	game_ui:flush_hand_card_grid()
end

--返回道里的牌到手牌  牌序的转移
function Class:backCardsToCur(indexs)
	for k, v in pairs(indexs) do
		table.insert(self.showedIndexs, v)
	end
	--显示牌发生变化 对应刷新current_cards
	self.current_cards = {}
	for k, v in pairs(self.showedIndexs) do
		table.insert(self.current_cards, self.default_cards[v])
	end
	self:showCurCardsByIndex()
end

--选择一道放入
function putin_dao(n)
	-- self.dao1Cards = {}
	-- self.dao2Cards = {}
	-- self.dao3Cards = {}
	if n == "1" then
		if #game_ui.clickUpCards <=(3 - #game_ui.dao1Cards) then
			for k, v in pairs(game_ui.clickUpCards) do
				table.insert(game_ui.dao1Cards, v)
			end
			game_ui:removeFromCur(game_ui.clickUpCards)
			game_ui.clickUpCards = {}
			game_ui:flush_dao_cards(game_ui.dao1Cards, game_ui.dao2Cards, game_ui.dao3Cards)
		end
	elseif n == "2" then
		if #game_ui.clickUpCards <=(5 - #game_ui.dao2Cards) then
			for k, v in pairs(game_ui.clickUpCards) do
				table.insert(game_ui.dao2Cards, v)
			end
			game_ui:removeFromCur(game_ui.clickUpCards)
			game_ui.clickUpCards = {}
			game_ui:flush_dao_cards(game_ui.dao1Cards, game_ui.dao2Cards, game_ui.dao3Cards)
		end
	elseif n == "3" then
		if #game_ui.clickUpCards <=(5 - #game_ui.dao3Cards) then
			for k, v in pairs(game_ui.clickUpCards) do
				table.insert(game_ui.dao3Cards, v)
			end
			game_ui:removeFromCur(game_ui.clickUpCards)
			game_ui.clickUpCards = {}
			game_ui:flush_dao_cards(game_ui.dao1Cards, game_ui.dao2Cards, game_ui.dao3Cards)
		end
	end
	game_ui:checkTodoSmarkInput()
end

--新道放入之后 检测是否要自动填满牌
function Class:checkTodoSmarkInput()
	-- if #self.dao1Cards + #self.dao2Cards + #self.dao3Cards > 8 then
	-- end
	local daoCount = 0
	if #self.dao1Cards == 3 then
		daoCount = daoCount + 1
	end
	if #self.dao2Cards == 5 then
		daoCount = daoCount + 1
	end
	if #self.dao3Cards == 5 then
		daoCount = daoCount + 1
	end
	if daoCount >= 2 then
		self:buman()
	end
end

function Class:buman()
	for i = 1, 3 - #self.dao1Cards do
		table.insert(game_ui.dao1Cards, self.showedIndexs[1])
		table.remove(self.showedIndexs, 1)
	end
	for i = 1, 5 - #self.dao2Cards do
		table.insert(game_ui.dao2Cards, self.showedIndexs[1])
		table.remove(self.showedIndexs, 1)
	end
	for i = 1, 5 - #self.dao3Cards do
		table.insert(game_ui.dao3Cards, self.showedIndexs[1])
		table.remove(self.showedIndexs, 1)
	end
	self:removeFromCur(self.showedIndexs)
	self.clickUpCards = {}
	self:flush_dao_cards(self.dao1Cards, self.dao2Cards, self.dao3Cards)
end

--从手牌中去除掉indexs
function Class:removeFromCur(indexs)
	local newindexs = {}
	for k, v in pairs(self.showedIndexs) do
		local has = false
		for a, b in pairs(indexs) do
			if v == b then
				has = true
			end
		end
		if not has then
			table.insert(newindexs, v)
		end
	end
	self.showedIndexs = newindexs
	--显示牌发生变化 对应刷新current_cards
	self.current_cards = {}
	for k, v in pairs(self.showedIndexs) do
		table.insert(self.current_cards, self.default_cards[v])
	end
	self:showCurCardsByIndex()
end

--根据indexs 控制部分手牌显示
function Class:showCurCardsByIndex()
	print("showCurCardsByIndex")
	for i = 1, 13 do
		local t = self.baipaiPanel:FindChild("Image_" .. i)
		self:enable(false, t)
	end
	for k, v in pairs(self.showedIndexs) do
		local t = self.baipaiPanel:FindChild("Image_" .. v)
		t.transform.localPosition = Vector3(t.transform.localPosition.x, 0, 0)
		self:enable(true, t)
	end
	if #self.showedIndexs == 13 then
		self:enable(false, self.btn_shouhui)
	else
		self:enable(true, self.btn_shouhui)
	end
	if #self.showedIndexs == 0 then
		self:enable(true, self.btn_chupai)
		self:enable(true, self.btn_shouhui)
		self:enable(false, self.AutoList)
		self:enable(false, self.ButtonList)
	else
		self:enable(false, self.btn_chupai)
		self:enable(false, self.btn_shouhui)
		if self.showAutobaipai then
			self:enable(true, self.AutoList)
			self:enable(false, self.ButtonList)
		else
			self:enable(false, self.AutoList)
			self:enable(true, self.ButtonList)
		end
	end
	self:show_btnlist()
	self:flush_hand_card_grid()
end

-- 道里记录 clickUp记录的都是第几张牌  原始牌default_cards不变  current_cards 实时手上牌
--道里面数据 映射显示
function Class:flush_dao_cards(dao1, dao2, dao3)
	print("flush_dao_cards")
	print(_s(dao1))
	print(_s(dao2))
	print(_s(dao3))
	--第一道
	for i = 1, 3 do
		local temp = self.daoPanel:FindChild("dao_1")
		if dao1[i] then
			self:enable(true, temp:GetChild(i - 1))
			self:set_card_value(temp:GetChild(i - 1), self.default_cards[dao1[i]])
		else
			self:enable(false, temp:GetChild(i - 1))
		end
	end
	--第二道
	for i = 1, 5 do
		local temp = self.daoPanel:FindChild("dao_2")
		if dao2[i] then
			self:enable(true, temp:GetChild(i - 1))
			self:set_card_value(temp:GetChild(i - 1), self.default_cards[dao2[i]])
		else
			self:enable(false, temp:GetChild(i - 1))
		end
	end
	--第三道
	for i = 1, 5 do
		local temp = self.daoPanel:FindChild("dao_3")
		if dao3[i] then
			self:enable(true, temp:GetChild(i - 1))
			self:set_card_value(temp:GetChild(i - 1), self.default_cards[dao3[i]])
		else
			self:enable(false, temp:GetChild(i - 1))
		end
	end
	if #dao1 > 0 then
		self:enable(true, self.daoBtn_1)
	else
		self:enable(false, self.daoBtn_1)
	end
	if #dao2 > 0 then
		self:enable(true, self.daoBtn_2)
	else
		self:enable(false, self.daoBtn_2)
	end
	if #dao3 > 0 then
		self:enable(true, self.daoBtn_3)
	else
		self:enable(false, self.daoBtn_3)
	end
	if #dao1 + #dao2 + #dao3 == 13 then
		self:check_xianggong()
		-- self:enable(true, self.btn_chupai)
		-- else
		-- 	self:enable(false, self.btn_chupai)
		self:enable(true, self.btn_shouhui)
	end
	if #dao1 + #dao2 + #dao3 == 0 then
		-- self:enable(false, self.btn_shouhui)
	else
		-- self:enable(true, self.btn_shouhui)
	end
end

--检测摆牌之后相公
function Class:check_xianggong()
	local cards1 = {}
	for k, v in pairs(self.dao1Cards) do
		table.insert(cards1, self.default_cards[v])
	end
	local cards2 = {}
	for k, v in pairs(self.dao2Cards) do
		table.insert(cards2, self.default_cards[v])
	end
	local cards3 = {}
	for k, v in pairs(self.dao3Cards) do
		table.insert(cards3, self.default_cards[v])
	end
	local type1, max1 = self:checkDaoType3(cards1)
	local type2, max2 = self:checkDaoType5(cards2)
	local type3, max3 = self:checkDaoType5(cards3)
	print(_s(cards1))
	print(_s(cards2))
	print(_s(cards3))
	print(type1)
	print(type2)
	print(type3)
	print(max1)
	print(max2)
	print(max3)
	local result = 1
	if type1 <= type2 and type2 <= type3 then
		if type2 == type3 then
			if max2 > max3 then
				result = 2
			else
				
			end
		end
		
		if type1 == type2 then
			if max1 > max2 then
				result = 2
			else
				
			end
		end
	else
		result = 2
	end
	
	if result == 1 then
		print("摆牌完成 可以出牌")
		self:enable(true, self.btn_chupai)
	elseif result == 2 then
		print("相公摆牌")
		self:enable(false, self.btn_chupai)
		self:show_xianggongTip(true)
	end
end

--显示相公提示
function Class:show_xianggongTip(needShow)
	self:enable(needShow, self.xianggongTip)
end

--起始发牌过程
function Class:fapaiAction(cards)
	-- self.canchooseCard = false
	game_ui.showAutobaipai = false
	GameAPI.SetGridLayoutGroup(self.baipaiPanel, 1)
	self:enable(true, self.baipaiPanel)
	for k, v in pairs(cards) do
		local t = self.baipaiPanel:FindChild("Image_" .. k)
		self:enable(false, t)
	end
	-- for j = 2, #self.id_order do
	for k, v in pairs(self.id_order) do
		-- print(k,v)
		if v ~= 1 then
			for i = 1, 13 do
				self:enable_child(false, "Player" .. v .. "/cardPanel/Image_" .. i)
			end
		end
	end
	for k, v in pairs(cards) do
		self:delay(k / 13, function()
			local t = self.baipaiPanel:FindChild("Image_" .. k)
			self:enable(true, t)
			local hua =(v - 1) % 4
			local pai = 1 +((v - hua - 1) / 4)
			if pai == 13 then
				pai = 0
			end
			local n = hua * 13 + pai + 1
			if n < 10 then
				self:image("纸牌_0" .. n, t)
			else
				self:image("纸牌_" .. n, t)
			end
		end)
	end
	-- for j = 2, #self.id_order do
	for k, v in pairs(self.id_order) do
		print(k, v)
		if v ~= 1 then
			for i = 1, 13 do
				self:delay(i / 13, function()
					print("Player" .. v .. "/cardPanel/Image_" .. i)
					local t = self:find_child("Player" .. v .. "/cardPanel/Image_" .. i)
					self:enable(true, t)
					self:image("纸牌_55", t)
				end)
			end
		end
	end
	self:delay(1.2, function()
		self.canchooseCard = true
		self:enableBaipai()
		self:flush_hand_card_grid()
	end)
	
end

--整理手牌位置
function Class:flush_hand_card_grid()
	self.canchooseCard = false
	GameAPI.SetGridLayoutGroup(self.baipaiPanel, 1)
	self:delay(0.1, function()
		GameAPI.SetGridLayoutGroup(self.baipaiPanel, 0)
		self.canchooseCard = true
	end)
end

--快速设置牌
function Class:Fastfapai(cards)
	game_ui.showAutobaipai = false
	GameAPI.SetGridLayoutGroup(self.baipaiPanel, 1)
	-- self.canchooseCard = false
	for k, v in pairs(cards) do
		local t = self.baipaiPanel:FindChild("Image_" .. k)
		self:enable(true, t)
		local hua =(v - 1) % 4
		local pai = 1 +((v - hua - 1) / 4)
		if pai == 13 then
			pai = 0
		end
		local n = hua * 13 + pai + 1
		if n < 10 then
			self:image("纸牌_0" .. n, t)
		else
			self:image("纸牌_" .. n, t)
		end
	end
	-- for j = 2, #self.id_order do
	for k, v in pairs(self.id_order) do
		-- print(k,v)
		if v ~= 1 then
			for i = 1, 13 do
				local t = self:find_child("Player" .. v .. "/cardPanel/Image_" .. i)
				self:enable(true, t)
				self:image("纸牌_55", t)
			end
		end
	end
	self:delay(0.2, function()
		self.canchooseCard = true
		self:enableBaipai()
		self:flush_hand_card_grid()
	end)
	
end

function click_typematch(n)
	game_ui:game_click_typematch(n)
end
--对子 两对  三条  顺子  同花  葫芦  铁支  同花顺
function Class:game_click_typematch(n)
	for i = 1, 13 do
		local t = game_ui.baipaiPanel:FindChild("Image_" .. i)
		t.transform.localPosition = Vector3(t.transform.localPosition.x, 0, 0)
	end
	
	self.clickUpCards = {}
	self.lastresultIndexs = {}
	--选择对子
	if n == "1" then
		-- 对子
		local count = math.random(#self.resultList[1])
		local showArr = self.resultList[1] [count]
		local showIndex = {self:findIndexBycard(showArr[1]), self:findIndexBycard(showArr[2])}
		print(_s(showIndex))
		self.lastresultIndexs = showIndex
	elseif n == "2" then
		--两对
		local count1 = math.random(#self.resultList[2])
		local count2 = - 1
		
		local n = math.random(#self.resultList[2])
		while(n == count1)
		do
			n = math.random(#self.resultList[2])
		end
		count2 = n
		print(count2)
		if count2 < count1 then
			local n = count2
			count2 = count1
			count1 = n
		end
		local showArr1 = self.resultList[2] [count1]
		local showArr2 = self.resultList[2] [count2]
		local showIndex = {self:findIndexBycard(showArr1[1]), self:findIndexBycard(showArr1[2]), self:findIndexBycard(showArr2[1]), self:findIndexBycard(showArr2[2])}
		print(_s(showIndex))
		self.lastresultIndexs = showIndex
	elseif n == "3" then
		--三条
		local count = math.random(#self.resultList[3])
		local showArr = self.resultList[3] [count]
		local showIndex = {self:findIndexBycard(showArr[1]), self:findIndexBycard(showArr[2]), self:findIndexBycard(showArr[3])}
		print(_s(showIndex))
		self.lastresultIndexs = showIndex
	elseif n == "4" then
		--顺子
		local count = math.random(#self.resultList[4])
		local showArr = self.resultList[4] [count]
		local showIndex = {self:findIndexBycard(showArr[1]), self:findIndexBycard(showArr[2]), self:findIndexBycard(showArr[3]), self:findIndexBycard(showArr[4]), self:findIndexBycard(showArr[5])}
		print(_s(showIndex))
		self.lastresultIndexs = showIndex
	elseif n == "5" then
		--同花
		local count = math.random(#self.resultList[5])
		local showArr = self.resultList[5] [count]
		local showIndex = {self:findIndexBycard(showArr[1]), self:findIndexBycard(showArr[2]), self:findIndexBycard(showArr[3]), self:findIndexBycard(showArr[4]), self:findIndexBycard(showArr[5])}
		print(_s(showIndex))
		self.lastresultIndexs = showIndex
	elseif n == "6" then
		--葫芦
		print(_s(self.resultList[6]))
		local count = math.random(#self.resultList[6])
		local showArr = self.resultList[6] [count]
		local showArr1 = showArr[1]
		local count2 = math.random(#showArr[2])
		local showArr2 = showArr[2] [count2]
		local showIndex = {self:findIndexBycard(showArr1[1]), self:findIndexBycard(showArr1[2]), self:findIndexBycard(showArr1[3]), self:findIndexBycard(showArr2[1]), self:findIndexBycard(showArr2[2])}
		print(_s(showIndex))
		self.lastresultIndexs = showIndex
	elseif n == "7" then
		--铁支
		local count = math.random(#self.resultList[7])
		local showArr = self.resultList[7] [count]
		local showIndex = {self:findIndexBycard(showArr[1]), self:findIndexBycard(showArr[2]), self:findIndexBycard(showArr[3]), self:findIndexBycard(showArr[4])}
		print(_s(showIndex))
		self.lastresultIndexs = showIndex
	elseif n == "8" then
		--同花顺
		local count = math.random(#self.resultList[8])
		local showArr = self.resultList[8] [count]
		local showIndex = {self:findIndexBycard(showArr[1]), self:findIndexBycard(showArr[2]), self:findIndexBycard(showArr[3]), self:findIndexBycard(showArr[4]), self:findIndexBycard(showArr[5])}
		print(_s(showIndex))
		self.lastresultIndexs = showIndex
	end
	-- self.lastClickedBtn = n
	for k, v in pairs(self.lastresultIndexs) do
		cardClickUp(v)
	end
	print(_s(self.clickUpCards))
	print(_s(self.lastresultIndexs))
end

function Class:findIndexBycard(card)
	-- body
	for k, v in pairs(self.default_cards) do
		if v == card then
			return k
		end
	end
end

--特殊牌型选择是
function special_yes()
	
end

--特殊牌型选择否
function special_no()
	
end

--用来测试牌型检测
function testCardCheck()
	-- body
	-- local cards = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
	local cards = {49, 1, 5, 9, 6, 10, 14, 18, 22, 32, 36, 40, 44, 48}
	-- game_ui:check_shunxuCard(cards)
	local result = game_ui:check_shunxuCard(cards)
	print(_s(result))	
end

--判定道里面牌牌型  第一道
function Class:checkDaoType3(cards)
	local type2Arr = self:check_Santiao(cards)
	if #type2Arr > 0 then
		--三条
		return 2, self:getMaxCard(type2Arr[1])
	end
	local type1Arr = self:check_Duizi(cards)
	if #type1Arr > 0 then
		--对子
		return 1, self:getMaxCard(type1Arr[1])
	end
	--散牌
	return 0, self:getMaxCard(cards)
end

function Class:getMaxCard(cards)
	local max = 0
	local hua = 0
	for k, v in pairs(cards) do
		if max < v then
			max = v
		end
	end
	return max
end

function Class:getCardCount(card)
	return card
end

--判定道里面牌牌型  二三道
function Class:checkDaoType5(cards)
	
	local arr8 = self:check_Tongshun(cards)
	if #arr8 > 0 then
		-- 同花顺
		return 8, self:getMaxCard(arr8[1])
	end
	local arr7 = self:check_Zhadan(cards)
	if #arr7 > 0 then
		-- 炸弹
		return 7, self:getMaxCard(arr7[1])
	end
	local arr6 = self:check_Hulu(cards)
	if #arr6 > 0 then
		-- 葫芦
		return 6, self:getCardCount(arr6[1] [1])
	end
	local arr5 = self:check_Tonghua(cards)
	if #arr5 > 0 then
		-- 同花
		return 5, self:getMaxCard(arr5[1])
	end
	local arr4 = self:check_Shunzi(cards)
	if #arr4 > 0 then
		-- 顺子
		if self:shunziMaxSpecial(arr4[1]) then
			return 4, 14
		else
			return 4, self:getMaxCard(arr4[1])
		end
	end
	local arr3 = self:check_Santiao(cards)
	if #arr3 > 0 then
		-- 三条
		return 3, self:getMaxCard(arr3[1])
	end
	local arr2 = self:check_Liangdui(cards)
	if #arr2 > 0 then
		-- 两对
		local arr = {}
		for i = 1, 2 do
			for k, v in pairs(arr2[i]) do
				table.insert(arr, v)
			end
		end
		return 2, self:getMaxCard(arr)
	end
	local arr1 = self:check_Duizi(cards)
	if #arr1 > 0 then
		-- 对子
		return 1, self:getMaxCard(arr1[1])
	end
	--散牌
	return 0, self:getMaxCard(cards)
end

--牌型判断
function Class:cardTypeCheck(cards)
	self.resultList = {}
	local arr8 = self:check_Tongshun(cards)
	self.resultList[8] = arr8
	local arr7 = self:check_Zhadan(cards)
	self.resultList[7] = arr7
	local arr6 = self:check_Hulu(cards)
	self.resultList[6] = arr6
	local arr5 = self:check_Tonghua(cards)
	self.resultList[5] = arr5
	local arr4 = self:check_Shunzi(cards)
	self.resultList[4] = arr4
	local arr3 = self:check_Santiao(cards)
	self.resultList[3] = arr3
	local arr2 = self:check_Liangdui(cards)
	self.resultList[2] = arr2
	local arr1 = self:check_Duizi(cards)
	self.resultList[1] = arr1
	
	for i = 1, 8 do
		-- print(_s(self.resultList[i]))
		if #self.resultList[i] > 0 then
			print(_s(self.resultList[i]))
			print(i .. "  BtnType_")
			self:enable(true, self.ButtonList:FindChild("BtnType_" .. i))
		else
			self:enable(false, self.ButtonList:FindChild("BtnType_" .. i))
		end
	end
end

--同花顺  顺子+同花
function Class:check_Tongshun(cards)
	local resultArr = self:check_Shunzi(cards)
	local resultArr2 = {}
	for k, v in pairs(resultArr) do
		if self:check_tonghua_5(v) then
			table.insert(resultArr2, v)
		end
	end
	return resultArr2
end

--5张牌检测同花
function Class:check_tonghua_5(cards)
	local istonghua = true
	local hua = - 1
	for k, v in pairs(cards) do
		if hua == - 1 then
			hua =(v - 1) % 4
		else
			if hua ~=(v - 1) % 4 then
				istonghua = false
				return false
			end
		end
	end
	return istonghua
end

--炸弹（铁支）
function Class:check_Zhadan(cards)
	local resultArr = self:check_sameCard(cards)
	local resultArr2 = {}
	for k, v in pairs(resultArr) do
		if #v >= 4 then
			-- body
			table.insert(resultArr2, v)
		end
	end
	return resultArr2
end

--葫芦 三带二
function Class:check_Hulu(cards)
	local resultArr = self:check_Santiao(cards)
	local rArr = {}
	local resultArr2 = {}
	
	for k, v in pairs(resultArr) do
		rArr = {}
		for x, y in pairs(cards) do
			local isin = false
			for c, d in pairs(v) do
				if y == d then
					isin = true
				end
			end
			if not isin then
				table.insert(rArr, y)
			end
		end
		local res = self:check_Duizi(rArr)
		if #res > 0 then
			local res2 = {v, res}
			table.insert(resultArr2, res2)
		end
	end
	return resultArr2
end

--同花
function Class:check_Tonghua(cards)
	local resultArr = self:check_sameHua(cards)
	local resultArr2 = {}
	for k, v in pairs(resultArr) do
		if #v >= 5 then
			table.insert(resultArr2, v)
		end
	end
	return resultArr2
end

--顺子
function Class:check_Shunzi(cards)
	local resultArr = self:check_shunxuCard(cards)
	local resultArr2 = {}
	for k, v in pairs(resultArr) do
		if #v >= 5 then
			table.insert(resultArr2, v)
		end
	end
	return resultArr2
end

--三条
function Class:check_Santiao(cards)
	local resultArr = self:check_sameCard(cards)
	local resultArr2 = {}
	for k, v in pairs(resultArr) do
		if #v >= 3 then
			table.insert(resultArr2, v)
		end
	end
	return resultArr2
end

--两对
function Class:check_Liangdui(cards)
	local resultArr = self:check_sameCard(cards)
	local resultArr2 = {}
	for k, v in pairs(resultArr) do
		if #v >= 2 then
			table.insert(resultArr2, v)
		end
	end
	if #resultArr2 >= 2 then
		return resultArr2
	else
		return {}
	end
end

--对子
function Class:check_Duizi(cards)
	local resultArr = self:check_sameCard(cards)
	local resultArr2 = {}
	for k, v in pairs(resultArr) do
		if #v >= 2 then
			table.insert(resultArr2, v)
		end
	end
	return resultArr2
end

--相同牌分组
function Class:check_sameCard(cards)
	-- body
	local sameCardTable = {}
	for i = 1, 13 do
		sameCardTable[i] = {}
	end
	for k, v in pairs(cards) do
		-- print(k, v)
		t1, t2 = math.modf((v - 1) / 4)
		table.insert(sameCardTable[t1 + 1], v)
	end
	-- print(_s(sameCardTable))
	return sameCardTable
end

--相同花色分组
function Class:check_sameHua(cards)
	local huaTable = {}
	for i = 1, 4 do
		huaTable[i] = {}
		for k, v in pairs(cards) do
			local hua =(v - 1) % 4
			if hua + 1 == i then
				table.insert(huaTable[i], v)
			end
		end
	end
	-- print(_s(huaTable))
	return huaTable
end

--顺序牌个数
--1 2 3 4 5 6 7 8 9  10 11 12 13
--2 3 4 5 6 7 8 9 10 J  Q  K  A
--10 J Q K A > A 2 3 4 5 > 9 10 J Q K
function Class:check_shunxuCard(cards)
	-- body
	-- local standarTable = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
	local standarTable = {13, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
	local resultArr = {}
	local leftArr = {}
	local equalArr = {}
	for k, v in pairs(cards) do
		leftArr[k] = v
	end
	for i = 1, #standarTable - 5 + 1 do
		local sdTb = {}
		for k, v in pairs(standarTable) do
			sdTb[k] = v
		end
		-- print(_s(sdTb))
		local lenList = {}
		for j = 1, 5 do
			table.insert(lenList, standarTable[i + j - 1])
		end
		-- print(_s(lenList))
		local addList = {}
		for j = 1, 5 do
			for k, v in pairs(leftArr) do
				t1, t2 = math.modf((v - 1) / 4)
				if t1 + 1 == lenList[j] then
					table.insert(addList, v)
					-- print(v)
					break
				end
			end
		end
		if #addList == 5 then
			table.insert(equalArr, addList)
		end
	end
	-- print(_s(equalArr))
	return equalArr
end

--特殊牌型判断
function Class:checkSpecialCards(cards)
	--一条龙   2 3 4 5 6 7 8 9 10 J Q K A
	table.sort(cards)
	local checkArr4 = {}
	for k, v in pairs(cards) do
		local hua =(v - 1) % 4
		local pai = 1 +((v - hua - 1) / 4)
		table.insert(checkArr4, pai)
	end
	print(_s(checkArr4))
	local isT = true
	for i = 1, 13 do
		if checkArr4[i] ~= i then
			isT = false
		end
	end
	if isT then
		return 4
	end
	--六对半   AA BB CC DD EE FF G
	local checkArr3 = self:check_sameCard(cards)
	local duiziCount = 0
	for k, v in pairs(checkArr3) do
		if #v == 2 then
			duiziCount = duiziCount + 1
		end
		if #v == 4 then
			duiziCount = duiziCount + 2
		end
	end
	print(_s(checkArr3))
	if duiziCount == 6 then
		return 3
	end
	--三顺子	123 12345 12345
	-- local standarTable = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
	-- local resultArr = {}
	-- local leftArr = {}
	-- local equalArr = {}
	-- for k, v in pairs(cards) do
	-- 	leftArr[k] = v
	-- end
	-- for i = 1, #standarTable - 5 + 1 do
	-- 	local sdTb = {}
	-- 	for k, v in pairs(standarTable) do
	-- 		sdTb[k] = v
	-- 	end
	-- 	-- print(_s(sdTb))
	-- 	local lenList = {}
	-- 	for j = 1, 5 do
	-- 		table.insert(lenList, standarTable[i + j - 1])
	-- 	end
	-- 	-- print(_s(lenList))
	-- 	local addList = {}
	-- 	for j = 1, 5 do
	-- 		for k, v in pairs(leftArr) do
	-- 			t1, t2 = math.modf((v - 1) / 4)
	-- 			if t1 + 1 == lenList[j] then
	-- 				table.insert(addList, v)
	-- 				-- print(v)
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	-- 	print(_s(addList))
	-- 	if #addList == 5 then
	-- 		table.insert(equalArr, addList)
	-- 	end
	-- end
	--三同花	123 45678 12345
	local checkArr1 = self:check_sameHua(cards)
	local huaCount = 0
	for k, v in pairs(checkArr1) do
		if #v == 5 then
			huaCount = huaCount + 1
		end
		if #v == 8 then
			huaCount = huaCount + 2
		end
		if #v == 10 then
			huaCount = huaCount + 2
		end
		if #v == 3 then
			huaCount = huaCount + 1
		end
	end
	if huaCount == 3 then
		return 1
	end
	return 0
end

--手牌点击选择
function cardClickUp(n)
	print(type(n))
	if game_ui.canchooseCard then
		if not IsInTable(n, game_ui.clickUpCards) then
			if #game_ui.clickUpCards < 5 then
				local t = game_ui.baipaiPanel:FindChild("Image_" .. n)
				t.transform.localPosition = Vector3(t.transform.localPosition.x, 30, 0)
				table.insert(game_ui.clickUpCards, n)
			end
		else
			local t = game_ui.baipaiPanel:FindChild("Image_" .. n)
			t.transform.localPosition = Vector3(t.transform.localPosition.x, 0, 0)
			removeValueFromTb(n, game_ui.clickUpCards)
		end
	end
end

-- table中是否包含某元素
function IsInTable(value, tbl)
	for k, v in ipairs(tbl) do
		if v == value then
			return true
		end
	end
	return false
end

--table中删除指定元素
function removeValueFromTb(value, tb1)
	for k, v in pairs(tb1) do
		if value == v then
			table.remove(tb1, k)
			break
		end
	end
end

function Class:put_cards_ok(id)
	print("完成")
	local idPos = self.id_order[id]
	self:enable(true, self.players[idPos].finish)
	self:enable(false, self.players[idPos].baipai)
end

-- shot_all[false]
-- played[true]
-- id[10001]
-- all_score[1]
-- shots ->
-- cards ->
-- score[1]
-- daos ->
function Class:room_end_turn(data)
	for k, v in pairs(self.id_order) do
		self:enable(false, self.players[v].finish)
		self:enable(false, self.players[v].baipai)
	end
	local shotCount = 0
	local dao4Score = {}
	local shotallIndex = - 1
	for k, v in pairs(data.datas) do
		-- print(k)
		-- print(_s(v))
		print(v.shot_all)
		-- print(v.played)
		print(v.id)
		print(v.all_score)
		print(_s(v.shots))
		-- print(v.cards)
		print(v.score)
		print(_s(v.daos))
		
		-- if v.shot_all then
		-- 	-- 本玩家通杀
		-- 	shotallIndex = k
		-- end
		for k, v in pairs(data.datas) do
			if #v.shots > 0 and #v.shots == #data.datas - 1 then
				-- 本玩家通杀
				shotallIndex = k
			end
		end
		
		local idPos = self.id_order[v.id]
		-- print(_s(self.id_order))
		-- print(idPos)
		for i = 1, 3 do
			local t = self.players[idPos].dao_1:GetChild(i - 1)
			self:set_card_value(t, v.cards[i])
		end
		local cards1 = {v.cards[1], v.cards[2], v.cards[3]}
		local type1, max1 = self:checkDaoType3(cards1)
		self:enable(true, self.players[idPos].Typedao_1)
		self:setdaoType(type1, self.players[idPos].Typedao_1)
		self:enable(true, self.players[idPos].Scoredao_1)
		self:text(v.daos[1], self.players[idPos].Scoredao_1)
		self:delay(1, function()
			for i = 1, 5 do
				local t = self.players[idPos].dao_2:GetChild(i - 1)
				self:set_card_value(t, v.cards[i + 3])
			end
			local cards2 = {v.cards[4], v.cards[5], v.cards[6], v.cards[7], v.cards[8]}
			local type2, max2 = self:checkDaoType5(cards2)
			self:enable(true, self.players[idPos].Typedao_2)
			self:setdaoType(type2, self.players[idPos].Typedao_2)
			self:enable(true, self.players[idPos].Scoredao_2)
			self:text(v.daos[2], self.players[idPos].Scoredao_2)
			
		end)
		self:delay(2, function()
			for i = 1, 5 do
				local t = self.players[idPos].dao_3:GetChild(i - 1)
				self:set_card_value(t, v.cards[i + 8])
			end
			local cards3 = {v.cards[9], v.cards[10], v.cards[11], v.cards[12], v.cards[13]}
			local type3, max3 = self:checkDaoType5(cards3)
			self:enable(true, self.players[idPos].Typedao_3)
			self:setdaoType(type3, self.players[idPos].Typedao_3)
			self:enable(true, self.players[idPos].Scoredao_3)
			self:text(v.daos[3], self.players[idPos].Scoredao_3)
			
			-- if #v.daos == 4 then
			-- 	self:enable(true, self.players[idPos].Scoredao_4)
			-- 	self:text(v.daos[4], self.players[idPos].Scoredao_4)
			-- end
		end)
		self:text(v.all_score, self.players[idPos].scoreTxt)
	end
	
	for i = 1, 4 do
		dao4Score[i] = 0
	end
	if shotallIndex ~= - 1 then
		for k, v in pairs(data.datas) do
			local idPos = self.id_order[v.id]
			if #data.datas == 3 then
				if k ~= shotallIndex then
					dao4Score[idPos] = dao4Score[idPos] - 5
				else
					dao4Score[idPos] = dao4Score[idPos] + 5 * 2
				end
			else
				if k ~= shotallIndex then
					dao4Score[idPos] = dao4Score[idPos] - 7
				else
					dao4Score[idPos] = dao4Score[idPos] + 7 * 3
				end
			end
		end
	end
	print(_s(dao4Score))
	for k, v in pairs(data.datas) do
		if #v.shots > 0 then
			for a, b in pairs(v.shots) do
				shotCount = shotCount + 1
				print(self.id_order[b])
				if #data.datas == 3 then
					dao4Score[self.id_order[v.id]] = dao4Score[self.id_order[v.id]] + 2
					dao4Score[self.id_order[b]] = dao4Score[self.id_order[b]] - 2
				else
					dao4Score[self.id_order[v.id]] = dao4Score[self.id_order[v.id]] + 3
					dao4Score[self.id_order[b]] = dao4Score[self.id_order[b]] - 3
				end
				self:delay(shotCount * 2, function()
					self:show_shot(v.id, b)
				end)
			end
		end
	end
	
	self:delay(2.1, function()
		for k, v in pairs(data.datas) do
			local idPos = self.id_order[v.id]
			self:enable(true, self.players[idPos].Scoredao_4)
			if #data.datas == 3 then
				self:text(dao4Score[idPos], self.players[idPos].Scoredao_4)
			end
			if #data.datas == 4 then
				self:text(dao4Score[idPos], self.players[idPos].Scoredao_4)
			end
		end
	end)
	
	self:delay(shotCount * 2 + 4, function()
		self:enable(true, self.btn_start)
		self:show_13result(data.datas)
	end)
end

--显示打枪
function Class:show_shot(id1, id2)
	local shotAn = GameAPI.Create2Dimage("shot_anim")
	shotAn.transform.parent = game_ui.players[game_ui.id_order[id1]].shot_effect.transform
	shotAn.transform.localPosition = Vector3(0, 0, - 5)
	shotAn.transform.localScale = Vector3(108, 108, 108)
	
	for i = 1, 3 do
		self:delay(i / 4 + 0.5, function()
			local dongAn = GameAPI.Create2Dimage("dong_anim")
			dongAn.transform.parent = game_ui.players[game_ui.id_order[id2]].shot_effect.transform
			
			local offX = math.random(- 80, 80)
			local offY = math.random(- 80, 80)
			dongAn.transform.localPosition = Vector3(offX, offY, - 5)
			dongAn.transform.localScale = Vector3(108, 108, 108)
		end)
	end
end

function Class:setdaoType(n, tx)
	local strType = ""
	if n == 0 then
		strType = "乌龙"
	elseif n == 1 then
		strType = "对子"
	elseif n == 2 then
		strType = "两对"
	elseif n == 3 then
		strType = "三条"
	elseif n == 4 then
		strType = "顺子"
	elseif n == 5 then
		strType = "同花"
	elseif n == 6 then
		strType = "葫芦"
	elseif n == 7 then
		strType = "铁支"
	elseif n == 8 then
		strType = "同花顺"
	end
	self:text(strType, tx)
end

--13单局结算
-- shot_all[false]
-- played[true]
-- id[10001]
-- all_score[1]
-- shots ->
-- cards ->
-- score[1]
function Class:show_13result(datas)
	print("show_result")
	self:enable(true, self.ui_result)
	
	local base = self.room_params.base_score
	
	local win = 0
	local infoCount = 0
	self:push_child("Result/Scores")
	
	-- local bossCount = 1
	for i = 1, 4 do
		self:enable_child(true, "Player" .. i)
	end
	for k, v in pairs(self.infos) do
		print(v.state)
		infoCount = infoCount + 1
		self:text(v.name .. "\nID:" .. k, self:find_child("Player" .. infoCount .. "/info"))
		for a, b in ipairs(datas) do
			print(b.id)
			if b.id == v.id then
				local cards = b.cards
				for i = 1, 13 do
					local t = self:find_child("Player" .. infoCount .. "/Cur/Image" .. i)
					self:set_card_value(t, b.cards[i])
				end
				self:text(b.score, self:find_child("Player" .. infoCount .. "/Score"))
				self:text(b.all_score, self:find_child("Player" .. infoCount .. "/Score2"))
			end
		end
	end
	
	-- self:enable_child(true, "Player" .. bossCount .. "/winner")
	-- self:enable_child(true, "Player" .. bossCount .. "/Boss")
	for i = tonumber(infoCount + 1), 4 do
		print("Player" .. i)
		self:enable_child(false, "Player" .. i)
	end
	
	self:pop_child()
	
	-- self:enable_child(false, "Result/Win")
	-- self:enable_child(false, "Result/Lost")
	-- if win == 1 then
	-- 	self:enable_child(true, "Result/Win")
	-- elseif win == - 1 then
	-- 	self:enable_child(true, "Result/Lost")
	-- end
	if self.room_round_count >= self.room_params.round_count then
		UI:enable_child(true, "BtnQuit", self.ui_result)
		local fun = function()
			show_history(true)
		end
		UI:button_child(fun, "BtnQuit", self.ui_result)
		UI:enable_child(false, "BtnStart", self.ui_result)
	else
		UI:enable_child(true, "BtnStart", self.ui_result)
		UI:enable_child(false, "BtnQuit", self.ui_result)
	end
end

return Class
