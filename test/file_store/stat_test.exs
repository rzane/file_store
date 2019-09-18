defmodule FileStore.StatTest do
  use ExUnit.Case
  alias FileStore.Stat

  test "checksum/1" do
    assert Stat.checksum("foo") == "acbd18db4cc2f85cedef654fccc4a4d8"
  end

  test "checksum_file/1" do
    assert Stat.checksum("test/fixtures/test.txt") == "d04792c42849660322276ec1c0d52057"
  end
end
