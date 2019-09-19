defmodule FileStoreTest do
  use ExUnit.Case
  alias FileStore.Adapters.Null, as: Adapter

  @key "test"
  @path "test/fixtures/test.txt"
  @content "blah"
  @store FileStore.new(adapter: Adapter, foo: "bar")

  test "new/1" do
    assert @store.adapter == Adapter
    assert @store.config.foo == "bar"
  end

  test "get_public_url/2" do
    assert FileStore.get_public_url(@store, @key) == @key
  end

  test "get_signed_url/2" do
    assert FileStore.get_signed_url(@store, @key) == {:ok, @key}
  end

  test "upload/3" do
    assert :ok = FileStore.upload(@store, @path, @key)
  end

  test "write/3" do
    assert :ok = FileStore.write(@store, @key, @content)
  end
end
