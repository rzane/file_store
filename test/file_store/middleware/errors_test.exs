defmodule FileStore.Middleware.ErrorsTest do
  use FileStore.AdapterCase

  @config [base_url: "http://localhost:4000"]

  setup do
    start_supervised!(FileStore.Adapters.Memory)
    store = FileStore.Adapters.Memory.new(@config)
    store = FileStore.Middleware.Errors.new(store)
    {:ok, store: store}
  end

  describe "exceptions" do
    setup do
      store = FileStore.Adapters.Error.new()
      store = FileStore.Middleware.Errors.new(store)
      {:ok, store: store}
    end

    test "write/4", %{store: store} do
      error = %FileStore.Error{
        action: "write to key",
        key: "key",
        reason: :boom
      }

      assert {:error, ^error} = FileStore.write(store, "key", "content")
    end

    test "read/2", %{store: store} do
      error = %FileStore.Error{
        action: "read key",
        key: "key",
        reason: :boom
      }

      assert {:error, ^error} = FileStore.read(store, "key")
    end

    test "upload/3", %{store: store} do
      error = %FileStore.UploadError{
        path: "path",
        key: "key",
        reason: :boom
      }

      assert {:error, ^error} = FileStore.upload(store, "path", "key")
    end

    test "download/3", %{store: store} do
      error = %FileStore.DownloadError{
        path: "path",
        key: "key",
        reason: :boom
      }

      assert {:error, ^error} = FileStore.download(store, "key", "path")
    end

    test "stat/2", %{store: store} do
      error = %FileStore.Error{
        action: "read stats for key",
        key: "key",
        reason: :boom
      }

      assert {:error, ^error} = FileStore.stat(store, "key")
    end

    test "delete/2", %{store: store} do
      error = %FileStore.Error{
        action: "delete key",
        key: "key",
        reason: :boom
      }

      assert {:error, ^error} = FileStore.delete(store, "key")
    end

    test "delete_all/1", %{store: store} do
      error = %FileStore.Error{
        action: "delete all keys",
        key: nil,
        reason: :boom
      }

      assert {:error, ^error} = FileStore.delete_all(store)
    end

    test "delete_all/2", %{store: store} do
      error = %FileStore.Error{
        action: "delete keys matching prefix",
        key: "key",
        reason: :boom
      }

      assert {:error, ^error} = FileStore.delete_all(store, prefix: "key")
    end

    test "copy/3", %{store: store} do
      error = %FileStore.CopyError{
        src: "src",
        dest: "dest",
        reason: :boom
      }

      assert {:error, ^error} = FileStore.copy(store, "src", "dest")
    end

    test "rename/3", %{store: store} do
      error = %FileStore.RenameError{
        src: "src",
        dest: "dest",
        reason: :boom
      }

      assert {:error, ^error} = FileStore.rename(store, "src", "dest")
    end

    test "get_signed_url/3", %{store: store} do
      error = %FileStore.Error{
        action: "generate signed URL for key",
        key: "key",
        reason: :boom
      }

      assert {:error, ^error} = FileStore.get_signed_url(store, "key")
    end
  end
end
