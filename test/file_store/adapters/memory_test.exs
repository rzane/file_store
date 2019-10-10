defmodule FileStore.Adapters.MemoryTest do
  use ExUnit.Case
  alias FileStore.Stat
  alias FileStore.Adapters.Memory, as: Adapter

  @key "test"
  @content "blah"
  @path "test/fixtures/test.txt"
  @etag "6f1ed002ab5595859014ebf0951522d9"
  @tmp Path.join(System.tmp_dir!(), "memory")
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

  test "write/3" do
    assert :ok = Adapter.write(@store, @key, @content)
  end

  test "read/3" do
    assert :ok = Adapter.write(@store, @key, @content)
    assert Adapter.read(@store, @key) == {:ok, @content}
  end

  test "upload/3" do
    assert :ok = Adapter.upload(@store, @path, @key)
  end

  test "download/3" do
    assert {:error, :enoent} = Adapter.download(@store, @key, @tmp)

    assert :ok = Adapter.write(@store, @key, @content)
    assert :ok = Adapter.download(@store, @key, @tmp)
    assert File.exists?(@tmp)
  end

  test "stat/2" do
    assert {:error, :enoent} = Adapter.stat(@store, @key)

    assert :ok = Adapter.write(@store, @key, @content)
    assert Adapter.stat(@store, @key) == {:ok, %Stat{key: @key, etag: @etag, size: 4}}
  end
end
