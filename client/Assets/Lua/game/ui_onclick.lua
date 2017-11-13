


function on_login()
	
	if is_debug_version then
		OnWXLoginRet("Test")
	else
		if client.wx_id then
			UI.show_watting()
			proto.user:wx_id_login(client.wx_id)
		else
			
			local wx_key = GameAPI.LoadString("wx_key", "")
			if wx_key == "" then
				GameAPI.WXLogin("")
			else
				UI.show_watting()
				proto.user:wx_login(wx_key)
			end
		end
	end
end

function click_close_game()
	
	if game_ui then
		game_click_quit()
	else
		UnityEngine.Application.Quit()
	end
end

function TestLogin()
	OnWXLoginRet("Test")
end

--点击返回房间
function on_back_room()
	
end

function OnWXLoginRet(value)
	
	if value == "Test" then
		local acc_id = GameAPI.LoadInt("TestKey", 0)
		client.need_save_id = acc_id
		
		proto.user:enter(acc_id)
		UI.show_watting()
	elseif value == "WXLogin_error" then
		UI.msg_box("微信登陆失败！")
	else
		GameAPI.SaveString("wx_key", value)
		UI.show_watting()
		proto.user:wx_login(value)
	end
end

function click_help()
	local u = UI.show_temp("RulePanel")
	if game_type == 1 then
		UI:enable_child(true, "S1", u)
		UI:enable_child(false, "S2", u)
	end
	
	if game_type == 2 then
		UI:enable_child(false, "S1", u)
		UI:enable_child(true, "S2", u)
	end
end

function click_shop()
	UI.show_watting()
	proto.user:get_txt("shop")
end

function game_click_setting()
	local node = UI.show_temp("SettingPanel")
	local setting = client.setting
	
	UI:slider_child(setting.music, "SliderMusic", node)
	UI:slider_child(setting.effect, "SliderSound", node)
	
	if game_ui then
		UI:enable_child(true, "BtnDis", node)
		UI:enable_child(false, "BtnClose", node)
	else
		UI:enable_child(false, "BtnDis", node)
		UI:enable_child(true, "BtnClose", node)
	end
	
	--UI:toggle_child(setting.vibrate,"Vibrate",node)
	--UI:toggle_child(setting.music,"Music",node)
	--UI:toggle_child(setting.effect,"Effect",node)
end

function on_sound_value(value)
	client.setting.effect = value
	GameAPI.SaveInt("s_effect", client.setting.effect)
end

function on_music_value(value)
	--print(value)
	if client.setting.music == 0 then
		client.setting.music = value
		Sound:play_music()
	else
		client.setting.music = value
		Sound:change_music_value(value)
	end
	GameAPI.SaveInt("s_music", client.setting.music)
end

function enable_vibrate()
	if client.setting.vibrate == 0 then
		client.setting.vibrate = 1
	else
		client.setting.vibrate = 0
	end
	
	GameAPI.SaveInt("s_vibrate", client.setting.vibrate)
end

function enable_music()
	if client.setting.music == 0 then
		client.setting.music = 1
		Sound:play_music()
	else
		client.setting.music = 0
		Sound:stop_music()
	end
	GameAPI.SaveInt("s_music", client.setting.music)
end

function enable_effect()
	if client.setting.effect == 0 then
		client.setting.effect = 1
	else
		client.setting.effect = 0
	end
	
	GameAPI.SaveInt("s_effect", client.setting.effect)
end

function show_history(quit)
	
	if game_ui then
		if game_ui.zongjiesuan_his and game_ui.zongjiesuan_his.round > 0 then
			client:room_show_history(game_ui.zongjiesuan_his, quit)
		else
			client:room_show_history({room_id = 0}, quit)
		end
	else
		UI.show_watting()
		proto.room:get_history()
	end
end

function show_replay(n)
	
	UI.show_watting()
	client.history = client.historyex[n]
	
	proto.room:show_replay(client.history.game_id)
end

function share_result()
	
	local str = "战绩"
	GameAPI.ShareShot(str)
	
end

function on_share_game()
	local str = "share,进程爬山,晋城人自己的炸金花," .. game_url
	GameAPI.CallFun(str)
end

function click_speach_start()
	if game_ui then
		local fun = function(data)
			if data ~= "" then
				proto.room:voice(data)
			end
			--GameAPI.PlaySpeech(data);
			UIAPI.CloseOne("Speach")
		end
		game_ui.speach_ui = UIAPI.ShowOne("Speach")
		ImRecordVolume(0)
		GameAPI.StartSpeech(fun, 10);
	end
end

function click_speach_stop()
	if game_ui then
		UIAPI.CloseOne("Speach")
		GameAPI.StopSpeech();
		game_ui.speach_ui = nil
	end
end

function click_userinfo()
	print("click_userinfo")
	local id = client.user_info.id
	proto.room:get_user_info(id)
end

function ImRecordVolume(value)
	if game_ui and game_ui.speach_ui then
		if value > 80 then
			value = 4
		elseif value > 60 then
			value = 3
		elseif value > 40 then
			value = 2
		elseif value > 20 then
			value = 1
		else
			value = 0
		end
		
		if value > 0 then
			game_ui:enable_child(true, "Index", game_ui.speach_ui)
			game_ui:art_number_child(value, "N", game_ui.speach_ui)
		else
			game_ui:enable_child(false, "Index", game_ui.speach_ui)
		end
	end
end

function click_ready()
	if game_ui then
		
		if game_ui.history then
			if game_ui.history.round >= game_ui.room_params.round_count then
				show_history(true)
				return
			end
		end
		proto.room:player_ready()
		game_ui:enable(false, game_ui.btn_start)
	end
end

function click_select_em()
	local temp = UI.show_temp("UIEmotion")
	
	local node = temp:FindChild("Node2/Scroll View/Viewport/Content")
	if game_ui then
		game_ui:set_em_txt(node)
	end
end

function send_txt_msg(txt)
	if game_ui then
		if txt ~= nil and txt ~= "" then
			proto.room:show_txt_msg(txt)
		end
	end
end

function click_show_emotion(index)
	if game_ui then
		proto.room:show_emotion(index)
	end
end

function click_show_emotion_ex(index)
	if game_ui then
		proto.room:show_emotion(50 + index)
	end
end
