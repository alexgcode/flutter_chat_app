import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quiver/iterables.dart';

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
  List<DisplayMessage> listMsg = [];
  List<int> bytesReceived = [];
  List<int> fileBytes = [];
  bool loading = false;
  String filePath = "";
  final Dio dio = Dio();

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
      print("Connecting..." + widget.ip);
      _socket = await Socket.connect(widget.ip, 1234); //funciona
      print("Connected ...");

      _socket!.listen((MessageEvent) {
        
        String rawString = utf8.decode(MessageEvent);
        Map<String, dynamic> messageMap = jsonDecode(rawString);
        Message msg = Message.fromJson(messageMap);

        
        if(msg.type == 2 && msg.part != -1)
        {
          print("mensaje tipo 2");

          fileBytes.addAll(base64Decode(msg.data));

          if(msg.offset == msg.part){
            saveImageFromTCP(fileBytes, msg.fileName!, msg.fileExtension!);
            print("listen path: " + filePath);
            setState(() {
              listMsg.add(DisplayMessage(2, msg.data, fileBytes,filePath) );
              
            });

          }
        }
        else
        {
          if(msg.part == -1){
            fileBytes = [];
          }
        
          setState(() {
            listMsg.add(DisplayMessage(1, msg.data, utf8.encode(msg.data),"") );
          });
        }
        
        print("escuchando");
      });
    } catch (e) {
      print(e);
      print("Not Connected");
    }
  }

  void SendMessage() {
    Message msg = Message(widget.senderNum, widget.targetNum, _msgController.text, 1, -1, -1, "","");
    String jsonMsg = jsonEncode(msg);

    _socket!.add(utf8.encode(jsonMsg)); //llama al socket para  encriptar el mensaje
    setState(() {
      listMsg.add(DisplayMessage(1, msg.data, utf8.encode(msg.data),"") ); //manda el mensaje a la lista para verlo en pantalla
    });
    _socket!.flush(); //necesario? (limpia cache/buffer del metodo)
    _msgController.clear();
  }

  Future<bool> _requestPermision(Permission permission) async {
    if(await permission.isGranted){
      return true;
    }
    else{
      var result = await permission.request();
      if(result == PermissionStatus.granted){
        return true;
      }
      else{
        return false;
      }
    }
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
                    child: item.type == 1 ? 
                      Text(item.data + "\n" + item.bytes.toString())
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          iconSize: 100,
                          onPressed: () => _openfiletest(item.path),
                          icon: Image.file(File(item.path), width: 100, height: 400, fit: BoxFit.fill),
                        ),
                        Text("Bytes: " + item.bytes.toString())
                      ]
                    )
                     //Image.file(File("/storage/emulated/0/Android/data/com.example.flutter_application_1/files/image.jpg"), width: 50, height: 200), //Text(item)
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
                    _openFilePicker(); //downloadFile();// Llamar a la función para abrir el selector de archivos
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

  void _openfiletest(String path){
    print("openfile path: " + path);
    OpenFile.open(path);
  }

  void saveImageFromTCP(List<int> by, String name, String extension) async {
    //Directory? directory = await getExternalStorageDirectory();// getApplicationDocumentsDirectory();

    Directory directory = Directory('/storage/emulated/0/Download');
    filePath = directory!.path+ "/"+name+"." +extension;

    print("directory path 1: " + directory!.path);
    
    if(await _requestPermision(Permission.manageExternalStorage)){

      print("directory path 2: " +directory.path);

      File filedef = File(directory.path + "/"+name+"." +extension);
      await filedef.create(recursive: true);
      await filedef.writeAsBytes(by);
      
      
      
      print("filepath save image: " + filePath);
    }
  }


  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Habilita la selección múltiple de archivos
    );

    if (result != null) {
      List<PlatformFile> files = result.files;
      for (PlatformFile file in files) {
        List<int> bytes = await File(file.path!).readAsBytes(); // Lee el archivo y obtiene los bytes

        print(file.path);
        
        List<List<int>> listChunks = partition(bytes,800).toList();
        int countoffset=1;
        for(var i=0; i<listChunks.length; i++)
        {
          print("chunk size: " + listChunks[i].length.toString());
          Message msg = Message(widget.senderNum, widget.targetNum, base64Encode(listChunks[i]), 2,countoffset,listChunks.length,file.name,file.extension);
          String jsonMsg = jsonEncode(msg);

          _socket!.add(utf8.encode(jsonMsg));
          
          sleep(Duration(milliseconds: 200));

          countoffset++;
        }
        
        //Message msg = Message(widget.senderNum, widget.targetNum, bytes.toString(), 2,-1,-1,[]);
        //String jsonMsg = jsonEncode(msg);

        //_socket!.add(utf8.encode(jsonMsg));

        setState(() {
          listMsg.add(DisplayMessage(2, "", bytes,file.path!) ); //manda el mensaje a la lista para verlo en pantalla
        });
        
        //_socket!.flush();
      }
      _socket!.flush();
    }
  }
}

class DisplayMessage {
  final int type;
  final String data;
  final List<int> bytes;
  final String path;

  DisplayMessage(this.type, this.data, this.bytes, this.path);
}

class Message {
  final String senderNumber;
  final String targetNumber;
  final String data;
  final int type;
  final int offset;
  final int part;
  final String? fileName;
  final String? fileExtension;

  Message(this.senderNumber, this.targetNumber, this.data, this.type, this.offset, this.part, this.fileName, this.fileExtension);

  Message.fromJson(Map<String, dynamic> json)
      : senderNumber = json['senderNumber'],
        targetNumber = json['targetNumber'],
        type = json['type'],
        offset = json['offset'],
        part = json['part'],
        data = json['data'],
        fileName = json['fileName'],
        fileExtension = json['fileExtension'];

  Map<String, dynamic> toJson() => {
        'senderNumber': senderNumber,
        'targetNumber': targetNumber,
        'type': type,
        'offset': offset,
        'part': part,
        'data': data,
        'fileName': fileName,
        'fileExtension': fileExtension,
      };
}

