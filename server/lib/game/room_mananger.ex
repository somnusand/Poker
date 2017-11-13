
require Tools



defmodule RoomManager do
    @max_count 10000

    def new(id,params) do
        room = get_user_room(id)

        if room == nil do
            create_room(id,params)
        else
            room
        end
    end

    def get_user_room(id) do
        GenServer.call(__MODULE__,{:get_user_room,id})
    end

    def find(id) do
        GenServer.call(__MODULE__,{:get_room,id})
    end

    def get_user_room_id(id) do
        GenServer.call(__MODULE__,{:get_user_room_id,id})
    end

    def enter_room(id,room_id,pid) do
        GenServer.cast(__MODULE__,{:enter_room,id,room_id,pid})
    end

    def quit_room(id,room_id) do
        GenServer.cast(__MODULE__,{:quit_room,id,room_id})
    end

    defp create_room(id,params) do
        GenServer.call(__MODULE__, {:new_room,id,params})
    end

    def close_room(id) do
        GenServer.cast(__MODULE__,{:close_room,id,false})
    end

    def close_room_force(id) do
        id = rem(id,@max_count)
        GenServer.cast(__MODULE__,{:close_room,id,true})
    end

    def get_game_count() do
        :mnesia.table_info(:room_info, :size)
    end

    def get_room_info(room_id) do
        GenServer.call(__MODULE__,{:get_room_info,room_id})
    end

    def start() do
		GenServer.start(__MODULE__,nil,[name: __MODULE__])
	end

    def stop() do
	end

