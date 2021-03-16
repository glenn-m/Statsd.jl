module Statsd

using Sockets

mutable struct Client
    host::IPv4
    port::Integer
    sock::IO
    prefix::String
    function Client(host::String="localhost", port::Integer=8125, prefix="")
        host = getaddrinfo(host)
        sock = UDPSocket()
        new(host, port, sock, prefix)
    end
end

# Send the metrics
function sc_send(sc::Client, data::String)
    send(sc.sock, sc.host, sc.port, data)
end

# Counter Functions
incr(sc::Client, metric, rate=nothing) = sc_metric(sc, "c", metric, 1, rate)
decr(sc::Client, metric, rate=nothing) = sc_metric(sc, "c", metric, -1, rate)

# Gauge, Timers, and Set
gauge(sc::Client, metric, value, rate=nothing) = sc_metric(sc, "g", metric, value, rate)
timing(sc::Client, metric, value, rate=nothing) = sc_metric(sc, "ms", metric, value, rate)
set(sc::Client, metric, value, rate=nothing) = sc_metric(sc, "s", metric, value, rate)

# Generate the metric and call send func
function sc_metric(sc::Client, type, metric, value, rate)
    if rate == nothing
        sc_send(sc, (isempty(sc.prefix) ? "" : "$(sc.prefix).") * "$metric:$value|$type")
    else
        sc_send(sc, (isempty(sc.prefix) ? "" : "$(sc.prefix).") * "$metric:$value|$type@$rate")
    end
end

end # module
