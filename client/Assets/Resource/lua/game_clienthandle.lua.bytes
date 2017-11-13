
local Class = {}



function NextDownLoad(step)
	while step <= 6 do
		local pos = GameAPI.BeginDown(step)
		if pos >= 0 then
			filePos = pos
			DownUI["step"] = step
			proto.account:get_file(step, pos)
			return
		end
		step = step + 1
	end
	DownUI = {}
	GameAPI.EndDown()
	GameAPI.ResetLoad()
end

function Class:user_user_info(user_info)
	
	self.user_info = user_info
	log(self.user_info)
	
	if client.need_save_id then
		if user_info.id ~= client.need_save_id then
			client.need_save_id = user_info.id
			GameAPI.SaveInt("TestKey", user_info.id)
		end
	end
	
	if is_debug_version then
		-- nothing
	else
		GameAPI.LoginSpeech(1001328, tostring(user_info.id), user_info.name)
	end
	
	proto.room:get_room()
end

function Class:account_get_file_ack(per, data)
	local len = string.len(data)
	if len > 0 then
		GameAPI.WriteDown(data)
	end
	
	SetDownloadUI(per)
	
	if per == 100 then
		GameAPI.EndDown()
		local step = DownUI.step + 1
		if step <= 6 then
			NextDownLoad(step)
		else
			DownUI = {}
			GameAPI.ResetLoad()
		end
	else
		local step = DownUI.step
		proto.account:get_file_ok(step, filePos)
		filePos = filePos + len
	end
end

function SetDownloadUI(per)
	if DownUI then
		UI:slider_child(per, "Slider", DownUI.node)
		UI:text_child("进度：" .. tostring(per) .. "%", "TP", DownUI.node)
		UI:text_child(string.format("%d/7",(DownUI.step + 1)), "TAll", DownUI.node)
	end
end

function Class:account_ver_ack(type, url, vers)
	game_url = url
	if type > 0 then
		UI.close_watting()
		UI.close_all()
		UIAPI.DeleteUI("LoginPanel")
		
		if GameAPI.CheckVer(vers) then
			DownUI = {}
			DownUI["node"] = UI.show_temp("Download")
			NextDownLoad(0)
		else
			if type == 1 then
				is_test_game = true
				OnWXLoginRet("Test")
				--UI:enable_child(true, "Test", ui)
--UI:enable_child(false, "Login", ui)
			else
				local ui = UIAPI.CreateUI("LoginPanel")
				is_test_game = nil
			end
		end
	else
		UI.close_watting()
		local fun_retry = function()
			GameAPI.CallFun("down," .. url)
		end
		
		local fun_quit = function()
			UnityEngine.Application.Quit()
		end
		
		UI.msg_box("游戏已经更新,\n你要下载吗？", fun_retry, fun_quit)
	end
end

function Class:user_heart_ack()
end

function Class:user_login_error(er)
	GameAPI.SaveString("wx_key", "")
	UI.close_watting()
	UI.msg_box(er)
end

function Class:user_wx_id(id)
	self.wx_id = id
end




function Class:user_change_card(card)
	
	self.user_info.card_count = self.user_info.card_count + card
	
	if main_ui then
		main_ui:text_child(tostring(client.user_info.card_count), "MainMenu/Top/Head/Cards/Text")
	end
end

function Class:user_get_txt_ack(key, text)
	UI.close_watting()
	print(key, text)
	if key == "shop" and text == "daili" then
		self:show_daili()
		return
	elseif key == "note" then
		if main_ui then
			main_ui:text_child(text, "MainMenu/Hint/PaoMa/Text")
		end
		return
	end
	
	text = string.gsub(text, "\\n", "\n");
	UI.msg_box(text)
end

function Class:show_daili()
	local temp = UI.show_temp("DaiLi")
	
	
	UI:button_child(function()
		self:show_trans()
	end, "BtnTrans", temp)
	
	UI:button_child(function()
		proto.account:get_gold_list(0, 10)
	end, "BtnInfo", temp)
