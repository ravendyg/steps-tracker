import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:provider/provider.dart';
import 'package:steps_tracker/data/BootsPair.dart';
import 'package:steps_tracker/data/BootsState.dart';
import 'package:steps_tracker/data/DayRecord.dart';
import 'package:steps_tracker/distanceEditorPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  final double _rowHeight = 36;

  List<DayRecord> dayRecords = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      body: _getBodyWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(ctx, '/edit-distance',
              arguments: EditorPageArguments());
        },
        child: const Icon(Icons.edit),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _getBodyWidget() {
    return Consumer<BootsState>(builder: (ctx, state, child) {
      if (state.loading) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Loading...'),
            ],
          ),
        );
      }

      return Container(
        child: HorizontalDataTable(
          leftHandSideColumnWidth: 100,
          rightHandSideColumnWidth: (state.pairs.length + 1) * 100,
          isFixedHeader: true,
          headerWidgets: _getHeaderWidget(state),
          leftSideItemBuilder: (BuildContext ctx, int index) =>
              _getFirstColumnRow(ctx, index, state.days[index]),
          rightSideItemBuilder: (BuildContext ctx, int index) =>
              _getRightHandSideColumnRow(ctx, index, state),
          itemCount: state.days.length,
          leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
          rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
          verticalScrollbarStyle: const ScrollbarStyle(
            isAlwaysShown: true,
            thickness: 4.0,
            radius: Radius.circular(5.0),
          ),
          horizontalScrollbarStyle: const ScrollbarStyle(
            isAlwaysShown: true,
            thickness: 4.0,
            radius: Radius.circular(5.0),
          ),
          enablePullToRefresh: false,
        ),
        height: MediaQuery.of(context).size.height,
      );
    });
  }

  List<Widget> _getHeaderWidget(BootsState state) {
    return [
      _getHeaderFirstItemWidget(state.totalDistance),
      ...state.pairs.map(_getHeaderBootsItemWidget),
      _getHeaderLastItemWidget('${state.pairs.length}'),
    ];
  }

  Widget _getHeaderItemWidget(String label, String sublabel) {
    var padding = EdgeInsets.fromLTRB(5, 0, 0, 0);
    var alignment = Alignment.centerLeft;

    return Container(
      child: Column(
        children: [
          Container(
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            height: 36,
            alignment: alignment,
            padding: padding,
          ),
          Container(
            child:
                Text(sublabel, style: TextStyle(fontWeight: FontWeight.normal)),
            height: 23,
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(width: 1, color: Colors.lightBlue.shade600)),
            ),
            constraints: BoxConstraints(minWidth: double.infinity),
            alignment: alignment,
            padding: padding,
          ),
        ],
      ),
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(width: 1, color: Colors.lightBlue.shade600),
          bottom: BorderSide(width: 1, color: Colors.lightBlue.shade600),
        ),
      ),
    );
  }

  Widget _getHeaderFirstItemWidget(double totalDistance) {
    var padding = EdgeInsets.fromLTRB(5, 0, 0, 0);
    var alignment = Alignment.centerLeft;

    return Container(
      child: Column(
        children: [
          Container(
            height: 36,
            alignment: alignment,
            padding: padding,
          ),
          Container(
            child: Text('${totalDistance.round()}',
                style: TextStyle(fontWeight: FontWeight.normal)),
            height: 23,
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(width: 1, color: Colors.lightBlue.shade600)),
            ),
            constraints: BoxConstraints(minWidth: double.infinity),
            alignment: alignment,
            padding: padding,
          ),
        ],
      ),
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(width: 1, color: Colors.lightBlue.shade600),
          bottom: BorderSide(width: 1, color: Colors.lightBlue.shade600),
        ),
      ),
      alignment: Alignment.center,
    );
  }

  Widget _getHeaderBootsItemWidget(BootsPair pair) {
    return _getHeaderItemWidget(pair.name, pair.total.round().toString());
  }

  Widget _getHeaderLastItemWidget(String nextId) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/edit-boots', arguments: nextId);
      },
      child: Container(
        child: Text('+ Add', style: TextStyle(fontWeight: FontWeight.bold)),
        width: 100,
        height: 60,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(width: 1, color: Colors.lightBlue.shade600),
            bottom: BorderSide(width: 1, color: Colors.lightBlue.shade600),
          ),
        ),
        alignment: Alignment.center,
      ),
    );
  }

  Widget _getFirstColumnRow(BuildContext ctx, int index, DayRecord day) {
    return Container(
      child: Text(day.displayDate()),
      width: 100,
      height: _rowHeight,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(width: 1, color: Colors.lightBlue.shade600),
          bottom: BorderSide(width: 1, color: Colors.lightBlue.shade600),
        ),
      ),
    );
  }

  Widget _getRightHandSideColumnRow(
      BuildContext ctx, int index, BootsState state) {
    var cells = state.pairs.map((p) {
      var day = state.days[index];
      var distance = day.getDistance(p.id);
      return GestureDetector(
        onTap: () {
          var args = EditorPageArguments();
          args.bootsId = p.id;
          args.dayId = index;
          Navigator.pushNamed(ctx, '/edit-distance', arguments: args);
        },
        child: Container(
          child: Row(
            children: <Widget>[
              Text('$distance'),
            ],
          ),
          width: 100,
          height: _rowHeight,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 1, color: Colors.lightBlue.shade600),
              bottom: BorderSide(width: 1, color: Colors.lightBlue.shade600),
            ),
          ),
        ),
      );
    });
    return Row(
      children: [...cells],
    );
  }
}
