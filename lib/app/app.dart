import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasirsuper/app/routes.dart';
import 'package:kasirsuper/core/core.dart';
import 'package:kasirsuper/features/home/blocs/blocs.dart';
import 'package:kasirsuper/features/settings/settings.dart';
import 'package:kasirsuper/features/product/blocs/blocs.dart';
import 'package:kasirsuper/features/pos/blocs/pos_bloc.dart';
import 'package:kasirsuper/features/transaction/blocs/transaction_bloc.dart';
import 'package:kasirsuper/features/service/blocs/blocs.dart';
import 'package:kasirsuper/core/database/database_helper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BottomNavBloc()),
        BlocProvider(create: (context) => ProfileBloc()),
        BlocProvider(create: (context) => ProductBloc(databaseHelper: DatabaseHelper())..add(LoadProducts())),
        BlocProvider(create: (context) => ServiceBloc(dbHelper: DatabaseHelper())..add(LoadServices())),
        BlocProvider(create: (context) => PosBloc()),
        BlocProvider(create: (context) => TransactionBloc(databaseHelper: DatabaseHelper())),
      ],
      child: MaterialApp(
        title: 'Kasir Super',
        debugShowCheckedModeBanner: false,
        theme: LightTheme(AppColors.green).theme,
        home: const SplashScreen(),
        onGenerateRoute: routes,
      ),
    );
  }
}