end



function Class:account_get_gold_list_ack(count, id, datas)
	UI.close_watting()
	local temp = UIAPI.ShowOne("GoldList")
	
	if count - id > 10 then
		UI:gray_child("BtnNext", temp)
	end
	
	if id > 10 then
		UI:gray_child("BtnPrev", temp)
	end
	
	local maxpage =(count - count % 10) / 10 + 1
	local page = id / 10 + 1
	
	UI:text_child(string.format("%d/%d", maxpage, page), "Page", temp)
	
	UI:button_child(function()
		if id > 0 then
			proto.account:get_gold_list(id - 10, 10)
		end
	end, "BtnPrev", temp)
	
	UI:button_child(function()
		if count - id > 10 then
			proto.account:get_gold_list(id + 10, 10)
		end
	end, "BtnNext", temp)
	
	print(_s(datas))
	
	local lnode = temp:FindChild("List")
	for i = 1, 10 do
		local child = lnode:GetChild(i)
		
		if datas[i] then
			local type = datas[i].type
			if type == 0 then
				UI:text_child("充值", 0, child)
				UI:text_child("", 1, child)
			elseif type == 1 then
				UI:text_child("赠送", 0, child)
				UI:text_child("", 1, child)
			elseif type == 2 then
				UI:text_child("注册", 0, child)
				UI:text_child("", 1, child)
			elseif type == 10 then
				if datas[i].gold > 0 then
					UI:text_child("转入", 0, child)
					UI:text_child(datas[i].src, 1, child)
				else
					UI:text_child("转出", 0, child)
					UI:text_child(tostring(datas[i].des), 1, child)
				end
			else
				UI:text_child("消耗", 0, child)
				UI:text_child("", 1, child)
			end
			
			UI:text_child(string.format("%d", datas[i].gold), 2, child)
			UI:text_child(datas[i].time, 3, child)
		else
			UI:text_child("", 0, child)
			UI:text_child("", 1, child)
			UI:text_child("", 2, child)
			UI:text_child("", 3, child)
		end
	end
	
end


function Class:show_trans()
	UI.show_temp("Trans")
end

function click_trans(id, count)
	
	id = tonumber(id)
	count = tonumber(count)
	
	if id and count and id > 0 and count > 0 and id ~= client.user_info.id then
		UI.show_watting()
		proto.account:send_gold(id, count, true)
	else
		UI.msg_box("无效输入")
	end
end

function Class:account_send_gold_check_ok(id, name, count)
	UI.close_watting()
	local fun = function()
		proto.account:send_gold(tonumber(id), tonumber(count), false)
	end
	
	local fun2 = function()
	end
	local txt = string.format("为玩家<color=#0000AF>%d %s</color>\n充值钻石<color=#0000AF>%d？</color>",
	id, name, count)
	UI.msg_box(txt, fun, fun2)
end

function Class:account_send_gold_ok()
	UI.close_watting()
	UI.msg_box("充值成功")
end

function Class:account_send_gold_fail(msg)
	UI.close_watting()
	UI.msg_box(msg)
end

function Class:room_get_room_ack(room_id)
	if room_id > 0 then
		proto.room:enter(room_id)
		client.room_id = room_id
	else
		UI.create("main_ui")
		UI.close_watting()
	end
end

function Class:room_re_enter(cur_id, round_host_id, order, cards, card_count, pi_card, his)
	if game_ui then
		game_ui:re_enter(cur_id, round_host_id, order, cards, card_count, pi_card, his)
	end
end

function Class:room_create_ack(roomid)
	self.room_id = roomid
	proto.room:enter(roomid)
end

function Class:room_create_error(txt)
	UI.close_watting()
	UI.msg_box(txt)
end

-- max 3 return
function Class:room_play_info(round, base_gold, infos, cards)
	if game_ui then
		game_ui:play_info(round, base_gold, infos, cards)
	end
