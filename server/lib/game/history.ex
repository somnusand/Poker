
require Tools

defmodule History  do
    @max_count 5
    @max_all_game_count 1

    def start() do
        GenServer.start(__MODULE__,nil,[name: __MODULE__])
    end

    def stop() do
        GenServer.stop(__MODULE__)
    end

    def save(id,data) do
        GenServer.cast(__MODULE__,{:save,id,data})
    end

    def load(id) do
        GenServer.call(__MODULE__,{:load,id})
    end

    def save_game(data) do
        GenServer.call(__MODULE__,{:save_game,data})
    end

    def load_game(game_id) do
        GenServer.call(__MODULE__,{:load_game,game_id})
    end


# gen server
    use GenServer

    def init(_) do

        MapDB.db_table(:history)
        MapDB.db_table(:his_game)
            
        state = %{}
        {:ok, state}
    end

    def handle_call({:load,id},_,state) do

        reply =
        case MapDB.dirty_read(:history,id) do
        nil ->
            []
        his ->
            his.datas
        end

        {:reply,reply,state}
    end

    def handle_call({:save_game,data},_,state) do
        id  = DataBase.new_id(:his_game)

        if id > @max_all_game_count do
            MapDB.dirty_delete(:his_game,id-@max_all_game_count)
        end
        MapDB.dirty_write(:his_game,%{id: id, datas: data})
        {:reply,id,state}
    end

    def handle_call({:load_game,id},_,state) do

        reply =
        case MapDB.dirty_read(:his_game,id) do
        nil ->
            nil
        his ->
            his.datas
        end

        {:reply,reply,state}
    end


    def handle_call(params,_from,state) do
        Tools.log({:handle_call,params})
        {:reply,nil,state}
    end


    def handle_cast({:save,id,data},state) do

        datas =
        case MapDB.dirty_read(:history,id) do
        nil ->
            []
        his ->
            if length(his.datas) >= @max_count do
                Enum.take(his.datas, @max_count - 1)
            else
                his.datas
            end
        end

        MapDB.dirty_write(:history,%{id: id, datas: [data|datas]})

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
        Server.restart_server(History)

        Tools.log(reason)
        :ok
    end

end
