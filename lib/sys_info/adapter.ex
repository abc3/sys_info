defmodule SysInfo.Adapter do
  @moduledoc """
  Defines the contract for OS-specific system metrics collectors.
  """

  @type usage_map :: %{
          total: integer(),
          used: integer(),
          free: integer(),
          percent: float()
        }

  @callback cpu_usage() :: float()
  @callback memory_info() :: usage_map()
  @callback swap_info() :: usage_map()
  @callback disk_info(String.t()) :: usage_map()
end
