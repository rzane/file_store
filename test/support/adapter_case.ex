defmodule FileStore.AdapterCase do
  use ExUnit.CaseTemplate

  @tmp Path.join(System.tmp_dir!(), "file_store")

  setup do
    File.rm_rf!(@tmp)
    File.mkdir!(@tmp)
    {:ok, tmp: @tmp}
  end

  using do
    quote location: :keep do
      import FileStore.AdapterCase

      describe "write/3" do
        test "writes a file", %{store: store} do
          assert :ok = FileStore.write(store, "foo", "bar")
          assert {:ok, "bar"} = FileStore.read(store, "foo")
        end

        test "overwrites a file", %{store: store} do
          assert :ok = FileStore.write(store, "foo", "bar")
          assert {:ok, "bar"} = FileStore.read(store, "foo")

          assert :ok = FileStore.write(store, "foo", "baz")
          assert {:ok, "baz"} = FileStore.read(store, "foo")
        end
      end

      describe "upload/3" do
        test "uploads a file", %{store: store} do
          bar = write("bar.txt", "bar")

          assert :ok = FileStore.upload(store, bar, "foo")
          assert {:ok, "bar"} = FileStore.read(store, "foo")
        end

        test "overwrites a file", %{store: store} do
          bar = write("bar.txt", "bar")
          baz = write("baz.txt", "baz")

          assert :ok = FileStore.upload(store, bar, "foo")
          assert {:ok, "bar"} = FileStore.read(store, "foo")

          assert :ok = FileStore.upload(store, baz, "foo")
          assert {:ok, "baz"} = FileStore.read(store, "foo")
        end

        test "fails when the source file is missing", %{store: store} do
          assert {:error, _} = FileStore.upload(store, "doesnotexist.txt", "foo")
        end
      end

      describe "download/3" do
        test "downloads a file", %{store: store} do
          download = join("download.txt")

          assert :ok = FileStore.write(store, "foo", "bar")
          assert :ok = FileStore.download(store, "foo", download)
          assert File.read!(download) == "bar"
        end
      end

      describe "stat/2" do
        test "retrieves file info", %{store: store} do
          assert :ok = FileStore.write(store, "foo", "bar")
          assert {:ok, stat} = FileStore.stat(store, "foo")
          assert stat.key == "foo"
          assert stat.size == 3
          assert stat.etag == "37b51d194a7513e45b56f6524f2d51f2"
        end

        test "fails when the file is missing", %{store: store} do
          assert {:error, _} = FileStore.stat(store, "completegarbage")
        end
      end

      describe "delete/2" do
        test "deletes the file", %{store: store} do
          assert :ok = FileStore.write(store, "foo", "bar")
          assert :ok = FileStore.delete(store, "foo")
        end
      end

      describe "get_public_url/2" do
        test "returns a URL", %{store: store} do
          assert :ok = FileStore.write(store, "foo", "bar")
          assert url = FileStore.get_public_url(store, "foo")
          assert is_valid_url(url)
        end
      end

      describe "get_signed_url/3" do
        test "returns a URL", %{store: store} do
          assert :ok = FileStore.write(store, "foo", "bar")
          assert {:ok, url} = FileStore.get_signed_url(store, "foo")
          assert is_valid_url(url)
        end
      end

      describe "list/3" do
        test "lists keys in the store", %{store: store} do
          assert :ok = FileStore.write(store, "foo", "")
          assert "foo" in Enum.to_list(FileStore.list!(store))
        end

        test "lists nested keys in the store", %{store: store} do
          assert :ok = FileStore.write(store, "foo/bar", "")
          assert "foo/bar" in Enum.to_list(FileStore.list!(store))
        end
      end
    end
  end

  def join(name) do
    Path.join(@tmp, name)
  end

  def write(name, data) do
    path = join(name)
    File.write!(path, data)
    path
  end

  def is_valid_url(value) do
    case URI.parse(value) do
      %URI{scheme: nil} -> false
      %URI{host: nil} -> false
      %URI{scheme: scheme} -> scheme =~ ~r"^https?$"
    end
  end
end
