
import std.string;
import socket = std.socket;
import io = std.stdio;
import time = core.time;
import bitmanip = std.bitmanip;

import net;

alias format = std.string.format;

const ushort PROTOCOL_ID = 35272;

const bool SERVER = true;
const bool CLIENT = false;

alias betn = bitmanip.bigEndianToNative;
alias ntbe = bitmanip.nativeToBigEndian;

struct HeaderEssential
{
	ushort protocolID = PROTOCOL_ID;
	bool essential = true;
	uint packetIndex;
	uint fragmentCount;
	uint fragmentIndex;
	uint purposeID;
}

struct HeaderNonEssential
{
	ushort protocolID = PROTOCOL_ID;
	bool essential = false;
	uint purposeID;
}

struct Packet
{
	int pos = 0;
	ubyte[] data;
	
	this(int size)
	{
		data = new ubyte[size];
	}
	
	// warning: does not convert edianess of each field
	// this will give add native edianess.
	void addStruct(T)(T obj)
	{
		ubyte[] bytes = cast(ubyte[])((&obj)[0..1]);
		data[pos..pos+T.sizeof] = bytes;
		pos += T.sizeof;
	}
	
	void add(T)(T obj)
	{
		ubyte[T.sizeof] bytes = ntbe(obj);
		data[pos..pos+T.sizeof] = bytes;
		pos += T.sizeof;
	}
	
	void add(bool v){data[pos] = cast(ubyte)v;pos++;}
	void add(byte v){data[pos] = cast(ubyte)v;pos++;}
	void add(ubyte v){data[pos] = v;pos++;}
	
	void add(HeaderEssential header)
	{
		add(header.protocolID);
		add(header.essential);
		add(header.packetIndex);
		add(header.fragmentCount);
		add(header.fragmentIndex);
		add(header.purposeID);
	}
	
	void add(HeaderNonEssential header)
	{
		add(header.protocolID);
		add(header.essential);
		add(header.purposeID);
	}
}

struct Conformation
{
	uint packetIndex;
	uint fragmentIndex;
}

void sendConformation(uint packetIndex, uint fragmentIndex)
{
	int size = HeaderNonEssential.sizeof + 8;
	Packet packet = Packet(size);
	
	HeaderNonEssential header;
	header.purposeID = 1;
	packet.add(header);
	
	packet.add(packetIndex);
	packet.add(fragmentIndex);
	
	writeln(packet);
	
	/*
	ubyte[] headerBytes = cast(ubyte[])((&header)[0..1]);
	
	int size = HeaderNonEssential.sizeof + 8;
	ubyte[] data = new ubyte[size];
	
	data[0..HeaderNonEssential.sizeof] = headerBytes;
	writeln(data);
	*/
}

bool side;

void writeln(T...)(T args)
{
	if(side == SERVER)
		io.writeln("SERVER: ", args);
	else
		io.writeln("CLIENT: ", args);
}

// last packet that has been processed
long lastPacket = -1;

int main(char[][] args)
{
	
	char[] sideArg = args[1];
	
	if(sideArg == "server")
	{
		side = SERVER;
		
		writeln("Booting server.");
		
		auto addr = new InternetAddress(55555);
		auto sock = new UdpSocket();
		sock.bind(addr);
		sock.blocking = false;
		
		ubyte[] data = new ubyte[512];
		
		sendConformation(55, 123);
		
		while(true)
		{
			try
			{
				Address fromAddr;
				int i = cast(int)sock.receiveFrom(data, fromAddr);
				if(i > 0)
				{
					writeln(data[0]);
					writeln(fromAddr);
					break;
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
		side = CLIENT;
		
		writeln("Booting client.");
		
		
		auto addr = new InternetAddress("127.0.0.1", 55555);
		auto sock = new UdpSocket();
		sock.connect(addr);
		sock.blocking = false;
		
		ubyte[1] data;
		data[0] = 99;
		sock.send(data);
		
	}
	
	return 0;
}
