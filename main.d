
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
	
	Packet p = Packet(1);
	
	p.addString("01234567890123456789012345678901234567890123456789012345678901234");
	
	s.sendPacket(p);
	
	io.writeln(s.readByte());
	
	return 0;
}
