
require Tools

defmodule G do
	use GenServer

	def start() do
		GenServer.start(__MODULE__,nil,[name: :g_values])

		{:ok, binary} = File.read("res/ver")
		vers = String.split(binary, ",")
		vers = Enum.map(vers, fn(v)->
			Tools.to_int(v)
		end)
		put(:res_ver,vers)

		files = [
			"lua",
			"luabase",
			"effect",
			"3d",
			"ogg",
			"res",
			"ui",
		]
		List.foldl(files, 0, fn(name,acc)->
			{:ok, binary} = File.read("res/#{name}")
			put(acc,binary)
			acc + 1
		end)

		{:ok, binary} = File.read("res_ios/ver")
		vers = String.split(binary, ",")
		vers = Enum.map(vers, fn(v)->
			Tools.to_int(v)
		end)
		put(:res_ver_ios,vers)

		List.foldl(files, 0, fn(name,acc)->
			{:ok, binary} = File.read("res_ios/#{name}")
			put(acc+100,binary)
			acc + 1
		end)
	end

	def stop() do

    end

	def get(key) do
		get(key,nil)
	end

	def get(key,defValue) do
		GenServer.call(:g_values,{:get,key,defValue})
	end

	def put(key,value) do
		GenServer.cast(:g_values,{:put,key,value})
	end

	def init(_) do

		Tools.log("global value server[G] started.")

		{:ok, %{}}
	end

	def handle_call({:get,key,defValue},_from,state) do
		{:reply,Map.get(state,key,defValue),state}
	end

	def handle_cast({:put,key,value},state) do
		{:noreply, Map.put(state,key,value)}
	end

	def handle_cast(params,state) do
		Tools.log({:error,:handle_cast,params})
		{:noreply, state}
	end

	def handle_info(params,state) do
		Tools.log({:handle_info,params})
		{:noreply, state}
	end

	def terminate(reason, _state) do
        #info = :erlang.get_stacktrace()
        #Tools.log(info)
        Server.restart_server(G)

        Tools.log(reason)
        :ok
    end


end
