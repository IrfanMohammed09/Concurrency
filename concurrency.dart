import 'dart:isolate';

import 'package:async/async.dart';

void main() async {
  final p = ReceivePort();
  await Isolate.spawn(
      thread, p.sendPort); // invoking the Isolate for first time opening stream
  // Convert the ReceivePort into a StreamQueue to receive messages from the
  // spawned isolate using a pull-based interface. Events are stored in this
  // queue until they are accessed by `events.next`.
  final events = StreamQueue<dynamic>(p);
  SendPort sendPort = await events.next;
  // The first message from the spawned isolate is a SendPort. This port is
  // used to communicate with the spawned isolate.
  int i = 0; // i is the variable shared by multiple isolates
  while (i < 1000) {
    sendPort.send(i);
    i = await events.next;
  }

  // Dispose the StreamQueue.
  await events.cancel();
}

void thread(SendPort sp) async {
  final commandPort = ReceivePort();
  sp.send(commandPort.sendPort);

  await for (int sv in commandPort) {
    sv += 1; // increase the shared variable value by 1
    print(sv); // print shared variable
    sp.send(
        sv); // send the shared varibale to other islote which is waitinf to access this variable
  }
  print('Spawned isolate finished.');
  Isolate.exit();
}