end

function Class:room_turn_id(id, time, round)
	if game_ui then
		game_ui:turn_id(id, time, round)
	end
end


function Class:room_show_card_ack(id)
	if game_ui then
		game_ui:show_card_ack(id)
	end
end

function Class:room_show_card_value(cards)
	if game_ui then
		game_ui:show_card_value(cards)
	end
end

function Class:room_put_gold(id, gold)
	if game_ui then
		game_ui:put_gold(id, gold)
	end
end

function Class:room_giveup_ack(id)
	if game_ui then
		game_ui:giveup_ack(id)
	end
end

function Class:room_check_result(id, id2, value)
	if game_ui then
		game_ui:check_result(id, id2, value)
	end
end

function Class:room_win_id(id, datas)
	if game_ui then
		game_ui:win_id(id, datas)
	end
end

function Class:room_end_games(his)
	print(his)
	if game_ui then
		game_ui:end_games(his)
	end
end

-- max 3 return end
function call_voice(id)
	if game_ui then
		game_ui:start_voice(id)
	end
end

function call_voice_end(id)
end

function Class:room_voice_ack(id, data)
	call_voice(id)
	GameAPI.PlaySpeech(data)
end

function Class:room_enter_ack(host_id, rounds, round_host, player_infos, room_params)
	
	UIAPI.DeleteUI("LoginPanel")
	
	UI.close_all()
	UI.create("game_ui")
	game_ui:enter_ack(host_id, rounds, round_host, player_infos, room_params)
	UI.close_watting()
end

function Class:room_offline_player(id)
	if game_ui then
		local index = game_ui.id_order[id]
		game_ui:enable(false, game_ui.players[index].ok)
		game_ui:enable(true, game_ui.players[index].offline)
	end
end

function Class:room_online_player(id, ip)
	if game_ui then
		local index = game_ui.id_order[id]
		game_ui.players[index].ip = ip
		game_ui:enable(false, game_ui.players[index].offline)
	end
end

function Class:room_enter_player(player_info)
	if game_ui then
		game_ui:enter_player(player_info)
	end
end

function Class:room_quit_player(id)
	if game_ui then
		game_ui:quit_player(id)
	end
end

function Class:room_show_emotion_ack(id, e)
	if game_ui then
		game_ui:show_emotion_ack(id, e)
	end
end

function Class:room_show_txt_msg_ack(id, e)
	if game_ui then
		game_ui:show_txt_msg_ack(id, e)
	end
end

function Class:room_quit_room()
	UI.close_watting()
	UI.close_all()
	print("quittomain")
	UI.create("main_ui")
end

function Class:room_quit_voto(time, ids)
	if game_ui then
		game_ui:quit_voto(time, ids)
	end
end

function Class:room_quit_voto_end(yes)
	if game_ui then
		game_ui:quit_voto_end(yes)
	end
end

function Class:room_quit_voto_time(time)
	if game_ui then
		game_ui:quit_voto_time(time)
	end
end

function Class:room_enter_error(txt)
	UI.close_watting()
	UI.msg_box(txt)
end

function Class:room_game_start(order)
	if game_ui then
		game_ui:game_start(order, true)
	end
end

function Class:room_saizhi(id, r1, r2)
	if game_ui then
		game_ui:game_saizhi(id, r1, r2)
	end
end

function Class:room_game_order(order, his)
	if game_ui then
		game_ui.history = his
		game_ui:set_his_score(his)
		game_ui:game_start(order)
	end
end


function Class:room_game_start_error(txt)
	UI.close_watting()
	UI.msg_box(txt)
end

function Class:room_game_init_cards(cards, card_count)
	--log(cards)
	print(card_count)
	if game_ui then
		game_ui:game_init_cards(cards, card_count)
	end
end


function Class:room_get_lai(id, card)
	if game_ui then
		game_ui:get_lai(id, card)
	end
