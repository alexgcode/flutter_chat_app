import 'package:flutter/material.dart';
import 'package:flutter_application_1/inicio_page.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _numController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingresa tu nombre de usuario';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(
                  labelText: 'IP',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingresa la IP';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: 'Puerto',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingresa el puerto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _numController,
                decoration: const InputDecoration(
                  labelText: 'Telefono',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingresa tu numero de telefono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String name = _nameController.text;
                    String ip = _ipController.text;
                    String port = _portController.text;
                    String num = _numController.text;
                    _nameController.clear();
                    Navigator.pop(context); 
                    Navigator.push(context, MaterialPageRoute(builder: 
                    (context) => IniPage(name: name, ip: ip, port: port, num: num)));
                  }
                },
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



/*class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController IPController = TextEditingController();
  TextEditingController PortController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Experimental"),
    ),
      body: Center(
        child: TextButton (
          onPressed:() => showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text("Datos"),
              content: Form(
                key: formKey,
                child:  Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TextFormField(
                      controller: IPController,
                      decoration: const InputDecoration(hintText: "IP de Servidor..."),
                      validator: (value){
                      if(value == null || value.isEmpty){
                        return "Ingrese IP";
                      }
                      return null;
                      },
                    ),
                    TextFormField(
                      controller: PortController,
                      decoration: const InputDecoration(hintText: "Puerto de Servidor..."),
                      validator: (value){
                      if(value == null || value.isEmpty){
                        return "Ingrese Puerto";
                      }
                      return null;
                      },
                    ),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(hintText: "Nombre usuario..."),
                      validator: (value){
                      if(value == null || value.isEmpty){
                        return "Ingrese un nombre de usuario";
                      }
                      return null;
                      },
                    ),
                  ],
                ), 
              ),
              actions: [
                TextButton(onPressed: (){nameController.clear(); Navigator.pop(context);}, child: const Text("Cancel")),
                TextButton(onPressed: (){
                  if(formKey.currentState!.validate()){
                    String name = nameController.text;
                    String ipServer = IPController.text;
                    String portServer = PortController.text;
                    nameController.clear();
                    Navigator.pop(context); 
                    Navigator.push(context, MaterialPageRoute(builder: 
                        (context) => GroupPage(name: name, ip: ipServer, port: portServer)
                      ));
                  }
                }, 
                child: const Text("Enter"))
              ],
            ),
          ),
          child: const Text(
            "Nuevo chat grupal", 
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 25), 
      ),
      ),
    ),
    );
  }
}*/