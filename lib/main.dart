import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'local_notification_service.dart';

const habitsBox = 'habits';
const dailyHabitsBox = 'dailyHabits';

Future<void> main() async {
  await Hive.initFlutter();
  await Hive.openBox(habitsBox);
  await Hive.openBox(dailyHabitsBox);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Map<String,dynamic>> _items = [];

  bool ooo = false;

  bool editList = false;

  late Box<String> habitsTableBox;

  final _habitsBox = Hive.box(habitsBox);
  final _dailyHabitsBox = Hive.box(dailyHabitsBox);

  var currentDate = DateTime.now();

  @override
  void initSate() {
    super.initState();
    NotificationService.init(initScheduled:true);
    _refreshItems();
  }

  void _refreshItems() {
    final data = _habitsBox.keys.map((key) {
      final value = _habitsBox.get(key);

      var itt = _dailyHabitsBox.values.where((item) => item['habit'] == key && item['date'] == "${currentDate.year}-${currentDate.month}-${currentDate.day}");
      return {
        "key" : key, "title":value["title"],"color":value['color'],'days':value['days'],'completed':itt.length > 0 ? true : false,'count':_dailyHabitsBox.values.where((item) => item['habit'] == key).length,'not':value['isNof'],'remTime':value['remTime'],'remText':value['remText']
      };
    }).toList();

    setState(() {
      _items = data.reversed.toList();

    });
  }

  _ChangeDay(DateTime date) {
    final data = _habitsBox.keys.map((key) {
      final value = _habitsBox.get(key);

      var itt = _dailyHabitsBox.values.where((item) => item['habit'] == key && item['date'] == "${currentDate.year}-${currentDate.month}-${currentDate.day}");
      return {
        "key" : key, "title":value["title"],"color":value['color'],'days':value['days'],'completed':itt.length > 0 ? true : false,'count':_dailyHabitsBox.values.where((item) => item['habit'] == key).length,'not':value['isNof'],'remTime':value['remTime'],'remText':value['remText']
      };
    }).toList();

    setState(() {
      _items = data.reversed.toList();
      currentDate = date;
    });
  }

  Future<void> _CompleteHabit(int habit,DateTime date) async {
    await _habitsBox.add({
      "habit":habit,
      "date":"${date.year}-${date.month}-${date.day}"
    }).then((value) => {
      _refreshItems()
    });
  }

  Future<void> _deleteItem(int habit) async {
    final delMap = _dailyHabitsBox.toMap();

    delMap.forEach((key, value) {
      if(value['habit'] == habit) {
        _dailyHabitsBox.delete(key);
      }
    });
    await _habitsBox.delete(habit);

    await NotificationService.cancelNotification(id:habit).then((value) => print("deleted $value"));

    _refreshItems();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Habit Deleted")));
  }

  @override
  Widget build(BuildContext context) {

    final date = new DateTime.now();
    final startOfYear = new DateTime(date.year,1,1,0,0);
    final firstMonday = startOfYear.weekday;
    final daysInFirstWeek = 8 - firstMonday;
    final diff = date.difference(startOfYear);
    var weeks = ((diff.inDays - daysInFirstWeek) / 7).ceil();

    var SSweek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    return Scaffold(

      body: SafeArea(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(

            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 15,),
              Row(
                children: [
                  Text("Today",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500),),
                  Spacer(),
                  Text("${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                ],
              ),
              SizedBox(height: 15,),
              Container(
                margin: EdgeInsets.only(left: 10,right: 10),
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: 7,
                    padding: EdgeInsets.only(right: 10,left: 10),
                    itemBuilder: (context,index) {
                      var sWeek = SSweek.add(Duration(days: index));

                      return InkWell(onTap: () => {
                        _ChangeDay(sWeek)
                      },
                          child: sWeek.day == currentDate.day ? cweekDay (startOfWeek:sWeek) : weekDay(startOfWeek:sWeek));
                    },
                    separatorBuilder: (context,index) => SizedBox(width: 20,),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              _items.isEmpty
                  ? const Center(
                child: Text("No Data",
                  style: TextStyle(fontSize: 30),),
              )
                  : Expanded(child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_,index) {
                  final currentItem = _items[index];

                  return InkWell(
                      onLongPress: () => {

                      },
                      onDoubleTap: () async => {
                        _deleteItem(currentItem['key'])
                      },
                      onTap: () => {
                        _CompleteHabit(currentItem['key'],currentDate)
                      },
                      child: !currentItem['completed'] ? cardNotDone(currentItem['count'],title:currentItem['title'],color:currentItem['color'],startOfYear:startOfYear,weeks:weeks) : cardDone(currentItem['title'],currentItem['color'],currentItem['count'],editList));

                },
              ))
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        tooltip: 'New Habit',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class cweekDay extends StatelessWidget {
  const cweekDay({
    Key? key,
    required this.startOfWeek,
  }) : super(key: key);

  final DateTime startOfWeek;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(
              Radius.circular(25.0),
            ),
          ),
          child: Column(
            children: [
              Text("${startOfWeek.day}",style: TextStyle(color: Colors.white,fontSize: 15),),
              SizedBox(height: 20,),
              Text("${DateFormat('EEE').format(startOfWeek)}",style: TextStyle(color: Colors.white,fontSize: 14),),
              SizedBox(height: 15,),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                ),
              )
            ],
          ),
        ),

      ],
    );
  }
}

class weekDay extends StatelessWidget {

  const weekDay({
    Key? key,
    required this.startOfWeek,
  }) : super(key: key);

  final DateTime startOfWeek;


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Text("${startOfWeek.day}",style: TextStyle(fontSize: 15),),
              SizedBox(height: 20,),
              Text("${DateFormat("EEE").format(startOfWeek)}",style: TextStyle(fontSize: 14),),
            ],
          ),
        )
      ],
    );
  }
}

class cardNotDone extends StatefulWidget {
  const cardNotDone(this.days,{Key? key, required this.title,required this.color,required this.startOfYear,required this.weeks}) : super(key: key);

  final String title;

  final String color;

  final DateTime startOfYear;
  final int weeks;

  final int days;

  @override
  State<cardNotDone> createState() => _cardNotDoneState();

}

class _cardNotDoneState extends State<cardNotDone> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 15,
                height: 15,
                child: Center(
                  child:Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black
                ),
              ),
              SizedBox(height: 10,),
              Expanded(child: Container(
                padding: EdgeInsets.only(top: 20,bottom: 3),
                width: 3,
                color: Colors.black,
              ))
            ],
          ),
          SizedBox(width: 5,),
          Expanded(child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(widget.color.getHexValue()),
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.title,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),

                      ],
                    ),

                    Text(widget.days.toString(),style: TextStyle(color: Colors.white),)
                  ],
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}

class cardDone extends StatelessWidget {
  cardDone(this.title,this.color,this.count,this.editList,{Key? key,}) : super(key: key);

  final String title;
  final String color;

  final int count;

  bool editList;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Column(children: [
            Container(
              width: 15,
              height: 15,
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(color.getHexValue())),
                    ),
                  ),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                  ),
                ),
              ),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(color.getHexValue())),
            ),
            SizedBox(height: 10,),
            Expanded(child:
            Container(
                padding: EdgeInsets.only(top: 20,bottom: 3),
                width: 3,
                color: Color(color.getHexValue())),
            )

          ],),
          Expanded(child:
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)
              ],
            ),
          )
          ),
          Column(
            children: [
              Text(count.toString())
            ],
          )
        ],
      ),
    );
  }
}

extension HexString on String {
  int getHexValue() => int.parse(replaceAll('#', '0xff'));
}