end

function Class:room_turn(id, time, card, gangs, hus)
	if game_ui then
		game_ui:turn_player(id, time, card, gangs, hus)
	end
end

function Class:room_put_card(id, card)
	if game_ui then
		game_ui:put_card(id, card)
	end
end

function Class:room_score(id, otherId, score)
	if game_ui then
		game_ui:room_score(id, otherId, score)
	end
end

function Class:room_gang(id, card, count, otherId, score)
	if game_ui then
		game_ui:room_gang(id, card, count, otherId, score)
	end
end

function Class:room_peng(id, card)
	if game_ui then
		game_ui:room_peng(id, card)
	end
end

function Class:room_hu(id, cards)
	if game_ui then
		game_ui:room_hu(id, cards)
	end
end

function Class:tuoguan()
	if game_ui then
		game_ui:tuoguan()
	end
end


function Class:room_wait_action(peng, gang, hu)
	if game_ui then
		game_ui:wait_action(peng, gang, hu)
	end
end

function Class:room_end_game(info, his)
	if game_ui then
		game_ui:room_end_game(info, his)
	end
end

function Class:room_show_replay_ack(data)
	
	UIAPI.DeleteUI("LoginPanel")
	
	UI.close_all()
	UI.create("game_ui")
	UI.close_watting()
	
	self.room_id = client.history.room_id
	game_ui:init_replay(client.history.game_id, data)
	
end

function Class:room_get_replay_data_ack(id, data)
	
	UI.close_watting()
	game_ui:set_replay_data(id, data)
end

function Class:room_show_history_ex(datas)
	
	client.historyex = datas
	
	UI.close_watting()
	if datas[1] == nil then
		UI.msg_box("没有历史战绩")
	else
		UIAPI.DeleteUI("History2")
		local temp = UI.show_temp("History2")
		
		local data_node = temp:FindChild("S/V/C/Data")
		for i = 1, 10 do
			local v = datas[i]
			local node = data_node:GetChild(i - 1)
			if v == nil then
				UI:enable_all_child(false, node)
			else
				UI:enable_all_child(true, node)
				local times = string.split(v.time, " ")
				
				local text = times[1] .. "\n" .. times[2]
				
				UI:text_child(text, 1, node)
				UI:text_child(tostring(v.room_id), 2, node)
				-- local iswin=0
				for j = 1, 4 do
					if v.names[j] then
						if client.user_info.name == v.names[j] then
							if v.scores[j] > 0 then
								UI:text_child("赢", 7, node)
								UI:text_child("", 8, node)
							else
								UI:text_child("输", 8, node)
								UI:text_child("", 7, node)
							end
						end
						local str = v.names[j] .. ":" .. tostring(v.scores[j])
						UI:text_child(str, j + 2, node)
					else
						UI:text_child("", j + 2, node)
					end
				end
				
			end
		end
		
		local fun = function()
			local v = datas[1]
			local t1 = v.names[1] .. " " .. tostring(v.scores[1])
			local t2 = v.names[2] .. " " .. tostring(v.scores[2])
			local t3 = v.names[3] .. " " .. tostring(v.scores[3])
			local t4 = v.names[4] .. " " .. tostring(v.scores[4])
			local t5 = v.names[5] .. " " .. tostring(v.scores[5])
			local t6 = v.names[6] .. " " .. tostring(v.scores[6])
			
			local str = string.format("share,十三水战绩,\n%s\n%s\n%s\n%s\n%s\n%s,%s",
			t1, t2, t3, t4, t5, t6, game_url)
			print(str)
			GameAPI.CallFun(str)
		end
		UI:button_child(fun, "BtnShare", temp)
	end
end

