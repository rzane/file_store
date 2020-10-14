defmodule FileStore.Adapters.S3Test do
  use FileStore.AdapterCase
  alias FileStore.Adapters.S3

  @region "us-east-1"
  @bucket "filestore"
  @prefix "prefix"
  @url "https://filestore.s3-us-east-1.amazonaws.com/foo"
  @prefixed_url "https://filestore.s3-us-east-1.amazonaws.com/prefix/foo"

  setup do
    {:ok, _} = Application.ensure_all_started(:hackney)
    {:ok, _} = ensure_bucket_exists()
    {:ok, store: FileStore.new(adapter: S3, bucket: @bucket)}
  end

  test "get_public_url/2", %{store: store} do
    assert FileStore.get_public_url(store, "foo") == @url
  end

  test "get_signed_url/2", %{store: store} do
    assert {:ok, url} = FileStore.get_signed_url(store, "foo")
    assert get_path(url) == "/filestore/foo"
    assert get_query(url, "X-Amz-Expires") == "3600"
  end

  test "get_signed_url/2 with custom expiration", %{store: store} do
    assert {:ok, url} = FileStore.get_signed_url(store, "foo", expires_in: 4000)
    assert get_path(url) == "/filestore/foo"
    assert get_query(url, "X-Amz-Expires") == "4000"
  end

  test "list/2 respects trailing slashes", %{store: store} do
    assert :ok = FileStore.write(store, "bar", "")
    assert :ok = FileStore.write(store, "foo", "")
    assert :ok = FileStore.write(store, "foo/bar", "")

    keys = Enum.to_list(FileStore.list!(store, prefix: "foo"))
    refute "bar" in keys
    assert "foo" in keys
    assert "foo/bar" in keys

    keys = Enum.to_list(FileStore.list!(store, prefix: "foo/"))
    refute "bar" in keys
    refute "foo" in keys
    assert "foo/bar" in keys
  end

  describe "with a prefix" do
    setup do
      {:ok, store: FileStore.new(adapter: S3, bucket: @bucket, prefix: @prefix)}
    end

    test "get_public_url/2", %{store: store} do
      assert FileStore.get_public_url(store, "foo") == @prefixed_url
    end

    test "get_signed_url/2", %{store: store} do
      assert {:ok, url} = FileStore.get_signed_url(store, "foo")
      assert get_path(url) == "/filestore/prefix/foo"
      assert get_query(url, "X-Amz-Expires") == "3600"
    end

    test "get_signed_url/2 with custom expiration", %{store: store} do
      assert {:ok, url} = FileStore.get_signed_url(store, "foo", expires_in: 4000)
      assert get_path(url) == "/filestore/prefix/foo"
      assert get_query(url, "X-Amz-Expires") == "4000"
    end

    test "list/2 lists files", %{store: store} do
      assert :ok = FileStore.write(store, "foo", "")
      assert "prefix/foo" in Enum.to_list(FileStore.list!(store))
    end

    test "list/2 respects prefix option", %{store: store} do
      assert :ok = FileStore.write(store, "bar", "")
      assert :ok = FileStore.write(store, "foo", "")
      assert :ok = FileStore.write(store, "foo/bar", "")

      keys = Enum.to_list(FileStore.list!(store, prefix: "foo"))
      refute "prefix/bar" in keys
      assert "prefix/foo" in keys
      assert "prefix/foo/bar" in keys

      keys = Enum.to_list(FileStore.list!(store, prefix: "foo/"))
      refute "prefix/bar" in keys
      refute "prefix/foo" in keys
      assert "prefix/foo/bar" in keys
    end
  end

  defp get_query(url, param) do
    url
    |> URI.parse()
    |> Map.fetch!(:query)
    |> URI.decode_query()
    |> Map.fetch!(param)
  end

  defp get_path(url) do
    url
    |> URI.parse()
    |> Map.fetch!(:path)
  end

  defp ensure_bucket_exists do
    @bucket
    |> ExAws.S3.head_bucket()
    |> ExAws.request()
    |> case do
      {:ok, resp} -> {:ok, resp}
      {:error, _} -> create_bucket()
    end
  end

  defp create_bucket do
    @bucket
    |> ExAws.S3.put_bucket(@region)
    |> ExAws.request()
  end
end
