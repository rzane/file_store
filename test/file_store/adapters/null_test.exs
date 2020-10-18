defmodule FileStore.Adapters.NullTest do
  use ExUnit.Case

  alias FileStore.Adapters.Null

  setup do
    {:ok, store: Null.new()}
  end

  test "get_public_url/2", %{store: store} do
    assert FileStore.get_public_url(store, "foo") == "foo"
  end

  test "get_signed_url/2", %{store: store} do
    assert FileStore.get_signed_url(store, "foo") == {:ok, "foo"}
  end

  test "write/3", %{store: store} do
    assert :ok = FileStore.write(store, "foo", "bar")
  end

  test "read/3", %{store: store} do
    assert :ok = FileStore.write(store, "foo", "bar")
    assert FileStore.read(store, "foo") == {:ok, ""}
  end

  test "download/3", %{store: store} do
    assert :ok = FileStore.download(store, "foo", "download.txt")
  end

  test "upload/3", %{store: store} do
    assert :ok = FileStore.upload(store, "upload.txt", "foo")
  end

  test "stat/2", %{store: store} do
    assert :ok = FileStore.write(store, "foo", "bar")
    assert {:ok, stat} = FileStore.stat(store, "foo")
    assert stat.key == "foo"
    assert stat.size == 0
    assert stat.etag == "d41d8cd98f00b204e9800998ecf8427e"
  end

  test "list/0", %{store: store} do
    assert Enum.to_list(FileStore.list!(store)) == []
  end
end
