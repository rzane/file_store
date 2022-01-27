defmodule FileStore.Error do
  defexception [:reason, :key, :action]

  @common_posix ~w(eacces eexist enoent enospc enotdir)a

  @impl true
  def message(%{action: action, key: nil, reason: reason}) do
    "could not #{action}: #{format(reason)}"
  end

  def message(%{action: action, reason: reason, key: key}) do
    "could not #{action} #{inspect(key)}: #{format(reason)}"
  end

  @doc false
  def format(reason) when reason in @common_posix do
    reason |> :file.format_error() |> IO.iodata_to_binary()
  end

  def format(reason) do
    inspect(reason)
  end
end

defmodule FileStore.UploadError do
  defexception [:reason, :path, :key]

  @impl true
  def message(%{reason: reason, path: path, key: key}) do
    reason = FileStore.Error.format(reason)
    "could not upload file #{inspect(path)} to key #{inspect(key)}: #{reason}"
  end
end

defmodule FileStore.DownloadError do
  defexception [:reason, :path, :key]

  @impl true
  def message(%{reason: reason, path: path, key: key}) do
    reason = FileStore.Error.format(reason)
    "could not download key #{inspect(key)} to file #{inspect(path)}: #{reason}"
  end
end

defmodule FileStore.CopyError do
  defexception [:reason, :src, :dest]

  @impl true
  def message(%{reason: reason, src: src, dest: dest}) do
    reason = FileStore.Error.format(reason)
    "could not copy #{inspect(src)} to #{inspect(dest)}: #{reason}"
  end
end

defmodule FileStore.RenameError do
  defexception [:reason, :src, :dest]

  @impl true
  def message(%{reason: reason, src: src, dest: dest}) do
    reason = FileStore.Error.format(reason)
    "could not rename #{inspect(src)} to #{inspect(dest)}: #{reason}"
  end
end
