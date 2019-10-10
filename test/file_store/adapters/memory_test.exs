defmodule FileStore.Adapters.MemoryTest do
  use FileStore.AdapterCase

  alias FileStore.Adapters.Memory

  setup do
    config = [
      adapter: Memory,
      base_url: "http://localhost:3000"
    ]

    start_supervised!(Memory)
    {:ok, store: FileStore.new(config)}
  end
end
