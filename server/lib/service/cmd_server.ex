require Tools

defmodule CmdServer do
	@save_time 1000
    @load_time 10000

	@is_debug false

	require Record
    Record.defrecord :acc, id: 0, name: :_, pwd: :_, op: :_, gold: 0, enable: true, regTime: :_, email: :_, nick: :_
	Record.defrecord :acc_online,  name: "", key: "", pwd: "", op: 0, id: 0, head0: 0, head1: 0

	Record.defrecord :daili, id: :_, name: :_, pwd: :_, op: :_, gold: :_, enable: :_, regTime: :_,  email: :_, nick: :_, head0: :_, head1: :_, head2: :_

	Record.defrecord :cfg_data, key: :_, value: :_

	Record.defrecord :gold_data, id: :_, date: :_, src: :_, des: :_, type: :_, gold: :_, time: :_

	Record.defrecord :search_add, name: :_, datas: :_

	def start() do
		Tools.db_table(acc,[:name])
		Tools.mem_table(acc_online)
		Tools.mem_table(search_add)

		Tools.db_table(daili,[:name])

		DataBase.check_init(:acc_name)

		loadCfgSave()

		init_log_gold()

		spawn fn -> accept(8188) end
		spawn fn -> accept_ex(8189) end
	end

	def stop() do
		closeCfgSave()
	end

	def loadCfgSave() do
		Tools.db_table(cfg_data)

		list = DataBase.find(cfg_data())

		Enum.each(list, fn(a)->
			Cfg.set(cfg_data(a,:key),cfg_data(a,:value))
		end)
	end

	def closeCfgSave() do
	end

	def setCfgValue(key,value) do
		DataBase.write(cfg_data(key: key, value: value))
		Cfg.set(key,value)
	end



	def accept(port) do
	  	{:ok, socket} = :gen_tcp.listen(port,
	                    [  :binary,
                            packet: :http_bin,
                            active: false,
                            reuseaddr: true,
                        ])

	  	Tools.log("cmd server started.")

	  	loop_acceptor(socket)
	end

	defp loop_acceptor(socket) do
	  	{:ok, client} = :gen_tcp.accept(socket)

	  	#IO.puts "accepted socket"
	  	pid = start_process(client)
	  	:gen_tcp.controlling_process(client,pid)
		loop_acceptor(socket)
	end

	defp start_process(socket) do
		#Tools.log("start...")
		spawn(fn()->
	        msg_fun(socket)
        end)
	end

	def accept_ex(port) do
	  	{:ok, socket} = :gen_tcp.listen(port,
	                    [  :binary,
                            packet: :http_bin,
                            active: false,
                            reuseaddr: true,
                        ])

	  	#Tools.log("cmd server started.")

	  	loop_acceptor_ex(socket)
	end

	defp loop_acceptor_ex(socket) do
	  	{:ok, client} = :gen_tcp.accept(socket)

	  	#IO.puts "accepted socket"
	  	pid = start_process_ex(client)
	  	:gen_tcp.controlling_process(client,pid)
		loop_acceptor_ex(socket)
	end

    defp start_process_ex(socket) do
		spawn(fn()->
	        case :inet.peername(socket) do
	        {:ok,{{127,0,0,1},_}} ->
	            local_fun(socket)
	        _ ->
	            Tools.log("error ip")
	        end
        end)
	end

	def local_fun(socket) do
		case :gen_tcp.recv(socket, 0, 5000) do
        {:ok, {:http_request, :GET, {:abs_path, datas}, _}} ->
			datas = String.split(datas, ["/","(",",",")","?","=", "&"])
			datas = List.foldl(datas, [], fn(a,acc)->
				if a == "" do
					acc
				else
					acc ++ [a]
				end
			end)
			#Tools.log(datas)
			case datas do
			["stop"|_] ->
				Server.stop()
				http_return(socket,"stop ok.")
			_ ->
				http_return(socket,"error cmd")
			end
		_ ->
			:ok
		end
	end

    def msg_fun(socket) do

        case :gen_tcp.recv(socket, 0, 5000) do
        {:ok, {:http_request, :GET, {:abs_path, datas}, _}} ->
			#Tools.log(datas)
            datas = String.split(datas, ["?","=", "&"])
			#Tools.log(datas)
            callback = get_param(datas,"jsoncallback")
			key = get_param(datas,"key")
            params = http_json(get_param(datas,"data"))
            #Tools.log(params)
			ret =
			case check_key(key) do
			false ->
				pre_cmd(params)
			acc ->
				if check_op(acc,params) do
					do_cmd(acc,params)
				else
					%{error: "没有权限"}
				end
			end
            http_return(socket,callback,ret)
        _ ->
            :ok
        end

        :gen_tcp.close(socket)
    end

    def get_param([param,call|_],param) do
        call
    end

    def get_param([_|list],param) do
        get_param(list,param)
    end

    def get_param(_,_) do
        ""
    end

    def http_json(bin) do
		bin = http_bin(bin)
		#Tools.log(bin)
        {:ok,ret} = Poison.decode(bin)
        ret = Enum.map(ret, fn({key,data})->
            {String.to_atom(key),data}
        end)
        Map.new(ret)
    end

    def http_bin(<<37,a,b,bin::binary>>) do
		data = String.to_integer(<<a,b>>,16)
        <<data,http_bin(bin)::binary>>
    end

    def http_bin(<<a,bin::binary>>) do
        <<a,http_bin(bin)::binary>>
    end

    def http_bin(_) do
        <<>>
    end


    defp http_return(socket,callback,ret) do
		{:ok,ret} = Poison.encode(ret)

        ret =
		if callback == "" do
			ret
		else
			"#{callback}(#{ret})"
		end
        len = byte_size(ret)
        data = "HTTP/1.0 200 OK\r\nServer: K17\r\nAccept-Ranges: bytes\r\nContent-Type: text/html\r\nContent-Length: #{len}\r\n\r\n#{ret}"
        :gen_tcp.send(socket, data )
        #Tools.log({"send",data})
    end

	defp http_return(socket,ret) do
        len = byte_size(ret)
        data = "HTTP/1.0 200 OK\r\nServer: K17\r\nAccept-Ranges: bytes\r\nContent-Type: text/html\r\nContent-Length: #{len}\r\n\r\n#{ret}"
        :gen_tcp.send(socket, data )
        #Tools.log({"send",data})
    end

	defp pre_cmd( %{cmd: "login", name: "admin", pwd: pwd} ) do
		admin_pwd = Cfg.get_string("admin_pwd")
		if pwd == admin_pwd do
			save_login_ok(acc(name: "admin", pwd: pwd, op: 0))
		else
			%{
				error: "密码错误"
			}
		end
    end

    defp pre_cmd( %{cmd: "login", name: name, pwd: pwd} ) do
		case login(name, pwd) do
		false ->
			#Tools.log("login faile")
			%{
				error: "密码错误"
			}
		data ->
			#Tools.log("login ok")
			save_login_ok(data)
		end
    end

	defp pre_cmd(cmd) do
		if @is_debug do
			t = acc_online()
			t = acc_online(t, pwd: "test" )
			do_cmd( t, cmd )
		else
	        #Tools.log({"error pre cmd:",cmd})
			%{
				error: "请先登录"
			}
		end
    end

	defp do_cmd(_,%{cmd: "room_info", id: id }) do
		id = Tools.to_int(id)
		case RoomManager.get_room_info(id) do
		nil ->
			%{
				error: "没有此房间"
			}
		info ->
			info
		end
	end

	defp do_cmd(_,%{cmd: "close_room", id: id }) do
		id = Tools.to_int(id)
		RoomManager.close_room_force(id)
		%{
			info: "关闭房间"
		}
	end

	defp do_cmd(_,%{cmd: "game_info"}) do
		%{
			data: %{
				count: UserManager.get_online_count(),
				game: RoomManager.get_game_count(),
				user_count: DataBase.data_count(:user_id),
			}
		}
	end

	defp do_cmd(_,%{cmd: "player_info", id: id}) do
		id = Tools.to_int(id)
		case MapDB.dirty_read(:user, id) do
		nil ->
			%{
				error: "无效id"
			}
		data ->
			info = getPlayerInfo(data)
			#Tools.log(data)
			%{
				data: info
			}
		end
	end

	defp do_cmd(_,%{cmd: "player_page", page: page}) do
		page = Tools.to_int(page)

		count = DataBase.data_count(:user_id)
		pageCount = div(count+9,10)
		page =
		cond do
		page < 1 ->
			1
		page > pageCount ->
			pageCount
		true ->
			page
		end

		startId = page * 10 - 9
		endId   = startId + 9

		startId =
		if startId < 1 do
			1
		else
			startId
		end

		endId =
		if endId > count do
			count
		else
			endId
		end

		data =
		if endId >= startId do
			Enum.map(startId..endId,fn(id)->
				id = 10000 + id
				case MapDB.dirty_read(:user, id) do
				nil ->
					%{
					}
				data ->
					getPlayerInfo(data)
				end
			end)
		else
			[]
		end




		%{
			data: data,
			count: count,
			page: page,
			pageCount: pageCount
		}

	end

	defp do_cmd(_,%{cmd: "enableUser", id: id}) do
		id = Tools.to_int(id)
		UserManager.enable_user(id,true)
		%{
			id: id
		}
	end

	defp do_cmd(_,%{cmd: "disableUser", id: id}) do
		id = Tools.to_int(id)
		UserManager.enable_user(id,false)
		%{
			id: id,
		}
	end





	defp do_cmd(_,%{cmd: "register", name: name, pwd: pwd, id: id, op: op} ) do
        register(name,pwd,id,op)
    end

	defp do_cmd(state,%{cmd: "change_pwd", oldPwd: old, newPwd: new} ) do
		if old == new do
			%{
				error: "新密码不能和旧密码相同"
			}
		else
			if acc_online(state,:pwd) != old do
				%{
					error: "旧密码不对"
				}
			else
				#Tools.log(acc_online(state,:name))
				#Tools.log(state)
				if acc_online(state,:name) == "admin" do
					Cfg.set("admin_pwd",new)
				else
	        		change_pwd(acc_online(state,:name),new)
					data = acc_online(state, pwd: new )
					DataBase.write(data)
				end
				%{
					data: "ok"
				}
			end
		end
    end

	defp do_cmd(_,%{cmd: "get_acc_datas"} ) do
		datas = DataBase.find(acc())
		datas = Enum.map(datas, fn(data)->
			%{
				name: acc(data,:name),
				op: acc(data,:op),
				regTime: acc(data,:regTime),
				email: acc(data,:email)
			}
		end)
        %{
			data: datas,
		}
    end

	defp do_cmd(_,%{cmd: "del_acc",name: name} ) do
		DataBase.delete(:acc, name)
        %{
		}
    end

	defp do_cmd(_,%{cmd: "add_acc",name: ""} ) do
		%{
			error: "帐号不能为空",
		}
	end
	defp do_cmd(_,%{cmd: "add_acc",name: "admin"} ) do
		%{
			error: "帐号不能为 admin",
		}
	end
	defp do_cmd(_,%{cmd: "add_acc",pwd: ""} ) do
		%{
			error: "密码不能为空",
		}
	end
	defp do_cmd(_,%{cmd: "add_acc",name: name,name: pwd,op: op,email: email} ) do
		case DataBase.read(:acc, name) do
		nil ->
			op = Tools.to_int(op)
			regTime = Tools.get_now_str()
			data = acc(name: name, pwd: pwd,
					nick: "",
					email: email, regTime: regTime, op: op )
			#Tools.log(data)


			DataBase.write(data)

			data = %{
				name: acc(data,:name),
				op: acc(data,:op),
				regTime: acc(data,:regTime),
				email: acc(data,:email)
			}

			%{
				data: data
			}
		_ ->
			%{
				error: "帐号已经存在"
			}
		end
    end

	defp do_cmd(_,%{cmd: "find_daili", id: id} ) do
		id = Tools.to_int(id)
		case UserManager.getUserDailiInfo(id) do
		nil ->
			%{
				error: "没有这个玩家"
			}
		data ->
			data
		end
	end

	defp do_cmd(_,%{cmd: "add_daili", id: id} ) do
		id = Tools.to_int(id)
		case UserManager.getUserDailiInfo(id) do
		nil ->
			%{
				error: "没有这个玩家"
			}
		data ->
			DataBase.write(daili(id: id,name: data.name,regTime: data.regTime))
			%{
				data: data
			}
		end
	end

	defp do_cmd(_,%{cmd: "get_daili_datas"} ) do
		datas = DataBase.find(daili())
		datas = Enum.map(datas, fn(data)->
			%{
				id: daili(data,:id),
				name: daili(data,:name),
				regTime: daili(data,:regTime),
			}
		end)
		%{
			data: datas,
		}
	end

	defp do_cmd(_,%{cmd: "del_daili",id: id} ) do
		DataBase.delete(:daili, id)
		%{
		}
	end

	defp do_cmd(state,%{cmd: "charge",id: id,gold: gold,type: type} ) do
		gold = Tools.to_int(gold)
		id = Tools.to_int(id)
		type = Tools.to_int(type)
		if acc_online(state,:op) > 0 and (gold <= 0) do
			%{error: "充值金额无效。"}
		else

			case MapDB.dirty_read(:user, id) do
			nil ->
				%{error: "玩家id无效"}
			_ ->
				op = acc_online(state,:op)
				fun =
				cond do
				op == 0 ->
					fn() ->
						true
					end
				op == 1 ->
					src_id = acc_online(state,:id)
					fn() ->
						case :mnesia.read(:acc,src_id) do
						[a] ->
							acc_gold = acc(a,:gold)
							if acc_gold < gold do
								"余额不足。"
							else
								:mnesia.write(acc(a,gold: acc_gold-gold))
								true
							end
						_ ->
							"代理id不对。"
						end
					end
				true ->
					src_id = acc_online(state,:id)
					fn() ->
						case :mnesia.read(:daili,src_id) do
						[a] ->
							acc_gold = daili(a,:gold)
							if acc_gold < gold do
								"余额不足。"
							else
								:mnesia.write(daili(a,gold: acc_gold-gold))
								true
							end
						_ ->
							"代理id不对。"
						end
					end
				end

				case :mnesia.transaction(fun) do
				{:atomic,true} ->
					case UserManager.add_gold(id,gold) do
					true ->
						#Tools.log(type)
						if type == 0 do
							log_gold(:charge,acc_online(state,:name),id,gold)
						else
							log_gold(:free,acc_online(state,:name),id,gold)
						end
						%{}
					erorr ->
						%{error: erorr}
					end
				{:atomic,error} ->
					%{error: error}
				_ ->
					%{error: "余额不足。"}
				end
			end
		end
	end


	defp do_cmd(_,%{cmd: "gacc_add",name: ""} ) do
		%{
			error: "帐号不能为空",
		}
	end
	defp do_cmd(_,%{cmd: "gacc_add",name: "admin"} ) do
		%{
			error: "帐号不能为 admin",
		}
	end
	defp do_cmd(_,%{cmd: "gacc_add",pwd: ""} ) do
		%{
			error: "密码不能为空",
		}
	end
	defp do_cmd(_,%{cmd: "gacc_add",name: name, pwd: pwd, op: op, email: email} ) do
		case DataBase.check_add(:acc_name, name) do
		true ->
			op = Tools.to_int(op)
			regTime = Tools.get_now_str()
			data = acc(name: name, pwd: pwd,
					nick: "",
					id: DataBase.new_id(:acc_id),
					email: email, regTime: regTime, op: op )
			#Tools.log(data)


			DataBase.write(data)

			data = %{
				id: acc(data,:id),
				gold: acc(data,:gold),
				name: acc(data,:name),
				op: acc(data,:op),
				regTime: acc(data,:regTime),
				email: acc(data,:email),
				enable: acc(data,:enable),
			}

			%{
				data: data
			}
		_ ->
			%{
				error: "帐号已经存在"
			}
		end
	end

	defp do_cmd(state,%{cmd: "gacc_charge",id: id,gold: gold,type: type} ) do
		gold = Tools.to_int(gold)
		id = Tools.to_int(id)
		type = Tools.to_int(type)


		if acc_online(state,:op) > 0 and (gold <= 0) do
			%{error: "充值金额无效。"}
		else
			case DataBase.read(:acc, id) do
			nil ->
				%{error: "没有此管理员"}
			data ->
				op = acc_online(state,:op)


				fun = fn() ->
					case :mnesia.read(:acc,id) do
					[b] ->
						b_gold = acc(b,:gold)
						:mnesia.write(acc(b,gold: b_gold+gold))
						true
					_ ->
						false
					end
		        end


		        case :mnesia.transaction(fun) do
				{:atomic,true} ->
					name = acc(data,:name)

					log_gold(:system,acc_online(state,:name),name,gold)

					%{
						id: id,
						gold: gold,
					}
				{:atomic,error} ->
					%{error: error}
				_ ->
					%{error: "余额不足。"}
				end
			end
		end
	end

	defp do_cmd(_,%{cmd: "gacc_info", id: id}) do
		id = Tools.to_int(id)
		case DataBase.read(:acc, id) do
		nil ->
			%{
				error: "无效id"
			}
		data ->
			info = %{
				id: acc(data,:id),
				gold: acc(data,:gold),
				name: acc(data,:name),
				op: acc(data,:op),
				regTime: acc(data,:regTime),
				email: acc(data,:email),
				enable: acc(data,:enable),

			}
			%{
				data: info
			}
		end
	end

	defp do_cmd(_,%{cmd: "gacc_page", page: page}) do
		page = Tools.to_int(page)

		count = DataBase.data_count(:acc_id)
		pageCount = div(count+9,10)
		page =
		cond do
		page < 1 ->
			1
		page > pageCount ->
			pageCount
		true ->
			page
		end

		startId = page * 10 - 9
		endId   = startId + 9

		startId =
		if startId < 1 do
			1
		else
			startId
		end

		endId =
		if endId > count do
			count
		else
			endId
		end

		data =
		if endId >= startId do
			Enum.map(startId..endId,fn(id)->
				case DataBase.read(:acc, id) do
				nil ->
					%{
						id: id,
						name: "not_found"
					}
				data ->
					%{
						id: acc(data,:id),
						gold: acc(data,:gold),
						name: acc(data,:name),
						op: acc(data,:op),
						regTime: acc(data,:regTime),
						email: acc(data,:email),
						enable: acc(data,:enable),
					}
				end
			end)
		else
			[]
		end




		%{
			data: data,
			count: count,
			page: page,
			pageCount: pageCount
		}

	end

	defp do_cmd(_,%{cmd: "gacc_enable", id: id}) do
		id = Tools.to_int(id)
		case DataBase.read(:acc, id) do
		nil ->
			:ok
		data ->
			data = acc(data,enable: true)
			DataBase.write(data)
		end
		%{
			id: id
		}
	end

	defp do_cmd(_,%{cmd: "gacc_disable", id: id}) do
		id = Tools.to_int(id)
		case DataBase.read(:acc, id) do
		nil ->
			:ok
		data ->
			data = acc(data,enable: false)
			DataBase.write(data)
		end
		%{
			id: id,
		}
	end

	defp do_cmd(state,%{cmd: "gacc_reset", id: id, pwd: pwd} ) do
		id = Tools.to_int(id)
		case DataBase.read(:acc, id) do
		nil ->
			%{
				error:  "账号不存在",
			}
		data ->
			data = acc(data,pwd: pwd)
			DataBase.write(data)

			%{
				data: "ok"
			}
		end
    end

	## -------------------------------------------


	defp do_cmd(_,%{cmd: "dacc_add",name: ""} ) do
		%{
			error: "帐号不能为空",
		}
	end
	defp do_cmd(_,%{cmd: "dacc_add",name: "admin"} ) do
		%{
			error: "帐号不能为 admin",
		}
	end
	defp do_cmd(_,%{cmd: "dacc_add",pwd: ""} ) do
		%{
			error: "密码不能为空",
		}
	end
	defp do_cmd(state,%{cmd: "dacc_add",name: name, pwd: pwd, email: email} ) do
		case DataBase.check_add(:acc_name, name) do
		true ->
			state_op =  acc_online(state,:op)
			{op,head0,head1,head2} =
			cond do
			state_op <= 1 ->
				{2,acc_online(state,:id),0,0}
			state_op == 2 ->
				{3,acc_online(state,:head0),acc_online(state,:id),0}
			state_op == 3 ->
				{4,acc_online(state,:head0),acc_online(state,:head1),acc_online(state,:id)}
			end

			regTime = Tools.get_now_str()
			data = daili(name: name, pwd: pwd,
					nick: "",
					id: DataBase.new_id(:daili_id),
					op: op,
					gold: 0,
					head0: head0,
					head1: head1,
					head2: head2,
					email: email, regTime: regTime, op: op )
			#Tools.log(data)


			DataBase.write(data)

			data = %{
				id: daili(data,:id),
				gold: daili(data,:gold),
				name: daili(data,:name),
				op: op,
				regTime: daili(data,:regTime),
				email: daili(data,:email),
				enable: daili(data,:enable),
			}

			%{
				data: data
			}
		_ ->
			%{
				error: "帐号已经存在"
			}
		end
	end

	defp do_cmd(state,%{cmd: "dacc_charge",id: id,gold: gold,type: type} ) do
		gold = Tools.to_int(gold)
		id = Tools.to_int(id)
		type = Tools.to_int(type)
		if acc_online(state,:op) > 0 and (gold <= 0) do
			%{error: "充值金额无效。"}
		else
			case DataBase.read(:daili, id) do
			nil ->
				%{error: "没有此管理员"}
			data ->
				op = acc_online(state,:op)
				fun =
				cond do
				op == 0 ->
					fn() ->
						case :mnesia.read(:daili,id) do
						[b] ->
							b_gold = daili(b,:gold)
							:mnesia.write(daili(b,gold: b_gold+gold))
							true
						_ ->
							false
						end
			        end
				op == 1 ->
					src_id = acc_online(state,:id)
					fn() ->
						case :mnesia.read(:acc,src_id) do
						[a] ->
							acc_gold = acc(a,:gold)
							if acc_gold < gold do
								"余额不足。"
							else

								case :mnesia.read(:daili,id) do
								[b] ->
									b_gold = daili(b,:gold)

									:mnesia.write(acc(a,gold: acc_gold-gold))
									:mnesia.write(daili(b,gold: b_gold+gold))

									true
								_ ->
									"代理id不对。"
								end
							end
						_ ->
							"代理id不对。"
						end
			        end
				true ->
					src_id = acc_online(state,:id)
					fn() ->
						case :mnesia.read(:daili,src_id) do
						[a] ->
							acc_gold = daili(a,:gold)
							if acc_gold < gold do
								"余额不足。"
							else
								case :mnesia.read(:daili,id) do
								[b] ->
									head_id =
									cond do
									op == 2 ->
										daili(b,:head1)
									op == 3 ->
										daili(b,:head2)
									true ->
										-1
									end

									if head_id == src_id do
										b_gold = daili(b,:gold)

										:mnesia.write(daili(a,gold: acc_gold-gold))
										:mnesia.write(daili(b,gold: b_gold+gold))

										true
									else
										"不是下级代理商。"
									end
								_ ->
									"余额不足。"
								end
							end
						_ ->
							"代理id不对。"
						end
			        end
				end

		        case :mnesia.transaction(fun) do
				{:atomic,true} ->
					name = acc(data,:name)
					log_gold(:system,acc_online(state,:name),name,gold)
					%{
						id: id,
						gold: gold,
					}
				{:atomic,error} ->
					%{error: error}
				_ ->
					%{error: "余额不足。"}
				end



			end
		end
	end

	defp do_cmd(_,%{cmd: "dacc_info", id: id}) do
		id = Tools.to_int(id)
		case DataBase.read(:daili, id) do
		nil ->
			%{
				error: "无效id"
			}
		data ->
			info = %{
				id: daili(data,:id),
				gold: daili(data,:gold),
				name: daili(data,:name),
				op: daili(data,:op),
				regTime: daili(data,:regTime),
				email: daili(data,:email),
				enable: daili(data,:enable),

			}
			%{
				data: info
			}
		end
	end

	defp do_cmd(_,%{cmd: "dacc_page", page: page}) do
		page = Tools.to_int(page)

		count = DataBase.data_count(:daili_id)

		#Tools.log(count)

		pageCount = div(count+9,10)
		page =
		cond do
		page < 1 ->
			1
		page > pageCount ->
			pageCount
		true ->
			page
		end

		startId = page * 10 - 9
		endId   = startId + 9

		startId =
		if startId < 1 do
			1
		else
			startId
		end

		endId =
		if endId > count do
			count
		else
			endId
		end

		data =
		if endId >= startId do
			Enum.map(startId..endId,fn(id)->
				case DataBase.read(:daili, id) do
				nil ->
					%{
						id: id,
						name: "not_found"
					}
				data ->
					%{
						id: daili(data,:id),
						gold: daili(data,:gold),
						name: daili(data,:name),
						op: daili(data,:op),
						regTime: daili(data,:regTime),
						email: daili(data,:email),
						enable: daili(data,:enable),
					}
				end
			end)
		else
			[]
		end




		%{
			data: data,
			count: count,
			page: page,
			pageCount: pageCount
		}

	end

	defp do_cmd(_,%{cmd: "dacc_enable", id: id}) do
		id = Tools.to_int(id)
		case DataBase.read(:daili, id) do
		nil ->
			:ok
		data ->
			data = daili(data,enable: true)
			DataBase.write(data)
		end
		%{
			id: id
		}
	end

	defp do_cmd(_,%{cmd: "dacc_disable", id: id}) do
		id = Tools.to_int(id)
		case DataBase.read(:daili, id) do
		nil ->
			:ok
		data ->
			data = daili(data,enable: false)
			DataBase.write(data)
		end
		%{
			id: id,
		}
	end

	defp do_cmd(state,%{cmd: "dacc_reset", id: id, pwd: pwd} ) do
		id = Tools.to_int(id)
		case DataBase.read(:daili, id) do
		nil ->
			%{
				error:  "账号不存在",
			}
		data ->
			data = daili(data,pwd: pwd)
			DataBase.write(data)

			%{
				data: "ok"
			}
		end
    end



	defp do_cmd(state,%{cmd: "ddacc_page"}) do
		d =
		if acc_online(state,:op) == 2 do
			daili(head1: :'$1')
		else
			daili(head2: :'$1')
		end
		q = [{:'==',:'$1',acc_online(state,:id)}]
		#Tools.log(q)
		list = DataBase.dirty_find(d,q)

		data = Enum.map(list,fn(data)->
			%{
				id: daili(data,:id),
				gold: daili(data,:gold),
				name: daili(data,:name),
				op: daili(data,:op),
				regTime: daili(data,:regTime),
				email: daili(data,:email),
				enable: daili(data,:enable),
			}
		end)

		%{
			data: data,
		}

	end

	defp do_cmd(state,%{cmd: "self_info"}) do
		#Tools.log(state)
		case acc_online(state,:op) do
		1 ->
			#Tools.log("dd1")
			id = acc_online(state,:id)
			case DataBase.read(:acc, id) do
			nil ->
				%{}
			data ->
				%{
					name: acc(data,:name),
					gold: acc(data,:gold),
				}
			end
		_ ->
			id = acc_online(state,:id)
			#Tools.log(id)
			case DataBase.read(:daili, id) do
			nil ->
				%{}
			data ->
				%{
					name: daili(data,:name),
					gold: daili(data,:gold),
				}
			end
		end
	end


	defp do_cmd(state,%{cmd: "search_day_info", startDate: startDate, endDate: endDate }) do
		startDate = Tools.get_date(startDate)
		endDate = Tools.get_date(endDate)
		if startDate != nil and endDate != nil do
			s = :calendar.date_to_gregorian_days(startDate)
			e = :calendar.date_to_gregorian_days(endDate)

			cond do
			e < s ->
				%{
					error: "开始日期大于结束日期"
				}
			e > s + 31 ->
				%{
					error: "查找不能超过一个月"
				}
			true ->
				data = Enum.map(s..e, fn(n)->
					date = :calendar.gregorian_days_to_date(n)

					case  MapDB.dirty_read(:day_info_his, date) do
					nil ->
						get_day_info(date)
					d ->
						d
					end
				end)
				%{
					data: data
				}
			end
		else
			%{
				error: "日期错误"
			}
		end
	end

	defp do_cmd(state,%{cmd: "search_day_gold", id: id, startDate: startDate, endDate: endDate }) do

		startDate = Tools.get_date(startDate)
		endDate = Tools.get_date(endDate)
		id = Tools.to_int(id)

		#Tools.log(startDate)
		#Tools.log(endDate)

		if startDate != nil and endDate != nil do
			s = :calendar.date_to_gregorian_days(startDate)
			e = :calendar.date_to_gregorian_days(endDate)

			cond do
			e < s ->
				%{
					error: "开始日期大于结束日期"
				}
			e > s + 30 ->
				%{
					error: "查找不能超过一个月"
				}
			true ->
				d = gold_data(src: :'$2', date: :'$3' )
				q = [{:'==',:'$2',id},{:'>=',:'$3',startDate},{:'=<',:'$3',endDate}]
				list1 = DataBase.dirty_find(d,q)

				d = gold_data(des: :'$2', date: :'$3' )
				list2 = DataBase.dirty_find(d,q)

				list = Enum.uniq(list1++list2)

				#Tools.log(list)
				#Tools.log(id)
				data = Enum.map(list, fn(a)->
					%{
						count: gold_data(a,:gold),
						op_id: gold_data(a,:src),
						time: Tools.get_datetime_str(gold_data(a,:date),gold_data(a,:time)),
						type: gold_data(a,:type),
					}
				end)
				%{
					data: data
				}
			end
		else
			%{
				error: "日期错误"
			}
		end
	end

	defp do_cmd(_,%{cmd: "get_cfg"} ) do
		%{
			note: Cfg.get_string(:note),
			shop: Cfg.get_string(:shop),
			gold: Cfg.get_number(:gold),
			ver: Cfg.get_number(:ver),
		}
	end

	defp do_cmd(_,%{cmd: "set_cfg",gold: gold, note: note, shop: shop, ver: ver} ) do
		gold = Tools.to_int(gold)
		setCfgValue(:gold,gold)
		setCfgValue(:note,note)
		setCfgValue(:shop,shop)
		ver = Tools.to_int(ver)
		setCfgValue(:ver,ver)

		Tools.log(ver)
		%{}
	end

	defp do_cmd(_,%{cmd: "get_cfg_ex"} ) do
		%{
			note: Cfg.get_string(:note),
			shop: Cfg.get_string(:shop),
			gold: Cfg.get_number(:gold),
			ver: Cfg.get_number(:ver),
			test: Cfg.get_number(:is_test),
		}
	end

	defp do_cmd(_,%{cmd: "set_cfg_ex",gold: gold, note: note, shop: shop, ver: ver, test: test} ) do
		gold = Tools.to_int(gold)
		setCfgValue(:gold,gold)
		setCfgValue(:note,note)
		setCfgValue(:shop,shop)
		setCfgValue(:is_test,test)

		ver = Tools.to_int(ver)
		setCfgValue(:ver,ver)
		%{}
	end

	defp do_cmd(state,%{cmd: "search_page_init"}) do

		name = acc_online(state,:name)

		d = gold_data(src: :'$2' )
		q = [{:'==',:'$2',name}]
		list = DataBase.dirty_findid(d,q)

		datas =  get_add_data(list,1)

		DataBase.dirty_write( search_add(name: name, datas: datas) )

		%{
			page: 1,
			count: length(list),
			data: datas
		}
	end

	defp do_cmd(state,%{cmd: "search_page", page: page}) do
		name = acc_online(state,:name)
		d = DataBase.dirty_read(:search_add, name)
		list = search_add(d, :datas)
		datas =  get_add_data(list,0)
		%{
			page: page,
			count: length(list),
			data: datas
		}
	end

	defp do_cmd(_,cmd) do
		Tools.log({"error cmd:",cmd})
		%{
			error: "错误命令。",
		}
	end

	def get_add_data(list,page) do
		startIndex = (page-1) * 10
		list = Enum.slice(list, startIndex, 10)
		Enum.map(list,fn(id)->
			a = DataBase.dirty_read(:gold_data, id)
			des_id = gold_data(a,:des)

			{id,name,type} =
			if is_number(des_id) do
				name = UserManager.get_player_name(des_id)
				{des_id,name,1}
			else
				{0,des_id,0}
			end
			%{
				gold: gold_data(a,:gold),
				id:   id,
				name: name,
				type: type,
				time: Tools.get_datetime_str(gold_data(a,:date),gold_data(a,:time)),
			}
		end)
	end




	defp check_key(key)  do

		case Regex.split(~r{_}, key, [parts: 2]) do
		[key,name] ->
			case DataBase.read(:acc_online, name) do
			nil ->
				#Tools.log({key,name})
				false
			data ->
				if acc_online(data, :key) == key do
					data
				else
					#Tools.log({key,acc_online(data, :key)})
					false
				end
			end
		_ ->
			false
		end
	end

	defp check_op(acc_data,params) do
		op = acc_online(acc_data,:op)
		#Tools.log(op)
		case op do
		0 ->
			true
		1 ->
			case params.cmd do
			"change_pwd" ->
				true
			"register" ->
				true
			_ ->
				true
			end
		_ ->
			true
		end
	end


	defp register(name,pwd,user_id,op) do
		case DataBase.read(:acc, name) do
		nil ->
			data = acc(name: name, pwd: pwd, op: op)
			DataBase.write(data)
			%{
				return: "注册成功。"
			}
		_ ->
			%{
				errro: "帐号已经存在！"
			}
		end
	end

	defp change_pwd(name,pwd) do

		case DataBase.read_index(:acc, name, :name) do
		nil ->
			case DataBase.read_index(:daili, name, :name) do
			nil ->
				false
			data ->
				data = daili(data, pwd: pwd)
				DataBase.write(data)
				%{
					return: "修改成功。"
				}
			end
		data ->
			data = acc(data, pwd: pwd)
			DataBase.write(data)
			%{
				return: "修改成功。"
			}
		end
	end

	defp login(name,pwd) do

		case DataBase.read_index(:acc, name, :name) do
		nil ->
			case DataBase.read_index(:daili, name, :name) do
			nil ->
				false
			data ->
				if daili(data,:pwd) == pwd do
					data
				else
					false
				end
			end
		data ->
			if acc(data,:pwd) == pwd do
				data
			else
				false
			end
		end
	end

	defp save_login_ok(data) do
		case elem(data, 0) do
		:acc ->
			name = acc(data,:name)
			id = acc(data,:id)
			pwd = acc(data,:pwd)
			op = acc(data,:op)
			key  = to_string( :rand.uniform(999999) )
			data = acc_online( id: id, name: name, pwd: pwd, key: key, op: op)
			#Tools.log(data)
			DataBase.write(data)
			%{
				key: "#{key}_#{name}",
				type: op,
			}
		_ ->
			name = daili(data,:name)
			id = daili(data,:id)
			pwd = daili(data,:pwd)
			op = daili(data,:op)
			head0 = daili(data,:head0)
			head1 = daili(data,:head1)
			key  = to_string( :rand.uniform(999999) )
			data = acc_online( id: id, name: name, pwd: pwd, key: key, op: op, head0: head0, head1: head1 )
			#Tools.log(data)
			DataBase.write(data)
			%{
				key: "#{key}_#{name}",
				type: op,
			}
		end
	end



	def init_log_gold() do
		fields = gold_data(gold_data())
		fields = Enum.map(fields,fn({key,_})-> key end)
		:mnesia.create_table(:gold_data, [
		          {:attributes, fields},
				  {:type, :bag},
				  {:index, [:src,:des,:type]},
		          {:disc_only_copies, [node()]},
       	          {:storage_properties,
        	      [{:dets, [{:auto_save, @save_time}]} ]
		}])
        :mnesia.wait_for_tables([:gold_data], @load_time)
	end

	def log_gold(type,src,des,gold) do
		#Tools.log({type,src,des,gold})
		type =
		case type do
		:charge ->
			0
		:free ->
			1
		:reg ->
			2
		:used ->
			11
		:send->
			10
		:system ->
			20
		_ ->
			11
		end
		{date,time} = :erlang.localtime()
		data = gold_data(	date: date,
							src: src,
							des: des,
							type: type,
							gold: gold,
							time: time
						)
		#Tools.log(data)
		LogData.log(data)
	end

	def find_log_dataids(id) do
		{date,_} = :erlang.localtime()
		date = Tools.add_date(date,-30)
		ids1 = DataBase.dirty_findid(gold_data(date: :'$2', des: :'$3'),[{:'>',:'$2',date},{:'==',:'$3',id}])
		ids2 = DataBase.dirty_findid(gold_data(date: :'$2', src: :'$3'),[{:'>',:'$2',date},{:'==',:'$3',id}])
		ids = ids1 ++ ids2
		ids = Enum.uniq(ids)
		ids = Enum.sort(ids)
		Enum.reverse(ids)
	end

	def get_log_datas(ids) do
		Enum.map(ids, fn(id)->
			case DataBase.dirty_read(:gold_data, id) do
			nil ->
				%{
					type: 0,
					src: "",
					des: 0,
					gold: 0,
					time: ""
				}
			data ->
				%{
					type: gold_data(data,:type),
					src: to_string(gold_data(data,:src)),
					des: gold_data(data,:des),
					gold: gold_data(data,:gold),
					time: Tools.get_datetime_str(gold_data(data,:date),gold_data(data,:time))
				}
			end
		end)
	end

	def get_day_info(date) do
		q = [{:'==',:'$2',date}]
		qs = gold_data(date: :'$2')
		list = DataBase.dirty_find(qs,q)


		gold = List.foldl(list, 0, fn(a,acc)->
			if gold_data(a,:type) == 0 do
				acc+gold_data(a,:gold)
			else
				acc
			end
		end)

		list = List.foldl(list, [], fn(a,acc)->
			if gold_data(a,:type) == 0 do
				[gold_data(a,:des)|acc]
			else
				acc
			end
		end)
		list = Enum.uniq(list)
		people = Enum.count(list)

		#Tools.log(date)
		#Tools.log(MapDB.dirty_read(:day_info, date))
		case MapDB.dirty_read(:day_info, date) do
		nil ->
			%{
				date:  Tools.get_date_str(date),
				game: 0,
				new_count: 0,
				act_count: 0,
				gold: gold,
				gold_people: people,
			}
		d ->
			%{
				date:  Tools.get_date_str(date),
				game: Map.get(d, :game, 0),
				new_count: Tools.get_map_list_count(d,:new),
				act_count: Tools.get_map_list_count(d,:login),
				gold: gold,
				gold_people: people,
			}
		end
	end

	defp getPlayerInfo(data) do
		%{
			id:   data.id,
			sex:  data.sex,
			name: data.name,
			gold: data.card_count,
			regTime:  Map.get(data, :regTime, "未知"),
			online: UserManager.is_online(data.id),
			enable:  Map.get(data, :enable, true),
			roomId: RoomManager.get_user_room_id(data.id),
		}
	end




end
