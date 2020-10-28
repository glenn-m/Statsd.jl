using Test
using Statsd
using Sockets

# Setup UDP Server to listen for Statsd messages
function test_setup()
    sock = UDPSocket()
    bind(sock, IPv4("127.0.0.1"), 8124)
    return sock
end

function read_statsd(sock)
    value = recv(sock)
    buffer = IOBuffer(reinterpret(UInt8, value))
    return String(readuntil(buffer, 0x00))
end

@testset "Statsd" begin
    sock = test_setup()
    client = Statsd.Client("localhost", 8124)
    @test client.host == IPv4("127.0.0.1")
    @test client.port == 8124
    @test typeof(client.sock) == UDPSocket

    # Test Counter
    Statsd.incr(client, "test")
    @test read_statsd(sock) == "test:1|c"
    Statsd.decr(client, "test")
    @test read_statsd(sock) == "test:-1|c"
    Statsd.incr(client, "test", 0.1)
    @test read_statsd(sock) == "test:1|c@0.1"
    Statsd.decr(client, "test", 0.2)
    @test read_statsd(sock) == "test:-1|c@0.2"

    # Test Gauge
    Statsd.gauge(client, "test", 1234)
    @test read_statsd(sock) == "test:1234|g"
    Statsd.gauge(client, "test", 1234, 0.3)
    @test read_statsd(sock) == "test:1234|g@0.3"
    # Test Timing
    Statsd.timing(client, "test", 0.3)
    @test read_statsd(sock) == "test:0.3|ms"
    Statsd.timing(client, "test", 0.3, 0.4)
    @test read_statsd(sock) == "test:0.3|ms@0.4"

    # Test Set
    Statsd.set(client, "test", 4)
    @test read_statsd(sock) == "test:4|s"
    Statsd.set(client, "test", 4, 0.5)
    @test read_statsd(sock) == "test:4|s@0.5"

    # Test sc_send
    Statsd.sc_send(client, "arbitrary string")
    @test read_statsd(sock) == "arbitrary string"

    # Test sc_metric
    Statsd.sc_metric(client, "g", "test", 9, 0.2)
    @test read_statsd(sock) == "test:9|g@0.2"
end
