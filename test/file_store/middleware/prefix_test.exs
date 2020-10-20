defmodule FileStore.Middleware.PrefixTest do
  use FileStore.AdapterCase

  alias FileStore.Adapters.Memory
  alias FileStore.Middleware.Prefix

  @config [base_url: "http://localhost:4000"]
  @plain Memory.new(@config)

  setup do
    start_supervised!(Memory)
    store = Memory.new(@config)
    store = Prefix.new(store, prefix: "prefix")
    {:ok, store: store}
  end

  test "adds a prefix to keys", %{store: store} do
    assert :ok = FileStore.write(store, "foo", "prefixed")
    assert {:ok, "prefixed"} = FileStore.read(@plain, "prefix/foo")
  end

  test "stat/2 removes prefix from the key", %{store: store} do
    assert :ok = FileStore.write(store, "foo", "bar")

    assert {:ok, stat} = FileStore.stat(store, "foo")
    assert stat.key == "foo"

    assert {:ok, stat} = FileStore.stat(@plain, "prefix/foo")
    assert stat.key == "prefix/foo"
  end

  test "list!/2 removes prefix from the key", %{store: store} do
    assert :ok = FileStore.write(store, "foo", "bar")
    assert "foo" in Enum.to_list(FileStore.list!(store))
    assert "prefix/foo" in Enum.to_list(FileStore.list!(@plain))
  end
end
