import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/app/app.dart';
import 'package:kasirsuper/core/core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  // Observer digunakan untuk melihat perubahan ketika ada perubahan di bloc
  Bloc.observer = AppBlocObserver();
  runApp(const MyApp());
}
