defmodule FileStore.Adapters.S3Test do
  use ExUnit.Case
  alias FileStore.Adapters.S3, as: Adapter

  @key "test"
  @content "blah"
  @region "us-east-1"
  @bucket "filestore"
  @path "test/fixtures/test.txt"
  @store FileStore.new(adapter: Adapter, bucket: @bucket)
  @url "https://filestore.s3-us-east-1.amazonaws.com/test"
  @download Path.join(System.tmp_dir!(), "s3-download")

  setup do
    {:ok, _} = Application.ensure_all_started(:hackney)
    :ok
  end

  test "get_public_url/2" do
    assert Adapter.get_public_url(@store, @key) == @url
  end

  test "get_signed_url/2" do
    assert {:ok, url} = Adapter.get_signed_url(@store, @key)
    assert get_query(url, "X-Amz-Expires") == "3600"
  end

  test "get_signed_url/2 with custom expiration" do
    assert {:ok, url} = Adapter.get_signed_url(@store, @key, expires_in: 4000)
    assert get_query(url, "X-Amz-Expires") == "4000"
  end

  test "write/3" do
    assert {:ok, _} = prepare_bucket()
    assert :ok = Adapter.write(@store, @key, @content)
    assert {:ok, _} = get_object(@key)
  end

  test "upload/3" do
    assert {:ok, _} = prepare_bucket()
    assert :ok = Adapter.upload(@store, @path, @key)
    assert {:ok, _} = get_object(@key)
  end

  test "download/3" do
    File.rm_rf!(@download)

    assert {:ok, _} = prepare_bucket()
    assert :ok = Adapter.upload(@store, @path, @key)
    assert :ok = Adapter.download(@store, @key, @download)
    assert File.exists?(@download)
  end

  defp get_query(url, param) do
    url
    |> URI.parse()
    |> Map.fetch!(:query)
    |> URI.decode_query()
    |> Map.fetch!(param)
  end

  defp get_object(key) do
    @bucket
    |> ExAws.S3.get_object(key)
    |> ExAws.request()
  end

  defp prepare_bucket do
    @bucket
    |> ExAws.S3.head_bucket()
    |> ExAws.request()
    |> case do
      {:ok, _} ->
        @bucket |> ExAws.S3.delete_object(@key) |> ExAws.request()

      _error ->
        @bucket |> ExAws.S3.put_bucket(@region) |> ExAws.request()
    end
  end
end
