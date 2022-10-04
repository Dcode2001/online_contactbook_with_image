import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_contactbook_with_iamge/viewpage.dart';

class insertpage extends StatefulWidget {
  const insertpage({Key? key}) : super(key: key);

  @override
  State<insertpage> createState() => _insertpageState();
}

class _insertpageState extends State<insertpage> {
  TextEditingController _name = TextEditingController();
  TextEditingController _contact = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  String path = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          // resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text("Contact Book"),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(
                              builder: (context) {
                                return SimpleDialog(
                                  title: Text("Select Picture"),
                                  children: [
                                    ListTile(
                                      onTap: () async {
                                        Navigator.pop(context);
                                        final XFile? photo =
                                            await _picker.pickImage(
                                                source: ImageSource.camera);

                                        if (photo != null) {
                                          path = photo.path;
                                          setState(() {});
                                        }
                                      },
                                      title: Text("Camera"),
                                      leading: Icon(Icons.camera_alt),
                                    ),
                                    ListTile(
                                      onTap: () async {
                                        Navigator.pop(context);
                                        final XFile? photo =
                                            await _picker.pickImage(
                                                source: ImageSource.gallery);

                                        if (photo != null) {
                                          path = photo.path;
                                          setState(() {});
                                        }
                                      },
                                      title: Text("Gallery"),
                                      leading: Icon(Icons.photo),
                                    )
                                  ],
                                );
                              },
                              context: context);
                        },
                        child: path.isEmpty
                            ? Image.asset(
                                "myimages/img.png",
                                height: 200,
                                width: 200,
                                fit: BoxFit.fill,
                              )
                            : Image.file(
                                File(path),
                                height: 200,
                                width: 200,
                                fit: BoxFit.fill,
                              ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: "User Name",
                            labelText: "Name",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                            filled: true,
                            fillColor: Colors.grey.shade100),
                      ),

                      SizedBox(height: 10),

                      TextField(
                          controller: _contact,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: "Contact Number",
                            labelText: "Contact",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                            filled: true,
                            fillColor: Colors.grey.shade100),
                      ),

                      SizedBox(height: 20),

                      ElevatedButton(
                          onPressed: () async {
                            String name = _name.text;
                            String contact = _contact.text;

                            // List<String> l = path.split(
                            //     "/"); // storage/emulted/0/Download/Image20220730.jpg  //slase thi alag padse...
                            //
                            // String imagename = l.last;
                            //
                            // // Dio dio = Dio();   dio name no object create

                            DateTime dt = DateTime.now();

                            String imagename = "$name"
                                "${dt.year}/${dt.month}/${dt.day}"
                                "${dt.hour}:${dt.minute}:${dt.second}.jpg";

                            // var formData = FormData.fromMap({});

                            var formData = path.isEmpty ?
                            FormData.fromMap({
                              'name': name,
                              'contact': contact,
                              'imageview':"0"
                            }) :
                            FormData.fromMap({
                              'name': name,
                              'contact': contact,
                              'imageview':"1",
                            'file': await MultipartFile.fromFile(path,
                                  filename: imagename),
                            });
                            var response = await Dio().post(
                                'https://ddevlopment.000webhostapp.com/DIVYESHFOLDER/contactbook.php',
                                data: formData); // Dio() direct object create.

                            print(response.data);

                            Map m = jsonDecode(response.data);

                            int connection = m['connection'];

                            if (connection == 1) {
                              int result = m['result'];

                              if (result == 1) {
                                print("Data Inserted.....");

                                Fluttertoast.showToast(
                                    msg: "Save Sucessfully....",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    fontSize: 16.0);

                                Navigator.pushReplacement(context, MaterialPageRoute(
                                      builder: (context) {
                                        return viewpage();
                                      },));
                              } else {

                                print("Data Not Inserted");
                                Fluttertoast.showToast(
                                    msg: "Contact Not Save",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            } else {
                              print("No DATA ?!!!!!!");
                            }

                            // Navigator.pushReplacement(context, MaterialPageRoute(
                            //   builder: (context) {
                            //     return viewpage();
                            //   },));
                          },
                          child: Text("Save"))
                    ]),
              ),
            ),
          ),
        ),
        onWillPop: GoBack);
  }

  Future<bool> GoBack() {
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return viewpage();
      },
    ));
    return Future.value();
  }
}
