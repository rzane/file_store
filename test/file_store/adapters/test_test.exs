defmodule FileStore.Adapters.TestTest do
  use ExUnit.Case
  alias FileStore.Adapters.Test, as: Adapter

  @key "test"
  @path "test/fixtures/test.txt"
  @content "blah"
  @store FileStore.new(adapter: Adapter)

  setup do
    start_supervised!(Adapter)
    :ok
  end

  test "get_public_url/2" do
    assert Adapter.get_public_url(@store, @key) == @key
  end

  test "get_signed_url/2" do
    assert Adapter.get_signed_url(@store, @key) == {:ok, @key}
  end

  test "copy/3" do
    assert :ok = Adapter.copy(@store, @path, @key)
    assert @key in Adapter.list_keys()
  end

  test "write/3" do
    assert :ok = Adapter.write(@store, @key, @content)
    assert @key in Adapter.list_keys()
  end
end
