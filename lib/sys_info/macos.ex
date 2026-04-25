defmodule SysInfo.MacOS do
  @moduledoc false
  @behaviour SysInfo.Adapter

  @impl true
  def cpu_usage do
    {output, 0} = System.cmd("top", ["-l", "1", "-n", "0"])

    regex = ~r/CPU usage: (\d+\.\d+)% user, (\d+\.\d+)% sys/

    case Regex.run(regex, output) do
      [_, user, sys] -> Float.parse(user) |> elem(0) |> Kernel.+(Float.parse(sys) |> elem(0))
      _ -> 0.0
    end
  end

  @impl true
  def memory_info do
    total = get_sysctl_int("hw.memsize")

    {vm_output, 0} = System.cmd("vm_stat", [])
    stats = parse_vm_stat(vm_output)

    page_size = 4096
    free = stats["Pages free"] * page_size
    inactive = stats["Pages inactive"] * page_size

    available = free + inactive
    used = total - available

    %{
      total: total,
      used: used,
      free: available,
      percent: Float.round(used / total * 100, 2)
    }
  end

  @impl true
  def swap_info do
    {output, 0} = System.cmd("sysctl", ["-n", "vm.swapusage"])

    regex = ~r/total = ([\d\.]+)M\s+used = ([\d\.]+)M\s+free = ([\d\.]+)M/
    [_, total, used, free] = Regex.run(regex, output)

    to_bytes = fn m ->
      Float.parse(m) |> elem(0) |> Kernel.*(1024) |> Kernel.*(1024) |> round()
    end

    t = to_bytes.(total)
    u = to_bytes.(used)
    f = to_bytes.(free)

    %{
      total: t,
      used: u,
      free: f,
      percent: if(t > 0, do: Float.round(u / t * 100, 2), else: 0.0)
    }
  end

  @impl true
  def disk_info(path) do
    {output, 0} = System.cmd("df", ["-k", path])
    # Split by lines and take the last one (skip header)
    lines = String.split(output, "\n", trim: true)
    data_line = List.last(lines)

    # Split by whitespace and extract values by their relative positions
    # 1st column: Filesystem
    # 2nd: 1024-blocks (Total)
    # 3rd: Used
    # 4th: Available (Free)
    parts = String.split(data_line, ~r/\s+/)

    total = Enum.at(parts, 1) |> String.to_integer()
    used = Enum.at(parts, 2) |> String.to_integer()
    free = Enum.at(parts, 3) |> String.to_integer()

    t = total * 1024
    u = used * 1024
    f = free * 1024

    %{
      total: t,
      used: u,
      free: f,
      percent: if(t > 0, do: Float.round(u / t * 100, 2), else: 0.0)
    }
  end

  defp get_sysctl_int(name) do
    {out, 0} = System.cmd("sysctl", ["-n", name])
    out |> String.trim() |> String.to_integer()
  end

  defp parse_vm_stat(output) do
    output
    |> String.split("\n", trim: true)
    |> Enum.drop(1)
    |> Map.new(fn line ->
      [key, val] = String.split(line, ~r/:\s+/)
      {key |> String.trim(), val |> String.trim_trailing(".") |> String.to_integer()}
    end)
  end
end
