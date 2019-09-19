defmodule FileStore.ConfigTest do
  use ExUnit.Case

  defmodule Storage do
    use FileStore.Config,
      otp_app: :my_app,
      adapter: FileStore.Adapters.Memory
  end

  test "new/0" do
    assert Storage.new() == %FileStore{adapter: FileStore.Adapters.Memory, config: %{}}
  end
end
