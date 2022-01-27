defmodule FileStore.Adapters.S3Test do
  use FileStore.AdapterCase
  alias FileStore.Adapters.S3
  alias FileStore.Stat

  @region "us-east-1"
  @bucket "filestore"
  @url "http://filestore.localhost:9000/foo"

  setup do
    {:ok, _} = Application.ensure_all_started(:hackney)
    prepare_bucket!()
    {:ok, store: S3.new(bucket: @bucket)}
  end

  test "get_public_url/3", %{store: store} do
    assert FileStore.get_public_url(store, "foo") == @url
  end

  test "get_public_url/3 with query params", %{store: store} do
    opts = [content_type: "text/plain", disposition: "attachment"]
    url = FileStore.get_public_url(store, "foo", opts)
    assert omit_query(url) == @url
    assert get_query(url, "response-content-type") == "text/plain"
    assert get_query(url, "response-content-disposition") == "attachment"
  end

  test "get_signed_url/3", %{store: store} do
    assert {:ok, url} = FileStore.get_signed_url(store, "foo")
    assert omit_query(url) == @url
    assert get_query(url, "X-Amz-Expires") == "3600"
  end

  test "get_signed_url/3 with query params", %{store: store} do
    opts = [content_type: "text/plain", disposition: "attachment"]
    assert {:ok, url} = FileStore.get_signed_url(store, "foo", opts)
    assert omit_query(url) == @url
    assert get_query(url, "X-Amz-Expires") == "3600"
    assert get_query(url, "response-content-type") == "text/plain"
    assert get_query(url, "response-content-disposition") == "attachment"
  end

  test "get_signed_url/3 with custom expiration", %{store: store} do
    assert {:ok, url} = FileStore.get_signed_url(store, "foo", expires_in: 4000)
    assert omit_query(url) == @url
    assert get_query(url, "X-Amz-Expires") == "4000"
  end

  describe "write/4" do
    test "sends the content-type with the data written", %{store: store} do
      :ok = FileStore.write(store, "foo", "{}", content_type: "application/json")

      assert {:ok, %Stat{type: "application/json"}} = FileStore.stat(store, "foo")
    end

    test "not sending content-type does not return on stat", %{store: store} do
      :ok = FileStore.write(store, "foo", "test")

      assert {:ok, %Stat{type: "application/octet-stream"}} = FileStore.stat(store, "foo")
    end
  end

  describe "copy/3" do
    test "copies a file", %{store: store} do
      :ok = FileStore.write(store, "foo", "test")

      assert :ok = FileStore.copy(store, "foo", "bar")
      assert {:ok, "test"} = FileStore.read(store, "foo")
      assert {:ok, "test"} = FileStore.read(store, "bar")
    end

    test "fails to copy a non existing file", %{store: store} do
      assert {:error, {:http_error, 404, _}} =
               FileStore.copy(store, "doesnotexist.txt", "shouldnotexist.txt")
    end

    test "copy replaces existing file", %{store: store} do
      :ok = FileStore.write(store, "foo", "test")
      :ok = FileStore.write(store, "bar", "i exist")

      assert :ok = FileStore.copy(store, "foo", "bar")
      assert {:ok, "test"} = FileStore.read(store, "foo")
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
      assert {:error, {:http_error, 404, _}} =
               FileStore.rename(store, "doesnotexist.txt", "shouldnotexist.txt")
    end

    test "rename replaces existing file", %{store: store} do
      :ok = FileStore.write(store, "foo", "test")
      :ok = FileStore.write(store, "bar", "i exist")

      assert :ok = FileStore.rename(store, "foo", "bar")
      assert {:error, _} = FileStore.stat(store, "foo")
      assert {:ok, _} = FileStore.stat(store, "bar")
    end
  end

  defp prepare_bucket! do
    @bucket
    |> ExAws.S3.put_bucket(@region)
    |> ExAws.request()
    |> case do
      {:ok, _} -> :ok
      {:error, {:http_error, 409, _}} -> clean_bucket!()
      {:error, reason} -> raise "Failed to create bucket, error: #{inspect(reason)}"
    end
  end

  defp clean_bucket! do
    @bucket
    |> ExAws.S3.delete_all_objects(list_all_keys())
    |> ExAws.request()
    |> case do
      {:ok, _} -> :ok
      {:error, reason} -> raise "Failed to clean bucket, error: #{inspect(reason)}"
    end
  end

  defp list_all_keys do
    @bucket
    |> ExAws.S3.list_objects()
    |> ExAws.stream!()
    |> Stream.map(& &1.key)
  end
end
