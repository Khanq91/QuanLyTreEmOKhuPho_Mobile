import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/providers/auth.dart';
import 'package:mobile/providers/phu_huynh.dart';
import 'package:mobile/providers/tinh_nguyen_vien.dart';
import 'package:mobile/screen/other/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize(),),
        ChangeNotifierProvider(create: (_) => PhuHuynhProvider(),),
        ChangeNotifierProvider(create: (_) => VolunteerProvider(),),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Quản lý Trẻ em Khu phố',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.grey[50],
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
              ),
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('vi', 'VN'), // Tiếng Việt
              Locale('en', 'US'), // English
            ],
            locale: const Locale('vi', 'VN'),
            home: SplashScreen(auth: auth),
          );
        },
      ),
    );
  }
}