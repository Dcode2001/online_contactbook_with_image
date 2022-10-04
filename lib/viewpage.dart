import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:online_contactbook_with_iamge/updatepage.dart';

import 'insertpage.dart';


class viewpage extends StatefulWidget {
  const viewpage({Key? key}) : super(key: key);

  @override
  State<viewpage> createState() => _viewpageState();
}

class _viewpageState extends State<viewpage> {
  List l = [];

  bool status = false;
  int result = 0;

  @override
  void initState() {
    super.initState();

    getAllData();
  }

  getAllData() async {
    Response response = await Dio().get(
        'https://ddevlopment.000webhostapp.com/DIVYESHFOLDER/viewdata.php');
    print(response.data.toString());

    Map m = jsonDecode(response.data);

    int connection = m['connection'];

    if (connection == 1) {
      result = m['result'];

      if (result == 1) {
        l = m['data'];
      }
    }

    status = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Data"),
        centerTitle: true,
      ),
      body: status
          ? (result == 1
              ? ListView.builder(
                  itemCount: l.length,
                  itemBuilder: (context, index) {
                    Map map = l[index];

                    String imageurl = map['imagename'] == ''? "" :
                        "https://ddevlopment.000webhostapp.com/DIVYESHFOLDER/${map['imagename']}";

                    return ListTile(

                      onLongPress: () async {

                        String serverlocation = map['imagename'];

                        showDialog(builder: (context) {
                          return AlertDialog(title: Text("Delete"),
                          content: Text("Are You Sure To Delete ${map['name'].toString().toUpperCase()} Permanatally??"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cancel",
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w600))),
                              TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    var formData = FormData.fromMap({
                                      'id': map['id'],
                                      'serverlocation': serverlocation,
                                    });
                                    var response = await Dio().post(
                                        'https://ddevlopment.000webhostapp.com/DIVYESHFOLDER/deletdata.php',
                                        data: formData);

                                    print(response.data);
                                    Map m = jsonDecode(response.data);
                                    int connection = m['connection'];

                                    if (connection == 1) {
                                      int result = m['result'];
                                      if (result == 1) {
                                        Fluttertoast.showToast(
                                            msg: "Deleted",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.black,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        setState(() {
                                          getAllData();
                                        });
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Contact Not Delete",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor:
                                            Colors.transparent,
                                            textColor: Colors.black,
                                            fontSize: 16.0);
                                      }
                                    }
                                  },
                                  child: Text(
                                    "Delete....",
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red),
                                  )),
                            ],

                          );
                        },context: context, );
                        String id = map['id'];

                        var url = Uri.parse('https://ddevlopment.000webhostapp.com/DIVYESHFOLDER/deletdata.php?id=$id');
                        var response = await http.get(url);
                        print('Response status: ${response.statusCode}');
                        print('Response body: ${response.body}');

                      },

                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) {
                            return updatepage(map);
                          },
                        ));
                      },

                      leading: imageurl.isEmpty
                          ? CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.purple.shade100,
                        backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/128/1077/1077114.png"),
                            // child: Image.asset(
                            //   "myimages/img.png",
                            //   fit: BoxFit.cover,
                            // ),
                          )
                          : CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(imageurl),
                            // child: Image.network(
                            //
                            //   imageurl,
                            //   height: 70,
                            //   width: 70,
                            //   fit: BoxFit.cover,
                              /*loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Stack(
                                    alignment: Alignment.center,
                                  children: [

                                    CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                    Text(((loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!) *
                                        100)
                                        .toInt()
                                        .toString() +
                                        "%",textAlign: TextAlign.center,),
                                  ],
                                );
                              },*/
                            // ),
                          ),
                      title: Text("${map['name']}"),
                      subtitle: Text("${map['contact']}"),
                    );
                  },
                )
              : Center(child: Text("No Data Found")))
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return insertpage();
            },
          ));
        },
        child: Icon(
          Icons.add,
          size: 40,
        ),
      ),
    );
  }
}
