defmodule FileStore.Adapters.S3Test do
  use FileStore.AdapterCase
  alias FileStore.Adapters.S3

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
