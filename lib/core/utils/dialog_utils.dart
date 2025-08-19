import 'package:flutter/material.dart';
//function to load
///function to hide
///function to
class DialogUtils{
  static void showLoading({required BuildContext context,required String msg}){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context){
          return AlertDialog(
            content: Row(children: [
              CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(msg,style: TextStyle(color:Colors.black,fontSize: 16),),
              )
            ]),
          );
        });
  }

  static void hideLoading({required BuildContext context}){
    Navigator.pop(context);
  }

  static showMsg({required BuildContext context,
    required String msg,
    String?posActionName,
    Function?posAction,
    String?negActionName,
    Function? negAction,
    String title=''
  }){
    List<Widget>actions=[];
    if(posActionName!=null){        //posAction is word not null
      actions.add(TextButton(onPressed: (){
        Navigator.pop(context);
        posAction?.call();   //if posAction is not equal null  call it /do it
      }, child: Text(posActionName)));
    }
    if(negActionName!=null){
      actions.add(TextButton(onPressed: (){
        Navigator.pop(context);
        negAction?.call();
      },
          child: Text(negActionName)));
    }
    showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Text(msg),
        title: Text(
          title,style: TextStyle(color: Colors.black),
        ),
        actions: actions,
      );
    });

  }
}