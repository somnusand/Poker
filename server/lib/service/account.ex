
require Tools

defmodule Account do
    @block_size 1024
# interface
# ----------------------------------------------------------
    def ver(state,v_id) do
        id = rem(v_id,10000)

        state =
        if v_id > 10000 do
            Map.put(state, :platform, :ios)
        else
            Map.put(state, :platform, :android)
        end

        url = Cfg.get_string(:ver)

        if  id >= Cfg.get_number(:ver) do
            if state.platform == :ios do
                vers = G.get(:res_ver_ios)

                if Cfg.get_number(:is_test) == 1 do
                    Proto.Account.ver_ack(1,url,vers)
                else
                    Proto.Account.ver_ack(2,url,vers)
                end
            else
                vers = G.get(:res_ver)
                Proto.Account.ver_ack(2,url,vers)
            end
        else
            Proto.Account.ver_ack(0, url,[])
        end
        state
    end

    def get_file(state,id,pos) do

        id  =
        if state.platform == :ios do
            id + 100
        else
            id
        end


        bin = G.get(id)
        len = byte_size(bin)
        if (len <= pos) do
            Proto.Account.get_file_ack(100, "")
        else
            Enum.each(0..3, fn(n)->
                send_pos = pos + (@block_size*n)
                if (len > send_pos) do
                    send_bin =
                    if len > send_pos + @block_size do
                        :binary.part(bin, send_pos, @block_size)
                    else
                        :binary.part(bin, send_pos, len-send_pos)
                    end
                    per = div((send_pos + @block_size)*100,len)
                    per = min(per,100)
                    Proto.Account.get_file_ack(per, send_bin)
                end
            end)
        end
        state
    end
	def get_file_ok(state,id, pos) do
        id  =
        if state.platform == :ios do
            id + 100
        else
            id
        end

        bin = G.get(id)
        len = byte_size(bin)
        send_pos = pos + (@block_size*4)
        if (len > send_pos) do
            send_bin =
            if len > send_pos + @block_size do
                :binary.part(bin, send_pos, @block_size)
            else
                :binary.part(bin, send_pos, len-send_pos)
            end
            per = div((send_pos + @block_size)*100,len)
            per = min(per,100)
            Proto.Account.get_file_ack(per, send_bin)
        end
        state
	end

    def login(state,name,pwd) do
        case GenServer.call(__MODULE__,{:login,name,pwd}) do
        {:ok,acc_id} ->
            Proto.Account.login_ok()
            Map.put(state,:acc_id,acc_id)
        {:error,Error} ->
            Proto.Account.login_fail(Error)
            state
        _ ->
            Proto.Account.login_fail("call timeout")
            state
        end
    end

    def register(state,name,pwd) do
        case GenServer.call(__MODULE__,{:register,name,pwd}) do
        {:ok,acc_id} ->
            Proto.Account.register_ok()
            Map.put(state,:acc_id,acc_id)
        {:error,Error} ->
            Proto.Account.register_fail(Error)
            state
        _ ->
            Proto.Account.register_fail("call timeout")
            state
        end
    end

    def get_gold_list(state,id,count) do
        ids =
        if id == 0 do
            CmdServer.find_log_dataids(state.user.id)
        else
            state.log_ids
        end

        subids = Enum.slice(ids, id, count)
        datas = CmdServer.get_log_datas(subids)

        Tools.log({subids,datas})

        Proto.Account.get_gold_list_ack(length(ids),id,datas)


        if id == 0 do
            Map.put_new(state, :log_ids, ids)
        else
            state
        end
    end


    def send_gold(state,id,gold,check) do
        cond do
        gold <= 0 ->
            Proto.Account.send_gold_fail("无效金额")
        state.user.card_count < gold ->
            Proto.Account.send_gold_fail("余额不足")
        true ->
            case MapDB.dirty_read(:user, id) do
            nil ->
                Proto.Account.send_gold_fail("玩家不存在")
            des ->
                if check do
                    Proto.Account.send_gold_check_ok(des.id,des.name,gold)
                else
                    case UserManager.send_gold(state.user.id,id,gold) do
                    true ->
                        Proto.Account.send_gold_ok()
                    _ ->
                        Proto.Account.send_gold_fail("充值失败")
                    end
                end
            end
        end
        state
    end

# server interface

    def start() do
        GenServer.start(__MODULE__,nil,[name: __MODULE__])
    end

    def stop() do

    end

# server DataBase
    require Record
    Record.defrecord :account, name: "", pwd: "", info: %{}


# gen server
    use GenServer

    def init(_) do
        Tools.db_table(account)



        state = %{}
        {:ok, state}
    end

    def handle_call({:login,name,pwd},_from,state) do
        reply =
        case DataBase.read(:account,name) do
        nil ->
            {:error,"user not exist"}
        account ->
            acc_pwd = account(account, :pwd)
            if acc_pwd == pwd do
                {:ok,name};
            else
                {:error,"password error"}
            end
        end
        {:reply,reply,state}
    end

    def handle_call({:register,name,pwd},_from,state) do
        reply =
        case DataBase.read(:account,name) do
        nil ->
            account = account(name: name, pwd: pwd)
            DataBase.write(account)
            {:ok,name}
        Account ->
            {:error,"user exist"}
        end
        {:reply,reply,state}
    end

    def handle_call(params,_from,state) do
        Tools.log({:handle_call,params})
        {:reply,nil,state}
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
        Tools.log(reason)
        :ok
    end

end
