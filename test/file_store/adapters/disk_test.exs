defmodule FileStore.Adapters.DiskTest do
  use ExUnit.Case
  alias FileStore.Adapters.Disk, as: Adapter

  @key "test"
  @path "test/fixtures/test.txt"
  @content "blah"
  @url "http://localhost:4000/uploads/test"

  setup do
    tmp = Path.join(System.tmp_dir!(), "uploads")
    store = FileStore.new(adapter: Adapter, storage_path: tmp)

    # Make sure we're starting with a clean slate
    File.rm_rf!(tmp)

    [store: store, tmp: tmp]
  end

  test "get_public_url/2", %{store: store} do
    assert Adapter.get_public_url(store, @key) == {:ok, @url}
  end

  test "get_signed_url/2", %{store: store} do
    assert Adapter.get_signed_url(store, @key) == {:ok, @url}
  end

  test "copy/3", %{store: store, tmp: tmp} do
    assert :ok = Adapter.copy(store, @path, @key)
    assert File.exists?(Path.join(tmp, @key))
  end

  test "write/3", %{store: store, tmp: tmp} do
    assert :ok = Adapter.write(store, @key, @content)
    assert File.exists?(Path.join(tmp, @key))
    assert File.read!(Path.join(tmp, @key)) == @content
  end
end
