defmodule FileStore.Adapters.DiskTest do
  use FileStore.AdapterCase

  alias FileStore.Adapters.Disk

  setup %{tmp: tmp} do
    {:ok, store: Disk.new(storage_path: tmp, base_url: "http://localhost:4000")}
  end
end
