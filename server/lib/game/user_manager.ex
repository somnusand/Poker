
require Tools

defmodule UserManager  do

    import User, only: :macros

    import Record
    defrecord :user_id, acc_id: "", user_id: ""
    defrecord :online_user, id: "", pid: nil


    def start() do
        #Tools.db_table(user_id)
        User.init()

        Tools.db_table(user_id)
        Tools.mem_table(online_user)

        MapDB.db_table(:user)
        GenServer.start(__MODULE__,nil,[name: __MODULE__])
    end

    def change_card(id,count) do
        if Cfg.get_number(:is_test) == 1 do
            :ok
        else
            GenServer.cast(__MODULE__,{:change_card,id,count})
        end
    end

    def enable_user(id,value) do
        GenServer.cast(__MODULE__,{:enable_user,id,value})
    end

    def add_game_count(id,is_win) do
        GenServer.cast(__MODULE__,{:add_game_count,id,is_win})
    end


    def stop() do
        GenServer.stop(__MODULE__)
    end

    def save(data) do
        GenServer.cast(__MODULE__,{:save,data})
    end

    def load(acc_id) do
        case GenServer.call(__MODULE__,{:load,acc_id}) do
        {:pid,pid} ->
            User.exchange(pid)
        data ->
            data
        end
    end

    def getUserDailiInfo(id) do
        GenServer.call(__MODULE__,{:getUserDailiInfo,id})
    end

    def add_gold(id,gold) do
        GenServer.call(__MODULE__,{:add_gold,id,gold})
    end

    def send_gold(id,des,gold) do
        GenServer.call(__MODULE__,{:send_gold,id,des,gold})
    end


    def quit(id) do
        GenServer.cast(__MODULE__,{:quit,id,self()})
    end

    def get_online_count() do
        :mnesia.table_info(:online_user, :size)
    end

    def is_online(id) do
        case DataBase.dirty_read(:online_user,id) do
        nil ->
            false
        _ ->
            true
        end
    end

    def get_player_name(id) do
        case MapDB.dirty_read(:user,id) do
        nil ->
            ""
        data ->
            data.name
        end
    end

