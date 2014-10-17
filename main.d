
static import io = std.stdio;
static import socket = std.socket;

// nc -l -p 55555

int main()
{
	auto addr = new socket.InternetAddress(55555);
	auto sock = new socket.TcpSocket();
	sock.bind(addr);
	sock.listen(1);
	
	auto s = sock.accept();
	
	char[256] data;
	s.receive(cast(void[])data);
	
	io.writeln(data);
	
	return 0;
}
