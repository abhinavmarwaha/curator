import 'package:audio_service/audio_service.dart';
import 'package:curator/Screens/defRssScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Utilities/ThemeChanger.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
        create: (_) => ThemeChanger(),
        child: Builder(builder: (context) {
          final theme = Provider.of<ThemeChanger>(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Curator',
            theme: theme.getTheme(),
            home: AudioServiceWidget(child: DefRssScreen(title: 'Curator')),
          );
        }));
  }
}
