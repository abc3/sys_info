defmodule SysInfo.MacOSTest do
  use ExUnit.Case, async: true
  alias SysInfo.MacOS

  @tag :macos
  test "cpu_usage/0 returns a float" do
    if :os.type() == {:unix, :darwin} do
      usage = MacOS.cpu_usage()
      assert is_float(usage)
      assert usage >= 0.0
    else
      :ok
    end
  end

  @tag :macos
  test "memory_info/0 returns correct structure" do
    if :os.type() == {:unix, :darwin} do
      info = MacOS.memory_info()
      assert is_integer(info.total)
      assert info.total > 0
      assert is_float(info.percent)
    end
  end

  @tag :macos
  test "swap_info/0 returns correct structure" do
    if :os.type() == {:unix, :darwin} do
      info = MacOS.swap_info()
      assert is_integer(info.total)
      assert is_float(info.percent)
    end
  end

  @tag :macos
  test "disk_info/1 returns correct structure" do
    if :os.type() == {:unix, :darwin} do
      info = MacOS.disk_info("/")
      assert is_integer(info.total)
      assert info.total > 0
    end
  end
end
