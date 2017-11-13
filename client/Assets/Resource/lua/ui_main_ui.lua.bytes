


local Class = {
    res = "MainPanel"
}


function Class:init()
    Sound:play_music("hall")

    delete_node("main/Canvas/main")

    proto.user:get_txt("note")

    main_ui = self

    self:text_child(client.user_info.name,"MainMenu/Top/Head/Name")
    self:text_child("ID:"..tostring(client.user_info.id),"MainMenu/Top/Head/ID")
    self:text_child(tostring(client.user_info.card_count),"MainMenu/Top/Head/Cards/Text")
    self:image_child(client.user_info.head,"MainMenu/Top/Head/Image")

    -- if is_test_game then
    --     self:enable_child(false,"MainMenu/Top/Head/Cards")

    --     self:enable_child(false,"CreateRoom/GameObject/Node1/Count")
    --     self:enable_child(false,"CreateRoom/GameObject/Node2/Count")

    --     self:text_child("8局","CreateRoom/GameObject/Node1/Round/Toggle/Label")
    --     self:text_child("16局","CreateRoom/GameObject/Node1/Round/Toggle (1)/Label")
    --     self:text_child("8局","CreateRoom/GameObject/Node2/Round/Toggle/Label")
    --     self:text_child("16局","CreateRoom/GameObject/Node2/Round/Toggle (1)/Label")
    -- end

    -- if game_type == 1 then
    --     self:enable_child(true,"CreateRoom/GameObject/Node1")
    --     self:enable_child(false,"CreateRoom/GameObject/Node2")
    -- end

    -- if game_type == 2 then
    --     self:enable_child(false,"CreateRoom/GameObject/Node1")
    --     self:enable_child(true,"CreateRoom/GameObject/Node2")
    -- end

    self:enable_child(false,"EnterRoom")
    self:enable_child(false,"CreateRoom")
end

function on_create_room()
    Sound:play_sound("clickSound")
    print("创建房间");
    main_ui:enable_child(true,"CreateRoom")
end

function on_enter_room()
    Sound:play_sound("clickSound")
    main_ui:enable_child(true,"EnterRoom")
    main_ui:clear_child_input("EnterRoom")
end

function on_return_main_menu()
    Sound:play_sound("clickSound")
    main_ui:enable_child(false,"EnterRoom")
    main_ui:enable_child(false,"CreateRoom")

end

function on_enter_enter_room(id)
    Sound:play_sound("clickSound")
    UI.show_watting()
    proto.room:enter(id)

    client.room_id = id
end

--创建规则一的房间
function on_enter_create_room1(round,count)
    Sound:play_sound("clickSound")
    UI.show_watting()
    print(count)
    proto.room:create_room({
        type = 2,
        round_count = (round+1)*10,
        player_count = 1,
        base_score = 1,
        ex_param1 = 2,
        ex_param2 = count+3,
        ex_param3 =1,
    })
end

-- --创建规则二的房间
-- function on_enter_create_room2(round,ma,count)
--     Sound:play_sound("clickSound")
--     UI.show_watting()
--     proto.room:create_room({
--         type = 0,
--         round_count = (round+1)*10,
--         player_count = 0,
--         base_score = 1,
--         -- player_count = count,
--         -- base_score = base,
--         -- ex_param1 = ma,
--         -- ex_param2 = count,
--     })
-- end

function Class:destroy()
    main_ui = nil
end


return Class
