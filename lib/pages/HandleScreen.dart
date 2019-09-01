import 'package:cloudlisten/pages/LoginPage.dart';
import 'package:cloudlisten/pages/NewHomePage.dart';
import 'package:cloudlisten/providers/AudioProvider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HandleScreen extends StatefulWidget {
  @override
  _HandleScreenState createState() => _HandleScreenState();
}

class _HandleScreenState extends State<HandleScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        // TODO: Handle this case.
        break;
      case AppLifecycleState.inactive:
        pause();
        break;
      case AppLifecycleState.paused:
        pause();
        break;
      case AppLifecycleState.suspending:
        pause();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = Provider.of<String>(context);
    TargetPlatform currentPlatform = Theme.of(context).platform;
    if (currentPlatform == TargetPlatform.iOS) {
      if (userId == null) return CircularProgressIndicator();
      return userId == '' ? LoginPage() : NewHomePage();
    }
    return Consumer<ConnectivityResult>(
      builder: (
        BuildContext context,
        ConnectivityResult connectivityResult,
        Widget child,
      ) {
        if (connectivityResult == null || userId == null)
          return Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        switch (connectivityResult) {
          case ConnectivityResult.wifi:
            return (userId == '') ? LoginPage() : NewHomePage();
          case ConnectivityResult.mobile:
            return (userId == '') ? LoginPage() : NewHomePage();
          case ConnectivityResult.none:
            pause();
            return NoInternetScreen();
          default:
            return Container(
              color: Colors.white,
              child: Center(
                child: Text('Unexpected Error'),
              ),
            );
        }
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cloud Upload'),
        backgroundColor: Theme.of(context).accentColor,
        centerTitle: true,
      ),
      body: Center(
        child: Text('Please connect to the Internet!!'),
      ),
    );
  }
}
