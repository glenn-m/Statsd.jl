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
    sd = Statsd.Client("localhost", 8124)
    @test sd.host == IPv4("127.0.0.1")
    @test sd.port == 8124
    @test typeof(sd.sock) == UDPSocket

    # Test Counter
    Statsd.incr(sd, "test")
    @test read_statsd(sock) == "test:1|c"
    Statsd.decr(sd, "test")
    @test read_statsd(sock) == "test:-1|c"
    Statsd.incr(sd, "test", 0.1)
    @test read_statsd(sock) == "test:1|c@0.1"
    Statsd.decr(sd, "test", 0.2)
    @test read_statsd(sock) == "test:-1|c@0.2"

    # Test Gauge
    Statsd.gauge(sd, "test", 1234)
    @test read_statsd(sock) == "test:1234|g"
    Statsd.gauge(sd, "test", 1234, 0.3)
    @test read_statsd(sock) == "test:1234|g@0.3"
    # Test Timing
    Statsd.timing(sd, "test", 0.3)
    @test read_statsd(sock) == "test:0.3|ms"
    Statsd.timing(sd, "test", 0.3, 0.4)
    @test read_statsd(sock) == "test:0.3|ms@0.4"

    # Test Set
    Statsd.set(sd, "test", 4)
    @test read_statsd(sock) == "test:4|s"
    Statsd.set(sd, "test", 4, 0.5)
    @test read_statsd(sock) == "test:4|s@0.5"
end
