import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_page.dart';
import 'dart:io';
import 'group_page.dart';


class IniPage extends StatefulWidget {
  final String name;
  final String ip;
  final String port;
  final String num;

  const IniPage({Key? key, required this.name, required this.ip, required this.port, required this.num})
      : super(key: key);

  @override
  State<IniPage> createState() => _IniPageState();
}

class _IniPageState extends State<IniPage> {
  List<ServerConnection> _connections = [];
  List<Socket> _sockets = [];
  bool _isConnecting = false;

  

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _numController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeConnections();
  }

  void _initializeConnections() {
    // Aquí puedes agregar tus conexiones de servidor iniciales utilizando los datos proporcionados por widget.
    _connections.addAll(
      [
        ServerConnection(name: "alex", ip: "-", port: "-", number: "979249947", messages: []),
        ServerConnection(name: "juan", ip: "-", port: "-", number: "75445554", messages: [])
      ]
    );
  }
  /*
  Future<void> connectServer() async {
    try{
        print("Connecting...");
        _socket = await Socket.connect(widget.ip, 1234);  //funciona
        print("Connected ...");

        _socket!.listen((MessageEvent) {

              String rawString = utf8.decode(MessageEvent);
              Map<String, dynamic> messageMap = jsonDecode(rawString);
              Message msg = Message.fromJson(messageMap);

              for (var i = 0; i < _connections.length; i++) {
                if(msg.senderNumber == _connections[i].number){

                  setState(() {
                    _connections[i].messages.add(msg.data);
                    rebuildAllChildren(context);
                  });
                  
                  print("mensaje agregado a : ${_connections[i].name}. Data: ${msg.data}");
                }
              }

              print("escuchando");
        });
      }
      catch(e){
        print(e);
        print("Not Connected");
      }
  }
  */

  /*
  Future<void> connectServer(ServerConnection connection) async {
    setState(() {
      _isConnecting = true;
      connection.status = 'Conectando...';
    });

    try {
      Socket socket = await Socket.connect(connection.ip, int.parse(connection.port)).timeout(const Duration(seconds: 15));

      setState(() {
        connection.status = 'Conectado';
        _isConnecting = false;
      });
      _sockets.add(socket);
    } on TimeoutException {
      setState(() {
        connection.status = 'Timeout';
        _isConnecting = false;
      });
    } catch (e) {
      setState(() {
        connection.status = 'Error: ${e.toString()}';
        _isConnecting = false;
      });
    }
  }
  */

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
        title: const Text('Chats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Regresar a la vista anterior
            Navigator.push(context, MaterialPageRoute(builder: 
                      (context) => HomePage()));
          },
        ),
      ),
      body: ListView.builder(
      itemCount: _connections.length,
      itemBuilder: (context, index) {
        final connection = _connections[index];

        return ListTile(
          leading: CircleAvatar(
            child: Text(connection.name[0]),
          ),
          title: Text(connection.name),
          subtitle: Text('Number: ${connection.number} | Status: ${connection.status}'),
          onTap: _isConnecting
              ? null
              : () {
                    String name = _nameController.text;
                    String ip = _ipController.text;
                    String port = _portController.text;
                    String senderNum = widget.num;
                    String targetNum = connection.number;

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupPage(name: name, ip: ip, port: port, senderNum: senderNum, targetNum:targetNum)),
                  );
                },
        );
      },
    ),
  );
}
}

class Message
{
  final String senderNumber;
  final String targetNumber;
  final String data;

  Message(this.senderNumber, this.targetNumber, this.data);

  Message.fromJson(Map<String, dynamic> json)
      : senderNumber = json['senderNumber'],
        targetNumber = json['targetNumber'],
        data = json['data'];

  Map<String, dynamic> toJson() => {
    'senderNumber': senderNumber,
    'targetNumber': targetNumber,
    'data': data
  };
}

class ServerConnection {
  final String name;
  final String ip;
  final String port;
  final String number;
  List<String> messages;
  String status;

  ServerConnection({
    required this.name,
    required this.ip,
    required this.port,
    required this.number,
    required this.messages,
    this.status = 'Desconectado'
  });
}