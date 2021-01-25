defmodule Interrupt do
  @moduledoc """
  Generated by erl2ex (http://github.com/dazuma/erl2ex)
  From Erlang source: (Unknown source file)
  At: 2019-12-20 13:57:25

  """

  def main() do
    server = start_server()
    :timer.sleep(5000)
    send(server, {:shutdown, self()})
    receive do
      {:ok, ^server} ->
        :ok
    end
  end


  def start_server() do
    :erlang.spawn(fn ->
      {:ok, context} = :erlzmq.context()
      {:ok, socket} = :erlzmq.socket(context, [:rep, {:active, true}])
      :ok = :erlzmq.bind(socket, 'tcp://*:5555')
      :io.format('Server started on port 5555~n')
      loop(context, socket)
    end)
  end


  def loop(context, socket) do
    receive do
      {:zmq, ^socket, msg, _flags} ->
        :erlzmq.send(socket, <<"You said: ", msg::binary>>)
        :timer.sleep(1000)
        loop(context, socket)
      {:shutdown, from} ->
        :io.format('Stopping server... ')
        :ok = :erlzmq.close(socket)
        :ok = :erlzmq.term(context)
        :io.format('done~n')
        send(from, {:ok, self()})
    end
  end

end

Interrupt.main