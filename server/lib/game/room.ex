require Tools
use Bitwise

defmodule Room do
    @player_count 4

    @off_close_time 60000

    @time_dis_room 30

    @tick 1000
    @error_create_room "创建房间失败"
    @error_enter_room_full   "房间已满"
    @error_enter_room_start "游戏已经开始"
    @error_enter_room_no "房间不存在"
    @error_enter_room "未知错误"
    @error_room_no_enough "钻石不足"
    @error_enter_room_ip "相同IP不能进入"

    @flag_ip 1


    def get_card_count(params) do
        # count = div(params.round_count + 7,8)
        # if params.player_count == 1 do
        #     count * 4
        # else
        #     count
        # end
        4
    end

    def get_user_info(state,id) do
        case MapDB.dirty_read(:user,id) do
        nil ->
            :ok
        data ->
            Proto.Room.get_user_info_ack(
                data.id,
                data.name,
                "",
                Map.get(data, :game_count, 0),
                Map.get(data, :game_win_count, 0),
                data.sex,
                data.head,
                "")
        end
        state
    end

    def create_room(state,params) do

        # if  rem(params.round_count,4) != 0  do
        if false do
            Proto.Room.create_error(@error_create_room)
            state
        else
            card_count = get_card_count(params)

            if card_count > state.user.card_count do
                Proto.Room.create_error(@error_room_no_enough)
                state
            else
            #params = put_in(params.round_count,1)

                case RoomManager.new(state.user.id,params) do
                nil ->
                    Proto.Room.create_error(@error_create_room)
                    state
                room ->
                    Proto.Room.create_ack(room.id)
                    Map.put(state,:room, room)
                end
            end
        end
    end

    def enter(state,id) do
        #Tools.log("....step1")
        #case state[:room] do
        #nil ->
            case RoomManager.find(id) do
            nil ->
                #Tools.log("....step2")
                Proto.Room.enter_error(@error_enter_room_no)
                state
            room ->
                #Tools.log("....step3")
                user = state.user
                case GenServer.call(room.pid,
                    {:enter,user.id,user.name,user.head,user.sex,user.ip}) do
                true ->
                    Map.put(state,:room, room)
                :full ->
                    Proto.Room.enter_error(@error_enter_room_full)
                    state
                :start ->
                    Proto.Room.enter_error(@error_enter_room_start)
                    state
                :has_ip ->
                    Proto.Room.enter_error(@error_enter_room_ip)
                    state
                _ ->
                    Proto.Room.enter_error(@error_enter_room)
                    state
                end
            end
        #room ->

        #    GenServer.call(room.pid,{:enter,state.user.id,state.user.name,nil})
        #    state
        #end
    end

    def get_room(state) do
        room = RoomManager.get_user_room(state.user.id)
        if room == nil do
            Proto.Room.get_room_ack(0)
            state
        else
            Proto.Room.get_room_ack(room.id)
            Map.put(state,:room, room)
        end
    end

    def cancel_tuoguan(state) do
        case state[:room] do
        nil ->
            state
        room ->
            GenServer.cast(room.pid,{:cancel_tuoguan,state.user.id})
            state
        end
    end

    def voice(state,value) do
        case state[:room] do
        nil ->
            state
        room ->
            fun = fn(room_state) ->
                Proto.Room.send_voice_ack(room_state.pids,state.user.id,value)
                room_state
            end
            GenServer.cast(room.pid,{:cast,fun})
            state
        end
    end

    def quit(state) do
        case state[:room] do
        nil ->
            Tools.log("quit1")
            Proto.Room.quit_room()
            state
        room ->
            Tools.log("quit2")
            case GenServer.call(room.pid,{:quit,state.user.id}) do
            true ->
                put_in(state.room,nil)
            _ ->
                state
            end
        end
    end

    def start(state) do
        case state[:room] do
        nil ->
            :ok
        room ->
            GenServer.cast(room.pid,{:start,state.user.id})
        end
        state
    end

    def player_ready(state) do
        case state[:room] do
        nil ->
            :ok
        room ->
            GenServer.cast(room.pid,{:start,state.user.id})
        end
        state
    end


    def put_cmd(state,cmd,params) do
        case state[:room] do
        nil ->
            :ok
        room ->
            GenServer.cast(room.pid,{:put_cmd,cmd,state.user.id,params})
        end
        state
    end


    def put_cards(state,cards,supper) do
        case state[:room] do
        nil ->
            :ok
        room ->
            GenServer.cast(room.pid,{:put_cards,state.user.id,cards,supper})
        end
        state
    end


    defp is_menber(state,id) do
        Enum.any?(state.players, fn({player_id,_}) ->
            id == player_id
        end)
    end

    def quit_vote_yes(state) do
        case state[:room] do
        nil ->
            :ok
        room ->
            fun = fn(room_state) ->
                user_id = state.user.id
                if is_menber(room_state,user_id) do
                    {has_vote,vote_time} =
                    case room_state[:vote] do
                    nil ->
                        {false,0}
                    vote ->
                        if vote.fun do
                            {true,0}
                        else
                            now = Tools.get_now()
                            {false,60-now+vote.time}
                        end
                    end

                    #Tools.log(vote_time)

                    cond do
                    vote_time >= 1 ->
                        Proto.Room.send_quit_voto_time(room_state.players[user_id].pid,vote_time)
                        room_state
                    has_vote ->
                        vote = room_state.vote
                        ids  = Enum.uniq([user_id|vote.ids])
                        vote = put_in(vote.ids, ids)

                        count = length(ids)

                        if count >= get_player_count(room_state) do


                            if vote.fun do
                                vote_end(room_state)

                                Process.cancel_timer(vote.fun)

                                vote = put_in(vote.fun, nil)
                                Map.put(room_state, :vote, vote)
                            else
                                room_state
                            end
                        else
                            now = Tools.get_now()
                            time = @time_dis_room - (now - vote.time)
                            Proto.Room.send_quit_voto(room_state.pids,time,ids)
                            Map.put(room_state, :vote, vote)
                        end
                    true ->
                        now = Tools.get_now()
                        time_fun = fn(r_state) ->
                            case r_state[:vote] do
                            nil ->
                                r_state
                            vote ->
                                vote_end(r_state)

                                vote = put_in(vote.fun, nil)
                                Map.put(r_state, :vote, vote)
                            end
                        end
                        fun_id = Process.send_after(self(),{:cast,time_fun},@time_dis_room*1000)
                        vote = %{ :time => now, :fun => fun_id, :time => now, :ids => [user_id]}

                        Proto.Room.send_quit_voto(room_state.pids,@time_dis_room,[user_id])

                        Map.put(room_state, :vote, vote)
                    end
                else
                    room_state
                end
            end
            GenServer.cast(room.pid,{:cast,fun})
        end
        state
    end

    def off_line(state) do
        #Tools.log({"off line",state.user.id})
        case state[:room] do
        nil ->
            :ok
        room ->
            fun = fn(room_state) ->
                user_id = state.user.id
                case room_state.players[user_id] do
                nil ->
                    room_state
                _ ->
                    room_state = put_in(room_state.players[user_id].off_line, true)
                    room_state = put_in(room_state.players[user_id].started, false)

                    all = Enum.all?(room_state.players, fn({_,player})->
                        player.off_line
                    end)

                    pids = List.delete(room_state.pids, room_state.players[user_id].pid)
                    Proto.Room.send_offline_player(pids,user_id)

                    if all do
                        time_fun = fn(r_state) ->

                            all = Enum.all?(r_state.players, fn({_,player})->
                                player.off_line
                            end)


                            if all do
                                if r_state.game_count > 0 do
                                    his = get_his_data(r_state)

                                    Enum.each(r_state.order_list, fn(id)->
                                        History.save(id, his)
                                    end)
                                end

                                RoomManager.close_room(r_state.id)
                                send(self(),:stop)
                            end
                            r_state
                        end
                        Process.send_after(self(),{:cast,time_fun},@off_close_time)
                    end
                    room_state
                end
            end
            GenServer.cast(room.pid,{:cast,fun})
        end
        state
    end

    def vote_end(room_state) do
        if room_state.game_count > 0 do
            his = get_his_data(room_state)

            Enum.each(room_state.order_list, fn(id)->
                History.save(id, his)
            end)
        end

        Proto.Room.send_quit_voto_end(room_state.pids,true)
        RoomManager.close_room(room_state.id)
        send(self(),:stop)
    end

    def get_his_data(state) do
        datas = Enum.map(state.players, fn({id,player})->
            %{
                id: id,
                name: player.name,
                score: player.gold,
                values: Tuple.to_list(player.his_values),

            }
        end)

        {{y,m,d},{h,s,_}} = :erlang.localtime()
        %{
            time: "#{y}-#{m}-#{d} #{h}:#{s} ",
            round: state.game_count,
            max_count: state.game_max_count,
            room_id: state.room_id,
            data: datas,
            game_id: 0
        }
    end

    def quit_vote_no(state) do
        case state[:room] do
        nil ->
            :ok
        room ->
            fun = fn(room_state) ->
                case room_state[:vote] do
                nil ->
                    room_state
                vote ->
                    if vote.fun do
                        Process.cancel_timer(vote.fun)

                        Proto.Room.send_quit_voto_end(room_state.pids,false)

                        #RoomManager.close_room(room_state.id)
                        #send(self(),:stop)

                        vote = put_in(vote.fun, nil)
                        Map.put(room_state, :vote, vote)
                    else
                        room_state
                    end
                end
            end
            GenServer.cast(room.pid,{:cast,fun})
        end
        state
    end

    def show_emotion(state,index) do
        case state[:room] do
        nil ->
            :ok
        room ->
            fun = fn(room_state) ->
                Proto.Room.send_show_emotion_ack(
                        room_state.pids,
                        state.user.id,
                        index)
                room_state
            end
            GenServer.cast(room.pid,{:cast,fun})
        end
        state
    end

    def show_txt_msg(state,msg) do
        case state[:room] do
        nil ->
            :ok
        room ->
            fun = fn(room_state) ->
                Proto.Room.send_show_txt_msg_ack(
                        room_state.pids,
                        state.user.id,
                        msg)
                room_state
            end
            GenServer.cast(room.pid,{:cast,fun})
        end
        state
    end


    # def get_history(state) do
    #     case History.load(state.user.id) do
    #     [a|_] ->
    #         Proto.Room.show_history(a)
    #     _ ->
    #         Proto.Room.show_history(%{
    #             time: "",
    #             round: 0,
    #             max_count: 0,
    #             room_id: 0,
    #             data: [],
    #             game_id: 0
    #         })
    #     end
    #     state
    # end

    def get_history(state) do

        # data = [
        #     "test1",
        #     "test2",
        #     "test3",
        #     "test4",
        # ]
        # a = %{
        #     game_id: 1,
        #     time: "2014-3-40 12:00:00",
        #     round: 2,
        #     max_count: 4,
        #     room_id: 310032,
        #     game_id: 23,
        #     names: data,
        #     scores: [1,2,3,4]
        # }
        # list = [a,a,a,a,a]

        list = History.load(state.user.id)
        list = Enum.map(list, fn(a)->
            names = Enum.map(a.data, fn(d)->
                d.name
            end)
            scores = Enum.map(a.data, fn(d)->
                d.score
            end)
            %{
                game_id: a.game_id,
                time: a.time,
                round: a.round,
                max_count: a.max_count,
                room_id: a.room_id,
		        names: names,
                scores: scores,
            }
        end)
        Proto.Room.show_history_ex(list)
        state
    end



    def init_replay(state) do

        cards = Enum.map(state.order_list, fn(id)->
            %{
                datas: state.players[id].cards
            }
        end)

        replay = %{
            cards: cards,
            card_count: length(state.cards),
            pi_card: state.lai_pi,
            steps: []
        }
        Map.put(state, :replay, replay)
    end

    def put_replay(state,cmd,id,card) do
        type =
        case cmd do
        :get_card ->
            0
        :put_card ->
            1
        :put_an_gang ->
            3
        :put_self_gang ->
            3
        :put_gang ->
            3
        :put_peng ->
            2
        :hu ->
            4
        _ ->
            nil
        end

        if type == nil do
            state
        else
            data =
            if id == 0 do
                type * 16
            else
                type * 16 + state.players[id].pos + 1
            end
            datas = [data,card|state.replay.steps]
            put_in(state.replay.steps, datas)
        end
    end

    def show_replay(state,id) do
        case History.load_game(id) do
        nil ->
            Proto.Room.show_replay_error("比赛不存在")
            state
        data ->
            Proto.Room.show_replay_ack(data)
            #Map.put(state,:replay,data)
            state
        end
    end

    def get_replay_data(state,id,index) do
        case History.load_game(id) do
        nil ->
            Proto.Room.show_replay_error("比赛不存在")
        data ->
            #Tools.log({id,index,length(data.datas)})
            #Tools.log(data.datas)
            len = length(data.datas)
            game_data = Enum.at(data.datas,len-index)
            Proto.Room.get_replay_data_ack(index,game_data)
        end
        state
    end

    def save_game(state,his) do

        players = Map.values(state.players)
        players = Enum.map(players,fn(x)->
            %{
                id: x.id,
                name: x.name,
                sex: x.sex,
                head: x.head,
                ip: x.ip,
                started: x.started,
                offline: x.off_line
            }
        end)

        data = %{
            players: players,
    		room_params: state.game_params,
    		order: state.order_list,
    		game_count: state.game_count,
            datas: state.replays
        }
        game_id = History.save_game(data)
        Map.put(his, :game_id, game_id)
    end

    def cc_history_list(datas,[r|results],base) do
        datas = List.foldl(r, datas, fn(a,acc) ->
            Enum.map(acc, fn(d)->

                score = Map.get(a, d.id, 0) * base
                d = put_in(d.score,d.score+score)

                case a.type do
                :self_hu ->
                    cond do
                    score > 0 ->
                        put_in(d.self_win,d.self_win+1)
                    true ->
                        d
                    end
                :hu ->
                    cond do
                    score > 0 ->
                        put_in(d.win,d.win+1)
                    score < 0 ->
                        put_in(d.lost,d.lost+1)
                    true ->
                        d
                    end
                :gang ->
                    cond do
                    score > 0 ->
                        put_in(d.gang,d.gang+1)
                    true ->
                        d
                    end
                :an_gang ->
                    cond do
                    score > 0 ->
                        put_in(d.an_gang,d.an_gang+1)
                    true ->
                        d
                    end
                true ->
                    d
                end
            end)
        end)

        cc_history_list(datas,results,base)
    end

    def cc_history_list(datas,[],_) do
        datas
    end


    def cc_history(state) do
        datas =
        case state[:results] do
        nil ->
            []
        [] ->
            []
        _ ->
            base = state.game_params.base_score
            list = Enum.map(state.order_list, fn(id)->
                rounds = Enum.map(state.results, fn(r) ->
                    l = Enum.map(r,fn(a)->
                        Map.get(a, id, 0) * base
                    end)
                    Enum.sum(l)
                end)

                %{
                    id: id,
                    name: state.players[id].name,
        		    self_win: 0,
        		    win: 0,
        		    lost: 0,
        		    an_gang: 0,
        		    gang: 0,
                    score: 0,
                    head:  state.players[id].head,
                    rounds: rounds,
                }
            end)

            cc_history_list(list,state.results,state.game_params.base_score)
        end

        {{y,m,d},{h,s,_}} = :erlang.localtime()
        %{
            time: "#{y}-#{m}-#{d} #{h}:#{s} ",
            round: state.game_count,
            max_count: state.game_max_count,
            room_id: state.room_id,
            data: datas,
            game_id: 0,
        }
    end

    def get_end_cards(state) do
        Enum.map(state.order_list, fn(id)->
            player = state.players[id]
            cards = get_hu_cards(state,id)

            %{
                cur: cards,
                hold: player.hold_cards
            }
        end)
    end

    def get_end_cards(state,ids) do
        Enum.map(state.order_list, fn(id)->
            player = state.players[id]
            cards = get_hu_cards(state,id,ids)

            %{
                cur: cards,
                hold: player.hold_cards
            }
        end)
    end


    def check_flag(state,flag) do
        band(state.game_params.ex_param3,flag) != 0
    end

    def has_ip(state,ip) do
        if check_flag(state,@flag_ip) do
            Enum.any?(state.players, fn({_,player})->
                #Tools.log({player.ip,ip})
                player.ip == ip
            end)
        else
            false
        end
    end

    def get_player_count(state) do
        Enum.count(state.order_list, fn(id)->
            id != nil
        end)
    end

    def get_hu_cards(state,id) do
        get_hu_cards(state,id,[])
    end

    def get_hu_cards(state,id,hu_ids) do
        cards = state.players[id].cards

        if rem(length(cards),3) == 2 do
            if Enum.member?(cards, state.cur_card) do
                cards = cards -- [state.cur_card]
                [state.cur_card|cards]
            else
                cards
            end
        else
            #Tools.log(state.cur_card)
            if Enum.member?(hu_ids, id) do
                [state.cur_card|cards]
            else
                cards
            end
        end
    end

    def get_hu_cards(state) do
        Enum.map(state.order_list, fn(id)->
            %{
                datas: get_hu_cards(state,id)
            }
        end)
    end


    def send_turn(pid, id, time, pai, gangs) do
        Proto.Room.send_turn(pid, id, time, pai, gangs, [])
    end

    def send_turn(pid, id, time, pai, gangs,hus) do
        Proto.Room.send_turn(pid, id, time, pai, gangs, hus)
    end


    # power up
    def power_up(state) do
        case state[:room] do
        nil ->
            state
        room ->
            GenServer.cast(room.pid,{:power_up,state.user.id})
            state
        end
    end

end