# gen server
    use GenServer

    def init(_) do

        #Process.send_after self, :tick, 2000

        #Tools.log(Server.User.__info__(:functions))
        state = %{}
        {:ok, state}
    end



    def handle_call( {:send_gold,src,id,gold},_,state) do
        reply =
        case MapDB.dirty_read(:user,id) do
        nil ->
            false
        data ->
            case DataBase.dirty_read(:online_user,id) do
            nil ->
                :ok
            user ->
                pid = online_user(user,:pid)
                Proto.User.send_change_card(pid,gold)
                User.cast(pid,fn(state)->
                     user = User.add_card(state.user,gold)
                     put_in(state.user, user)
                end)
            end

            data = User.add_card(data,gold)
            MapDB.dirty_write(:user, data)

            id = src
            gold = -gold
            case MapDB.dirty_read(:user,id) do
            nil ->
                :ok
            data ->
                case DataBase.dirty_read(:online_user,id) do
                nil ->
                    :ok
                user ->
                    pid = online_user(user,:pid)
                    Proto.User.send_change_card(pid,gold)
                    User.cast(pid,fn(state)->
                         user = User.add_card(state.user,gold)
                         put_in(state.user, user)
                    end)
                end

                data = User.add_card(data,gold)
                MapDB.dirty_write(:user, data)
            end

            CmdServer.log_gold(:send,src,id,gold)
            true
        end
        {:reply,reply,state}
    end




    def handle_call( {:add_gold,id,gold},_,state) do
        reply =
        case MapDB.dirty_read(:user,id) do
        nil ->
            Tools.log({id,gold})
            "无效id"
        data ->

            case DataBase.dirty_read(:online_user,id) do
            nil ->
                :ok
            user ->
                pid = online_user(user,:pid)
                Proto.User.send_change_card(pid,gold)
                User.cast(pid,fn(state)->
                     user = User.add_card(state.user,gold)
                     put_in(state.user, user)
                end)
            end

            data = User.add_card(data,gold)
            MapDB.dirty_write(:user, data)
            true
        end
        {:reply,reply,state}
    end
    def handle_call({:getUserDailiInfo,id},_,state) do
        reply =
        case MapDB.dirty_read(:user,id) do
        nil ->
            nil
        data ->
            #Tools.log({id,data})
            %{
                name: data.name,
                id: id,
                regTime: Map.get(data, :regTime, "未知"),
            }
        end
        {:reply,reply,state}
    end

    def handle_call({:load,user_info},{from,_},state) do

        acc_id =
        if is_integer(user_info) do
            user_info
        else
            user_info.acc_id
        end

        reply =
        case DataBase.dirty_read(:user_id,acc_id) do
        nil ->
            id = DataBase.new_id(:user_id) + 10000

            acc_id =
            if is_integer(user_info) do
                id
            else
                case user_info[:name] do
                nil ->
                    nil
                _ ->
                    acc_id
                end
            end

            if acc_id != nil do
                DataBase.write(user_id(acc_id: acc_id,user_id: id))

                user = User.new(user_info)

                if user.card_count > 0 do
                    CmdServer.log_gold( :reg, 0, id, user.card_count)
                end

                user = put_in(user.id, id)

                MapDB.dirty_write(:user,user)

                DataBase.dirty_write(online_user(id: id,pid: from))

                LogData.log_day_id(:new,user.id)

                user
            else
                nil
            end
        data ->

            id = user_id(data,:user_id)

            case DataBase.dirty_read(:online_user,id) do
            nil ->
                user = MapDB.dirty_read(:user,id)
                case Map.get(user, :enable, true) do
                false ->
                    nil
                _ ->
                    DataBase.dirty_write(online_user(id: id,pid: from))
                    user
                end
            ol_user ->
                DataBase.dirty_write(online_user(ol_user,pid: from))

                pid = online_user(ol_user,:pid)
                send(pid,:stop_by_switch)

                user = MapDB.dirty_read(:user,id)
                user
                #pid = online_user(ol_user,:pid)
                #{:pid,pid}
            end
        end

        {:reply,reply,state}
    end




    def handle_call(params,_from,state) do
        Tools.log({:handle_call,params})
        {:reply,nil,state}
    end

    def handle_cast( {:add_game_count,id,is_win},state) do
        case DataBase.dirty_read(:online_user,id) do
        nil ->
            #Tools.log("no onlie")
            :ok
        user ->
            #Tools.log(count)

            pid = online_user(user,:pid)

            User.cast(pid,fn(state)->
                 user = User.add_game(state.user,is_win)
                 #Tools.log(user.card_count)
                 put_in(state.user, user)
            end)
        end

        case MapDB.dirty_read(:user,id) do
        nil ->
            :ok
        user ->
            user = User.add_game(user,is_win)
            MapDB.dirty_write(:user, user)
        end

        {:noreply, state}
    end


    def handle_cast({:enable_user,id,value},state) do

        case MapDB.dirty_read(:user,id) do
        nil ->
            :ok
        user ->
            user = Map.put(user, :enable, value )
            MapDB.dirty_write(:user, user)

            if value == false do
                case DataBase.dirty_read(:online_user,id) do
                nil ->
                    :ok
                ol_user ->
                    pid = online_user(ol_user,:pid)
                    send(pid,:stop_by_switch)
                    DataBase.dirty_delete(:online_user,id)
                end
            end
        end

        {:noreply, state}
    end

    def handle_cast({:change_card,id,count},state) do


        case DataBase.dirty_read(:online_user,id) do
        nil ->
            #Tools.log("no onlie")
            :ok
        user ->
            #Tools.log(count)

            pid = online_user(user,:pid)
            Proto.User.send_change_card(pid,count)

            User.cast(pid,fn(state)->
                 user = User.add_card(state.user,count)
                 #Tools.log(user.card_count)
                 put_in(state.user, user)
            end)
        end

        case MapDB.dirty_read(:user,id) do
        nil ->
            :ok
        user ->

            CmdServer.log_gold( :used, id, 0, count)

            user = User.add_card(user,count)
            MapDB.dirty_write(:user, user)
        end

        {:noreply, state}
    end

    def handle_cast({:quit,id,pid},state) do
        case DataBase.dirty_read(:online_user,id) do
        nil ->
            :ok
        ol_user ->
            ol_pid = online_user(ol_user,:pid)
            if ol_pid == pid do
                DataBase.dirty_delete(:online_user,id)
            end
        end
        {:noreply, state}
    end

    def handle_cast({:save,data},state) do
        MapDB.dirty_write(:user,data)
        {:noreply, state}
    end

    def handle_cast(params,state) do
        Tools.log({:handle_cast,params})
        {:noreply, state}
    end


    def handle_info(:tick, state) do
        Enum.each(1..100, fn(i)->
			CmdServer.log_gold(:charge,i,0,100)
		end)
        Tools.log(:tick)
        Process.send_after self, :tick, 100
        {:noreply, state}
    end

    def handle_info(params,state) do

        Tools.log({:handle_info,params})

        {:noreply, state}
    end

    def terminate(reason, _state) do
        info = :erlang.get_stacktrace()
        Tools.log(info)

        Server.restart_server(UserManager)

        Tools.log(reason)
        :ok
    end

end
