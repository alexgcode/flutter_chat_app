import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class GroupPage extends StatefulWidget {
  final String name;
  final String ip;
  final String port;
  final String num;
  const GroupPage(
      {Key? key,
      required this.name,
      required this.ip,
      required this.port,
      required this.num})
      : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  List<String> listMsg = [];
  TextEditingController _msgController = TextEditingController();
  TextEditingController _conectecController = TextEditingController();

  Socket? _socket; //definimos socket
  String message = ""; //definimos mensaje
  bool isConnecting = false; //no esta conectado

  @override
  void initState() {
    //funcion que se llama al mostrar la pantalla
    super.initState();
    setState(() {
      //refesca el estado de las variables
      _conectecController.text = "not conected";
    });
  }

  Future<void> connectServer() async {
    _socket!.listen((MessageEvent) {
      //crea el hilo para decodificar los mensajes del celular
      setState(() {
        listMsg.add(utf8.decode(MessageEvent));
        print(listMsg); //muestra por consola
      });
    });
  }

  void SendMessage() {
    _socket!.add(utf8.encode(
        "<${widget.name}>: ${_msgController.text}")); //llama al socket para  encriptar el mensaje
    setState(() {
      listMsg.add(
          "<${widget.name}>: ${_msgController.text}"); //manda el mensaje a la lista para verlo en pantalla
    });
    _socket!.flush(); //necesario? (limpia cache/buffer del metodo)
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          IconButton(
            onPressed: connectServer,
            icon: const Icon(Icons.computer),
          ),
          Text(_conectecController.text),
          Expanded(
            child: ListView.builder(
              itemCount: listMsg.length,
              itemBuilder: (context, int index) {
                final item = listMsg[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(item),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: "Mensaje",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: SendMessage,
                  icon: const Icon(Icons.send),
                ),
                IconButton(
                  onPressed: () {
                    _openFilePicker(); // Llamar a la función para abrir el selector de archivos
                  },
                  icon: const Icon(Icons.attach_file),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Habilita la selección múltiple de archivos
    );

    if (result != null) {
      List<PlatformFile> files = result.files;
      for (PlatformFile file in files) {
        List<int> bytes = await File(file.path!)
            .readAsBytes(); // Lee el archivo y obtiene los bytes
        _socket!.add(bytes);
      }
    }
  }
}
