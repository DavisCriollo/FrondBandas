import 'package:flutter/material.dart';
import 'package:infobandas/src/services/socket_service.dart';
import 'package:provider/provider.dart';



class StatusPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {



final socketServer = Provider.of<SocketService>(context);


    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Server Status: ${socketServer.serverStatus}'),
          ],
        ),
     ),
     floatingActionButton: FloatingActionButton(
       child: Icon(Icons.message),
       onPressed: (){
        //  TAREAS:
        // emitir:`mensaje-nuevo`
        // {nombre:'Flutter',mensaje:'Es Genial !!'}
        socketServer.socket.emit('emitir-mensaje',{
          'nombre':'Flutter',
          'mensaje':'Mensaje de Flutter'
        });
       },
     ),
   );
  }
}