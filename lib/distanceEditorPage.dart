import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steps_tracker/data/BootsState.dart';
import 'package:steps_tracker/utils/dateUtils.dart';

class EditorPageArguments {
  int dayId = -1;
  String bootsId = '-1';
}

class DistanceEditorPage extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return Consumer<BootsState>(builder: (ctx, state, child) {
      final EditorPageArguments args =
          ModalRoute.of(ctx)?.settings.arguments as EditorPageArguments;
      DateTime day;
      double distance = 0.0;
      if (args.dayId >= 0) {
        // editing existing record
        day = state.days[args.dayId].day;
        distance = state.getDayBootsDistance(day, args.bootsId);
      } else {
        // creating a new one
        // today by default
        day = state.days[0].day;
      }
      return DistanceEditorPageContent(
        dayId: args.dayId,
        day: day,
        pairId: args.bootsId,
        distance: distance,
      );
    });
  }
}

class DistanceEditorPageContent extends StatefulWidget {
  final int dayId;
  final DateTime day;
  final String pairId;
  final double distance;

  DistanceEditorPageContent(
      {Key? key,
      required this.dayId,
      required this.day,
      required this.pairId,
      required this.distance})
      : super(key: key);

  @override
  _DistanceEditorPageContent createState() => _DistanceEditorPageContent();
}

class _DistanceEditorPageContent extends State<DistanceEditorPageContent> {
  final _distanceController = TextEditingController();
  DateTime _date = DateTime.now();
  String _pairId = '-1';
  bool _isNew = true;

  @override
  void initState() {
    _date = widget.day;
    _pairId = widget.pairId;
    if (widget.distance != 0.0) {
      _distanceController.text = '${widget.distance}';
    }
    if (_pairId != '-1') {
      _isNew = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit day distance'),
      ),
      body: Consumer<BootsState>(builder: (ctx, state, child) {
        List<DropdownMenuItem<String>> listItems = [
          ...state.pairs.map<DropdownMenuItem<String>>((e) {
            return DropdownMenuItem<String>(
              value: e.id,
              child: Text(e.name),
            );
          })
        ];
        if (_pairId == '-1') {
          listItems = [
            DropdownMenuItem<String>(
              value: '-1',
              child: Text('Select the boots'),
            ),
            ...listItems,
          ];
        }
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
                  child: ElevatedButton(
                    child: Text(formatDateWithWeekDay(_date)),
                    onPressed: () => _selectDate(ctx),
                  ),
                ),
                Container(
                  child: DropdownButton<String>(
                    value: _pairId,
                    items: listItems,
                    onChanged: (String? newVal) {
                      if (newVal != null && newVal != _pairId) {
                        setState(() {
                          _pairId = newVal;
                        });
                      }
                    },
                  ),
                  margin: EdgeInsets.fromLTRB(0, 24, 0, 24),
                ),
                if (_pairId != '-1') ...[
                  Container(
                    child: TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      autofocus: !_isNew,
                    ),
                  ),
                ],
                Container(
                  child: TextButton(
                    child: Text(
                      'Save',
                      style: TextStyle(
                          color: _pairId != '-1'
                              ? Colors.blue.shade600
                              : Colors.grey.shade600),
                    ),
                    onPressed: _pairId != '-1'
                        ? () {
                            state.updateDistance(widget.dayId, _date, _pairId,
                                _distanceController.text);
                            Navigator.pop(context);
                          }
                        : null,
                  ),
                  margin: EdgeInsets.fromLTRB(0, 24, 0, 24),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }
}
