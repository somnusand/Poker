
require Logger

defmodule Tools do

 	def list_fold_2([a|list1],[b|list2],acc,fun) do
		acc = fun.(a,b,acc)
		list_fold_2(list1,list2,acc,fun)
	end

	def list_fold_2(_,_,acc,_) do
		acc
	end

	def list_fold_3([a|list1],[b|list2],[c|list3],acc,fun) do
		acc = fun.(a,b,c,acc)
		list_fold_3(list1,list2,list3,acc,fun)
	end

	def list_fold_3(_,_,_,acc,_) do
		acc
	end

    def list_map_2([a|list1],[b|list2],fun) do
		r = fun.(a,b)
		[r|list_map_2(list1,list2,fun)]
	end

    def list_map_2([],_,_) do
        []
    end

    def list_map_2(_,[],_) do
        []
    end

    defmacro db_table({r,_,_},indexs) do
		quote do
             l = unquote(r)(unquote(r)())
             fileds = Enum.map(l,fn({key,_})-> key end)

             DataBase.db_table(unquote(r),fileds,unquote(indexs))
        end
    end

    defmacro db_table({r,_,_}) do
		quote do
             l = unquote(r)(unquote(r)())
             fileds = Enum.map(l,fn({key,_})-> key end)

             DataBase.db_table(unquote(r),fileds)
        end
    end

    defmacro disk_table({r,_,_}) do
		quote do
             l = unquote(r)(unquote(r)())
             fileds = Enum.map(l,fn({key,_})-> key end)

             DataBase.disk_table(unquote(r),fileds)
        end
    end

    defmacro mem_table({r,_,_}) do
		quote do
             l = unquote(r)(unquote(r)())
             fileds = Enum.map(l,fn({key,_})-> key end)

             DataBase.mem_table(unquote(r),fileds)
        end
    end

	defmacro log(term) do
		quote do
			list = String.split(__ENV__.file,"/")
			file_name = List.last(list)
			Tools.putout_log "[file:" <> to_string(file_name)
				<> " line:"
				<> to_string(__ENV__.line) <> "] "
				<> Macro.to_string(unquote(term))
		end
	end

	defmacro error(term) do
		quote do
			list = String.split(__ENV__.file,"/")
			file_name = List.last(list)
			Tools.putout_log "[error -> file:" <> to_string(file_name)
				<> " line:"
				<> to_string(__ENV__.line) <> "] "
				<> Macro.to_string(unquote(term))
		end
	end

	defmacro debug(term) do
		quote do
			list = String.split(__ENV__.file,"/")
			file_name = List.last(list)
			Tools.putout_log "[debug -> file:" <> to_string(file_name)
				<> " line:"
				<> to_string(__ENV__.line) <> "] "
				<> Macro.to_string(unquote(term))
		end
	end

    def putout_log(str) do
        IO.puts(str)
        #Logger.info str
        str = str <> "\n"
        Log.log str
    end


    def get_now() do
        System.os_time(:milliseconds) / 1000
    end

    # def get_now() do
    #     {t1,t2,t3} = :erlang.now()
    #     t1 * 1000000 + t2 + t3 / 1000000
    # end

    # def get_now() do
    #     now = System.os_time() / 1000000
    #     now / 1000
    # end

    def get_day_count(date1,date2) do
        n1  = :calendar.date_to_gregorian_days(date1)
        n2  = :calendar.date_to_gregorian_days(date2)
        n1 - n2
    end

    def get_now_str() do
        {{y,m,d},{h,s,mm}} = :erlang.localtime()
        get_datetime_str({{y,m,d},{h,s,mm}})
    end

    def get_datetime_str(date,time) do
        get_datetime_str({date,time})
    end

    def get_datetime_str({{y,m,d},{h,s,mm}}) do
        h = Tools.zero_string(h,2)
        s = Tools.zero_string(s,2)
        mm = Tools.zero_string(mm,2)
        "#{y}-#{m}-#{d} #{h}:#{s}:#{mm}"
    end

    def zero_string(number,n) do
        str = to_string(number)
        len = String.length(str)
        if len < n do
            zero_string_add(n-len,str)
        else
            str
        end
    end

    defp zero_string_add(0,str) do
        str
    end

    defp zero_string_add(n,str) do
        str = <<"0",str::binary>>
        zero_string_add(n-1,str)
    end

    def inc_date(date) do
        n = :calendar.date_to_gregorian_days(date)
        n = n + 1
        :calendar.gregorian_days_to_date(n)
    end

    def add_date(date,n) do
        date_n = :calendar.date_to_gregorian_days(date)
        date_n= date_n + n
        :calendar.gregorian_days_to_date(date_n)
    end

    def to_int(id) when is_integer(id) do
        id
    end

    def to_int(id) do
        try do
            String.to_integer(id)
        catch
        _, _ ->
            0
        end
    end

    def get_date(d) do
        case String.split(d, "-") do
        [a,b,c] ->
            {to_int(a),to_int(b),to_int(c)}
        _ ->
            nil
        end
    end

    def get_date_str({y,m,d}) do
        "#{y}-#{m}-#{d}"
    end

    def get_map_list_count(m,key) do
        case m[key] do
        nil ->
            0
        data ->
            if is_list(data) do
                length(data)
            else
                data
            end
        end
    end

end
