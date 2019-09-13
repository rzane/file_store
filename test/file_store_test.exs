defmodule FileStoreTest do
  use ExUnit.Case
  doctest FileStore

  @adapter FileStore.Adapters.Null
  @store FileStore.new(adapter: @adapter, foo: "bar")

  test "new/1" do
    assert @store.adapter == @adapter
    assert @store.config.foo == "bar"
  end

  test "write/1" do
    assert FileStore.write(@store, "foo", "bar") == :ok
  end
end
