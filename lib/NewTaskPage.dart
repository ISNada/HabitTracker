import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'local_notification_service.dart';

class NewTaskPage extends StatefulWidget {
  NewTaskPage(this.habit,{Key? key, required this.habitsBox}) : super(key: key);

  final Box<dynamic> habitsBox;

  dynamic habit;

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {

  List<int> selectedDays = [];

  bool isLoading = false;

  final TextStyle placeholderTextFieldStyle = TextStyle(color: Colors.grey.shade400);

  TextEditingController titleTextEditingController = new TextEditingController();
  TextEditingController descTextEditingController = new TextEditingController();

  var colors = ['#EC5555','#F5EE75','#21C069','#0758F1','#867AF5','#A98363','#929592'];

  var days = ['sunday','monday','tuesday','wednesday','thursday','friday','saturday'];

  var selectedColor = 0;

  bool state = false;

  DateTime selectedDate = DateTime.now();

  DateTime _choosenDateTime = DateTime.now();


  @override
  void initState() {

    if(widget.habit != null) {
      titleTextEditingController.text = widget.habit['title'];
      descTextEditingController.text = widget.habit['remText'] != null ? widget.habit['remText'] : "";

      selectedDays = widget.habit['days'];

      selectedColor = colors.indexOf(widget.habit['color']);

      setState(() {
        state = widget.habit['not'];
        _choosenDateTime = widget.habit['remTime'];
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.only(left: 20,right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Color(0xFF756d54),
                        size: 32,
                      ),
                    ),
                  ),
                  Spacer(),
                  Center(
                    child: Text(widget.habit != null ? "Edit Habit" : "Add New Habit",
                      style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 25,
                          letterSpacing: 0.0,
                          color: Colors.black
                      ),),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      saveToDb();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.done,
                        color: Color(0xFF756d54),
                        size: 32,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20,),
              TextField(
                controller: titleTextEditingController,
                autocorrect: false,
                autofocus: true,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    hintText: 'Title...',
                    filled: true,
                    fillColor: Colors.brown.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none
                    )
                ),
              ),
              SizedBox(height: 20,),
              Container(
                margin: EdgeInsets.only(left: 10,right: 10),
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context,index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = index;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(colors[index].getHexValue())
                            ),
                            child: selectedColor == index ? Icon(Icons.check,color: Colors.white,) : null,
                          ),
                        );
                      },
                      separatorBuilder: (context,index) => SizedBox(width: 10,),
                      itemCount: colors.length),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                margin: EdgeInsets.only(left: 10,right: 10),
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context,index) {
                        return Material(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if(selectedDays.contains(index)) {
                                  selectedDays.remove(index);
                                } else {
                                  selectedDays.add(index);
                                }
                              });
                            },
                            child: Container(
                              height: 50,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: selectedDays.contains(index) ? Color(colors[selectedColor].getHexValue()) : Colors.brown.shade100,
                                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              ),
                              child: Center(
                                child: Text(days[index],style: TextStyle(
                                    color: Colors.white
                                ),),
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context,index) => SizedBox(width: 10,)
                      , itemCount: days.length),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                width: double.infinity,
                child: Row(
                  children: [
                    Text("Add Reminder", style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                    Spacer(),
                    SizedBox(width: MediaQuery.of(context).size.width*0.15,
                      child: Switch.adaptive(value: state, onChanged: (value) {
                        setState(() {
                          state = value;
                        });
                      }),)
                  ],
                ),
              ),
              SizedBox(height: 20,),
              if(state == true) Container(
                margin: EdgeInsets.only(left: 10,right: 10),
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showDatePicker(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(19),
                        decoration: BoxDecoration(
                          color: Colors.brown.shade100,
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.timer_outlined,color: Colors.black,),
                            SizedBox(width: 5,),
                            Text("${_choosenDateTime.hour}:${_choosenDateTime.minute}",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black
                              ),)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 15,),
                    Expanded(child: TextField(
                      controller: descTextEditingController,
                      autocorrect: false,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          hintText: 'Reminder Text...',
                          filled: true,
                          fillColor: Colors.brown.shade100,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none
                          )
                      ),
                    ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showDatePicker(ctx) {
    showCupertinoModalPopup(context: ctx, builder: (_) => Container(
      height: 500,
      color: Color.fromARGB(255, 255, 255, 255),
      child: Column(
        children: [
          SizedBox(
            height: 400,
            child: CupertinoDatePicker(initialDateTime: DateTime.now(),
                mode: CupertinoDatePickerMode.time,
                onDateTimeChanged: (val) {setState(() {
                  _choosenDateTime = val;
                });}),
          ),
          CupertinoButton(child: Text("OK"), onPressed: () => Navigator.of(ctx).pop())
        ],
      ),
    ));
  }

  Future<void> saveToDb() async {
    int df = -1;

    if(widget.habit != null) {
      await widget.habitsBox.put(widget.habit['key'],{
        "title":titleTextEditingController.text,
        "color":colors[selectedColor],
        "days":selectedDays,
        "isNof":state,
        "remText":descTextEditingController.text,
        "remTime":_choosenDateTime
      });

      if(state) {
        if(widget.habit['isNof']) {
          await NotificationService.cancelNotification(
              id:widget.habit['key']
          );
        }

        NotificationService.showScheduledNotification(id:widget.habit['key'],
            title:descTextEditingController.text,body:titleTextEditingController.text,payload:"",sechuledDate:_choosenDateTime,days:selectedDays);
      }
    } else {
      await widget.habitsBox.add({
        "title":titleTextEditingController.text,
        "color":colors[selectedColor],
        "days":selectedDays,
        "isNof":state,
        "remText":descTextEditingController.text,
        "remTime":_choosenDateTime
      }).then((value) => {
        df = value
      });

      if(state) {

        NotificationService.showScheduledNotification(id:df,
            title:descTextEditingController.text,body:titleTextEditingController.text,payload:"",sechuledDate:_choosenDateTime,days:selectedDays);
      }
    }

    Navigator.pop(context,true);
  }
}

extension HexString on String {
  int getHexValue() => int.parse(replaceAll('#', '0xff'));
}