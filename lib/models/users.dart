import 'package:dart_discord/dart_discord.dart' as dart_discord;
import 'dart:io';
import 'package:dart_discord/database/database.dart';



class User {
   String? name;
  String? password;
  

  User(this.name,this.password);

Future<void> register() async{

      var databaseInstance=Database();
           await databaseInstance.openDB();
           await databaseInstance.addUser(this.name,this.password);
   
}

Future<bool> login() async{
    
    var databaseInstance=Database();
    await databaseInstance.openDB();
    bool success=await databaseInstance.login(this.name,this.password);
   
   return success;
}

}