function Class:room_show_history(his, quit)
	client.history = his
	print("显示总结算")
	UI.close_watting()
	if(his.room_id <= 0) then
		UI.msg_box("没有历史战绩")
	else
		UIAPI.DeleteUI("History")
		local temp = UI.show_temp("History")
		
		UI:text_child(his.time, "Text2", temp)
		UI:text_child("房号:" .. tostring(his.room_id), "Text1", temp)
		
		local data_node = temp:FindChild("Panel")
		
		local player_count = 0
		local boss_n = 0
		local max_Score = 0
		print(_s(his.data))
		for i, v in ipairs(his.data) do
			print(v.head)
			player_count = player_count + 1
			local node = data_node:GetChild(i - 1)
			
			UI:text_child(v.name .. "\nID:" .. tostring(v.id), "info", node)
			
			if v.score > 0 then
				UI:text_child("+" .. tostring(v.score), "Score", node)
				game_ui:enable(true, node:FindChild("Win"))
				game_ui:enable(false, node:FindChild("Lose"))
			else
				UI:text_child(tostring(v.score), "Score", node)
				game_ui:enable(false, node:FindChild("Win"))
				game_ui:enable(true, node:FindChild("Lose"))
			end
			
			
			-- UI:image_child(v.head,"head",node)
			for a, b in pairs(game_ui.infos) do
				if b.id == v.id then
					UI:image_child(b.head, "head", node)
				end
			end
			
			local host_img = node:FindChild("head/Image")
			if v.id == game_ui.host_id then
				game_ui:enable(true, host_img)
			else
				game_ui:enable(false, host_img)
			end
		end
		
		for i = player_count + 1, 4 do
			local node = data_node:GetChild(i - 1)
			game_ui:enable(false, node)
		end
		
		if quit then
			
			local fun = function()
				UI.close_all()
				UI.create("main_ui")
			end
			UI:button_child(fun, "BtnQuit", temp)
			
			local funs = function()
				-- local v = datas[1]
				-- local t1 = v.names[1] .. " " .. tostring(v.scores[1])
				-- local t2 = v.names[2] .. " " .. tostring(v.scores[2])
				-- local t3 = v.names[3] .. " " .. tostring(v.scores[3])
				-- local t4 = v.names[4] .. " " .. tostring(v.scores[4])
				-- local str = string.format("share,哎呦麻将战绩,\n%s\n%s\n%s\n%s,%s",
				--     t1,t2,t3,t4,game_url)
				-- print(str)
				-- GameAPI.CallFun( str )
			end
			UI:button_child(funs, "BtnShare", temp)
		end
	end
end


function Class:room_player_ready_ack(id)
	if game_ui then
		game_ui:room_player_ready_ack(id)
	end
end

function Class:room_get_user_info_ack(id, name, note, roundCount, winCount, sex, img, code)
	local temp = UI.show_temp("Info")
	
	local rate
	if roundCount <= 0 then
		rate = 100
	else
		rate = winCount * 100 / roundCount
	end
	
	UI:text_child("昵称:" .. name, "text/name", temp)
	-- UI:text_child("签名:"..note,"text/note",temp)
	UI:text_child("ID:" .. tostring(id), "text/id", temp)
	-- UI:text_child("总局:"..tostring(roundCount),"text/round",temp)
	-- UI:text_child("胜率:"..tostring(rate).."%","text/rate",temp)
	-- UI:text_child("胜局:"..tostring(winCount),"text/win",temp)
	-- UI:text_child("绑定推荐码:"..code,"text/code",temp)
	if sex == 1 then
		UI:text_child("性别:男", "text/sex", temp)
	else
		UI:text_child("性别:女", "text/sex", temp)
	end
	UI:image_child(img, "Head", temp)
end


function Class:room_power_up_ack(ids, powers)
	if game_ui then
		game_ui:power_up_ack(ids, powers)
	end
end

function Class:room_put_cards_ok(id)
	if game_ui then
		print("room_put_cards_ok")
		game_ui:put_cards_ok(id)
	end
end

function Class:room_end_turn(datas)
	if game_ui then
		game_ui:room_end_turn(datas)
	end
end

return Class
