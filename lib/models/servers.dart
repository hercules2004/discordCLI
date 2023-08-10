import 'package:dart_discord/dart_discord.dart' as dart_discord;
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:dart_discord/models/users.dart';
import 'package:dart_discord/database/database.dart';


class Message {
  String? message;
  User user;

  Message(this.message, this.user);
}

class Channel {
  String? name;
  List<Message> messages = [];

  Channel(this.name); 

}


class Server {
  String? name;
 
  List<Channel> channels = [];
  List<User> users=[];

  Server(this.name); 

Future<void> createServer(User curruser) async {
  var databaseInstance = Database();
  var name3=this.name;
   var server2 = await server.findOne(where.eq('name', this.name));
  if(server2!=null){
    print('This server already exists. You are now logged in the server $name3.');
  }else{
  await databaseInstance.createServer(this.name);
  
  try {
    var server1 = await server.findOne(where.eq('name', this.name));
    if (server1 != null) {
      var updatedUsers = List<Map<String, dynamic>>.from(server1['users'] ?? []);
      updatedUsers.add({
        'name': curruser.name,
        'password': curruser.password
      }); 
      await server.update(
        where.eq('name', this.name),
        modify.set('users', updatedUsers),
      );
    } else {
      print('Server document not found.');
    }
  } catch (e) {
    print('Error updating server document: $e');
  }
 }
}


Future<bool> joinServer(User curruser) async{
    //add the logged in user to the users list
      var databaseInstance=Database();
           var ans=await databaseInstance.joinServer(this.name);
           if(ans){
            try {
              var server1 = await server.findOne(where.eq('name', this.name));
              if (server1 != null) {
                   var updatedUsers = List<Map<String, dynamic>>.from(server1['users'] ?? []);
                   bool userPresent=false;
                   for(var user in server1['users']){
                    if(user['name']==curruser.name) userPresent=true;
                   }
                   if(userPresent) return true;
                   updatedUsers.add({
                     'name': curruser.name,
                     'password': curruser.password
               }); 
              await server.update(
                   where.eq('name', this.name),
                   modify.set('users', updatedUsers),
              );
            } else {
              print('Server document not found.');
            }
          } catch (e) {
              print('Error updating server document: $e');
          }
           }
         return ans;
}
 
Future<void> createChannel(var channelName, var userName) async {
  var channel = Channel(channelName);

  try {
    var server1 = await server.findOne(where.eq('name', this.name));
    
    if (server1 != null) {
      var updatedChannels = List<Map<String, dynamic>>.from(server1['channels'] ?? []);
      bool ans=false;
      for(var channel1 in updatedChannels){
        if(channel1['name']==channelName) ans=true;
      }
      if(ans) print('The channel already exists.');
      else{
     var channelMap = {
      'name': channelName,
      'messages': [], 
    };

    for(var message in channel.messages){
      channelMap['messages'].add({
        'message': message.message,
        'user': message.user
      });
    }
      updatedChannels.add(channelMap); 

      await server.update(
        where.eq('name', this.name),
        modify.set('channels', updatedChannels),
      );
    }
    } else {
      print('Server document not found.');
    }
  } catch (e) {
    print('Error updating server document: $e');
  }
}

Future<bool> joinChannel(var channelName) async{

   try {
    var server1 = await server.findOne(where.eq('name', this.name));
    
    if (server1 != null) {
      var updatedChannels = List<Map<String, dynamic>>.from(server1['channels'] ?? []);
      bool ans=false;
      for(var channel1 in updatedChannels){
        if(channel1['name']==channelName) ans=true;
      }
      return ans;
      
    } else {
      print('Server document not found.');
      return false;
    }
  } catch (e) {
    print('Error joining the channel: $e');
    return false;
  }
}

Future<void> viewUsers() async{
   try {
    var server1 = await server.findOne(where.eq('name', this.name));
    if (server1 != null) {
      var updatedUsers = List<Map<String, dynamic>>.from(server1['users'] ?? []);
      for(var user1 in updatedUsers){
        print(user1['name']);
      }
      
      
    } else {
      print('Server document not found.');
    }
  } catch (e) {
    print('Error joining the channel: $e');
  }
}

Future<void> viewChannels() async{
   try {
    var server1 = await server.findOne(where.eq('name', this.name));
    if (server1 != null) {
      var updatedChannels = List<Map<String, dynamic>>.from(server1['channels'] ?? []);
      for(var channel in updatedChannels){
        print(channel['name']);
      }
      
      
    } else {
      print('Server document not found.');
    }
  } catch (e) {
    print('Error joining the channel: $e');
  }
}

 
Future<void> sendMessage(var msg, User user, var channelName) async {
  
  try {
    var server1 = await server.findOne(where.eq('name', this.name));
    
    if (server1 != null) {
      var updatedChannels = List<Map<String, dynamic>>.from(server1['channels'] ?? []);
      
      var channelMap = updatedChannels.firstWhere(
          (channel) => channel['name'] == channelName,
          orElse: () => {'name': channelName, 'messages': []} // Provide a default value here
      );
      
      if (channelMap != null) {
        var messagesList=(channelMap['messages'] as List?)?.cast<Map<String,dynamic>>() ?? [];
        messagesList.add({
          'message': msg,
          'user': {
            'name': user.name, // You can add other user properties here if needed
            'password': user.password
          },
        });

        await server.update(
          where.eq('name', this.name),
          modify.set('channels', updatedChannels),
        );
        
      } else {
        print('Channel not found in the server.');
      }
    } else {
      print('Server document not found.');
    }
  } catch (e) {
    print('Error updating server document: $e');
  }
}

Future<void> viewMessages(var channelName) async{
   try {
    var server1 = await server.findOne(where.eq('name', this.name));
    if (server1 != null) {
      var updatedChannels = List<Map<String, dynamic>>.from(server1['channels'] ?? []);
      for(var channel1 in updatedChannels){
        if(channel1['name']==channelName){
           for(var messages in channel1['messages']){
            var user1=messages['user']['name'];
            var message1=messages['message'];
            print("$user1 :  $message1");
           }
        }
      }
      
      
    } else {
      print('Server document not found.');
    }
  } catch (e) {
    print('Error joining the channel: $e');
  }
}

}
