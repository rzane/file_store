defmodule FileStore.Stat do
  @moduledoc """
  A struct that holds file information.

  ### Fields

    * `key` - The unique identifier for the file.

    * `etag` - A fingerprint for the contents of a file.
      This is almost always an MD5 checksum.

    * `size` - The byte size of the file.

    * `type` - The content-type of the file.

  """

  @enforce_keys [:key, :size, :etag, :type]
  defstruct [:key, :size, :etag, :type]

  @type t :: %__MODULE__{
          key: binary,
          etag: binary,
          size: non_neg_integer,
          type: binary
        }

  @doc """
  Compute an MD5 checksum.

  ### Example

      iex> FileStore.Stat.checksum("hello world")
      "5eb63bbbe01eeed093cb22bb8f5acdc3"

  """
  @spec checksum(binary | Enumerable.t()) :: binary
  def checksum(data) when is_binary(data) do
    :md5
    |> :crypto.hash(data)
    |> Base.encode16()
    |> String.downcase()
  end

  def checksum(data) do
    data
    |> Enum.reduce(:crypto.hash_init(:md5), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

  @doc """
  Compute the MD5 checksum of a file on disk.

  ### Example

      iex> FileStore.Stat.checksum_file("test/fixtures/test.txt")
      {:ok, "0d599f0ec05c3bda8c3b8a68c32a1b47"}

      iex> FileStore.Stat.checksum_file("test/fixtures/missing.txt")
      {:error, :enoent}

  """
  @spec checksum_file(Path.t()) :: {:ok, binary} | {:error, File.posix()}
  def checksum_file(path) do
    {:ok, path |> stream!() |> checksum()}
  rescue
    e in [File.Error] -> {:error, e.reason}
  end

  # In v1.16 `File.stream!/3` changed the ordering of its parameters. In order
  # to avoid any deprecation warnings going forward, we need to flip out the
  # implementation.
  if Version.compare(System.version(), "1.16.0") in [:gt, :eq] do
    defp stream!(path), do: File.stream!(path, 2048, [])
  else
    defp stream!(path), do: File.stream!(path, [], 2048)
  end
end
