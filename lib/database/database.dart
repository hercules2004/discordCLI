import 'package:dart_discord/dart_discord.dart' as dart_discord;
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';

 late Db? db; 
late DbCollection collection; 
  late DbCollection server;

class Database {
 // Declare db as an instance variable

Future<void> openDB() async {
    db = Db('mongodb://localhost:27017');
    await db!.open();
    collection = db!.collection('Registered_Users');
    server = db!.collection('Servers');
    print("Database opened successfully!");
}

Future<void> createServer(var name) async{
       var document = {'name': name, 'channels': [], 'users': []};
       await server.insert(document);
       print('Server Created Successfully');
}

Future<bool> joinServer(var name) async{
       var obj1=await server.findOne({"name" : name});
       if(obj1==null){
        print('This Server does not exists.');
        return false;
       }else{
        return true;
       }
}


Future<void> addUser(var name, var password) async {
    try {
        if (name == null || password == null) {
      print('Error: Name and password cannot be null.');
      return;
    }
          var obj1=await collection.findOne({"name" : name});
          if(obj1==null){
      var document = {'name': name, 'password': password};
      await collection.insert(document);
      print('Document inserted successfully!');
    }else print('User already registered');
    } catch (e) {
      print('Error: $e');
    }
}

Future<bool> login(String? name, String? password) async {
    try {
        if (name == null || password == null) {
      print('Error: Name and password cannot be null.');
      return false;
    }
      var obj1=await collection.findOne({"name" : name});
     
      if(obj1==null){
        print('The User is not registered yet');
        return false;
      }else{
        if(obj1['password']==password){
            print('Login Successfull');
            return true;
        }else{
            print('Passwords do not match');
            return false;
        }
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
}

Future<void> closeDB() async {
    await db?.close();
    print("Database closed successfully!");
}

}

