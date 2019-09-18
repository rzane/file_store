defmodule FileStore.Stat do
  @enforce_keys [:key]
  defstruct [:key, :size, :etag]

  @type t() :: %__MODULE__{
          key: binary(),
          etag: binary() | nil,
          size: non_neg_integer() | nil
        }

  @doc """
  Compute the MD5 checksum.
  """
  @spec checksum(binary() | Enum.t()) :: binary()
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
  """
  @spec checksum_file(Path.t()) :: {:ok, binary()} | {:error, File.posix()}
  def checksum_file(path) do
    {:ok, path |> File.stream!() |> checksum()}
  rescue
    e in [File.Error] -> {:error, e.reason}
  end
end
