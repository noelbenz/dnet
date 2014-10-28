
static import socket = std.socket;
static import io = std.stdio;
static import thread = core.thread;
static import time = core.time;
static import mutex = core.sync.mutex;

import net;

// number of clients that are supported upon program startup
const NUM_CLIENTS = 20;

// By default variables are thread local.
// Mutexes are meant to be global of course.
// None of the mutex methods are shared
// so __gshared is our best option right now unless
// we want to cast in and out of shared, which is not
// @safe, more work, defeats the point of shared, and 
// produces the same results.
// The downside is we add an ugly looking modifier. Oh well.
__gshared mutex.Mutex clientsMutex;
__gshared Client[20] clients;
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
	synchronized(clientsMutex)
	{
		int id = newClientID();
		
		if(id == -1)
			return null;
		
		if (clients[id] is null)
			clients[id] = new Client();
		
		auto c = clients[id];
		c.id = id;
		
		return c;
	}
}
Client getClient(int i)
{
	synchronized(clientsMutex)
		return clients[i];
}

void sendToAll(Packet p)
{
	for(int i = 0; i < NUM_CLIENTS; i++)
	{
		Client c = getClient(i);
		if(c !is null)
		{
			c.send(p);
		}
	}
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
				auto p = Packet(2);
				p.addUByte(id);
				sendToAll(p);
			}
		}
		io.writeln("Receive: Connection closed by client.");
		releaseClient(id);
	}
	
	void send(Packet p)
	{
		synchronized {
			socket.sendPacket(p);
		}
	}
	
	void ping()
	{
		send(Packet(1));
	}
}



int main()
{
	clientsMutex = new mutex.Mutex;
	
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
