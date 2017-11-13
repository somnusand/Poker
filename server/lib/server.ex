
require Tools

defmodule Server do
    @servers [
        Log,
        Cfg,
        DataBase,
        LogData,
        G,
        History,
        Account,
        UserManager,
        RoomManager,
        TcpServer,
        CmdServer,
    ]

    def init() do
        <<a::64, b::64, c::64>> = :crypto.strong_rand_bytes(24)
        :rand.seed(:exs64, {a,b,c})

        Process.register(self(), :main_server_pid)

        HTTPoison.start

        Enum.each(@servers,fn(mod)->
            apply(mod, :start, [])
        end)

        Tools.log(node())
    end

    def destroy() do
        servers = Enum.reverse(@servers)
        Enum.each(servers,fn(mod)->
            apply(mod, :stop, [])
        end)

        Tools.log("stop end.")
    end

    def stop() do
        send(:main_server_pid, :stop)
    end

    def restart_server(mod) do
        Process.send_after :main_server_pid, {:restart,mod}, 1000

        #send :main_server_pid, {:restart,mod}
    end

    def update() do
        receive do
        {:restart,mod} ->
            Tools.log({"restart",mod})
            apply(mod, :start, [])
            update()
        :stop ->
            Tools.log("start stop...")
            destroy()
        _ ->
            update()
        end
    end

end
