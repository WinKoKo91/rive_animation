import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:rive_animation/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SMIBool? _isDanced;
  SMITrigger? isLookUp;

  Artboard? riveArtboard;

  @override
  void initState() {
    rootBundle.load('assets/animations/birb.riv').then((value) async {
      try {
        final file = RiveFile.import(value);
        final artBoard = file.mainArtboard;
        var controller = StateMachineController.fromArtboard(artBoard, 'birb');
        if (controller != null) {
          artBoard.addController(controller);

          _isDanced = controller.findSMI('dance');
          isLookUp = controller.findSMI('look up');
        }
        setState(() {
          riveArtboard = artBoard;
        });
      } catch (e) {
        print(e);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //https://public.rive.app/community/runtime-files/2063-4080-flutter-puzzle-hack-project.riv

          const Text(
            "Welcome To\nFlutter Reactive Animations",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          SizedBox(
            width: 400,
            height: 400,
            child: riveArtboard != null
                ? Rive(
                    artboard: riveArtboard!,
                  )
                : null,
          ),
          Switch(
              value: _isDanced?.value ?? false,
              onChanged: (value) => toggleDance(value)),
          const Text("Dance"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onClickFAB,
        child: const Icon(Icons.arrow_upward),
      ),
    );
  }

  void _onClickFAB() {
    isLookUp?.value = true;
  }

  toggleDance(bool value) {
    setState(() {
      _isDanced!.value = value;
    });
  }
}
