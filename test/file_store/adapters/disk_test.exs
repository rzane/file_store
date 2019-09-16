defmodule FileStore.Adapters.DiskTest do
  use ExUnit.Case
  alias FileStore.Adapters.Disk, as: Adapter

  @key "test"
  @path "test/fixtures/test.txt"
  @content "blah"
  @url "http://localhost:4000/uploads/test"

  @tmp Path.join(System.tmp_dir!(), "uploads")
  @upload Path.join(@tmp, @key)
  @download Path.join(@tmp, "download")
  @store FileStore.new(adapter: Adapter, storage_path: @tmp)

  setup do
    File.rm_rf!(@tmp)
    :ok
  end

  test "get_public_url/2" do
    assert Adapter.get_public_url(@store, @key) == @url
  end

  test "get_signed_url/2" do
    assert Adapter.get_signed_url(@store, @key) == {:ok, @url}
  end

  test "write/3" do
    assert :ok = Adapter.write(@store, @key, @content)
    assert File.exists?(@upload)
    assert File.read!(@upload) == @content
  end

  test "upload/3" do
    assert :ok = Adapter.upload(@store, @path, @key)
    assert File.exists?(@upload)
  end

  test "download/3" do
    assert :ok = Adapter.upload(@store, @path, @key)
    assert :ok = Adapter.download(@store, @key, @download)
    assert File.exists?(@download)
  end
end
