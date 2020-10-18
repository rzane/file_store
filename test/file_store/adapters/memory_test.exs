defmodule FileStore.Adapters.MemoryTest do
  use FileStore.AdapterCase

  alias FileStore.Adapters.Memory

  setup do
    start_supervised!(Memory)
    {:ok, store: Memory.new(base_url: "http://localhost:3000")}
  end
end
