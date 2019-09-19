defmodule FileStore.StatTest do
  use ExUnit.Case
  alias FileStore.Stat

  test "checksum/1" do
    assert Stat.checksum("foo") == "acbd18db4cc2f85cedef654fccc4a4d8"
  end

  test "checksum_file/1" do
    assert Stat.checksum_file("test/fixtures/test.txt") ==
             {:ok, "0d599f0ec05c3bda8c3b8a68c32a1b47"}
  end
end
