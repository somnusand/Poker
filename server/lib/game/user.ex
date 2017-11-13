

require Tools

defmodule User do

    require Record
    Record.defrecord :wx_keys, key: :_, acc_id: :_

    def init() do
        Tools.db_table(wx_keys,[:acc_id])
    end

    def enter(state,acc_id) do
        case UserManager.load(acc_id) do
        nil ->
            state
        user ->
            login_ok_fun(state,user)
        end
    end

    def save_wx_key(key,acc_id) do
        #Tools.log({key,acc_id})
        fun = fn() ->
            case :mnesia.index_read(:wx_keys, acc_id, :acc_id) do
            [a] ->
                :mnesia.delete({:wx_keys, key})
            _ ->
                :ok
            end
            :mnesia.write(wx_keys(key: key, acc_id: acc_id))
        end
        :mnesia.transaction(fun)
        #Tools.log(ret)
    end


    def wx_login(state,key) do

        case DataBase.read(:wx_keys,key) do
        nil ->
            wx_loginFun(state,key)
        data ->

            acc_id = wx_keys(data,:acc_id)
            Proto.User.wx_id(acc_id)


            case UserManager.load(%{acc_id: acc_id}) do
            nil ->
                state
            user ->
                login_ok_fun(state,user)
            end
        end
    end


    def wx_loginFun(state,key) do
        #Tools.log(key)

        id   = "wx38d106cb4e490b50"
        code = "ace72bd9345edd88953dc1ae38e60966"


        req = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{id}&secret=#{code}&code=#{key}&grant_type=authorization_code"

        ret =
        case HTTPoison.get!(req) do
        {:error,msg} ->
            Tools.log({:net_error,msg})
            {:error,"网络错误"}
        data ->
            rec =  Poison.decode!(data.body)
            #Tools.log(rec)


            case rec["access_token"] do
            nil ->
                Tools.log(req)
                Tools.log(data.body)
                {:error,"凭证错误"}
            _ ->
                token = rec["access_token"]
                id = rec["openid"]
                req = "https://api.weixin.qq.com/sns/userinfo?access_token=#{token}&openid=#{id}"

                case HTTPoison.get!(req) do
                {:error,msg} ->
                    Tools.log({:net_error,msg})
                    {:error,"网络错误"}
                data ->
                    rec =  Poison.decode!(data.body)

                    #Tools.log(rec)

                    case rec["unionid"] do
                    nil ->
                        Tools.log(req)
                        Tools.log(data.body)
                        {:error,"凭证错误"}
                    acc_id ->
                        %{
                            acc_id: acc_id,
                            sex: rec["sex"],
                            name: rec["nickname"],
                            head: rec["headimgurl"],
                        }
                    end
                end
            end
        end

        case ret do
        {:error,er} ->
            Proto.User.login_error(er)
            state
        data ->

            Proto.User.wx_id(data.acc_id)

            case UserManager.load(data) do
            nil ->
                state
            user ->
                save_wx_key(key,data.acc_id)
                login_ok_fun(state,user)
            end
        end
    end

    def wx_id_login(state,acc_id) do
        case UserManager.load(%{acc_id: acc_id}) do
        nil ->
            state;
        user ->
            login_ok_fun(state,user)
        end
    end

    def login_ok_fun(state,user) do
        user = get_ip(state,user)

        state = Map.put(state,:user,user)

        Proto.User.user_info(%{
            name: user.name,
            id: user.id,
            card_count: user.card_count,
            head: user.head,
            sex: user.sex,
            ip: user.ip
        })

        state = Map.put(state,:on_closed,&User.quit/1)

        LogData.log_day_id(:login,user.id)

        Map.put(state,:acc_id, user.acc_id)
    end

    def get_txt(state,key) do
        id = String.to_atom(key)
        case id do
        :shop ->
            if DataBase.has_id(:daili,state.user.id) do
                Proto.User.get_txt_ack(key,"daili")
            else
                Proto.User.get_txt_ack(key,Cfg.get_string(id))
            end
        _ ->
            Proto.User.get_txt_ack(key,Cfg.get_string(id))
        end
        state
    end

    def quit(state) do
        case Map.get(state,:user) do
        nil ->
            state
        user ->
            Room.off_line(state)

            #UserManager.save(user)
            UserManager.quit(user.id)
            Map.put(state,:user,nil)
        end
    end

    def heart(state) do
        Proto.User.heart_ack()
        state
    end

# ------------------------------------------------------------
    def call(pid,fun) do
        TcpServer.call(pid,fun)
    end

    def cast(pid,fun) do
        TcpServer.cast(pid,fun)
    end

    def new(id) when is_integer(id) do
        m = to_string(id)
        name = String.replace("测试,", ",",m)
         %{ id: id,
            card_count: Cfg.get_number(:gold),
            acc_id: id,
            name: name,
            head: "http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/0",
            sex: 1,
            regTime: Tools.get_now_str()
         }
    end

    def new(user_info) do
        Map.merge(user_info, %{
            id: 0,
            card_count: Cfg.get_number(:gold),
            regTime: Tools.get_now_str()
        })
    end


    def exchange(pid) do
        call(pid,&exchange_fun/1)
    end

    defp exchange_fun(state) do
        reply = state.user
        state = Map.put(state,:user,nil)
        {reply,state}
    end

    def add_card(user,card) do
        put_in(user.card_count, user.card_count+card)
    end

    def add_game(user,is_win) do
        count = Map.get(user, :game_count, 0)
        user = Map.put(user, :game_count, count+1)
        if is_win do
            count = Map.get(user, :game_win_count, 0)
            Map.put(user, :game_win_count, count+1)
        else
            user
        end
    end

    def format_id({id1,id2,id3,id4}) do
        id1 = to_string(id1)
        id2 = to_string(id2)
        id3 = to_string(id3)
        id4 = to_string(id4)
        "#{id1}.#{id2}.#{id3}.#{id4}"
    end

    def format_id(_) do
        "0.0.0.0"
    end


    def get_ip(state,user) do
        ip =
        case :inet.peername(state.socket) do
        {:ok,{ip,_}} ->
            format_id(ip)
        _ ->
            "0.0.0.0"
        end

        Map.put(user,:ip,ip)
    end
end
