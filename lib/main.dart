import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference sensorDataCollection =
      FirebaseFirestore.instance.collection('sensor_data');

  int airQuality = 0;
  int humidity = 0;
  int temperature = 0;
  bool isDataLoaded = false;

  Future<void> fetchSensorData() async {
    DocumentSnapshot documentSnapshot =
        await sensorDataCollection.doc('12Ym3KI8GfgQqJ3Z4O1g').get();

    if (documentSnapshot.exists) {
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        if (data.containsKey('air_quality_sensor') &&
            data.containsKey('humidity_sensor') &&
            data.containsKey('temperature_sensor')) {
          setState(() {
            airQuality = data['air_quality_sensor'] as int;
            airQuality += Random().nextInt(5) - 2;
            humidity = data['humidity_sensor'] as int;
            humidity += Random().nextInt(5) - 2;
            temperature = data['temperature_sensor'] as int;
            temperature += Random().nextInt(5) - 2;
            isDataLoaded = true;
          });
        } else {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('One or more fields are missing in the document'),
            ),
          );
        }
      } else {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document does not exist'),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Flutter App',
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Smart Home App',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isDataLoaded)
                Container(
                  width: 200,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[400]!,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Air Quality: $airQuality',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Humidity: $humidity',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Temperature: $temperature',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: fetchSensorData,
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: Colors.blue),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    child: Text(
                      isDataLoaded
                          ? 'Refresh Sensor Data'
                          : 'Fetch Sensor Data',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
