import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:weatherappdemo/api_services/api_services.dart';
import 'package:weatherappdemo/weather_data/bloc/weather_bloc.dart';
import 'package:weatherappdemo/weather_data/weather_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        useMaterial3: false
      ),
      home: BlocProvider(
        create: (context) => WeatherBloc(
          WeatherApiService(),
          FirebaseFirestore.instance,
        ),
        child: WeatherScreen(),
      ),
    );
  }
}