import 'package:flutter/material.dart';

class Button_Light extends StatefulWidget {
   String status;
  final Function(String,String) changeStatus;
  final String topic;
  final IconData iconToDisplay;
  final String name;

  Button_Light({
    super.key,
    required this.status,
    required this.changeStatus,
    required this.topic,
    required this.iconToDisplay,
    required this.name
  });

  @override
  State<Button_Light> createState() => _Button_LightState();
}

class _Button_LightState extends State<Button_Light> {

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        setState(() {
         if(widget.status == 'on'){
          widget.status = 'off';
        }else{
          widget.status  = 'on';
        }
        widget.changeStatus(widget.topic, widget.status  );
        });

      } ,
      child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff363E50), Color(0xff2E3648)]),
              //color: Color(0xff333D4D),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                    color: Color(0xff222939),
                    blurRadius: 15,
                    spreadRadius: 5,
                    offset: Offset(-8, 20))
              ]),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.status == 'on' ? Color(0xff00CCFA) : Color(0xff4D5665),
                        boxShadow: [
                          BoxShadow(
                            color: widget.status == 'on' ? Color(0xff00CCFA) : Color(0xff4D5665),
                            spreadRadius: 1,
                            blurRadius: 15,
                            offset: Offset(0, 0),
                          )
                        ]),
                    child: Center(
                        child: Icon(
                      widget.iconToDisplay,
                      size: 55,
                      color: widget.status == 'on' ? Colors.white : Color(0xff707A86),
                    ))),
              ),
              SizedBox(height: 15),
              Text(widget.name,style: TextStyle(color: widget.status == 'on'? Colors.white :Color(0xff737C8B)),)
            ],
          )),
    );
  }
}

