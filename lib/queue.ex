defmodule Queue do
  use GenServer
  require Logger

  # CLIENT
  def start_link(start_value) when is_list(start_value) do
    GenServer.start_link(__MODULE__, start_value, name: __MODULE__)
  end

  def enqueue(pid, element) do
    Logger.info("enqueue() called", ansi_color: :green)
    GenServer.cast(pid, {:enqueue, element})
  end

  def dequeue(pid) do
    Logger.info("dequeue() called", ansi_color: :red)
    GenServer.call(pid, :dequeue)
  end

  # SERVER CALLBACKS
  @impl true
  def init(queue) do
    Logger.info("Queue started at #{DateTime.utc_now()}", ansi_color: :yellow)
    IO.inspect(queue, label: "Initial value: ")
    scheduler()
    {:ok, queue}
  end

  @impl true
  # ASYNC
  def handle_cast({:enqueue, element}, queue) do
    Logger.info("Enqueuing ... #{element}", ansi_color: :green)
    {:noreply, [element | queue]}
  end

  @impl true
  # SYNC
  def handle_call(:dequeue, _from, [head | tail]) do
    Logger.info("Dequeuing #{head}", ansi_color: :red)
    {:reply, head, tail}
  end

  @impl true
  # SYNC
  def handle_call(:dequeue, _from, []) do
    Logger.info("Dequeuing nil", ansi_color: :red)
    {:reply, nil, []}
  end

  @impl true
  def handle_info(_message, state) do
    Logger.info("[#{Date.utc_today()}] - queue/dequeue", ansi_color: :yellow)

    Process.send(__MODULE__, {:enqueue, Enum.random(1..1_000)}, [])
    scheduler(10)

    Process.send(__MODULE__, :dequeue, [])
    scheduler(15)
    {:noreply, state}
  end

  def scheduler(time \\ 10) do
    Logger.info("scheduler() called", ansi_color: :yellow)
    Process.send_after(self(), :queue_or_dequeue, 1000 * time)
  end
end
