
static import socket = std.socket;
static import io = std.stdio;
static import cc = std.concurrency;
static import thread = core.thread;
static import time = core.time;

import net;

alias ThreadID = cc.Tid;
alias threadID = cc.thisTid;

class Client
{
	Socket socket;
	
	this(Socket socket)
	{
		this.socket = socket;
	}
	
	void send(Packet p)
	{
		socket.sendPacket(p);
	}
	
	void ping()
	{
		Packet p = Packet(1);
		send(p);
	}
	
private:
	
	this(){}
}

void handleReceive(shared(Client) c)
{
	
	Socket s = cast(Socket)(c.socket);
	
	while(s.isAlive())
	{
		int id = s.readUByte();
		
		// default value is 0 when connection is closed
		if(id == 0)
		{
			break;
		}
		else
		{
			io.writeln(id);
		}
	}
	io.writeln("Receive: Connection closed by client.");
}

void handleSend(shared(Client) c)
{
	thread.Thread t = thread.thread_attachThis();
	
	Socket s = cast(Socket)(c.socket);
	
	while(s.isAlive())
	{
		char[1] data;
		data[0] = 65;
		int bytesSent = s.send(cast(void[])data);
		
		// error. assuming connection closed for the time being
		if(bytesSent == -1)
			break;
		
		t.sleep(time.dur!"seconds"(1));
	}
	io.writeln("Send: Connection closed by client.");
}


int main()
{
	io.writeln("Starting a server.");
	
	auto addr = new InternetAddress(55555);
	auto sock = new TcpSocket();
	sock.bind(addr);
	sock.listen(1);
	
	while(true)
	{
		auto s = sock.accept();
		
		shared(Client) client = cast(shared(Client)) new Client(s);
		cc.spawn(&handleReceive, client);
		cc.spawn(&handleSend, client);
	}
	
	return 0;
}
