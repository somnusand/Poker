
require Tools

defmodule Log do
	use GenServer

	def start() do
		GenServer.start(__MODULE__,nil,[name: __MODULE__])
	end

	def stop() do

    end

	def log(str) do
		GenServer.cast(__MODULE__,{:log,str})
	end

	def init(_) do
        {:ok,io} = File.open("log.txt", [:write,:binary,:utf8,:delayed_write])
		{:ok, %{file: io}}
	end

	def handle_call(_,_from,state) do
		{:reply,:ok,state}
	end

    def handle_cast({:log,str},state) do
		IO.write(state.file, str)
		{:noreply, state}
	end

	def handle_cast(params,state) do
		Tools.log({:error,:handle_cast,params})
		{:noreply, state}
	end

	def handle_info(params,state) do
		Tools.log({:handle_info,params})
		{:noreply, state}
	end

end
