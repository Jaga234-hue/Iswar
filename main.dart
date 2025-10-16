import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user/fragments/chat_screen.dart';
import 'user/fragments/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: MaterialApp(
        title: 'Iswar AI',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: Color(0xFF1e1e2f),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF0f0f23),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        home: ChatScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}