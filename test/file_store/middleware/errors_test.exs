defmodule FileStore.Middleware.ErrorsTest do
  use FileStore.AdapterCase

  @config [base_url: "http://localhost:4000"]

  setup do
    start_supervised!(FileStore.Adapters.Memory)
    store = FileStore.Adapters.Memory.new(@config)
    store = FileStore.Middleware.Errors.new(store)
    {:ok, store: store}
  end

  test "read/2 is wrapped", %{store: store} do
    assert {:error, error} = FileStore.read(store, "invalid")

    assert %FileStore.Error{} = error
    assert error.key == "invalid"
    assert error.action == "read key"
    assert error.reason == :enoent
  end

  test "upload/3 is wrapped", %{store: store} do
    assert {:error, error} = FileStore.upload(store, "invalid", "key")

    assert %FileStore.UploadError{} = error
    assert error.key == "key"
    assert error.path == "invalid"
    assert error.reason == :enoent
  end

  test "download/3 is wrapped", %{store: store} do
    assert {:error, error} = FileStore.download(store, "invalid", "path")

    assert %FileStore.DownloadError{} = error
    assert error.key == "invalid"
    assert error.path == "path"
    assert error.reason == :enoent
  end
end
