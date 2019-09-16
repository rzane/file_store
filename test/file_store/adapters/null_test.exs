defmodule FileStore.Adapters.NullTest do
  use ExUnit.Case
  alias FileStore.Adapters.Null, as: Adapter

  @key "test"
  @path "test/fixtures/test.txt"
  @content "blah"
  @download "foo"
  @store FileStore.new(adatper: Adapter)

  test "get_public_url/2" do
    assert Adapter.get_public_url(@store, @key) == @key
  end

  test "get_signed_url/2" do
    assert Adapter.get_signed_url(@store, @key) == {:ok, @key}
  end

  test "write/3" do
    assert :ok = Adapter.write(@store, @key, @content)
  end

  test "upload/3" do
    assert :ok = Adapter.upload(@store, @path, @key)
  end

  test "download/3" do
    assert :ok = Adapter.download(@store, @key, @download)
  end
end
