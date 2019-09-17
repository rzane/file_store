defmodule FileStore.Stat do
  @enforce_keys [:key]
  defstruct [:key, :size, :etag]

  @type t() :: %__MODULE__{
          key: binary(),
          etag: binary() | nil,
          size: non_neg_integer() | nil
        }

  @doc """
  Compute the MD5 checksum of a file on disk.
  """
  @spec compute_checksum(Path.t()) :: {:ok, binary()} | {:error, %File.Error{}}
  def compute_checksum(path) do
    path
    |> File.stream!([], 2_048)
    |> Enum.reduce(:crypto.hash_init(:md5), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
    |> (fn v -> {:ok, v} end).()
  rescue
    error in [File.Error] -> {:error, error}
  end
end
