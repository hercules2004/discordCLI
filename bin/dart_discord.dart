import 'package:dart_discord/dart_discord.dart' as dart_discord;
import 'dart:io';
import 'package:dart_discord/models/users.dart';
import 'package:dart_discord/models/servers.dart';



void main(List<String> arguments) async {
  bool running = true;
  var curruser = User(null, null);
  var currserver=Server(null);
  var currchannel=Channel(null);
  bool loggedIn = false;
  bool messageSend=false;

  while (running) {
    print("Hello");

    if (!loggedIn) {
      var input = stdin.readLineSync();
      if (input == "register") {
        print("Enter your name");
        var name = stdin.readLineSync();
        print("Enter password");
        var password = stdin.readLineSync();
        print("Confirm Your Password");
        var cpassword = stdin.readLineSync();
        var user1 = User(name, password);
        if (password == cpassword) {
          await user1.register();
        } else {
          print('Passwords do not match');
        }
      } else if (input == "login") {
        print("Enter your name");
        var name = stdin.readLineSync();
        print("Enter password");
        var password = stdin.readLineSync();
        curruser = User(name, password);
        loggedIn = await curruser.login();
      }
    } else {
      print("Do you want to create a server or join a server?");
      var input2 = stdin.readLineSync();
      bool serverLogin=false;
      if (input2 == "create") {
        print('Please Enter the Server Name');
        var name = stdin.readLineSync();
        var server1 = Server(name);
        currserver=server1;
        serverLogin=true;
        await server1.createServer(curruser);
      } else if (input2 == "join") {
        print('Please Enter the Server Name you want to join');
        var name = stdin.readLineSync();
        // TODO: Implement logic to join an existing server based on the name.
        var server1 = Server(name);
        serverLogin=await server1.joinServer(curruser);
        if(serverLogin){
          currserver=Server(name);
        }
      } else if (input2 == "logout") {
        loggedIn = false;
        curruser = User(null, null);
        print("Logout successfull");
        // TODO: Close the current server connection, if any.
      } else if (input2 == "user") {
        print(curruser.name);
      } else {
        print("Invalid command. Please input either 'create', 'join', 'logout', or 'user'");
      }
      while(serverLogin){
        bool channelLogin=false;
        print('Do you want to create a channel or join a channel. Enter "exit" for exiting the current server.');
        print('The command "view users" would enable you to check all tghe users joined in the server');
        var input2=stdin.readLineSync();
        if(input2=="view users"){
          await currserver.viewUsers();
        }
        else if(input2=="exit") serverLogin=false;
        else if(input2=="create"){
          print("Enter the name of the channel you want to create");
          var channelName=stdin.readLineSync();
         await currserver.createChannel(channelName, curruser.name);
         channelLogin=true;
         currchannel=Channel(channelName);
        }else if(input2=="join"){
          print("Enter the name of the channel you want to join");
          var channelName=stdin.readLineSync();
          var channel=Channel(channelName);
          channelLogin= await currserver.joinChannel(channelName);
          if(channelLogin) currchannel=channel;
       }
       if(channelLogin) {
            messageSend=true;
            while(messageSend){
            print("Enter the message you want to send or Enter 'exit' for exiting the current Channel.");
            print("The command 'view' would enable you to check the messages in the given channel");
            var msg=stdin.readLineSync();
            if(msg=="exit") messageSend=false;
            else if(msg=="view") await currserver.viewMessages(currchannel.name);
            else await currserver.sendMessage(msg,curruser,currchannel.name);
            }
          }
      }
    }
  }
}
