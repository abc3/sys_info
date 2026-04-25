# SysInfo

A lightweight Elixir library for retrieving system metrics (CPU, RAM, Swap, Disk). Supports both Linux and macOS.

Unlike the standard `:cpu_sup`, `SysInfo` reads data directly from system files (`/proc` on Linux) or via system calls (`sysctl`, `top` on macOS), ensuring high accuracy and preventing false spikes caused by the collection process itself.

## Installation

Add `sys_info` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sys_info, "~> 0.1.0"}
  ]
end
```

## Usage

### Get All Metrics at Once

```elixir
SysInfo.info()
# => %{
#      cpu: 12.5,
#      ram: %{total: 17179869184, used: 8589934592, free: 8589934592, percent: 50.0},
#      swap: %{total: 2147483648, used: 1073741824, free: 1073741824, percent: 50.0},
#      disk: %{total: 494384795648, used: 200000000000, free: 294384795648, percent: 40.45}
#    }
```

### CPU Usage

Returns the current CPU usage as a percentage.

```elixir
SysInfo.cpu_usage()
# => 5.2
```

*Note: On Linux, it takes two samples with a 100ms interval to calculate the delta accurately.*

### Memory Info (RAM)

Returns RAM usage details in bytes.

```elixir
SysInfo.memory_info()
# => %{total: 17179869184, used: 8589934592, free: 8589934592, percent: 50.0}
```

### Swap Info

Returns swap partition details in bytes.

```elixir
SysInfo.swap_info()
```

### Disk Info

Returns disk usage for the specified path (defaults to `/`) in bytes.

```elixir
SysInfo.disk_info("/")
```

## Platform Implementation

- **Linux**: Direct reading of `/proc/stat` and `/proc/meminfo`. This is the most efficient way with minimal overhead.
- **macOS**: Uses `sysctl`, `vm_stat`, and `top`. Since macOS lacks `/proc`, it utilizes native Darwin system utilities.
