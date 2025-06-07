import 'package:flutter/material.dart';
import 'package:flutter_application_demo/English/random_word_screen.dart';
import 'package:flutter_application_demo/English/show_word_screen.dart';
import 'package:flutter_application_demo/home_screen.dart';
import 'login_screen.dart';
import 'package:flutter_application_demo/Metal/metal_price_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,

        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.teal, width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.grey[700]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.teal, // Màu nền mặc định cho ElevatedButton.
            foregroundColor: Colors.white, // Màu chữ mặc định.
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 24.0,
            ),
            textStyle: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 3.0, // Độ nổi của nút.
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.teal, // Màu chữ mặc định cho TextButton.
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0, // Bỏ bóng của AppBar nếu muốn
          // backgroundColor: Colors.teal, // Đã đặt ở trên colorScheme
          // foregroundColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false, // Ẩn banner "Debug" ở góc trên phải.
      // home: const LoginScreen(),
      initialRoute: '/metalPriceScreen',
      routes: {
        '/metalPriceScreen': (context) => const MetalPricesScreen(),
        '/randomWordScreen': (context) => const RandomWordScreen(),
        '/wordViewScreen': (context) => const WordViewScreen(),
        '/loginScreen': (context) => const LoginScreen(),
        '/homeScreen':
            (context) => HomeScreen(
              param: ModalRoute.of(context)!.settings.arguments as HomeParam,
            ),
      }, // Đặt LoginScreen làm màn hình khởi đầu của ứng dụng.
    );
  }
}
