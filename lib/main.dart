import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controllerName = TextEditingController();
  final controllerCpf = TextEditingController();
  final controllerAge = TextEditingController();
  final controllerSexo = TextEditingController();

  final format = DateFormat("yyyy-MM-dd");
  String ErroBusca = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text('Cadastro'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: controllerName,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Insira seu nome',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                            width: 2
                          )
                        )
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: controllerCpf,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Insira seu CPF',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                            width: 2
                          )
                        )
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: controllerAge,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Insira sua idade',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                            width: 2
                          )
                        )
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: controllerSexo,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Insira seu gênero',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                            width: 2
                          )
                        )
                      ),
                    ),
                    SizedBox(height: 20),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        final name = controllerName.text;
                        final cpf = controllerCpf.text;
                        final age = controllerAge.text;
                        final genere = controllerSexo.text;
                        final user = User(
                          name: name, 
                          cpf: cpf,
                          age: int.parse(age), 
                          sexo:genere,
                        );

                        createUser(user);                        
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(onPressed: () {
                      buscarPeloCPF(controllerCpf.text);  
                                           
                    }, 
                    child: Text('Buscar pelo CPF',
                      style: TextStyle(color: Colors.white,fontSize: 14),
                    ),
                      style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 6, 30, 168)
                    ), 
                    ),
                    SizedBox(height: 20),
                    Text(ErroBusca,
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
            ),
          ),
      );
  }


  //Criando o elemento na base de dados
  Future createUser(User user) async{
    String doc = user.cpf;
    //Referenciando documento
    final docUser = FirebaseFirestore.instance.collection('users').doc(doc);

    final json = user.toJason();
    //Criando o documento
    await docUser.set(json);
  }
//}

Future buscarPeloCPF(String cpf) async{
  final colecao = FirebaseFirestore.instance.collection('users');

  var documento = await colecao.doc(cpf).get();
  //print(documento.data());
  
  if (documento.data() !=  null){
    //Tem que converter o .data() para json
    var data = jsonEncode(documento.data());
    //Depois tem que converter em Map
    Map<String,dynamic> usuario = jsonDecode(data);
    User user = User(cpf: usuario['cpf'], name: usuario['name'], age: usuario['age'], sexo: usuario['sexo']);

    setState(() {
      controllerName.clear();
      controllerCpf.clear();
      controllerAge.clear();
      controllerSexo.clear();
      ErroBusca = '';
    
      controllerName.text = user.name;
      controllerCpf.text = user.cpf;
      controllerAge.text = user.age.toString();
      controllerSexo.text = user.sexo;
    });
  }else{
    setState(() {
      ErroBusca = 'CPF não encontrado!';
    });
  }
}
}
//classe do usuário
class User {
    final String cpf;
    final String name;
    final int age;
    final String sexo;

    User({
      required this.cpf,
      required this.name,
      required this.age,
      required this.sexo,
    });
    
    Map<String, dynamic> toJason() => {
      'cpf' : cpf,
      'name': name,
      'age' : age,
      'sexo':sexo,
    };
  }
