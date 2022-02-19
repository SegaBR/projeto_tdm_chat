import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projetotdm_chat/screens/chat_message.dart';
import 'text_composer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ChatScreen extends StatefulWidget{
  @override
  _ChatScreenState createState() => _ChatScreenState(); 
}

class _ChatScreenState extends State<ChatScreen>{
  final GoogleSignIn googleSignIn = GoogleSignIn();
  User? _currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  final CollectionReference _mensagens = FirebaseFirestore.instance.collection('mensagens');

  @override
  void initState(){
    super.initState();
    initializeDateFormatting();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser=user;
      });
    });
  }

  Future<User?> _getUserGoogle({required BuildContext context}) async{
    User? user;
    if(_currentUser != null) return _currentUser;

    if(kIsWeb){
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      try{
        final UserCredential userCredential =
        //await auth.signInWithPopup(GithubAuthProvider());
        await auth.signInWithPopup(authProvider);

        user = userCredential.user;
      } catch(e) {
        print(e);
      }
    }else{
      final GoogleSignInAccount? googleSingInAccount =
      await googleSignIn.signIn();

      if(googleSingInAccount != null ){
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSingInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        try{
          final UserCredential userCredential =
          await auth.signInWithCredential(credential);
          user = userCredential.user;

        } on FirebaseAuthException catch (e) {
          print(e);
        }catch (e){
          print(e);
        }
      }
    }
    return user;
  }

  Future<User?> _getUserGitHub({required BuildContext context}) async{
    User? user;
    if(_currentUser != null) return _currentUser;

    if(kIsWeb){
      try{
        final UserCredential userCredential =
        await auth.signInWithPopup(GithubAuthProvider());

        user = userCredential.user;
      } catch(e) {
        print(e);
      }
    }else{

    }
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_currentUser != null ? 'Olá, ${_currentUser?.displayName}'
        : 'Chat App'),
        elevation: 0,
        actions: <Widget>[
          _currentUser != null
              ? IconButton(
            icon: Icon(Icons.logout),
            onPressed: (){
              FirebaseAuth.instance.signOut();
              googleSignIn.signOut();
              _scaffoldKey.currentState?.showSnackBar(
                  SnackBar(
                      content: Text("Logout"),
                  )
              );
            },
          )
              : Container(
              margin: const EdgeInsets.symmetric(horizontal:20),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.g_mobiledata),
                    onPressed: (){
                      _currentUser =  _getUserGoogle(context: context) as User?;
                      _scaffoldKey.currentState?.showSnackBar(
                          SnackBar(
                            content: Text("Login Google"),
                          )
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.h_mobiledata),
                    onPressed: (){
                      _currentUser =  _getUserGitHub(context: context) as User?;
                      _scaffoldKey.currentState?.showSnackBar(
                          SnackBar(
                            content: Text("Login GitHub"),
                          )
                      );
                    },
                  )
                ]
            )
          )
        ],
      ),
      body:Column(
        children: <Widget>[
          Expanded(child: StreamBuilder<QuerySnapshot>(
              stream: _mensagens.orderBy('time').snapshots(),
              builder: (context, snapshot){
                switch (snapshot.connectionState){
                  case ConnectionState.waiting :
                    return Center(child: CircularProgressIndicator());
                  default:
                    List<DocumentSnapshot> documents = snapshot.data!.docs.reversed.toList();
                    return ListView.builder(
                        itemCount : documents.length,
                        reverse: true,
                        itemBuilder: (context, index){
                          return ChatMessage(documents[index],
                          documents[index].get('uid') ==
                          _currentUser?.uid);
                        }
                    );
                }
              },
            ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ]
      )
    );
  }


  void _sendMessage({String? text, XFile? imgFile}) async{
    final CollectionReference _mensagens = FirebaseFirestore.instance.collection('mensagens');

    User? user = _currentUser;

    if(user!=null){

      Map<String, dynamic> data = {
        'time' : Timestamp.now(),
        'url'  : "",
        'uid'  : user.uid,
        'senderName' : user.displayName,
        'sendPhotoUrl' : user.photoURL
      };

      String id = "";
      if(user != null)
        id= user.uid;

      if(imgFile!=null){
        setState(() {
          _isLoading = true;
        });
        firebase_storage.UploadTask uploadTask;
        firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref()
            .child("imgs")
            .child(id + DateTime.now().millisecondsSinceEpoch.toString());
        final metadados = firebase_storage.SettableMetadata(
            contentType: "image/jpeg",
            customMetadata: {"picked-file-path": imgFile.path}
        );
        if(kIsWeb){
          uploadTask = ref.putData(await imgFile.readAsBytes(), metadados);
        }else{
          uploadTask =  ref.putFile(File(imgFile.path));
        }
        var taskSnapshot = await uploadTask;
        String imageUrl = "";
        imageUrl= await taskSnapshot.ref.getDownloadURL();
        data['url'] = imageUrl;
        print('url:' + imageUrl);
        setState(() {
          _isLoading = false;
        });
      }else{
        data['text'] = text;
      }

      _mensagens.add(data);
      print("dado armazenado: "+data.toString());
    }else {
      const snackBar = SnackBar(
          content: Text("Não foi possível fazer login"),
          backgroundColor: Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }


  
}