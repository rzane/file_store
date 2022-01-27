defmodule FileStore.Adapters.MemoryTest do
  use FileStore.AdapterCase

  alias FileStore.Adapters.Memory

  @url "http://localhost:4000/foo"

  setup do
    start_supervised!(Memory)
    {:ok, store: Memory.new(base_url: "http://localhost:4000")}
  end

  test "get_public_url/3 with query params", %{store: store} do
    opts = [content_type: "text/plain", disposition: "attachment"]
    url = FileStore.get_public_url(store, "foo", opts)
    assert omit_query(url) == @url
    assert get_query(url, "content_type") == "text/plain"
    assert get_query(url, "disposition") == "attachment"
  end

  test "get_signed_url/3 with query params", %{store: store} do
    opts = [content_type: "text/plain", disposition: "attachment"]
    assert {:ok, url} = FileStore.get_signed_url(store, "foo", opts)
    assert omit_query(url) == @url
    assert get_query(url, "content_type") == "text/plain"
    assert get_query(url, "disposition") == "attachment"
  end

  describe "copy/3" do
    test "copies a file", %{store: store} do
      :ok = FileStore.write(store, "foo", "test")

      assert :ok = FileStore.copy(store, "foo", "bar")
      assert {:ok, "test"} = FileStore.read(store, "foo")
    end

    test "fails to copy a non existing file", %{store: store} do
      assert {:error, :enoent} = FileStore.copy(store, "doesnotexist.txt", "shouldnotexist.txt")
    end

    test "copy replaces existing file", %{store: store} do
      :ok = FileStore.write(store, "foo", "test")
      :ok = FileStore.write(store, "bar", "i exist")

      assert :ok = FileStore.copy(store, "foo", "bar")
      assert {:ok, "test"} = FileStore.read(store, "bar")
    end
  end

  describe "rename/3" do
    test "renames a file", %{store: store} do
      :ok = FileStore.write(store, "foo", "test")

      assert :ok = FileStore.rename(store, "foo", "bar")
      assert {:error, _} = FileStore.stat(store, "foo")
      assert {:ok, _} = FileStore.stat(store, "bar")
    end

    test "fails to rename a non existing file", %{store: store} do
      assert {:error, :enoent} = FileStore.rename(store, "doesnotexist.txt", "shouldnotexist.txt")
    end

    test "rename replaces existing file", %{store: store} do
      :ok = FileStore.write(store, "foo", "test")
      :ok = FileStore.write(store, "bar", "i exist")

      assert :ok = FileStore.rename(store, "foo", "bar")
      assert {:error, _} = FileStore.stat(store, "foo")
      assert {:ok, _} = FileStore.stat(store, "bar")
    end
  end
end
