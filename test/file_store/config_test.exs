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

  defmodule MiddlewareConfig do
    use FileStore.Config,
      otp_app: :my_app,
      adapter: FileStore.Adapters.Memory,
      base_url: "http://example.com",
      middleware: [{FileStore.Middleware.Prefix, prefix: "/foo"}]
  end

  test "new/0 with inline configuration" do
    assert InlineConfig.new() == %FileStore.Adapters.Memory{base_url: "http://example.com"}
  end

  test "new/0 with application config" do
    Application.put_env(:my_app, ApplicationConfig, base_url: "http://example.com")
    assert ApplicationConfig.new() == %FileStore.Adapters.Memory{base_url: "http://example.com"}
  end

  test "new/0 with a prefix" do
    assert MiddlewareConfig.new() == %FileStore.Middleware.Prefix{
             __next__: %FileStore.Adapters.Memory{base_url: "http://example.com"},
             prefix: "/foo"
           }
  end
end
