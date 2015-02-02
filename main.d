
import std.string;
import socket = std.socket;
import io = std.stdio;
import time = core.time;

import net;

alias format = std.string.format;

void newClient(Socket s)
{
	ubyte[] data = [1, 3, 'A', 'B', 'C'];
	s.send(data);
}

int main(char[][] args)
{
	
	char[] side = args[1];
	
	if(side == "server")
	{
		io.writeln("Booting server.");
		
		auto addr = new InternetAddress(55555);
		auto sock = new UdpSocket();
		sock.bind(addr);
		sock.blocking = false;
		
		ubyte[1] data;
		
		while(true)
		{
			try
			{
				Address fromAddr;
				int i = sock.receiveFrom(data, fromAddr);
				if(i > 0)
				{
					io.writeln(data[0]);
					io.writeln(fromAddr);
				}
			}
			catch(Exception e)
			{
				io.writeln(e);
			}
		}
		
	}
	else
	{
		io.writeln("Booting client.");
		
		
		auto addr = new InternetAddress("127.0.0.1", 55555);
		auto sock = new UdpSocket();
		sock.connect(addr);
		sock.blocking = false;
		
		ubyte[1] data;
		data[0] = 99;
		sock.send(data);
		
		while(true)
		{
			
		}
	}
	
	return 0;
}
