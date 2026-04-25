defmodule SysInfoTest do
  use ExUnit.Case
  doctest SysInfo

  test "info/0 returns all metrics" do
    result = SysInfo.info()

    assert Map.has_key?(result, :cpu)
    assert Map.has_key?(result, :ram)
    assert Map.has_key?(result, :swap)
    assert Map.has_key?(result, :disk)

    assert is_float(result.cpu)
    assert is_map(result.ram)
    assert is_map(result.swap)
    assert is_map(result.disk)
  end

  test "individual functions work" do
    assert is_float(SysInfo.cpu_usage())
    assert %{total: _, used: _, free: _, percent: _} = SysInfo.memory_info()
  end
end
