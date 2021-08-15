import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:steps_tracker/config.dart';
import 'package:steps_tracker/data/BootsState.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
const SESSION_ID_KEY = 'SESSION_ID_KEY';
const EMAIL_KEY = 'EMAIL_KEY';
final refreshTokenKey = 'refresh_token';
const NO_CONNECTION = 'NO_CONNECTION';
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email'],
);

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return Consumer<BootsState>(builder: (ctx, state, child) {
      return SettingsPageContent();
    });
  }
}

class SettingsPageContent extends StatefulWidget {
  SettingsPageContent({Key? key}) : super(key: key);

  @override
  _SettingsPageContent createState() => _SettingsPageContent();
}

class _SettingsPageContent extends State<SettingsPageContent> {
  bool _accountLoading = true;
  String _sessionId = '';
  String _accountError = '';
  String _email = '';
  String _lastBackupDate = '';
  bool _backupLoading = true;
  String _backupError = '';

  Future<void> _login() async {
    setState(() {
      _accountLoading = true;
      _accountError = '';
    });

    try {
      final a = await _googleSignIn.signIn();
      if (a != null) {
        final googleKey = await a.authentication;
        final idToken = googleKey.idToken;
        if (idToken == null) {
          throw new Exception('Id token is empty');
        }
        final response =
            await http.post(Uri.parse('${Config.API_URL}/users/signup-google'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                },
                body: jsonEncode(<String, String>{
                  'idToken': idToken,
                }));
        if (response.statusCode == 200) {
          final js = json.decode(response.body);
          String sessionId = js['sessionId'];
          String email = js['email'];
          secureStorage.write(key: SESSION_ID_KEY, value: sessionId);
          secureStorage.write(key: EMAIL_KEY, value: email);
          setState(() {
            _sessionId = sessionId;
            _email = email;
          });
          await _getLastBackupDay(sessionId);
        } else if (response.statusCode == 401) {
          await _cleanSession();
        } else {
          setState(() {
            _accountError = NO_CONNECTION;
          });
        }

        setState(() {
          _accountLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _accountLoading = false;
        _sessionId = '';
        _accountError = e is SocketException ? NO_CONNECTION : e.toString();
        _email = '';
      });
    }
  }

  Future<void> _backup(BuildContext ctx) async {
    setState(() {
      _backupLoading = true;
    });
    var state = Provider.of<BootsState>(ctx, listen: false);
    String error = '';
    String date = _lastBackupDate;

    try {
      final response = await http.post(
        Uri.parse('${Config.API_URL}/backups'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'sessionId': _sessionId
        },
        body: jsonEncode(state.toJson()),
      );
      if (response.statusCode == 200) {
        final js = json.decode(response.body);
        date = js['date'];
      } else {
        error = response.reasonPhrase ?? response.body;
      }
    } catch (e) {
      error = e is SocketException ? NO_CONNECTION : e.toString();
    }
    setState(() {
      _backupLoading = false;
      _backupError = error;
      _lastBackupDate = date;
    });
  }

  Future<void> _restoreBackup(BuildContext ctx) async {
    setState(() {
      _backupLoading = true;
    });
    String error = '';
    var state = Provider.of<BootsState>(ctx, listen: false);
    try {
      final response = await http.get(
        Uri.parse('${Config.API_URL}/backups'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'sessionId': _sessionId
        },
      );
      if (response.statusCode == 200) {
        // print(response.body);
        state.set(response.body);
      } else {
        error = response.reasonPhrase ?? response.body;
      }
    } catch (e) {
      error = e is SocketException ? NO_CONNECTION : e.toString();
    }
    setState(() {
      _backupLoading = false;
      _backupError = error;
    });
  }

  Future<void> _cleanSession() async {
    await secureStorage.delete(key: SESSION_ID_KEY);
    setState(() {
      _sessionId = '';
      _email = '';
    });
  }

  void _logout() async {
    final sid = _sessionId;
    try {
      await _cleanSession();
      await http.post(
        Uri.parse('${Config.API_URL}/users/sign-out'),
        headers: <String, String>{
          'sessionId': sid,
        },
      );
    } catch (e) {}
  }

  void _initAction() async {
    String sessionId = await secureStorage.read(key: SESSION_ID_KEY) ?? '';
    String email = await secureStorage.read(key: EMAIL_KEY) ?? '';
    if (sessionId.isEmpty) {
      setState(() {
        _accountLoading = false;
        _backupLoading = false;
      });
      return;
    } else {
      setState(() {
        _accountLoading = false;
        _sessionId = sessionId;
        _email = email;
      });
      await _getLastBackupDay(sessionId);
    }
  }

  Future<void> _getLastBackupDay(String sessionId) async {
    String error = '';
    String date = '';
    try {
      final response = await http.get(
        Uri.parse('${Config.API_URL}/backups/date'),
        headers: <String, String>{
          'sessionId': sessionId,
        },
      );
      if (response.statusCode == 200) {
        final js = json.decode(response.body);
        date = js['date'];
      } else if (response.statusCode == 401) {
        await _cleanSession();
      } else {
        error = NO_CONNECTION;
      }
    } catch (e) {
      error = e is SocketException ? NO_CONNECTION : e.toString();
    }
    setState(() {
      _backupLoading = false;
      _backupError = error;
      _lastBackupDate = date;
    });
  }

  @override
  void initState() {
    _initAction();
    super.initState();
  }

  List<Widget> _accountBlock(BuildContext ctx) {
    var items = [_header('Account:')];
    if (_accountLoading) {
      items.add(
        _wrapListItem(
          Text('Loading...'),
        ),
      );
      return items;
    }

    if (_accountError.isNotEmpty) {
      String errorMessage = _accountError;
      if (_accountError == NO_CONNECTION) {
        errorMessage = 'Cannot connect to the server, try later';
      }
      items.add(
        _wrapListItem(
          Text(errorMessage),
        ),
      );
    }

    if (_email.isEmpty) {
      items.add(
        _wrapListItem(
          _inlineBtn('Log In', _login),
        ),
      );
    } else {
      items.add(
        _wrapListItem(
          Text(_email),
        ),
      );
      items.add(
        _wrapListItem(
          _inlineBtn('Log Out', _logout),
        ),
      );
    }

    return items;
  }

  List<Widget> _backupBlock(BuildContext ctx) {
    var items = [
      Padding(padding: EdgeInsets.all(8.0)),
      _header('Backup:'),
    ];

    if (_email.isEmpty) {
      return items;
    }

    if (_backupLoading) {
      items.add(
        _wrapListItem(
          Text('Loading...'),
        ),
      );
      return items;
    }

    if (_backupError.isNotEmpty) {
      String errorMessage = _backupError;
      if (_backupError == NO_CONNECTION) {
        errorMessage = 'Cannot connect to the server, try later';
      }
      items.add(
        _wrapListItem(
          Text(errorMessage),
        ),
      );
    }

    var date =
        _lastBackupDate.isEmpty ? 'Never' : _lastBackupDate.substring(0, 10);
    items.add(
      _wrapListItem(
        Text(date),
      ),
    );
    items.add(
      _wrapListItem(
        _inlineBtn('Backup', () {
          _backup(ctx);
        }),
      ),
    );
    items.add(
      _wrapListItem(
        _inlineBtn('Restore backup', () {
          _restoreBackup(ctx);
        }),
      ),
    );

    return items;
  }

  Widget _wrapListItem(Widget wgt) {
    return Container(
      margin: EdgeInsets.only(left: 8, top: 8),
      constraints: BoxConstraints(minHeight: 32),
      child: wgt,
    );
  }

  Widget _inlineBtn(String text, void Function() onPressed) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.blue.shade600),
        recognizer: TapGestureRecognizer()..onTap = onPressed,
      ),
    );
  }

  Widget _header(String label) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Consumer<BootsState>(builder: (ctx, state, child) {
        return Container(
          alignment: Alignment.center,
          height: double.infinity,
          child: Container(
            // constraints: BoxConstraints(minWidth: 150, maxWidth: 300),
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(padding: EdgeInsets.fromLTRB(4, 4, 4, 4)),
                ..._accountBlock(ctx),
                ..._backupBlock(ctx),
              ],
            ),
          ),
        );
      }),
    );
  }
}