#-- GenServer
    require Record
    Record.defrecord :room_info, id: 0, key: 0, host_id: 1234567, pid: nil, params: %{}, players: []
    Record.defrecord :player_room, id: 1235678, pid: nil, room_id: 12345678, room_pid: nil

    use GenServer

    def init(_) do
        #Tools.log(Server.User.__info__(:functions))

        <<a::64, b::64, c::64>> = :crypto.strong_rand_bytes(24)
        :rand.seed(:exs64, {a,b,c})

        Tools.mem_table(room_info)
        Tools.mem_table(player_room)

        state = %{max_id: 0}



        {:ok, state}
    end

    defp seach_id(id) do
        seach_loop_id(id+1,id)
    end

    defp seach_loop_id(id,id) do
        nil
    end

    defp seach_loop_id(@max_count,end_id) do
        seach_loop_id(0,end_id)
    end

    defp seach_loop_id(n,end_id) do
        if DataBase.dirty_has_key(:room_info,n) do
            seach_loop_id(n+1,end_id)
        else
            n
        end
    end


    def handle_call({:new_room,id,params}, {pid,_}, state) do
        room_id = seach_id(state.max_id)

        key = :rand.uniform(9) * 10 + :rand.uniform(9)
        key_room_id = room_id + key * @max_count

        room_pid = RoomMax3.start(room_id,key_room_id,id,params)
        # case params.type do
        # 0 ->
        #     RoomLai.start(room_id,key_room_id,id,params)
        # 1 ->
        #     RoomXuan.start(room_id,key_room_id,id,params)
        # 2 ->
        #     RoomLai_1.start(room_id,key_room_id,id,params)
        # _ ->
        #     nil
        # end

        if room_pid == nil do
            {:reply,nil,state}
        else
            #Tools.log(room_id)
            case room_id do
            nil ->
                {:reply,nil,state}
            _ ->
                DataBase.dirty_write(room_info(id: room_id,
                                    key: key,
                                    host_id: id, pid: room_pid, params: params, players: [id]))

                DataBase.dirty_write(player_room(id: id, pid: pid, room_id: key_room_id, room_pid: room_pid))

                state = put_in(state.max_id,room_id)

                reply = %{
                    id: key_room_id,
                    pid: room_pid
                }

                {:reply,reply,state}
            end
        end
    end

    def handle_call({:get_room_info,room_id},_from,state) do

        key = div(room_id,@max_count)
        room_id = rem(room_id,@max_count)

        reply =
        case DataBase.dirty_read(:room_info,room_id) do
        nil ->
            nil
        room ->
            if room_info(room,:key) == key do
                pid = room_info(room, :pid)
                %{
                    id:  room_id + key * @max_count,
                    players: room_info(room,:players)
                }
            else
                nil
            end
        end

        {:reply, reply, state}
    end

    def handle_call({:get_user_room,id},_from,state) do
        reply =
        case DataBase.dirty_read(:player_room,id) do
        nil ->
            nil
        room ->
            room_id = player_room(room, :room_id)
            room_pid  = player_room(room, :room_pid)
            %{
                id:  room_id,
                pid: room_pid
            }
        end

        {:reply, reply, state}
    end

    def handle_call({:get_user_room_id,id},_from,state) do
        reply =
        case DataBase.dirty_read(:player_room,id) do
        nil ->
            0
        room ->
            player_room(room, :room_id)
        end

        {:reply, reply, state}
    end


    def handle_call({:get_room,room_id},_from,state) do

        key = div(room_id,@max_count)
        room_id = rem(room_id,@max_count)

        reply =
        case DataBase.dirty_read(:room_info,room_id) do
        nil ->
            nil
        room ->
            if room_info(room,:key) == key do
                pid = room_info(room, :pid)
                %{
                    id:  room_id + key * @max_count,
                    pid: pid
                }
            else
                nil
            end
        end

        {:reply, reply, state}
    end

    def handle_call(params,_from,state) do
        Tools.log({:handle_call,params})
        {:reply,nil,state}
    end

    def handle_cast({:enter_room,id,room_id,pid}, state) do
        case DataBase.dirty_read(:room_info,room_id) do
        nil ->
            nil
        room ->
                players   = room_info(room, :players)
                players   = [id|players]
                players = Enum.uniq(players)
                DataBase.dirty_write(room_info(room, players: players))

                key = room_info(room, :key)

                room_pid  = room_info(room, :pid)
                key_room_id = room_id + key * @max_count

                DataBase.dirty_write(player_room(id: id,  pid: pid, room_pid: room_pid,room_id: key_room_id))
        end

        {:noreply,state}
    end

    def handle_cast({:quit_room,id,room_id},state) do
        case DataBase.dirty_read(:player_room,id) do
        nil ->
            nil
        p_room ->


            if room_id == player_room(p_room,:room_id) do

                key = div(room_id,@max_count)
                room_id = rem(room_id,@max_count)

                case DataBase.dirty_read(:room_info,room_id) do
                nil ->
                    nil
                room ->
                    if room_info(room, :key) == key do
                        players   = room_info(room, :players)
                        players = List.delete(players, id)
                        DataBase.dirty_write(room_info(room, players: players))
                    else
                        nil
                    end
                end
                DataBase.dirty_delete(:player_room,id)
            else
                nil
            end
        end
        {:noreply, state}
    end

    def handle_cast({:close_room,id,force},state) do

        #key = div(id,@max_count)
        #id = rem(id,@max_count)

        case DataBase.dirty_read(:room_info,id) do
        nil ->
            #Tools.log({"no room",id})
            nil
        room ->
            #if room_info(room, :key) == key do

            DataBase.dirty_delete(:room_info,id)
            Enum.each(room_info(room,:players),fn(x)->
                #Tools.log({"delete",x})
                DataBase.dirty_delete(:player_room,x)
            end)
            if force do
                room_pid = room_info(room,:pid)
                send(room_pid,:force_stop)
            end
            #else
            #    Tools.log({"room key is not",id})
            #    nil
            #end
        end
        {:noreply, state}
    end

    def handle_cast(params,state) do
        Tools.log({:handle_cast,params})
        {:noreply, state}
    end

    def handle_info(params,state) do

        Tools.log({:handle_info,params})

        {:noreply, state}
    end

    def terminate(reason, _state) do
        #info = :erlang.get_stacktrace()
        #Tools.log(info)
        Server.restart_server(RoomManager)

        Tools.log(reason)
        :ok
    end

end
