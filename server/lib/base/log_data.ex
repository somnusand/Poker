
require Tools

defmodule LogData do
	use GenServer

	def start() do
		GenServer.start_link(__MODULE__,nil,[name: __MODULE__])
	end

	def stop() do

    end

	def log(data) do
		#Tools.log(data)
		GenServer.cast(__MODULE__,{:log,data})
	end

	def log_day_add(type) do
		GenServer.cast(__MODULE__,{:log_day_add,type,1})
	end

	def log_day_add(type,value) do
		GenServer.cast(__MODULE__,{:log_day_add,type,value})
	end

	def log_day_id(type,value) do
		GenServer.cast(__MODULE__,{:log_day_id,type,value})
	end


	def init(_) do
		MapDB.db_table(:day_info)
		MapDB.db_table_order(:day_info_his)

		Process.send_after self, :tick, 5000

		day_info_date =
		case :mnesia.dirty_last(:day_info_his) do
		:'$end_of_table' ->
		 	{date,_} = :erlang.localtime()
		 	date
		date ->
		 	 Tools.inc_date(date)
		end

		Tools.log(day_info_date)

		Tools.log("LogData server started.")

		{:ok, %{ day_info_date: day_info_date } }
	end

	def handle_call(_,_from,state) do
		{:reply,:ok,state}
	end

    def handle_cast({:log,data},state) do
		Tools.log({:log,data})
		table = elem(data, 0)
		id = DataBase.new_id(table)
		data = put_elem(data, 1, id)
		DataBase.dirty_write(data)
		Tools.log(data)
		{:noreply, state}
	end

	def handle_cast({:log_day_add,data,value},state) do
		{date,_} = :erlang.localtime()
		t = MapDB.dirty_read(:day_info, date, %{id: date})
		t =
		case t[data] do
		nil ->
			Map.put_new(t, data, value)
		old_value ->
			Map.put(t, data, value+old_value)
		end
		MapDB.dirty_write(:day_info, t)
		{:noreply, state}
	end

	def handle_cast({:log_day_id,data,id},state) do
		{date,_} = :erlang.localtime()
		t = MapDB.dirty_read(:day_info, date, %{id: date})
		t =
		case t[data] do
		nil ->
			Map.put_new(t, data, [id])
		old_value ->
			ids =
			if Enum.member?(old_value,id) do
				old_value
			else
				[id|old_value]
			end
			Map.put(t, data, ids)
		end
		MapDB.dirty_write(:day_info, t)
		{:noreply, state}
	end


	def handle_cast(params,state) do
		Tools.log({:error,:handle_cast,params})
		{:noreply, state}
	end


	def handle_info(:tick, state) do
		{date,_} = :erlang.localtime()
		state =
		if state.day_info_date >= date do
			state
		else
			data = CmdServer.get_day_info(state.day_info_date)
			MapDB.dirty_write(:day_info_his, data, state.day_info_date)
			#Tools.log({state.day_info_date, data})
			put_in(state.day_info_date, date)
		end


		Process.send_after self, :tick, 5000
		{:noreply, state}
	end

	def handle_info(params,state) do
		Tools.log({:handle_info,params})
		{:noreply, state}
	end

	def terminate(reason, _state) do
        #info = :erlang.get_stacktrace()
        #Tools.log(info)
        Server.restart_server(LogData)

        Tools.log(reason)
        :ok
    end

end
