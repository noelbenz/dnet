
static import io = std.stdio;
static import socket = std.socket;

int main()
{
	auto addr = new socket.InternetAddress("127.0.0.1", 3300);
	auto sock = new socket.TcpSocket(addr);
	
	sock.listen(1);
	
	auto s = sock.accept();
	
	char[256] data;
	s.receive(cast(void[])data);
	
	io.writeln(data);
	
	return 0;
}
