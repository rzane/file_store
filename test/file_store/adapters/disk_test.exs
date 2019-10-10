defmodule FileStore.Adapters.DiskTest do
  use FileStore.AdapterCase

  alias FileStore.Adapters.Disk

  setup %{tmp: tmp} do
    config = [
      adapter: Disk,
      storage_path: tmp,
      base_url: "http://localhost:4000"
    ]

    {:ok, store: FileStore.new(config)}
  end
end
