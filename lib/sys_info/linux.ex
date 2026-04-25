defmodule SysInfo.Linux do
  @moduledoc false
  @behaviour SysInfo.Adapter

  @impl true
  def cpu_usage(sample_ms \\ 100) do
    {total1, idle1} = read_cpu_stats()
    :timer.sleep(sample_ms)
    {total2, idle2} = read_cpu_stats()

    diff_total = total2 - total1
    diff_idle = idle2 - idle1

    if diff_total > 0 do
      Float.round(100 * (diff_total - diff_idle) / diff_total, 2)
    else
      0.0
    end
  rescue
    _ -> 0.0
  end

  @impl true
  def memory_info do
    stats = read_meminfo()
    total = stats["MemTotal"] || 0
    available = stats["MemAvailable"] || stats["MemFree"] + stats["Cached"] || 0
    used = total - available

    %{
      total: total * 1024,
      used: used * 1024,
      free: available * 1024,
      percent: calculate_percent(used, total)
    }
  end

  @impl true
  def swap_info do
    stats = read_meminfo()
    total = stats["SwapTotal"] || 0
    free = stats["SwapFree"] || 0
    used = total - free

    %{
      total: total * 1024,
      used: used * 1024,
      free: free * 1024,
      percent: calculate_percent(used, total)
    }
  end

  @impl true
  def disk_info(path) do
    {output, 0} = System.cmd("df", ["-B1", path])
    lines = String.split(output, "\n", trim: true)
    data_line = List.last(lines)
    parts = String.split(data_line, ~r/\s+/)

    total = Enum.at(parts, 1) |> String.to_integer()
    used = Enum.at(parts, 2) |> String.to_integer()
    free = Enum.at(parts, 3) |> String.to_integer()

    %{
      total: total,
      used: used,
      free: free,
      percent: calculate_percent(used, total)
    }
  end

  defp read_cpu_stats do
    "/proc/stat"
    |> File.read!()
    |> String.split("\n")
    |> List.first()
    |> String.split()
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer/1)
    |> then(fn list ->
      {Enum.sum(list), Enum.at(list, 3)}
    end)
  end

  defp read_meminfo do
    "/proc/meminfo"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Map.new(fn line ->
      [key, val | _] = String.split(line, ~r/:\s+/)
      {key, val |> String.trim_trailing(" kB") |> String.to_integer()}
    end)
  end

  defp calculate_percent(0, _), do: 0.0
  defp calculate_percent(_, 0), do: 0.0
  defp calculate_percent(used, total), do: Float.round(used / total * 100, 2)
end
