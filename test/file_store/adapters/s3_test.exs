defmodule FileStore.Adapters.S3Test do
  use FileStore.AdapterCase
  alias FileStore.Adapters.S3

  @region "us-east-1"
  @bucket "filestore"
  @url "https://filestore.s3-us-east-1.amazonaws.com/foo"

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
    assert get_query(url, "X-Amz-Expires") == "3600"
  end

  test "get_signed_url/2 with custom expiration", %{store: store} do
    assert {:ok, url} = FileStore.get_signed_url(store, "foo", expires_in: 4000)
    assert get_query(url, "X-Amz-Expires") == "4000"
  end

  defp get_query(url, param) do
    url
    |> URI.parse()
    |> Map.fetch!(:query)
    |> URI.decode_query()
    |> Map.fetch!(param)
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
