


defmodule MapDB do
    @save_time 1000
    @load_time 10000

    def db_table(table) do
        :mnesia.create_table(table, [
		          {:attributes, [:id,:data]},
		          {:disc_copies,[node()]},
       	          {:storage_properties,
        	         [{:ets, [:compressed]}, {:dets, [{:auto_save, @save_time}]} ]}])
        #GenServer.call(__MODULE__,{:table,table})
        :mnesia.wait_for_tables([table], @load_time)
    end

    def db_table_order(table) do
        :mnesia.create_table(table, [
                  {:type,:ordered_set},
		          {:attributes, [:id,:data]},
		          {:disc_copies,[node()]},
       	          {:storage_properties,
        	         [{:ets, [:compressed]}, {:dets, [{:auto_save, @save_time}]} ]}])
        #GenServer.call(__MODULE__,{:table,table})
        :mnesia.wait_for_tables([table], @load_time)
    end

    def disk_table(table) do
        :mnesia.create_table(table, [
		          {:attributes, [:id,:data]},
		          {:disc_only_copies, [node()]},
       	          {:storage_properties,
        	      [{:dets, [{:auto_save, @save_time}]} ]
		}])
        :mnesia.wait_for_tables([table], @load_time)
    end

    def mem_table(table) do
        :mnesia.create_table(table, [
    		{:attributes, [:id,:data]},
    		{:ram_copies,[node()]},
           	{:storage_properties,
            	[{:ets, [:compressed]}]
    		}])
    end

    def dirty_read(table,id) do
        dirty_read(table,id,nil)
    end

    def dirty_read(table,id,defValue) do
        case :mnesia.dirty_read(table,id) do
        [r] ->
            elem(r,2)
        _ ->
            defValue
        end
    end




    def dirty_write(table,data) do
        :mnesia.dirty_write({table,data.id,data})
    end

    def dirty_write(table,data,key) do
        :mnesia.dirty_write({table,key,data})
    end

    def dirty_delete(table,id) do
        :mnesia.dirty_delete(table,id)
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
            if ret == nil do
                nil
            else
                elem(ret,2)
            end
        _ ->
            nil
        end
    end


    def write(table,data) do
        fun = fn() ->
            :mnesia.write({table,data.id,data})
        end
        :mnesia.transaction(fun)
    end
end
