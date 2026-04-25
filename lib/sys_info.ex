defmodule SysInfo do
  @moduledoc """
  System metrics collector for CPU, RAM, Swap, and Disk.
  Supports Linux and macOS.
  """

  @adapter (case :os.type() do
              {:unix, :linux} -> SysInfo.Linux
              {:unix, :darwin} -> SysInfo.MacOS
              _ -> raise "Unsupported OS"
            end)

  @type usage_info :: %{
          optional(:cpu) => float(),
          optional(:ram) => SysInfo.Adapter.usage_map(),
          optional(:swap) => SysInfo.Adapter.usage_map(),
          optional(:disk) => SysInfo.Adapter.usage_map()
        }

  @doc """
  Returns a map with CPU, RAM, Swap and Disk usage metrics.
  """
  @spec info() :: usage_info()
  def info do
    %{
      cpu: cpu_usage(),
      ram: memory_info(),
      swap: swap_info(),
      disk: disk_info()
    }
  end

  @doc "Returns current CPU usage percentage."
  defdelegate cpu_usage(), to: @adapter

  @doc "Returns RAM usage info in bytes."
  defdelegate memory_info(), to: @adapter

  @doc "Returns Swap usage info in bytes."
  defdelegate swap_info(), to: @adapter

  @doc "Returns Disk usage info for the root partition in bytes."
  defdelegate disk_info(path \\ "/"), to: @adapter
end
