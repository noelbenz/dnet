
module net;

static import socket = std.socket;

alias Socket = socket.Socket;
alias TcpSocket = socket.TcpSocket;
alias InternetAddress = socket.InternetAddress;
alias Address = socket.Address;

/**
 * Reads an unsigned byte from the socket object and returns it as an int.
 */
int readUByte(Socket s)
{
	ubyte[1] data;
	s.receive(cast(void[])data);
	return cast(int)data[0];
}
void sendUByte(Socket s, int v)
{
	ubyte[1] data;
	data[0] = cast(ubyte)v;
	s.send(data);
}

/**
 * Reads a signed byte from the socket object and returns it as an int.
 */
int readByte(Socket s)
{
	byte[1] data;
	s.receive(cast(void[])data);
	return cast(int)data[0];
}
void sendByte(Socket s, int v)
{
	byte[1] data;
	data[0] = cast(byte)v;
	s.send(data);
}




private union btoUShort
{
	ubyte[2] bytes;
	ushort value;
}
/**
 * Reads an unsigned short from the socket object and returns it as an int.
 */
int readUShort(Socket s)
{
	ubyte[2] data;
	s.receive(cast(void[])data);
	
	btoUShort conv = {bytes : data};
	return cast(int)conv.value;
}
void sendUShort(Socket s, int v)
{
	btoUShort conv = {value : cast(ushort)v};
	s.send(conv.bytes);
}


private union btoShort
{
	byte[2] bytes;
	short value;
}
/**
 * Reads a signed short from the socket object and returns it as an int.
 */
int readShort(Socket s)
{
	byte[2] data;
	s.receive(cast(void[])data);
	
	btoShort conv = {bytes : data};
	return cast(int)conv.value;
}
void sendShort(Socket s, int v)
{
	btoShort conv = {value : cast(short)v};
	s.send(conv.bytes);
}










private union btoUInt
{
	ubyte[4] bytes;
	uint value;
}
/**
 * Reads an unsigned int from the socket object.
 */
uint readUInt(Socket s)
{
	ubyte[4] data;
	s.receive(cast(void[])data);
	
	btoUInt conv = {bytes : data};
	return conv.value;
}
void sendUInt(Socket s, uint v)
{
	btoUInt conv = {value : v};
	s.send(conv.bytes);
}

private union btoInt
{
	byte[4] bytes;
	int value;
}
/**
 * Reads a signed int from the socket object.
 */
int readInt(Socket s)
{
	byte[4] data;
	s.receive(cast(void[])data);
	
	btoInt conv = {bytes : data};
	return conv.value;
}
void sendInt(Socket s, int v)
{
	btoInt conv = {value : v};
	s.send(conv.bytes);
}














private union btoULong
{
	ubyte[8] bytes;
	ulong value;
}
/**
 * Reads an unsigned long from the socket object.
 */
long readULong(Socket s)
{
	ubyte[8] data;
	s.receive(cast(void[])data);
	
	btoULong conv = {bytes : data};
	return conv.value;
}
void sendULong(Socket s, ulong v)
{
	btoULong conv = {value : v};
	s.send(conv.bytes);
}


private union btoLong
{
	byte[8] bytes;
	long value;
}
/**
 * Reads a signed long from the socket object.
 */
long readLong(Socket s)
{
	byte[8] data;
	s.receive(cast(void[])data);
	
	btoLong conv = {bytes : data};
	return conv.value;
}
void sendLong(Socket s, long v)
{
	btoLong conv = {value: v};
	s.send(conv.bytes);
}











private union btoFloat
{
	byte[4] bytes;
	float value;
}

/**
 * Reads a float from the socket object.
 */
float readFloat(Socket s)
{
	byte[4] data;
	s.receive(cast(void[])data);
	
	btoFloat conv = {bytes : data};
	return conv.value;
}
void sendFloat(Socket s, float v)
{
	btoFloat conv = {value : v};
	s.send(conv.bytes);
}

private union btoDouble
{
	byte[8] bytes;
	double value;
}

/**
 * Reads a double from the socket object.
 */
double readDouble(Socket s)
{
	byte[8] data;
	s.receive(cast(void[])data);
	
	btoDouble conv = {bytes : data};
	return conv.value;
}
void sendDouble(Socket s, double v)
{
	btoDouble conv = {value : v};
	s.send(conv.bytes);
}








/**
 * Reads a boolean from the socket object.
 */
bool readBool(Socket s)
{
	return s.readUByte() != 0;
}
void sendBool(Socket s, bool v)
{
	s.sendUByte(v ? 1 : 0);
}






/**
 * Reads a string from the socket object.
 */
char[] readString(Socket s)
{
	uint length = s.readUInt();
	
	char[] data = new char[length];
	
	s.receive(cast(void[])data);
	
	return data;
}
void sendString(Socket s, string v)
{
	uint length = cast(uint)v.length;
	s.sendUInt(length);
	s.send(v);
}




struct Packet
{
	ubyte[] data;
	
	this(int id)
	{
		this.addUByte(id);
	}
}

Packet addUByte(Packet p, int v)
{
	p.data ~= cast(byte)v;
	return p;
}
Packet addByte(Packet p, int v)
{
	p.data ~= cast(ubyte)v;
	return p;
}
Packet addUShort(Packet p, int v)
{
	btoUShort conv = {value : cast(ushort)v};
	p.data = p.data ~ cast(ubyte[])conv.bytes;
	return p;
}
Packet addShort(Packet p, int v)
{
	btoShort conv = {value: cast(short)v};
	p.data = p.data ~ cast(ubyte[])conv.bytes;
	return p;
}
Packet addUInt(Packet p, uint v)
{
	btoUInt conv = {value : v};
	p.data = p.data ~ cast(ubyte[])conv.bytes;
	return p;
}
Packet addInt(Packet p, int v)
{
	btoInt conv = {value : v};
	p.data = p.data ~ cast(ubyte[])conv.bytes;
	return p;
}
Packet addULong(Packet p, ulong v)
{
	btoULong conv = {value : v};
	p.data = p.data ~ cast(ubyte[])conv.bytes;
	return p;
}
Packet addLong(Packet p, long v)
{
	btoLong conv = {value : v};
	p.data = p.data ~ cast(ubyte[])conv.bytes;
	return p;
}
Packet addFloat(Packet p, float v)
{
	btoFloat conv = {value : v};
	p.data = p.data ~ cast(ubyte[])conv.bytes;
	return p;
}
Packet addDouble(Packet p, double v)
{
	btoFloat conv = {value : v};
	p.data = p.data ~ cast(ubyte[])conv.bytes;
	return p;
}
Packet addBool(Packet p, bool v)
{
	p.addUByte(v ? 1 : 0);
	return p;
}
Packet addString(Packet p, string v)
{
	p.addUInt(cast(uint)v.length);
	p.data = p.data ~ cast(immutable(ubyte[]))v;
	return p;
}

