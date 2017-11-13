
defmodule Proto do
	import BaseRead, only: :functions
	def on_message(state,bin) do
		{n,bin} = read_byte(bin)
		on_message(n,state,bin)
	end
	def on_message(0,state,bin) do
		Proto.Account.on_message(state,bin)
	end
	def on_message(1,state,bin) do
		Proto.Room.on_message(state,bin)
	end
	def on_message(2,state,bin) do
		Proto.User.on_message(state,bin)
	end
end
