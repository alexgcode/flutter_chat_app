import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';


class GroupPage extends StatefulWidget{
  final String name;
  final String ip;
  final String port;
  const GroupPage({Key? key, required this.name, required this.ip, required this.port}) : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}


class _GroupPageState extends State<GroupPage> {
  List <String>listMsg = [];
  TextEditingController _msgController = TextEditingController();
  TextEditingController _conectecController = TextEditingController();
  

  Socket? _socket; 
  String message="";
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _conectecController.text = "not conected";
    });
    
  }


  Future<void> connectServer() async {
      try{
        setState(() {
          _conectecController.text = "Connecting ...";
        });
        _socket = await Socket.connect(widget.ip, int.parse(widget.port)).timeout(const Duration(seconds: 15));  //funcio
        setState(() {
          _conectecController.text = "Connected";
        });
        

        _socket!.listen((MessageEvent) {
            setState(() {
              listMsg.add(utf8.decode(MessageEvent));
              print(listMsg);
            });

        });

      }
      on TimeoutException {
        setState(() {
          _conectecController.text = "timeout";
        });
      }
      catch(e){
        setState(() {
          _conectecController.text = e.toString();
        });
      }
    }


  void SendMessage() {
    //setState(() {
    //  _msgController.text = "presionado";
    //});
    
    _socket!.add(utf8.encode("<${widget.name}>: ${_msgController.text}"));  //funciona
    setState(() {
      listMsg.add("<${widget.name}>: ${_msgController.text}");
    });
    _socket!.flush(); //necesario?
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Grupal") ,
      ),
      body: Column (children: [
        IconButton(onPressed: connectServer, 
                icon: const Icon(
                  Icons.computer
                )),
        Text(_conectecController.text),
        Expanded(child: ListView.builder(
                      itemCount: listMsg.length,
                      itemBuilder: (contex, int index){
                        final item = listMsg[index];
                        return ListTile(
                          title: Text(item),
                        );
                      },
                    ),
                ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: 
              Row(
              children: [
                Expanded(child: TextField(
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
                IconButton(onPressed: SendMessage, 
                icon: const Icon(
                  Icons.send
                )),
              ],
        ),
      ),
    ]
  ),
  /*
floatingActionButton: FloatingActionButton(
        onPressed: SendMessage, 
        tooltip: 'Send Message',
        child: const Icon(Icons.send),
      ),*/
);
}
}
