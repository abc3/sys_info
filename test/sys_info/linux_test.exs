defmodule SysInfo.LinuxTest do
  use ExUnit.Case, async: true
  alias SysInfo.Linux

  @tag :linux
  test "cpu_usage/0 returns a float" do
    if :os.type() == {:unix, :linux} do
      assert is_float(Linux.cpu_usage(10))
    else
      :ok
    end
  end

  @tag :linux
  test "memory_info/0 returns correct structure" do
    if :os.type() == {:unix, :linux} do
      info = Linux.memory_info()
      assert is_integer(info.total)
      assert is_integer(info.used)
      assert is_integer(info.free)
      assert is_float(info.percent)
    else
      :ok
    end
  end

  @tag :linux
  test "disk_info/1 returns correct structure" do
    if :os.type() == {:unix, :linux} do
      info = Linux.disk_info("/")
      assert is_integer(info.total)
      assert info.total > 0
    else
      :ok
    end
  end
end
