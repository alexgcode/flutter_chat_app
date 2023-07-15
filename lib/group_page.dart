import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class GroupPage extends StatefulWidget {
  final String name;
  final String ip;
  final String port;
  final String senderNum;
  final String targetNum;

  GroupPage(
      {Key? key,
      required this.name,
      required this.ip,
      required this.port,
      required this.senderNum,
      required this.targetNum})
      : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  TextEditingController _msgController = TextEditingController();
  TextEditingController _conectecController = TextEditingController();

  Socket? _socket;
  String message = ""; //definimos mensaje
  bool isConnecting = false; //no esta conectado
  List<String> listMsg = [];

  @override
  void initState() {
    //funcion que se llama al mostrar la pantalla
    super.initState();
    setState(() {
      //refesca el estado de las variables
      _conectecController.text = "not conected";
    });

    connectServer();
  }

  Future<void> connectServer() async {
    try {
      print("Connecting...");
      _socket = await Socket.connect(widget.ip, 1234); //funciona
      print("Connected ...");

      _socket!.listen((MessageEvent) {
        String rawString = utf8.decode(MessageEvent);
        Map<String, dynamic> messageMap = jsonDecode(rawString);
        Message msg = Message.fromJson(messageMap);

        setState(() {
          listMsg.add(msg.data);
          print(msg.data);
        });
        

        print("escuchando");
      });
    } catch (e) {
      print(e);
      print("Not Connected");
    }
  }

  void SendMessage() {
    Message msg = Message(widget.senderNum, widget.targetNum, _msgController.text);
    String jsonMsg = jsonEncode(msg);

    _socket!.add(utf8.encode(jsonMsg)); //llama al socket para  encriptar el mensaje
    setState(() {
      listMsg
          .add(msg.data); //manda el mensaje a la lista para verlo en pantalla
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

        Message msg = Message(widget.senderNum, widget.targetNum, bytes.toString());
        String jsonMsg = jsonEncode(msg);

        if(jsonMsg.length > 2018)
        {

        }

        _socket!.add(utf8.encode(jsonMsg));
      }
    }
  }
}

class Message {
  final String senderNumber;
  final String targetNumber;
  //final int type;
  //final int offset;
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
