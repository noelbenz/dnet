
static import io = std.stdio;

import net;

int main()
{
	auto addr = new InternetAddress(55555);
	auto sock = new TcpSocket();
	sock.bind(addr);
	sock.listen(1);
	
	auto s = sock.accept();
	
	io.writeln(s.readByte());
	
	char[4] data = "abcd\n".dup;
	s.send(data);
	
	io.writeln(s.readByte());
	
	return 0;
}
