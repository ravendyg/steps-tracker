import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:steps_tracker/data/BootsPair.dart';
import 'package:steps_tracker/data/BootsState.dart';

class BootsEditorPage extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return Consumer<BootsState>(builder: (ctx, state, child) {
      var bootsId = ModalRoute.of(ctx)?.settings.arguments as String;
      BootsPair? bootsPair = state.pairs.firstWhereOrNull(
        (element) => element.id == bootsId,
      );
      var isNew = false;
      if (bootsPair == null) {
        bootsPair = BootsPair('${state.pairs.length}', '');
        isNew = true;
      }
      return BootsEditorPageContent(
        bootsPair: bootsPair,
        isNew: isNew,
      );
    });
  }
}

class BootsEditorPageContent extends StatefulWidget {
  final bool isNew;
  final BootsPair bootsPair;
  BootsEditorPageContent(
      {Key? key, required this.isNew, required this.bootsPair})
      : super(key: key);

  @override
  _BootsEditorPageContent createState() => _BootsEditorPageContent();
}

class _BootsEditorPageContent extends State<BootsEditorPageContent> {
  final _bootsNameController = TextEditingController();
  var _btnEnabled = false;

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'Add pair' : 'Edit pair'),
      ),
      body: Consumer<BootsState>(builder: (ctx, state, child) {
        return Container(
          alignment: Alignment.center,
          height: double.infinity,
          child: Container(
            constraints: BoxConstraints(minWidth: 150, maxWidth: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: TextField(
                    controller: _bootsNameController,
                    onChanged: (val) {
                      setState(() {
                        _btnEnabled =
                            val.length > 0 && val != widget.bootsPair.name;
                      });
                    },
                    autofocus: widget.isNew,
                  ),
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 24),
                ),
                TextButton(
                  child: Text(
                    'Save',
                    style: TextStyle(
                        color: _btnEnabled
                            ? Colors.blue.shade600
                            : Colors.grey.shade600),
                  ),
                  onPressed: _btnEnabled
                      ? () {
                          if (widget.isNew) {
                            widget.bootsPair.name = _bootsNameController.text;
                            state.addPair(widget.bootsPair);
                            Navigator.pop(context);
                          }
                        }
                      : null,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _bootsNameController.dispose();
    super.dispose();
  }
}
