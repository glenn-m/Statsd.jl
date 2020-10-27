# Statsd.jl

A basic implementation of a Julia StatsD client.

## Quickstart

```julia
julia> Pkg.add("Statsd")
julia> using Statsd
```

### Usage

`Statsd.jl` defaults to sending metrics to `127.0.0.1:8125`.

You can specify a hostname and port as well.

```julia
# Setup the statsd client
client = Statsd.Client("172.10.0.3", 9003)
```

#### Counters

```julia
# increment http.requests bucket
Statsd.incr(client,"http.requests")
# decrement http.requests bucket
Statsd.decr(client,"http.requests")
```

#### Timers

```julia
# job.duration took 500ms to complete
Statsd.timing(client,"job.duration",500)
```

#### Gauges

```julia
# Set disk.usage value to 1029
Statsd.gauge(client,"disk.usage",1029)
```

#### Sets

```julia
# Set unique.occurence to 3001
Statsd.set(client,"unique.occurence", 3001)
```

For more information please refer to the [StatsD project](https://github.com/etsy/statsd).
