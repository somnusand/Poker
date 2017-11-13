require Tools


defmodule RoomMax3 do
    @tick 1000
    @is_test true
    @is_test_card false


    @start_time 6
    @play_time 60

    #@peng_time 2
    @peng_time 5
    # ...
    # ...

    @max_round 8 #8

    def start(id,key_room_id,host_id,params) do
		case GenServer.start(__MODULE__,[id,key_room_id,host_id,params]) do
		{:ok,pid} ->
            pid
        _ ->
            nil
		end
	end

#-- GenServer

    use GenServer

    def init([id,key_room_id,host_id,params]) do
        ##Tools.log(Server.User.__info__(:functions))

        <<a::64, b::64, c::64>> = :crypto.strong_rand_bytes(24)
        :rand.seed(:exs64, {a,b,c})

        params =
        if @is_test do
            put_in(params.round_count,1)
        else
            params
        end

        order_list  = Enum.map(1..params.ex_param2,fn(_)->
            nil
        end)

        #Tools.log(params.ex_param2)
        #Tools.log(order_list)

        state = %{  state: nil,
                    inval: 1, players: %{}, pids: [],
                    id: id, time: 0, wait_time: 0,
                    room_id: key_room_id,
                    host_id: host_id,
                    game_params: params,
                    order_list: order_list,

                    max_count: 10,
                    max_player_count: params.ex_param2,
                    replays: [],

                    game_count: 0,
                    cur_card: 0,
                    rounds: 0,
                    game_max_count: params.round_count}

        state = tick(state)

        {:ok, state}
    end

    def handle_call({:quit,id}, {self_pid,_},state) do

        player_ids = Map.keys(state.players)
        if Enum.member?(player_ids,id) do
            #Tools.log({"quit ->1",state.state})
            cond do
            (state.state == nil) or (state.state == :end_game) ->
                User.cast(self_pid,fn(x)->
                    case x[:room] do
                    nil ->
                        x
                    room ->
                        if room.id == state.id do
                            put_in(x.room,nil)
                        else
                            x
                        end
                    end
                end)

                pids = state.pids
                pid = state.players[id].pid
                pids = List.delete(pids, pid)
                players = Map.delete(state.players, id)

                order_list = List.replace_at(state.order_list, state.players[id].pos, nil)

                state = Map.merge(state, %{
                    pids: pids,
                    players: players,
                    order_list: order_list,
                })

                if (players == []) or (state.state == nil and state.host_id==id) do
                    send(self(),:stop)
                    Proto.Room.send_quit_room([self_pid|state.pids])
                    RoomManager.close_room(state.id)
                else
                    RoomManager.quit_room(id,state.id)
                    Proto.Room.send_quit_room(self_pid)
                    Proto.Room.send_quit_player(state.pids,id)
                end
                {:reply,true,state}
            true ->
                {:reply,false,state}
            end
        else
            #Tools.log({"quit ->2",state.state})
            {:reply,false,state}
        end
    end

    def handle_call({:enter,id,name,image,sex,ip},{pid,_},state) do
        #Tools.log("enter step1")
        player_ids = Map.keys(state.players)

        #Tools.log(player_ids)
        #Tools.log(id)
        cond do
        Enum.member?(player_ids,id)  ->
            #Tools.log("enter step2")
            pids = List.delete(state.pids, state.players[id].pid)

            Proto.Room.send_online_player(pids,id,ip)

            pids = [pid|pids]
            state = put_in(state.pids, pids)

            state = put_in(state.players[id].pid, pid)
            state = put_in(state.players[id].ip, ip)
            state = put_in(state.players[id].off_line, false)

            state = put_in(state.players[id].tuo_guan, false)
            send_room_info(state,id)

            #Tools.log(state)

            playingInfo(state,pid,id)

            {:reply,true,state}
        # state.state != nil ->
        #     #Tools.log("step3")
        #     {:reply,:start,state}
        true ->
            #Tools.log("step4")
            len = length(player_ids)

            len =
            if Enum.member?(player_ids, state.host_id) do
                len
            else
                len + 1
            end

            cond do
            len >= state.max_player_count ->
                {:reply,:full,state}
            # Room.has_ip(state,ip) ->
            #     {:reply,:has_ip,state}
            true ->
                {pos,state} = get_pos(state,id)
                RoomManager.enter_room(id,state.id,pid)

                player = %{id: id, pid: pid, name: name, head: image,
                            put_count: [],
                            his_values: {0,0,0,0,0,0},
                            pos: pos, showed: false, gold: 0,
                            state: :not_play,
                            sex: sex, tuo_guan: false, ip: ip, started: false,
                            cards: [],
                            cur_gold: 0,
                            put_ok: false,
                            off_line: false}
                players = Map.put_new(state.players,id,player)

                send_add_player(state,player)

                pids = state.pids ++ [pid]

                if Room.has_ip(state,ip) do
                    txt = "本局部分玩家IP相同 他们是:\n"
                    txt = List.foldl(state.order_list, txt, fn(player_id,acc)->
                        if player_id == nil or player_id == id do
                            acc
                        else
                            if players[player_id].ip == ip do
                                <<acc::binary,players[player_id].name::binary,","::binary>>
                            else
                                acc
                            end
                        end
                    end)
                    txt = <<txt::binary,name::binary>>
                    Proto.Room.send_enter_error(pids,txt)
                end


                state = Map.merge(state,%{players: players, pids: pids})

                send_room_info(state,id)

                playingInfo(state,pid,id)

                {:reply,true,state}
            end
        end
    end


    def handle_call(params,_from,state) do
        Tools.log({:handle_call,params})
        {:reply,nil,state}
    end


    def handle_cast({:cast,fun},state) do
		state = fun.(state)
		{:noreply,state}
	end

    def handle_cast({:cancel_tuoguan,id},state) do
        player_ids = Map.keys(state.players)
        case Enum.member?(player_ids,id) do
        true ->
            state = put_in(state.players[id].tuo_guan, false)
            {:noreply, state}
        _ ->
            {:noreply, state}
        end
    end

    def handle_cast({:start,id},state) do
        #Tools.log("start")

        if is_menber(state,id) do

            cond do
            @is_test ->
                state = put_in(state.players[id].started, true)
                players = state.players

                id = 1
                {pos,state} = get_pos(state,id)
                player = %{id: id, pid: nil, off_line: false, gold: 0,
                    pos: pos, showed: false,
                    cards: [],
                    cur_gold: 0,
                    put_ok: false,
                    supper: 0,
                    his_values: {0,0,0,0,0,0},
                    name: "1", image: nil, head: "", sex: 0, ip: "", started: true }
                #Tools.log(player)
                send_add_player(state,player)
                players = Map.put(players,id,player)

                id = 2
                {pos,state} = get_pos(state,id)
                player = %{id: id, pid: nil, off_line: false, gold: 0,
                    pos: pos, showed: false,
                    cards: [],
                    cur_gold: 0,
                    put_ok: false,
                    supper: 0,
                    his_values: {0,0,0,0,0,0},
                    name: "1", image: nil, head: "", sex: 0, ip: "", started: true }
                #Tools.log(player)
                send_add_player(state,player)
                players = Map.put(players,id,player)

                # id = 2
                # {pos,state} = get_pos(state,id)
                # player = %{id: id, pid: nil, off_line: false,  gold: 0,
                #     pos: pos, showed: false,
                #     name: "2", image: nil, head: "",sex: 1, ip: "", started: true }
                # send_add_player(state,player)
                # players = Map.put(players,id,player)
                #
                #
                #
                # id = 3
                # {pos,state} = get_pos(state,id)
                # player = %{id: id, pid: nil, off_line: false, gold: 0,
                #     pos: pos, showed: false,
                #     name: "3", image: nil, head: "",sex: 1, ip: "", started: true }
                # send_add_player(state,player)
                # players = Map.put(players,id,player)


                #Tools.log(state)

                state = Map.merge(state,%{players: players})
                #state = tick(state)

                {:noreply, state}

            # (state.state == nil) ->
            #     state = put_in(state.players[id].started, true)
            #     Proto.Room.send_player_ready_ack(state.pids,id)
            #     if is_all_ready(state) and state.state == nil do
            #         state = tick(state)
            #         card_count = Room.get_card_count(state.game_params)
            #         if state.game_params.player_count == 1 do
            #             UserManager.change_card(state.host_id,-card_count)
            #         else
            #             Enum.each(state.players, fn({id,_})->
            #                 UserManager.change_card(id,-card_count)
            #             end)
            #         end
            #         LogData.log_day_add(:game,1)
            #         {:noreply, put_in(state.state,:start)}
            #     else
            #         {:noreply,state}
            #     end
            (state.state == :init_cards) or (state.state == nil) ->
                case state.players[id] do
                nil ->
                    {:noreply, state}
                _ ->
                    state = put_in(state.players[id].started, true)
                    Proto.Room.send_player_ready_ack(state.pids,id)
                    state = put_in(state.wait_time,@start_time+state.time)
                    {:noreply, state}
                end
            true ->
                {:noreply, state}
            end
        else
            {:noreply, state}
        end
    end



    def handle_cast(:stop,state) do
        {:stop, :normal, state}
    end

    def handle_cast({:put_cmd,cmd,id,params},state) do
        state = update_cmd(state,cmd,id,params)
        {:noreply, state}
    end

    def handle_cast({:put_cards,id,cards,supper},state) do
        state =
        case state.players[id] do
        nil  ->
            state
        player ->
            if player.state == :playing do
                case player.cards -- cards do
                [] ->
                    if length(cards) == 13 do

                        Proto.Room.send_put_cards_ok(state.pids,id)
                        if supper do
                            case supper_cards_value(cards) do
                            0 ->
                                state
                            value ->
                                player = Map.put(player, :supper, value)
                                player = Map.put(player, :put_ok, true)
                                player = Map.put(player, :cards, cards)
                                put_in(state.players[id],player)
                            end
                        else
                            player = Map.put(player, :supper, 0)
                            player = Map.put(player, :put_ok, true)
                            player = Map.put(player, :cards, cards)
                            put_in(state.players[id],player)
                        end
                    else
                        state
                    end
                _ ->
                    state
                end
            else
                state
            end

        end
        {:noreply, state}
    end

    def handle_cast(params,state) do
        Tools.log({:handle_cast,params})
        {:noreply, state}
    end


    def handle_info({:cast,fun},state) do
		state = fun.(state)
		{:noreply,state}
	end

    def handle_info({:put_cmd,cmd,id,params},state) do
        #Tools.log({:put_cmd,cmd,id,params})
        state = update_cmd(state,cmd,id,params)
        {:noreply, state}
    end

    def handle_info(:update,state) do

        state =
        cond do
        state.inval < 0 ->
            if state.state != :end_game do
                RoomManager.close_room(state.id)
                put_in(state.state, :end_game)
            else
                state
            end
        state.inval > 1 ->
            tick(state)
        true ->
            # now = System.os_time() / 1000000
            # now = now / 1000

            now = Tools.get_now()

            #Tools.log(now)
            state = put_in(state.time,now)
            state = update(state)

            if state.inval > 0 do
                tick(state)
            else
                #quit_all(state)
                #Process.send_after self, :stop, 5000
                RoomManager.close_room(state.id)
                put_in(state.state, :end_game)
            end
        end

        {:noreply, state}
    end

    def handle_info(:stop,state) do
		{:stop, :normal, state}
	end

    def handle_info(:force_stop,state) do
        Proto.Room.send_quit_room(state.pids)
		{:stop, :normal, state}
	end

    def handle_info(params,state) do

        Tools.log({:handle_info,params})

        {:noreply, state}
    end



    def terminate(reason, state) do
        #info = :erlang.get_stacktrace()
        #Tools.log(info)
        case reason do
        :normal ->
            Tools.log("exit normal")
        _ ->
            RoomManager.close_room(state.id)

            Tools.log(reason)
        end

        :ok
    end


    defp playingInfo(state,pid,id)  do
        if state.state == :playing do
            info = List.foldl(state.order_list, [], fn(id,acc)->
                cond do
                id == nil ->
                    acc
                state.players[id].state == :not_play ->
                    acc
                true ->
                    p = state.players[id]
                    r = %{
                        id: id,
                        state: p.state,
                        gold: p.gold,
                        put_count: p.put_count,
                        showed: p.showed,
                    }
                    acc ++ [r]
                end
            end)
            cards = state.players[id].cards
            # if state.players[id].showed do
            #     cards = state.players[id].cards
            #     t = get_card_type(cards)
            #     [t|cards]
            # else
            #     [0,0,0,0]
            # end
            round = state.rounds
            Proto.Room.send_play_info(pid,round,state.base_count,info,cards)
            id = state.cur_player_id
            t = state.wait_time-state.time
            t = :erlang.round(t)
            t = max(0,t)
            Proto.Room.send_turn_id(pid,id,t,state.rounds)
        end
    end

    defp is_menber(state,id) do
        Enum.any?(state.players, fn({player_id,_})->
            id == player_id
        end)
    end

    defp get_pos(state,id) do
        case state.players[id] do
        nil ->
            pos  =  get_nil_pos(state.order_list)
            order_list = List.replace_at(state.order_list, pos, id)
            {pos,put_in(state.order_list,order_list)}
        player ->
            {player.pos,state}
        end
    end

    defp get_nil_pos(list) do
        get_nil_pos(list,0)
    end

    defp get_nil_pos([nil|_],n) do
        n
    end

    defp get_nil_pos([_|list],n) do
        get_nil_pos(list,n+1)
    end

    defp find_started_pos(state,next_pos) do
        next_pos = rem(next_pos,length(state.order_list))
        case Enum.at(state.order_list, next_pos, nil) do
        nil ->
            find_started_pos(state,next_pos+1)
        id ->
            if state.players[id].started do
                id
            else
                find_started_pos(state,next_pos+1)
            end
        end
    end


    defp send_add_player(state,player) do
        info = %{
            id: player.id,
            name: player.name,
            sex: player.sex,
            head: player.head,
            ip: player.ip,
            started: player.started,
            offline: player.off_line,
            pos: player.pos,
            gold: player.gold
        }
        Proto.Room.send_enter_player(state.pids,info)
    end

    defp send_room_info(state,id) do
        players = Map.values(state.players)
        infos = Enum.map(players,fn(x)->
            %{
                id: x.id,
                name: x.name,
                sex: x.sex,
                head: x.head,
                ip: x.ip,
                started: x.started,
                offline: x.off_line,
                pos: x.pos,
                gold: x.gold,
            }
        end)
        player = state.players[id]
        rounds = state.game_count
        round_host = Map.get(state,:round_host_id,0)
        #Tools.log("send_room_info")
        Proto.Room.send_enter_ack(player.pid,state.host_id,
                            rounds, round_host,
                            infos,state.game_params)
    end


    defp tick(state) do


        tick = @tick * state.inval

        #Tools.log(tick)
        if tick >= 0 do
            Process.send_after self, :update, tick
        end

        put_in(state.inval,1)
    end


    defp quit_state(state) do
        case state[:room] do
        nil ->
            state
        _ ->
            put_in(state.room,nil)
        end
    end


    defp update(state=%{state: nil}) do
        state = update_start(state)

        if state.state != nil do
            card_count = Room.get_card_count(state.game_params)
            UserManager.change_card(state.host_id,-card_count)
        end

        state
    end

    defp update(state=%{state: :init_cards}) do
        update_start(state)
    end



    defp update(state=%{state: :playing}) do
        if @is_test do
            any_ok =
            Enum.any?(state.players, fn({_,player})->
                 player.put_ok
            end)

            if any_ok do
                end_game(state)
            else
                state
            end
        else
            if check_all_put(state) do
                end_game(state)
            else
                state
            end
        end
    end

    defp update(state=%{state: :stopping}) do
        Enum.each(state.players,fn(player)->
            User.cast(player.pid,&quit_state/1)
        end)
        put_in(state.state, :stopped)
    end

    defp update(state) do
        state
    end




    defp update_start(state) do
        count = Enum.count(state.players, fn({_,player})->
            player.started == false
        end)

        ready_count = Enum.count(state.players, fn({_,player})->
            player.started == true
        end)

        #Tools.log({ready_count,count})

        cond do
        ready_count < state.max_player_count ->
            state
        (count==0) -> #|| (state.wait_time < state.time) ->

            ids = get_started_ids(state)
            Proto.Room.send_game_start(state.pids,ids)

            cards =
            if @is_test_card do
                cards = [1,5,9, 1,5,9,13,17, 1,5,9,13,17,]
                cards = cards ++ cards ++ cards
            else
                len = 52
                cards = Enum.map(1..len,fn(x)-> x end)
                Enum.take_random(cards, len)
            end

            state = put_in(state.game_count,state.game_count+1)

            # next_pos =
            # case state[:round_host_id] do
            # nil ->
            #     0
            # last_id ->
            #     state.players[last_id].pos + 1
            # end


            # next_id = find_started_pos(state,next_pos)
            # state = Map.put(state, :round_host_id, next_id)

            state =
            case state[:round_host_id] do
            nil ->
                next_id = get_not_nil_id(state,0)
                Map.put(state, :round_host_id, next_id)
            _ ->
                state
            end

            #Tools.log(state.round_host_id)
            cur_id = find_started_pos(state,state.players[state.round_host_id].pos + 1)
            cur_player_id = state.players[cur_id].id

            state=put_in(state.rounds,0)
            #Proto.Room.send_turn_id(state.pids,cur_player_id, @play_time,state.rounds)



            {players,_} = List.foldl(state.order_list,{[],cards},fn(id,{ret,ret_ards})->
                if id == nil do
                    {ret,ret_ards}
                else
                    data = state.players[id]

                    if data.started == false do
                        data = Map.put(data, :state, :not_play)
                        data = Map.put(data, :cards, [])
                        data = Map.put(data, :put_count, [])
                        data = Map.put(data, :put_ok, false)
                        {[{id,data}|ret],ret_ards}
                    else
                        {player_cards,new_cards}  = Enum.split(ret_ards,13)
                        player_cards = Enum.sort(player_cards)
                        data = Map.merge(data,%{
                                cards: player_cards,
                                state: :playing,
                                put_count: [1],
                                showed: false,
                                show_all: false,
                                put_ok: false,
                                supper: 0,
                            })

                        Proto.Room.send_show_card_value(state.players[id].pid,player_cards)
                        {[{id,data}|ret],new_cards}
                    end
                end
            end)
            players = Map.new(players)

            state = Map.merge(state, %{state: :playing,
                                inval: 3,
                                sub_state: nil,
                                cur_player_id: cur_player_id,
                                wait_time: @play_time + state.time,
                                base_count: 0,
                                #playing_count: ready_count,
                                rounds: 0,

                                #cards: cards,
                                index: 0,
                                players: players,
                                result: [],
                                pengs: [],
                                gangs: [],
                                hus:   [],
                                pause_cmds: [],
                                lai: 0,
                                cur_card: 0,
                                his_count: %{},
                                history: [],
                                has_cheng: false,
                                lai_pi: 0})
            state
        true ->
            state
        end
    end

    # defp update_cmd(state=%{state: :playing},cmd,id,params) do
    #     #Tools.log({:update_cmd,state.cur_player_id,state.sub_state})
    #
    #     if state.cur_player_id == id do
    #         case do_cmd(state,cmd,params) do
    #         false ->
    #             do_other_cmd(state,cmd,id,params)
    #         ret ->
    #             ret
    #         end
    #     else
    #         do_other_cmd(state,cmd,id,params)
    #     end
    # end

    defp update_cmd(state,_,_,_) do
        state
    end

    defp get_not_nil_id(state,pos) do
        pos = rem(pos,length(state.order_list))
        case Enum.at(state.order_list,pos) do
        nil ->
            get_not_nil_id(state,pos+1)
        id ->
            id
        end
    end

    defp get_next_player_id(state) do
        get_next_player_id(state,state.players[state.cur_player_id].pos+1)
    end

    defp get_next_player_id(state,pos) do
        pos = rem(pos,length(state.order_list))
        case Enum.at(state.order_list,pos) do
        nil ->
            get_next_player_id(state,pos+1)
        id ->
            case state.players[id].state do
            :playing ->
                id
            _ ->
                get_next_player_id(state,pos+1)
            end
        end
    end


    defp check_all_put(state) do
        Enum.all?(state.players, fn({_,player})->
            (player.state == :not_play) or (player.put_ok)
        end)
    end

    def check_3tong(tongs) do
        list = Enum.map(0..3,fn(hua)->
            Enum.count(tongs, fn(tong)->
                hua == tong
            end)
        end)

        Enum.all?(list, fn(count)->
            count == 3 or count == 5 or count == 0
        end)
    end

    def check_3shun(list) do
        value =
        Enum.any?(list, fn(a)->
            if Enum.member?(list, a+1) and Enum.member?(list, a+2) do
                new_list = list -- [a,a+1,a+2]
                [a|_] = new_list
                list1 = [a,a+1,a+2,a+3,a+4]
                list2 = new_list -- list1
                [a|_] = list2
                if list2 == [a,a+1,a+2,a+3,a+4] || (a==0 and list2 == [a,a+1,a+2,a+3,12]) do
                    true
                else
                    if a == 2 do
                        list1 = [a,a+1,a+2,a+3,12]
                        list2 = new_list -- list1
                        [a|_] = list2
                        list2 == [a,a+1,a+2,a+3,a+4] || (a==0 and list2 == [a,a+1,a+2,a+3,12])
                    else
                        false
                    end
                end
            else
                false
            end
        end)

        if value do
            value
        else
            value =
            if Enum.member?(list, 0) and Enum.member?(list, 1) and Enum.member?(list, 12) do
                new_list = list -- [0,1,2]
                [a|_] = new_list
                list1 = [a,a+1,a+2,a+3,a+4]
                list2 = new_list -- list1
                [a|_] = list2
                if list2 == [a,a+1,a+2,a+3,a+4] || (a==0 and list2 == [a,a+1,a+2,a+3,12]) do
                    true
                else
                    if a == 0 do
                        list1 = [a,a+1,a+2,a+3,12]
                        list2 = new_list -- list1
                        [a|_] = list2
                        list2 == [a,a+1,a+2,a+3,a+4] || (a==0 and list2 == [a,a+1,a+2,a+3,12])
                    else
                        false
                    end
                end
            else
                false
            end
        end
    end

    def check_6dui([a,b,b|list]) do
        check_6dui(list++[a])
    end

    def check_6dui([a,a|list]) do
        check_6dui(list)
    end

    def check_6dui([a]) do
        true
    end

    def check_6dui(_) do
        false
    end

    def supper_cards_value(list) do
        list = Enum.map(list,fn(c)->
             getHuaValue(c)
        end)
        listValue = Enum.map(list,fn({_,c})->
             c
        end)
        listValue = Enum.sort(listValue)

        if listValue == [0,1,2,3,4,5,6,7,8,9,10,11,12] do
            26
        else
            if check_6dui(listValue) do
                6
            else
                if check_3shun(listValue) do
                    6
                else
                    listValue = Enum.map(list,fn({c,_})->
                         c
                    end)
                    listValue = Enum.sort(listValue)
                    if check_3tong(listValue) do
                        6
                    else

                    end
                end
            end
        end
    end

    defp supper_player_value(player) do
        player[:supper]
    end

    defp check_lines(cards1,cards2) do
        values1 = get_lines_values(cards1)
        values2 = get_lines_values(cards2)

        {gun,value} =
        Tools.list_fold_2(values1,values2,{0,0},fn(a,b,{gun,acc})->
            if a > b do
                {_,value} = a
                {gun+1,acc + value}
            else
                {_,value} = b
                {gun-1,acc - value}
            end

        end)

        gun_value =
        if abs(gun) == 3 do

            [{{t1,_},_},{{t2,_},_},{{t3,_},_}] =
            if gun > 0 do
                values1
            else
                values2
            end

            v1 =
            case t1 do
            5 ->
                3
            _ ->
                0
            end

            v2 =
            case t2 do
            8 ->
                2
            9 ->
                8
            10 ->
                10
            _ ->
                0
            end

            v3 =
            case t3 do
            9 ->
                4
            10 ->
                5
            _ ->
                0
            end
            #Tools.log({t1,t2,t3})
            #Tools.log({v1,v2,v3})

            v = v1 + v2 + v3
            if gun > 0 do
                v
            else
                -v
            end
        else
            0
        end


        {gun,value+gun_value}
    end

    def get3value(a1,a2,a3) do

        list = [a1,a2,a3]
        list = Enum.sort(list)
        list = Enum.map(list,fn(c)->
             getHuaValue(c)
        end)
        [{h1,v1},{h2,v2},{h3,v3}] = list


        if v1 == v2 do
            if v2 == v3 do
                {{5,v1},3}
            else
                {{3,{v1,v3,h2}},1}
            end
        else
            if v2 == v3 do
                {{3,{v3,v1,h3}},1}
            else
                {{1,{v3,v2,v1,h3}},1}
            end
        end
    end

    def get5value_2(b1,b2,b3,b4,b5) do
        t = get5type(b1,b2,b3,b4,b5)

        case t do
        {10,_} ->
            {t,10}
        {9,_} ->
            {t,8}
        {8,_} ->
            {t,2}
        _ ->
            {t,1}
        end
    end

    def get5value(b1,b2,b3,b4,b5) do
        t = get5type(b1,b2,b3,b4,b5)
        case t do
        {10,_} ->
            {t,5}
        {9,_} ->
            {t,4}
        _ ->
            {t,1}
        end
    end

    def get5type(b1,b2,b3,b4,b5) do
        list = [b1,b2,b3,b4,b5]
        list = Enum.sort(list)

        [b1,b2,b3,b4,b5] = list

        list = Enum.map(list,fn(c)->
             getHuaValue(c)
        end)

        listHua = Enum.map(list,fn({c,_})->
             c
        end)

        [h1,h2,h3,h4,h5] = listHua

        is_tonghua = Enum.all?(listHua, fn(n)-> n == h1 end)

        listValue = Enum.map(list,fn({_,c})->
             c
        end)

        [a1,a2,a3,a4,a5] = listValue
        is_sun = (a1+1==a2) and (a1+2==a3) and (a1+3==a4) and ((a1+4==a5)or(a1==0 and a5==12))

        cond do
        is_tonghua or is_sun ->
            cond do
            is_tonghua and is_sun ->
                {10,{a5,a4,a3,a2,a1,h5}}
            is_tonghua ->
                {7,{a5,a4,a3,a2,a1,h5}}
            true ->
                {6,{a5,a4,a3,a2,a1,h5}}
            end
        (a1==a2) and (a1==a3) and (a1==a4) ->
            {9,a1}
        (a2==a3) and (a2==a4) and (a2==a5) ->
            {9,a5}
        (a1==a2) and (a1==a3) ->
            if a4 == a5 do
                {8,a1}
            else
                {5,a1}
            end
        (a2==a3) and (a2==a4) ->
            if a1 == a5 do
                {8,a2}
            else
                {5,a2}
            end
        (a3==a4) and (a3==a5) ->
            if a1 == a2 do
                {8,a5}
            else
                {5,a5}
            end
        # (a1==a2) ->
        #     cond do
        #     a3 == a4 ->
        #         amax = max(a1,a3)
        #         amin = max(a1,a3)
        #         {a,_} = List.keyfind(list, amax, 1, nil)
        #         {3,{amax,amin,a5,a4,a}}
        #     a4 == a5 ->
        #     true ->
        #         alist = Enum.filter(list, fn({_,c})->
        #             c == a1
        #         end)
        #         {a,_} = Enum.max(alist)
        #         {3,{amax,a1,a5,a4,a3,a}}
        #     end
        true ->
            alist = get2list(listValue,[])
            len = length(alist)
            cond do
            len == 2 ->
                amax = Enum.max(alist)
                amin = Enum.min(alist)
                vList = listValue -- alist
                vList = vList -- alist
                [as] = vList
                a = List.foldl(list, 0, fn({h,v},acc) ->
                    if v == amax do
                        h
                    else
                        acc
                    end
                end)
                {4,{amax,amin,as,a}}
            len == 1 ->
                [amax] = alist
                vList = listValue -- alist
                vList = vList -- alist
                vList = Enum.reverse(vList)
                a = List.foldl(list, 0, fn({h,v},acc) ->
                    if v == amax do
                        h
                    else
                        acc
                    end
                end)
                vList = [amax|vList] ++ [a]
                {3,List.to_tuple(vList)}
            true ->
                {1,{a5,a4,a3,a2,a1,h5}}
            end
        end
    end

    def get2list([a,a|list],ret) do
        ret = ret ++ [a]
        get2list(list,ret)
    end

    def get2list([a|list],ret) do
        get2list(list,ret)
    end

    def get2list(_,ret) do
        ret
    end

    def get_lines_values([a1,a2,a3,b1,b2,b3,b4,b5,c1,c2,c3,c4,c5]) do
        v1 = get3value(a1,a2,a3)
        v2 = get5value_2(b1,b2,b3,b4,b5)
        v3 = get5value(c1,c2,c3,c4,c5)
        cond do
        v2 > v3 ->
            t = {{0,{}},0}
            [t,t,t]
        v1 > v2 ->
            t = {{0,{}},0}
            [t,t,t]
        true ->
            [v1,v2,v3]
        end
    end

    def form_test_cards([]) do
        []
    end

    def form_test_cards([card|cards]) do
        card = div(card,100) + (rem(card,100)-2) * 4
        [card|form_test_cards(cards)]
    end

    def test_end_cards(supper1,cards1,supper2,cards2,supper3,cards3) do
        cards1 = form_test_cards(cards1)
        cards2 = form_test_cards(cards2)
        cards3 = form_test_cards(cards3)

        supper1 =
        if supper1 do
            RoomMax3.supper_cards_value(cards1)
        else
            0
        end

        supper2 =
        if supper2 do
            RoomMax3.supper_cards_value(cards2)
        else
            0
        end

        supper3 =
        if supper3 do
            RoomMax3.supper_cards_value(cards3)
        else
            0
        end

        players = %{
            1 => %{
                cards: cards1,
                supper: supper1,
                state: :playing,
                cur_gold: 0,
                gold: 0,
                started: true,
                his_values: [],
            },
            2 => %{
                cards: cards2,
                supper: supper2,
                state: :playing,
                cur_gold: 0,
                gold: 0,
                started: true,
                his_values: [],
            },
            3 => %{
                cards: cards3,
                supper: supper3,
                state: :playing,
                cur_gold: 0,
                gold: 0,
                started: true,
                his_values: [],
            }
        }

        state  = %{
            players: players,
            game_count: 1,
            game_max_count: 10,
            state: :playing,
            pids: [],
            wait_time: 0,
            time: 0,
        }
        end_game(state)
    end

    def test_end_cards(supper1,cards1,supper2,cards2,supper3,cards3,supper4,cards4) do
        cards1 = form_test_cards(cards1)
        cards2 = form_test_cards(cards2)
        cards3 = form_test_cards(cards3)
        cards4 = form_test_cards(cards4)

        supper1 =
        if supper1 do
            RoomMax3.supper_cards_value(cards1)
        else
            0
        end

        supper2 =
        if supper2 do
            RoomMax3.supper_cards_value(cards2)
        else
            0
        end

        supper3 =
        if supper3 do
            RoomMax3.supper_cards_value(cards3)
        else
            0
        end


        supper4 =
        if supper4 do
            RoomMax3.supper_cards_value(cards4)
        else
            0
        end

        players = %{
            1 => %{
                cards: cards1,
                supper: supper1,
                state: :playing,
                cur_gold: 0,
                gold: 0,
                started: true,
                his_values: [],
            },
            2 => %{
                cards: cards2,
                supper: supper2,
                state: :playing,
                cur_gold: 0,
                gold: 0,
                started: true,
                his_values: [],
            },
            3 => %{
                cards: cards3,
                supper: supper3,
                state: :playing,
                cur_gold: 0,
                gold: 0,
                started: true,
                his_values: [],
            },
            4 => %{
                cards: cards4,
                supper: supper4,
                state: :playing,
                cur_gold: 0,
                gold: 0,
                started: true,
                his_values: [],
            }
        }

        state  = %{
            players: players,
            game_count: 1,
            game_max_count: 10,
            state: :playing,
            pids: [],
            wait_time: 0,
            time: 0,
        }
        end_game(state)
    end

    defp get_groups([_]) do
        []
    end

    defp get_groups([id1,id2]) do
        [{id1,id2}]
    end

    defp get_groups([id1|list]) do
        list_group = Enum.map(list, fn(id)->
            {id1,id}
        end)
        list_group ++ get_groups(list)
    end

    defp end_game(state) do

        list = Enum.filter(state.players,fn({_,player})->
            player.state == :playing
        end)


        has_supper = Enum.any?(state.players,fn({_,player})->
            (player.state == :playing) and (player[:supper] > 0)
        end)

        player_count  = length(list)

        basegan =
        cond do
        player_count >= 4 ->
            3
        player_count == 3 ->
            2
        true ->
            0
        end



        ids =  List.foldl(list, [], fn({id,player},acc)->
            if player[:supper] > 0 do
                acc
            else
                [id|acc]
            end
        end)

        daodatas =
        if length(ids) < 2  do
            Enum.map(ids,fn(id)->
                {id,[0,0,0]}
            end)
        else
            daolist = Enum.map(ids,fn(id)->
                values = get_lines_values(state.players[id].cards)
                {id,values}
            end)

            Enum.map(daolist,fn({id,id_values})->
                daolist_new = List.keydelete(daolist, id, 0)
                values = List.foldl(daolist_new,[0,0,0],fn({n_id,n_values},[a1,a2,a3])->
                    [d1,d2,d3] =
                    Tools.list_map_2(id_values,n_values,fn({v1,value1},{v2,value2})->
                        if v1 > v2 do
                            value1
                        else
                            -value2
                        end
                    end)
                    [a1+d1,a2+d2,a3+d3]
                end)
                {id,values}
            end)
        end

        #Tools.log(daodatas)
        daodatas = Map.new(daodatas)


        players_value = Enum.map(list, fn({id,player}) ->
            supper_value = supper_player_value(player)
            {gold,qian} = List.foldl(list, {0,[]}, fn({o_id,o_player},{acc,qian})->
                o_supper_value = supper_player_value(o_player)

                #Tools.log({supper_value,o_supper_value})

                if supper_value != 0 or o_supper_value != 0 do
                    acc =
                    if supper_value != 0 do
                        acc + supper_value
                    else
                        acc
                    end

                    if o_supper_value != 0 do
                        {acc - o_supper_value,qian}
                    else
                        {acc,qian}
                    end
                else
                    if o_id != id do
                        {t,value} = check_lines(player.cards,o_player.cards)
                        if abs(t) == 3 and (has_supper == false) do
                            acc =
                            if value > 0 do
                                acc + value + basegan
                            else
                                acc + value - basegan
                            end

                            if value > 0 do
                                {acc,[o_id|qian]}
                            else
                                {acc,qian}
                            end
                        else
                            {acc + value,qian}
                        end
                    else
                        {acc,qian}
                    end
                end
            end)
            {id,{gold,qian}}
        end)

        #Tools.log(players_value)

        guns = Enum.filter(players_value, fn({_,{_,qians}}) ->
            length(qians) == (player_count - 1)
        end)



        players_value =
        case guns do
        [{shot_id,_}] ->
            #Tools.log(shot_id)
            basegan_bei =
            cond do
            player_count >= 4 ->
                7
            player_count == 3 ->
                5
            true ->
                0
            end


            players_value = Enum.map(players_value, fn({id,{gold,qian}}) ->
                if shot_id == id do
                    {id,{gold,qian}}
                else
                    {id,{gold-basegan_bei,qian}}
                end
            end)

            players_value = Enum.map(players_value, fn({id,{gold,qian}}) ->
                #Tools.log(gold)
                if shot_id == id do
                    gold = List.foldl(players_value, 0, fn({_,{gold,_}},acc) ->
                        #Tools.log(gold)
                        if gold < 0  do
                            acc - gold
                        else
                            acc
                        end
                    end)
                    {id,{gold,qian}}
                else
                    {id,{gold,qian}}
                end
            end)
            players_value
        _ ->
            players_value
        end

        players_value = Map.new(players_value)




        list = Enum.map(state.players, fn({id,player}) ->

            if player.state == :not_play do
                player = put_in(player.cur_gold, 0)
                {id,player}
            else
                {gold,_} = players_value[id]

                his_values = player.his_values
                #pai_k = get_card_k(player.cards)
                #k_count = elem(his_values, pai_k)
                #his_values = put_elem(his_values, pai_k, k_count+1)
                player = Map.merge(player, %{
                    cur_gold: gold,
                    gold: gold + player.gold,
                    started: false,
                    his_values: his_values,
                })
                {id,player}
            end
        end)

        datas = Enum.map(list, fn({id,player}) ->
            qian =
            case players_value[id] do
            {_,qian} ->
                qian
            _ ->
                []
            end
            if player.state == :playing do
                %{
                    id: id,
                    cards: player.cards,
                    score:   player.cur_gold,
                    all_score:   player.gold,
                    played: true,
                    shots: qian,
                    shot_all: length(qian) == player_count,
                    daos: Map.get(daodatas, id, []),
                }
            else
                %{
                    id: id,
                    cards: [],
                    score:   0,
                    all_score:   player.gold,
                    played: false,
                    shots: [],
                    shot_all: false,
                    daos: [],
                }
            end
        end)

        if @is_test do
            Enum.each(datas, fn(d)->
                Tools.log(d.daos)
                Tools.log(d.score)
                Tools.log(d.shots)
            end)
        end


        Proto.Room.send_end_turn(state.pids, %{
            datas: datas,
        })


        state = put_in(state.players,Map.new(list))

        # state = put_in(state.game_count,state.game_count+1)


        state =
        if state.game_count < state.game_max_count  do
            state = put_in(state.state,:init_cards)
            put_in(state.wait_time,state.time+@start_time)
        else

            his = Room.get_his_data(state)
            Proto.Room.send_end_games(state.pids,his)

            Enum.each(state.order_list, fn(id)->
                History.save(id, his)
            end)

            send(self(),:stop)

            RoomManager.close_room(state.id)
            put_in(state.state,:end_game)
        end
    end


    defp do_win(state,win_ids) do

        [win_id|_] = win_ids
        all_gold = List.foldl(state.order_list, 0, fn(id,acc)->
            case state.players[id] do
            nil ->
                acc
            player ->
                gold = Enum.sum(player.put_count)
                acc + gold
            end
        end)

        win_id_count = length(win_ids)
        win_gold = div(all_gold,win_id_count)
        win_lest_gold = all_gold - win_gold * win_id_count


        play_count = Enum.count(state.players, fn({id,player}) ->
            (player.state != :not_play)
        end)

        xies = List.foldl(state.order_list, [], fn(id,acc)->
            case state.players[id] do
            nil ->
                acc
            player ->
                if player.state == :not_play do
                    acc
                else
                    case get_card_type(player.cards) do
                    10 ->
                        [id|acc]
                    _ ->
                        acc
                    end
                end
            end
        end)

        list = Enum.map(state.players, fn({id,player}) ->
            if player.state == :not_play do
                nil
            else
                t = get_card_type(player.cards)


                gold = Enum.sum(player.put_count)
                gold =
                if Enum.member?(win_ids, id) do
                    if id == win_id do
                        win_gold - gold + win_lest_gold
                    else
                        win_gold - gold
                    end
                else
                    -gold
                end

                ex_gold =
                if Enum.member?(xies, id) do
                    5 * (play_count - length(xies))
                else
                    -5 * length(xies)
                end

                %{
                    id: id,
                    cards: [t|player.cards],
                    giveup: (player.state == :give_up),
		            showed: player.showed,
                    gold: gold,
                    ex_gold: ex_gold,
                }
            end
        end)
        datas = List.foldl(list,[],fn(a,acc)->
            case a do
            nil ->
                acc
            _ ->
                [a|acc]
            end
        end)

        Proto.Room.send_win_id(state.pids,win_ids,datas)
        state = put_in(state.round_host_id,win_id)
        #Tools.log(state.round_host_id)

        list = Enum.map(state.players, fn({id,player}) ->

            if player.state == :not_play do
                {id,player}
            else
                gold = Enum.sum(player.put_count)
                gold =
                if Enum.member?(win_ids, id) do
                    if id == win_id do
                        win_gold - gold + win_lest_gold
                    else
                        win_gold - gold
                    end
                else
                    -gold
                end

                gold =
                if Enum.member?(xies, id) do
                    gold + 5 * (play_count - length(xies))
                else
                    gold - 5 * length(xies)
                end

                his_values = player.his_values
                pai_k = get_card_k(player.cards)
                k_count = elem(his_values, pai_k)
                his_values = put_elem(his_values, pai_k, k_count+1)
                player = Map.merge(player, %{
                    gold: player.gold+gold,
                    started: false,
                    his_values: his_values,
                })
                {id,player}
            end
        end)

        state = put_in(state.players,Map.new(list))

        # state = put_in(state.game_count,state.game_count+1)


        state =
        if state.game_count < state.game_max_count  do
            state = put_in(state.state,:init_cards)
            put_in(state.wait_time,state.time+@start_time)
        else

            his = Room.get_his_data(state)
            Proto.Room.send_end_games(state.pids,his)

            Enum.each(state.order_list, fn(id)->
                History.save(id, his)
            end)

            send(self(),:stop)

            RoomManager.close_room(state.id)
            put_in(state.state,:end_game)
        end
    end


    defp cross_round(_,pos1,pos1) do
        false
    end

    defp cross_round(state,pos1,pos2) do
        pos1 = rem(pos1 + 1,length(state.order_list))
        case Enum.at(state.order_list, pos1) do
        nil ->
            cross_round(state,pos1,pos2)
        id ->
            if id == state.round_host_id do
                true
            else
                cross_round(state,pos1,pos2)
            end
        end
    end

    defp next_player(state) do
        playing_count = Enum.count(state.players, fn({_,x}) ->
             x.state == :playing
        end)

        if playing_count == 1 do
            [id|_] = get_live_ids(state)
            do_win(state,[id])
        else

            id = get_next_player_id(state)

            pos1 = state.players[state.cur_player_id].pos
            pos2 = state.players[id].pos

            state =


            if state.rounds == @max_round do
                ids = get_win_ids(state)
                do_win(state,ids)
            else
                Proto.Room.send_turn_id(state.pids,id, @play_time,state.rounds)
                state = put_in(state.cur_player_id,id)
                put_in(state.wait_time,state.time+@play_time)
            end

            if cross_round(state,pos1,pos2)  do
                put_in(state.rounds,state.rounds+1)
            else
                state
            end
        end
    end

    defp get_started_ids(state) do
        list = Enum.filter(state.players, fn({_,x}) ->
             x.started
        end)
        Enum.map(list,fn({id,_}) -> id end)
    end

    defp get_live_ids(state) do
        list = Enum.filter(state.players, fn({_,x}) ->
             x.state == :playing
        end)
        Enum.map(list,fn({id,_}) -> id end)
    end

    def get_win_ids(state) do
        list = Enum.filter(state.players, fn({_,x}) ->
             x.state == :playing
        end)

        list =
        case Enum.filter(list, fn({id,player}) -> is235(player.cards) end)  do
        [] ->
            Enum.map(list,fn({id,player}) ->
                value = get_card_value(player.cards)
                {value,id}
            end)
        list235 ->
            list = list -- list235
            v =  Enum.any?(list, fn({id,player})->
                {t,_,_,_} = get_card_value(player.cards)
                t != 10
            end)
            if v do
                Enum.map(list,fn({id,player}) ->
                    value = get_card_value(player.cards)
                    {value,id}
                end)
            else
                Enum.map(list235,fn({id,player}) ->
                    value = get_card_value(player.cards)
                    {value,id}
                end)
            end
        end

        {m,_} = Enum.max(list)

        List.foldl(list, [], fn({value,id},acc)->
            if value == m do
                [id|acc]
            else
                acc
            end
        end)
    end


    defp do_cmd(state,:give_up,_) do
        id  = state.cur_player_id
        Proto.Room.send_giveup_ack(state.pids,id)
        #state = put_in(state.playing_count,state.playing_count-1)
        state = put_in(state.players[id].state,:give_up)
        next_player(state)
    end

    defp do_cmd(state,:put_gold,[count]) do
        count = max(state.base_count,count)
        if (state.max_count < count) do
            state
        else
            id  = state.cur_player_id

            Proto.Room.send_put_gold(state.pids,id,count)

            state = put_in(state.base_count,count)

            count = get_real_count(state,id,count)
            last_count = state.players[id].put_count
            state = put_in(state.players[id].put_count,last_count++[count])

            next_player(state)
        end
    end

    # defp do_cmd(state,:put_all,_) do
    #     id  = state.cur_player_id
    #     Proto.Room.send_put_all(state.pids,id)
    #     state = put_in(state.players[id].show_all,true)
    #     next_player(state)
    # end

    defp do_cmd(state,:check,[other_id]) do
        id  = state.cur_player_id
        count = get_real_count(state,id,state.base_count)

        # Proto.Room.send_put_gold(state.pids,id,count)
        Proto.Room.send_put_gold(state.pids,id,state.base_count)

        last_count = state.players[id].put_count
        state = put_in(state.players[id].put_count,last_count++[count])

        #state = put_in(state.playing_count,state.playing_count-1)

        state =
        if check_win(state.players[id].cards,state.players[other_id].cards) do
            Proto.Room.send_check_result(state.pids,id,other_id,true)
            put_in(state.players[other_id].state,:lost)
        else
            Proto.Room.send_check_result(state.pids,id,other_id,false)
            put_in(state.players[id].state,:lost)
        end

        next_player(state)
    end

    defp do_cmd(_,_,_) do
        false
    end

    defp do_other_cmd(state,:show_card,id,_) do
        Proto.Room.send_show_card_ack(state.pids,id)
        t = get_card_type(state.players[id].cards)
        cards = [t|state.players[id].cards]
        Proto.Room.send_show_card_value(state.players[id].pid,cards)
        put_in(state.players[id].showed, true)
    end

    defp do_other_cmd(state,_,_,_) do
        state
    end

    defp get_real_count(state,id,0) do
        1
    end

    defp get_real_count(state,id,count) do
        if state.players[id].showed do
            count * 2
        else
            count
        end
    end




    def check_win(cards1,cards2) do
        value1 =  get_card_value(cards1)
        value2 =  get_card_value(cards2)

        if value1 > value2 do
            case value1 do
            {10,_,_,_} ->
                if is235(cards2) do
                    false
                else
                    true
                end
            _ ->
                true
            end
        else
            case value2 do
            {10,_,_,_} ->
                if is235(cards1) do
                    true
                else
                    false
                end
            _ ->
                false
            end
        end
    end

    defp is235(cards) do
        case get_card_value(cards) do
        {5,c3,c2,c1} ->
            (c3+2 == 5) and (c2+2 == 3) and (c1+2 == 2)
        _ ->
            false
        end
    end

    defp get_card_k(cards) do
        {t,_,_,_} = get_card_value(cards)
        case t do
        10 ->
            0
        9 ->
            1
        8 ->
            2
        7 ->
            3
        6 ->
            4
        _ ->
            5
        end
    end

    defp get_card_type(cards) do
        {t,_,_,_} = get_card_value(cards)
        t
    end

    defp get_card_value([c1,c2,c3]) do
        {h1,v1} = getHuaValue(c1)
        {h2,v2} = getHuaValue(c2)
        {h3,v3} = getHuaValue(c3)

        cond do
        (v1 == v2) and (v2 == v3) ->
            {10,v3,v2,v1}
        (h1 == h2) and (h2 == h3) ->
            cond do
            (v1+1 == v2) and (v2+1 == v3) ->
                {9,v3,v2,v1}
            (v1 == 0) and (v2 == 1) and (v3 == 12) ->
                {9,v3,v2,v1}
            true ->
                {8,v3,v2,v1}
            end
        (v1+1 == v2) and (v2+1 == v3) ->
            {7,v3,v2,v1}
        (v1 == 0) and (v2 == 1) and (v3 == 12) ->
            {7,v3,v2,v1}
        (v1 == v2) ->
            {6,v1,v1,v3}
        (v2 == v3) ->
            {6,v2,v2,v1}
        true ->
            {5,v3,v2,v1}
        end
    end


    defp getHuaValue(card) do
        {rem(card-1,4),div(card-1,4)}
    end

end
