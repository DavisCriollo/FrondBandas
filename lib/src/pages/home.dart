import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infobandas/src/models/band.dart';
import 'package:infobandas/src/services/socket_service.dart';


import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Metalica', votes: 5),
    // Band(id: '2', name: 'Nirvana', votes: 3),
    // Band(id: '3', name: 'Heroes del Silencio', votes: 2),
    // Band(id: '4', name: 'Bon Jovi', votes: 1),
  ];

  @override
  void initState() {
    final socketServer = Provider.of<SocketService>(context, listen: false);
    socketServer.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

    setState(() {});

    print(payload);
  }

  @override
  void dispose() {
    final socketServer = Provider.of<SocketService>(context, listen: false);
    socketServer.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketServer = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: (socketServer.serverStatus == ServerStatus.Online)
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ],
        title: Text(
          'Nombre de Bandas',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: 
      
       Column(
        children: [
          _showGrafica(),
          Expanded(
            child: 
            ListView.builder(
              itemCount: bands.length,
              itemBuilder: (BuildContext context, int index) =>
                  bandTile(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: Icon(Icons.add),
        onPressed: addNewBand,
      ),
    );
  }

  Widget bandTile(Band band) {
    final socketServer = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: EdgeInsets.only(left: 5.0),
        alignment: Alignment.centerLeft,
        color: Colors.red,
        child: Text(
          'Delete Band',
          style: TextStyle(color: Colors.white),
        ),
      ),
      key: Key(band.id),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20.0),
        ),
        onTap: () => socketServer.socket.emit('puntaje-banda', {'id': band.id}),
      ),
      //======== REALIZA LA ELIMINACION =====
      onDismissed: (_) =>
          socketServer.socket.emit('delete-banda', {'id': band.id}),

      // =================
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Nuevo nombre de Banda:'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              child: Text('Add'),
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList(textController.text),
            )
          ],
        ),
      );
    }
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text('Nuevo nombre de Banda:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Cerrar'),
              onPressed: () => addBandToList(textController.text),
            )
          ],
        );
      },
    );
  }

  void addBandToList(String name) {
    print(name);
    if (name.length > 1) {
      //  AGREGAMOS DATO
      // TAREA
      // emitir: add-band
      // {name: name}
      final socketServer = Provider.of<SocketService>(context, listen: false);
      socketServer.socket.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  // MUESTRA GRAFICA
  Widget _showGrafica() {
    Map<String, double> dataMap = new Map();

    bands.forEach(
        (band) => dataMap.putIfAbsent(band.name, () => band.votes.toDouble()));

    final List<Color> colorList = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.brown,
      Colors.pink,
      Colors.orange,
    ];

    return Container(
      margin: EdgeInsets.all(3.0),
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        // chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
