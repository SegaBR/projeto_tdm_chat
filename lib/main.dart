import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/chat_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: "AIzaSyCMbHxPnqZUudr6goYvGZQOtrJB15-IsF0",
          appId: "1:396873502683:web:033c79bbbb37c451cbe1fe",
          authDomain: "projetotdm-chat.firebaseapp.com",
          messagingSenderId: "396873502683",
          projectId: "projetotdm-chat",
          storageBucket: "projetotdm-chat.appspot.com",

        ),
    );
  }else{
      await Firebase.initializeApp();
  }

  final CollectionReference _contatos =
  FirebaseFirestore.instance.collection('contatos');

  //_contatos.add({"nome":"Ana", "idade":"20"});
  //_contatos.doc("jSZVsHPSJgdHX9nyrt03").update({"idade":'45', "fone":"99999-9999"});
  //_contatos.doc("7UPXgGCp83FJFzy2ZK2G").delete();

  QuerySnapshot snapshot = await _contatos.get();

  snapshot.docs.forEach((element){
    print(element.data().toString());
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatScreen(),
    );
  }
}