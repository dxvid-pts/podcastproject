import 'dart:io';

import 'package:dlna/dlna.dart';
import 'package:flutter/material.dart';
import 'package:multicast_dns/multicast_dns.dart';
//import 'package:dlna/dlna.dart';

class CastTestScreenRemove extends StatefulWidget {
  @override
  _CastTestScreenRemoveState createState() => _CastTestScreenRemoveState();
}

class _CastTestScreenRemoveState extends State<CastTestScreenRemove> {
  // List<DLNADevice> devices = List();

  @override
  void initState() {
    /*var dlnaManager = DLNAManager();
    dlnaManager.enableCache();
    dlnaManager.setRefresher(DeviceRefresher(onDeviceAdd: (dlnaDevice) {
      print('add ' + dlnaDevice.toString());
      setState(() {
        if (!devices.contains(dlnaDevice)) devices.add(dlnaDevice);
      });
    }, onDeviceRemove: (dlnaDevice) {
      print('remove ' + dlnaDevice.toString());
    }, onDeviceUpdate: (dlnaDevice) {
      print('update ' + dlnaDevice.toString());
    }, onSearchError: (error) {
      print(error);
    }));
    dlnaManager.startSearch();*/
    initA();
    super.initState();
  }

  initA() async {
    const String name = '_dartobservatory._tcp.local';
    /* var factory =
        (dynamic host, int port, {bool reuseAddress, bool reusePort, int ttl}) {
      return RawDatagramSocket.bind(host, port,
          reuseAddress: true, reusePort: false, ttl: ttl);
    };

    var client = MDnsClient(rawDatagramSocketFactory: factory);*/
    // var client = MDnsClient();
    /*
    // Start the client with default options.
    await client.start();

    // Get the PTR recod for the service.
    await for (PtrResourceRecord ptr in client
        .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
      // Use the domainName from the PTR record to get the SRV record,
      // which will have the port and local hostname.
      // Note that duplicate messages may come through, especially if any
      // other mDNS queries are running elsewhere on the machine.
      await for (SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
          ResourceRecordQuery.service(ptr.domainName))) {
        // Domain name will be something like "io.flutter.example@some-iphone.local._dartobservatory._tcp.local"
        final String bundleId =
            ptr.domainName; //.substring(0, ptr.domainName.indexOf('@'));
        print('Dart observatory instance found at '
            '${srv.target}:${srv.port} for "$bundleId".');
      }
    }
    client.stop();

    print('Done.');*/
    var dlnaManager = DLNAManager();
    dlnaManager.setRefresher(DeviceRefresher(onDeviceAdd: (dlnaDevice) {
      print('add ' + dlnaDevice.toString());
    }, onDeviceRemove: (dlnaDevice) {
      print('remove ' + dlnaDevice.toString());
    }, onDeviceUpdate: (dlnaDevice) {
      print('update ' + dlnaDevice.toString());
    }, onSearchError: (error) {
      print(error);
    }));
    dlnaManager.startSearch();
    await Future.delayed(Duration(seconds: 10));
   // print((await dlnaManager.getLocalDevices()).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('cast'),
      ),
      /*body: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (_, index) {
            return Text(devices[index].deviceName);
          }),*/
    );
  }
}
