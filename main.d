
static import socket = std.socket;
static import io = std.stdio;
static import thread = core.thread;
static import time = core.time;

import net;

// number of clients that are supported upon program startup
const NUM_CLIENTS = 20;

Client[20] clients;
int[20] releasedClients;

int clientsUsed = 0;
int cur = -1;
// warning: doesn't check if client i has already been released
void releaseClient(int i)
{
	cur++;
	releasedClients[cur] = i;
}
int newClientID()
{
	// no clients currently released
	if(cur == -1)
	{
		// still have unused client objects
		if(clientsUsed < NUM_CLIENTS)
		{
			int id = clientsUsed;
			clientsUsed++;
			return id;
		}
		// no released clients and full use of all client instances
		// cannot accept new connection
		// future: expand array?
		else
		{
			return -1;
		}
	}
	
	int id = releasedClients[cur];
	cur--;
	return id;
}
Client newClient()
{
	int id = newClientID();
	
	if(id == -1)
		return null;
	
	if (clients[id] is null) {
		clients[id] = new Client();
	}
	
	auto c = clients[id];
	c.id = id;
	return c;
}



class Client : thread.Thread
{
	bool connected;
	int id;
	Socket socket;
	
	this()
	{
		super(&handleReceive);
	}
	
	void handleReceive()
	{
		while(socket.isAlive())
		{
			int id = socket.readUByte();
			
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
	
	void send(Packet p)
	{
		//cc.send(sendThread, cast(immutable(Packet))p);
	}
	
	void ping()
	{
		send(Packet(1));
	}
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
		
		Client c = newClient();
		c.socket = s;
		
		c.start();
	}
	
	return 0;
}
