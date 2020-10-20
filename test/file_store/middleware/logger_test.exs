defmodule FileStore.Middleware.LoggerTest do
  use FileStore.AdapterCase
  import ExUnit.CaptureLog
  require Logger

  @config [base_url: "http://localhost:4000"]

  setup :silence_logger

  setup do
    start_supervised!(FileStore.Adapters.Memory)
    store = FileStore.Adapters.Memory.new(@config)
    store = FileStore.Middleware.Logger.new(store)
    {:ok, store: store}
  end

  test "logs a successful write", %{store: store} do
    Logger.configure(level: :debug)
    out = capture_log(fn -> FileStore.write(store, "foo", "bar") end)
    assert out =~ ~r/WRITE OK key="foo"/
  end

  test "logs a failed read", %{store: store} do
    Logger.configure(level: :debug)
    out = capture_log(fn -> FileStore.read(store, "none") end)
    assert out =~ ~r/READ ERROR key="none" error=:enoent/
  end

  defp silence_logger(_) do
    Logger.configure(level: :error)

    on_exit(fn ->
      Logger.configure(level: :debug)
    end)
  end
end
