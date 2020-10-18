defmodule FileStore.ConfigTest do
  use ExUnit.Case

  defmodule InlineConfig do
    use FileStore.Config,
      otp_app: :my_app,
      adapter: FileStore.Adapters.Memory,
      base_url: "http://example.com"
  end

  defmodule ApplicationConfig do
    use FileStore.Config,
      otp_app: :my_app,
      adapter: FileStore.Adapters.Memory
  end

  test "new/0 with inline configuration" do
    assert InlineConfig.new() == %FileStore.Adapters.Memory{base_url: "http://example.com"}
  end

  test "new/0 with application config" do
    Application.put_env(:my_app, ApplicationConfig, base_url: "http://example.com")
    assert ApplicationConfig.new() == %FileStore.Adapters.Memory{base_url: "http://example.com"}
  end
end
