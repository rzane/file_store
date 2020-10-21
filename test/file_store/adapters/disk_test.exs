defmodule FileStore.Adapters.DiskTest do
  use FileStore.AdapterCase

  alias FileStore.Adapters.Disk

  @url "http://localhost:4000/foo"

  setup %{tmp: tmp} do
    {:ok, store: Disk.new(storage_path: tmp, base_url: "http://localhost:4000")}
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
end
