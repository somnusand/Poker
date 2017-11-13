
require Tools


defmodule Cfg do

 	def start() do
 		load_cfgs("config_data/")
 		load_cfgs("config_server/")
    end

    def stop() do
    end


    defp load_cfgs(path) do

        case File.ls(path) do
        {:ok,files}  ->
     		Enum.each(files,fn(file)->
     			if String.contains?(file,".cfg") do
     				load_cfg(path , file)
     			end
     		end)
        _ ->
            Tools.log({"can't find:",path})
        end
    end


    def get_number(id) do
        get_field(:cfg_server,id,1)
    end

    def get_string(id) do
        get_field(:cfg_server,id,2)
    end

 	def get(table,id) do
 		case :ets.lookup(table,id)do
 		[record] ->
 			record
 		_ ->
 			nil
 		end
 	end


    def set(id,value) when is_number(value) do
        set_field(:cfg_server,id,1,value)
    end

    def set(id,value) do
        set_field(:cfg_server,id,2,value)
    end


 	def get_field(table,id,filed) when is_atom(id) do
 		try do
 			:ets.lookup_element(table, id, filed+1)
 		rescue
 			_ ->
 				nil
 		end
 	end

    def get_field(table,id,filed) do
 		try do
            id = String.to_atom(id)
 			:ets.lookup_element(table, id, filed+1)
 		rescue
 			_ ->
 				nil
 		end
 	end

    def set_field(table,id,filed,value) when is_atom(id) do
 		try do
 			:ets.update_element(table, id, {filed+1,value})
 		rescue
 			_ ->
 				nil
 		end
 	end

    def set_field(table,id,filed,value) do
 		try do
            id = String.to_atom(id)
 			:ets.update_element(table, id, {filed+1,value})
 		rescue
 			_ ->
 				nil
 		end
 	end


 	def match(table,list,base_quest,get_field_id) do
		ets_qs =
		List.foldl(list,base_quest,fn({id,value},acc)->
			put_elem(acc,get_field_id.(id),value)
		end)
		:ets.match_object(table,ets_qs)
	end

	def find(table,list,base_quest,get_field_id) do

		ets_qs =
		List.foldl(list,[],fn(q,acc)->
			{v1,op,v2} =  q

			id1  = get_field_id.(v1)
			id2  = get_field_id.(v2)

			id1 = "$" <> to_string(id1+1)
			id1 = String.to_atom(id1)

			ets_q =
			if id2 == nil do
				{op,id1,v2}
			else
				id2 = "$" <> to_string(id2+1)
				id2 = String.to_atom(id2)
				{op,id1,id2}
			end
			[ets_q|acc]
		end)


		q = [{base_quest,ets_qs,[:"$_"]}]

		:ets.select(table,q)
	end


 	defp load_cfg(path,file) do
 		#Tools.log("load config: " <> file)

 		{:ok,bin} =  File.read(path <> file)

 		lines = String.split(bin,"\n")

        [_,types|lines] = lines
 	# 	[names,types|lines] = lines
        #
 	# 	names =  String.split(names,",")
 	# 	names = Enum.map(names,fn(v)->
 	# 		String.to_atom(v)
 	# 	end)

 		types =  String.split(types,",")
 		types = Enum.map(types,fn(v)->
 			String.to_atom(v)
 		end)


 		[file_name|_] = String.split(file,".")
 		file_name = "cfg_" <> file_name

 		table = String.to_atom(file_name)
 		:ets.new(table,[:set,:named_table,:public])

 		Enum.map(lines,fn(v)->
 			values =  String.split(v,",")

 			values = Tools.list_fold_2(types,values,[],fn(type,value,acc)->
 				value = case type do
 				:string ->
 					value
 				:enum ->
 					String.to_atom(value)
 				:bool ->
 					case value do
 					"true" ->
 						true
 					"TRUE" ->
 						true
 					_ ->
 						false
 					end
                :key ->
                    toKeyValue(value)
                :list ->
                    toListValue(value)
 				_ ->
 					toValue(value)
 				end

 				acc ++ [value]
 			end)
 			:ets.insert(table, List.to_tuple(values))
        end)
 	end

    defp toKeyValue(data) do
        case Integer.parse(data) do
        {value,""} ->
            value
        _ ->
            case Float.parse(data) do
            {value,""} ->
                value
            _ ->
                String.to_atom(data)
            end
        end
    end

    defp toValue(data) do
        case Integer.parse(data) do
        {value,""} ->
            value
        _ ->
            case Float.parse(data) do
            {value,""} ->
                value
            _ ->
                data
            end
        end
    end

    defp toListValue(value) do
        values =  String.split(value,";")
        Enum.map(values,fn(v)->
            toValue(v)
        end)
    end
end
