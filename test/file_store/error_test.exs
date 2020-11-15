defmodule FileStore.ErrorTest do
  use ExUnit.Case, async: true

  alias FileStore.Error
  alias FileStore.UploadError
  alias FileStore.DownloadError

  describe "FileStore.Error" do
    test "generates an error message" do
      error = %Error{key: "key", action: "read key", reason: "blah"}
      assert Exception.message(error) == "could not read key \"key\": \"blah\""
    end

    test "formats posix errors" do
      error = %Error{key: "key", action: "read key", reason: :enoent}

      assert Exception.message(error) ==
               "could not read key \"key\": no such file or directory"
    end
  end

  describe "UploadError" do
    test "generates an error message" do
      error = %UploadError{key: "key", path: "path", reason: "blah"}
      assert Exception.message(error) == "could not upload file \"path\" to key \"key\": \"blah\""
    end

    test "formats posix errors" do
      error = %UploadError{key: "key", path: "path", reason: :enoent}

      assert Exception.message(error) ==
               "could not upload file \"path\" to key \"key\": no such file or directory"
    end
  end

  describe "DownloadError" do
    test "generates an error message" do
      error = %DownloadError{key: "key", path: "path", reason: "blah"}

      assert Exception.message(error) ==
               "could not download key \"key\" to file \"path\": \"blah\""
    end

    test "formats posix errors" do
      error = %DownloadError{key: "key", path: "path", reason: :enoent}

      assert Exception.message(error) ==
               "could not download key \"key\" to file \"path\": no such file or directory"
    end
  end
end
