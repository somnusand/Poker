
require Tools

defmodule DataBase do
    @save_time 1000
    @load_time 10000

    def db_table(table,fileds,indexs) do
        :mnesia.create_table(table, [
		          {:attributes, fileds},
                  {:index, indexs},
		          {:disc_copies,[node()]},
       	          {:storage_properties,
        	         [{:ets, [:compressed]}, {:dets, [{:auto_save, @save_time}]} ]}])
        #GenServer.call(__MODULE__,{:table,table})
        :mnesia.wait_for_tables([table], @load_time)
    end

    def db_table(table,fileds) do
        # Tools.log(table)
        # Tools.log(fileds)
        :mnesia.create_table(table, [
		          {:attributes, fileds},
		          {:disc_copies,[node()]},
       	          {:storage_properties,
        	         [{:ets, [:compressed]}, {:dets, [{:auto_save, @save_time}]} ]}])
        #GenServer.call(__MODULE__,{:table,table})
        :mnesia.wait_for_tables([table], @load_time)
    end

    def disk_table(table,fileds) do
        :mnesia.create_table(table, [
		          {:attributes, fileds},
		          {:disc_only_copies, [node()]},
       	          {:storage_properties,
        	      [{:dets, [{:auto_save, @save_time}]} ]
		}])
        :mnesia.wait_for_tables([table], @load_time)
    end

    def mem_table(table,fileds) do
        :mnesia.create_table(table, [
    		{:attributes, fileds},
    		{:ram_copies,[node()]},
           	{:storage_properties,
            	[{:ets, [:compressed]}]
    		}])
    end

    def dirty_read(table,id) do
        case :mnesia.dirty_read(table,id) do
        [r] ->
            r
        _ ->
            nil
        end
    end


    def dirty_write(data) do
        :mnesia.dirty_write(data)
    end

    def dirty_delete(table,id) do
        :mnesia.dirty_delete(table,id)
    end

    def dirty_has_key(table,id) do
        case :mnesia.dirty_read(table,id) do
        [_] ->
            true
        _ ->
            false
        end
    end

    def dirty_findid(data) do

        table = elem(data, 0)
        data = put_elem(data,1,:'$1')
        matchHead = data
        guard = []
        result = [:'$1']
        :mnesia.dirty_select(table, [{matchHead, guard, result}])
    end

    def dirty_findid(data,qList) do

        table = elem(data, 0)
        matchHead = put_elem(data,1,:'$1')

        guard = Enum.map(qList,fn({t,key,value})->
            {t,key,{:const,value}}
        end)

    	result = [:'$1']

        #Tools.log(guard)
    	:mnesia.dirty_select(table, [{matchHead, guard, result}])

    end

    def dirty_find(data,qList) do
        table = elem(data, 0)
        matchHead = data
        guard = Enum.map(qList,fn({t,index,value})->
            {t,index,{:const,value}}
        end)
        Tools.log(guard)
        result = [:'$_']
        :mnesia.dirty_select(table, [{matchHead, guard, result}])
    end


    def new_id(table) do
        # mnesia:dirty_update_counter/3 is performed as an atomic operation
        # although it is not protected by a transaction.
        :mnesia.dirty_update_counter(:keys, table, 1)
    end

    def data_count(table) do
        case :mnesia.dirty_read(:keys,table) do
        [{_,_,id}] ->
            id
        a ->
            0
        end
    end


    def read(table,id) do
        fun = fn() ->
            case :mnesia.read(table,id) do
            [r] ->
                r
            _ ->
                nil
            end
        end
        case :mnesia.transaction(fun) do
        {:atomic,ret} ->
            ret
        _ ->
            nil
        end
    end

    def read_index(table,id,key) do
        #Tools.log({table,key,id})
        case :mnesia.dirty_index_read(table, id, key) do
        [a] ->
            #Tools.log(a)
            a
        error ->
            #Tools.log(error)
            nil
        end
    end


    def write(data) do
        fun = fn() ->
            :mnesia.write(data)
        end
        :mnesia.transaction(fun)
    end

    def check_init(table) do
        db_table(table,[:key,:value])
    end

    def check_add(table,key) do

        Tools.log( :mnesia.dirty_read(table, key)  )
        fun = fn() ->
            case :mnesia.read(table, key) do
            [] ->
                :mnesia.write({table,key,0})
                true
            _ ->
                false
            end
        end
        case :mnesia.transaction(fun) do
        {:atomic,ret} ->
            ret
        error ->
            Tools.log(error)
            false
        end
    end

    def delete(table,id) do
        fun = fn() ->
            :mnesia.delete({table,id})
        end
        :mnesia.transaction(fun)
    end

    def find(data) do
        f = fn() ->
            table = elem(data, 0)
        	matchHead = data
        	guard = []
        	result = [:'$_']
        	:mnesia.select(table, [{matchHead, guard, result}])
        end
        case :mnesia.transaction(f) do
        {:atomic, list} ->
            list
        _ ->
            []
        end
    end

    def findid(data) do
        f = fn() ->
            table = elem(data, 0)
            data = put_elem(data,1,:'$1')
        	matchHead = data
        	guard = []
        	result = [:'$1']
        	:mnesia.select(table, [{matchHead, guard, result}])
        end
        case :mnesia.transaction(f) do
        {:atomic, list} ->
            list
        _ ->
            []
        end
    end

    def findid(data,qList) do
        f = fn() ->
            table = elem(data, 0)
            data = put_elem(data,1,:'$1')
            guard = Enum.map(qList,fn({t,index,value})->
                {t,index,{:const,value}}
            end)
        	matchHead = data
        	result = [:'$1']

            Tools.log(guard)
        	:mnesia.select(table, [{matchHead, guard, result}])
        end
        case :mnesia.transaction(f) do
        {:atomic, list} ->
            list
        _ ->
            []
        end
    end

    def has_id(table,id) do
        case :mnesia.dirty_read(table,id) do
        [_] ->
            true
        _ ->
            false
        end
    end


    def wait_for_load() do
        GenServer.call(__MODULE__,wait_for_load, @load_time + 1000 )
    end


    use GenServer

	def start() do
        :mnesia.create_schema([node()])
        :mnesia.start()

        GenServer.start(__MODULE__,nil,[name: __MODULE__])
	end

    def stop() do

    end

	def init(_) do
        :mnesia.create_table(:keys, [
            {:attributes, [:name,:index]},
            {:disc_copies,[node()]},
            {:storage_properties,
            [{:ets, [:compressed]}, {:dets, [{:auto_save, @save_time}]} ]
            }])

		state = [:keys]
		{:ok, state}
	end

    def handle_call(:wait_for_load,_from,state) do
        :mnesia.wait_for_tables(state, @load_time)
		{:reply,nil,state}
	end

    def handle_call({:table,table},_from,state) do
		{:reply,nil,[table|state]}
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
        Server.restart_server(DataBase)

        Tools.log(reason)
        :ok
    end
end
