require Tools



defmodule TcpServer do
	@used_time_out true
	@time_out_time 60

# ---  tcp listen  ---
#
	def start() do
		spawn fn -> accept(8178) end
	end

	def stop() do
	end

	def accept(port) do
	  	{:ok, socket} = :gen_tcp.listen(port,
	                    [:binary, packet: 2, active: true, reuseaddr: true])

	  	Tools.log("tcp server started.")

	  	loop_acceptor(socket)
	end

	defp loop_acceptor(socket) do
	  	{:ok, client} = :gen_tcp.accept(socket)

	  	#IO.puts "accepted socket"
	  	pid = start_process(client)
	  	:gen_tcp.controlling_process(client,pid)

		loop_acceptor(socket)
	end

	def cast(pid,fun) do
        GenServer.cast(pid,{:cast,fun})
    end

	def call(pid,fun) do
        GenServer.call(pid,{:call,fun})
    end

	def stop(pid) do
        GenServer.cast(pid,:stop)
    end

# --- client link server logic ---
#

	use GenServer

	defp start_process(socket) do
		case GenServer.start(__MODULE__,socket) do
		{:ok,pid} ->
			pid;
		_ ->
			nil
		end
	end

	def init(socket) do
		#Tools.log(Server.User.__info__(:functions))
		state = %{class: :tcp_server,socket: socket, time_out: @time_out_time}

		if @used_time_out do
			Process.send_after self, :tick, 1000
		end

		{:ok, state}
	end



	def handle_call({:call,fun},_from,state) do
		{reply,state} = fun.(state)
		{:reply,reply,state}
	end

	def handle_call(params,_from,state) do
		Tools.log({:handle_call,params})
		{:reply,nil,state}
	end

	def handle_cast({:cast,fun},state) do
		state = fun.(state)
		{:noreply,state}
	end

	def handle_cast(:stop,state) do
		{:stop, :normal, state}
	end

	def handle_cast(params,state) do
		Tools.log({:handle_cast,params})
		{:noreply, state}
	end


	def handle_info(:stop,state) do
		{:stop, :normal, state}
	end

	def handle_info(:stop_by_switch,state) do
		state = put_in(state.on_closed, nil)
		{:stop, :normal, state}
	end


	def handle_info({:tcp,_,data},state) do
		#Tools.log({:recived,data})

		state =
		case Proto.on_message(state,data) do
		newState = %{class: :tcp_server} ->
			newState
		_ ->
			state
		end

		state = put_in(state.time_out,@time_out_time)

		{:noreply, state}
	end

	def handle_info({:tcp_closed,socket},state) do
		state =
			if state.socket == socket do
				Tools.log("do close socket")
				%{state | :socket => nil}
			else
				Tools.log("close socket outtime")
				state
			end

		send(self(),:stop)

		{:noreply, state}
	end

	def handle_info({:client,data},state) do
		case state.socket do
		nil ->
			:ok
		_ ->
			:gen_tcp.send(state.socket,data)
		end

		#Tools.log({:send,data})

		{:noreply, state}
	end

	def handle_info(:tick,state) do

		state = put_in(state.time_out, state.time_out - 1)

		if state.time_out < 0 do
			send(self(),:stop)
		else
			Process.send_after self, :tick, 1000
		end

		{:noreply, state}
	end

	def handle_info(params,state) do

		Tools.log({:handle_info,params})

		{:noreply, state}
	end

	def terminate(reason, state) do
		#info = :erlang.get_stacktrace()
		#Tools.log(info)

		case Map.get(state,:on_closed) do
		nil ->
			#Tools.log("nothing")
			:ok;
		fun ->
			#Tools.log("on_closed")
			fun.(state)
		end
		case reason do
		:normal ->
			:ok
		_ ->
			Tools.log(reason)
			:ok
		end
	end

end
