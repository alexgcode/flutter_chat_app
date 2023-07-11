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
    _connections.add(
      ServerConnection(name: widget.name, ip: widget.ip, port: widget.port, number: widget.num),
    );
  }

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
          subtitle: Text('IP: ${connection.ip} | Port: ${connection.port} | Status: ${connection.status}'),
          onTap: _isConnecting
              ? null
              : () {
                    String name = _nameController.text;
                    String ip = _ipController.text;
                    String port = _portController.text;
                    String num = _numController.text;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupPage(name: name, ip: ip, port: port, num: num)),
                  );
                },
        );
      },
    ),
  );
}
}

class ServerConnection {
  final String name;
  final String ip;
  final String port;
  final String number;
  String status;

  ServerConnection({
    required this.name,
    required this.ip,
    required this.port,
    required this.number,
    this.status = 'Desconectado',
  });
}