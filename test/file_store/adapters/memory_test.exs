defmodule FileStore.Adapters.MemoryTest do
  use FileStore.AdapterCase

  alias FileStore.Adapters.Memory

  setup do
    start_supervised!(Memory)
    {:ok, store: FileStore.new(adapter: Memory)}
  end
end
