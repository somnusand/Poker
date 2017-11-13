#!/bin/sh

pkill -9 elixir

elixir --detached -S mix run --no-halt main.exs
