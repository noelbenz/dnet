
static import std.string;
static import socket = std.socket;
static import io = std.stdio;
static import thread = core.thread;
static import time = core.time;
static import mutex = core.sync.mutex;

import net;

alias format = std.string.format;

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
__gshared Client[NUM_CLIENTS] clients;
__gshared int clientsUsed = 0;

__gshared mutex.Mutex releaseMutex;
__gshared int[NUM_CLIENTS] releasedClients;
__gshared int clientsReleased = -1;
// warning: doesn't check if client i has already been released
void releaseClient(int id)
{
	synchronized(releaseMutex)
	{
		clientsReleased++;
		releasedClients[clientsReleased] = id;
	}
}
// warning: doesn't check if there are any released clients
int renewClient()
{
	synchronized(releaseMutex)
	{
		int id = releasedClients[clientsReleased];
		clientsReleased--;
		return id;
	}
}
int newClientID()
{
	// no clients currently released
	if(clientsReleased == -1)
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
	// reuse a released client object
	else
		return renewClient();
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
			int pid = socket.readUByte();
			
			// default value is 0 when connection is closed
			if(pid == 0)
			{
				break;
			}
			else
			{
				char[] msg = socket.readString();
				auto fmsg = format("Client(%d): %s", id, cast(string)msg);
				io.writeln(fmsg);
				auto p = Packet(2);
				p.addString(fmsg);
				sendToAll(p);
			}
		}
		io.writefln("Receive: Connection closed by client(%d).", id);
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

class Receiver : thread.Thread
{
	Socket socket;
	
	this()
	{
		super(&receive);
	}
	
	void receive()
	{
		while(true)
		{
			int id = socket.readUByte();
			
			if(id == 0)
			{
				break;
			}
			else
			{
				io.writeln(socket.readString());
			}
		}
	}
}

int main(char[][] args)
{
	char[] side = args[1];
	
	if(side == "server")
	{
		clientsMutex = new mutex.Mutex;
		releaseMutex = new mutex.Mutex;
		
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
			
			io.writefln("Accepted new client(%d).", c.id);
			
			c.start();
		}
	}
	else
	{
		io.writeln("Booting client.");
		
		auto addr = new InternetAddress("127.0.0.1", 55555);
		auto sock = new TcpSocket();
		sock.connect(addr);
		
		io.writeln("Connected!");
		
		Receiver r = new Receiver();
		r.socket = sock;
		r.start();
		
		while(true)
		{
			string msg = io.readln();
			
			Packet p = Packet(2);
			p.addString(msg[0 .. $-1]);
			
			sock.sendPacket(p);
		}
		
	}
	
	return 0;
}
