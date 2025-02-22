import 'dart:convert';
import 'dart:io';

import 'package:aan_uas/bloc/custom_bloc.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:nb_utils/nb_utils.dart';


import 'home.dart';

class EditData extends StatefulWidget {
  Map data;
   EditData(this.data, {super.key});

  @override
  State<EditData> createState() => _EditDataState();
}

class _EditDataState extends State<EditData> {
  TextEditingController nominalCont = TextEditingController();

  TextEditingController keteranganCont = TextEditingController();

  TextEditingController tanggalCont = TextEditingController();

  TextEditingController tipeCont = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  CustomBloc _imgTrans = CustomBloc();
  XFile? _image;

  @override
  void initState() {
    nominalCont.text = widget.data['nominal'];
    keteranganCont.text = widget.data['keterangan'];
    tanggalCont.text = widget.data['tanggal'];
    tipeCont.text = widget.data['tipe'];
    _imgTrans.changeVal(widget.data['trans']);
    super.initState();
  }

   void _openDatePicker(BuildContext context) {
    BottomPicker.date(
      pickerTitle: Text(
        'Pilih Tanggal',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.blue,
        ),
      ),
      dateOrder: DatePickerDateOrder.dmy,
      initialDateTime: DateTime(1996, 10, 22),
      // maxDateTime: DateTime(1998),
      // minDateTime: DateTime(1980),
      pickerTextStyle: TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      onChange: (index) {
        print(index);
        //  tanggal.text= index.toString();
        //   setState(() {
        //     Navigator.pop(context);
        //   });
      },
      onSubmit: (index) {
       tanggalCont.text= index.toString();
          setState(() {
          });
      },
      bottomPickerTheme: BottomPickerTheme.plumPlate,
    ).show(context);
  }


  @override
  Widget build(BuildContext context) {

  String removeBase64(String img) {
  if (img.contains('data:image/png;base64, ') == true) {
    var img64 = img.split('data:image/png;base64, ');
    String imgNew = img64[1].replaceAll(RegExp(r'\s+'), '');
    return imgNew;
  } else {
    return '';
  }
}

  Future getImageGallery(context) async {
    final XFile? imageFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    _image = imageFile!;

    final bytes = File(_image!.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    _imgTrans.changeVal(img64);
    print(img64);
    Navigator.pop(context);
  }

  Future getImageCamera(context) async {
    final XFile? imageFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    _image = imageFile!;
    final bytes = File(_image!.path).readAsBytesSync();
    String img64 = base64Encode(bytes);
    _imgTrans.changeVal(img64);
    print(img64);
    Navigator.pop(context);
  }

   Future editWallet(String key, String nominal, String keterangan, String tanggal, String tipe) async {
        DatabaseReference databaseReference =
            FirebaseDatabase.instanceFor(app: Firebase.app(),
          databaseURL:
              'https://aan-uas-default-rtdb.asia-southeast1.firebasedatabase.app/').ref().child('wallets');

      databaseReference.child(key).update({
         'key_user': userDetail['key'],
         'nominal': nominal,
          'keterangan': keterangan,
          'tanggal': tanggal,
          'tipe': tipe,
          'trans': _imgTrans.state,
      }).then((value){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update Data berhasil !', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green,));
        print("Transaction edited successfully!");
        Navigator.pop(context);
        Navigator.pop(context);
        return true;
      })
      .catchError((error){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update Data gagal !', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red,));
        print("Failed to edit trans: $error");
        return false;
      });

      }


      return Scaffold(
      appBar: AppBar(
      centerTitle: true,
      title: Text('Update Data', style: GoogleFonts.aBeeZee(fontSize:16),),
      flexibleSpace: Container(
           decoration: BoxDecoration(
           gradient: LinearGradient(
           begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Colors.white,
              Colors.blue
            ])
           ),
          ),
         ),
      body: SafeArea(child: SingleChildScrollView(child: 
      Padding(padding: EdgeInsets.symmetric(horizontal: 10), 
      child: Column(
        children: [
          Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
           10.height,
            Text(
             'Foto Transaksi',
              style: primaryTextStyle(size: 14, color: Colors.grey),
            ),
            SizedBox(
              height: 0.01 * MediaQuery.of(context).size.height,
            ),
            BlocBuilder(
                bloc: _imgTrans,
                buildWhen: (previous, current) {
                  if (previous != current) {
                    return true;
                  } else {
                    return false;
                  }
                },
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () {
                      Dialogs.bottomMaterialDialog(
                      barrierDismissible: true,
                      color: Colors.white,
                      title: 'Pilih',
                      customView: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    getImageCamera(context);
                                  },
                                  child: Container(
                                    width: 0.15 * MediaQuery.of(context).size.width,
                                    child: Image.asset(
                                      'img/icon_camera.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 0.1 * MediaQuery.of(context).size.width,
                                ),
                              GestureDetector(
                                  onTap: () {
                                    getImageGallery(context);
                                  },
                                  child: Container(
                                    width: 0.15 * MediaQuery.of(context).size.width,
                                    child: Image.asset(
                                      'img/icon_gallery.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      customViewPosition: CustomViewPosition.BEFORE_ACTION,
                      context: context,
                      actions: []
                      // [
                      // IconsButton(
                      //   onPressed: () {
                      //     Navigator.pop(context);
                      //   },
                      //   text: 'Kembali',
                      //   iconData: Icons.arrow_back,
                      //   color: WAInfo1,
                      //   textStyle: TextStyle(color: WALightColor),
                      //   iconColor: WALightColor,
                      // ),
                      // ]
                      );},
                    child: _imgTrans.state != ''
                        ? Stack(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    MemoryImage(base64Decode(base64 == true
                                        ? removeBase64(_imgTrans.state)
                                        : _imgTrans.state)),
                                maxRadius: 0.11 * MediaQuery.of(context).size.width,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 0.15 * MediaQuery.of(context).size.width,
                                  left: 0.2 * MediaQuery.of(context).size.width,
                                ),
                                child: Icon(
                                  Icons.change_circle,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              )
                            ],
                          )
                        : Stack(
                            children: [
                              Container(
                                width: 0.2 * MediaQuery.of(context).size.width,
                                height: 0.2 * MediaQuery.of(context).size.width,
                                child: Image.asset(
                                  'img/icon_note.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 0.12 * MediaQuery.of(context).size.width,
                                  left: 0.15 * MediaQuery.of(context).size.width,
                                ),
                                child: Icon(
                                  Icons.change_circle,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              )
                            ],
                          ),
                  );
                }),
          ],
          ),
          10.height,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nominal',
                style: GoogleFonts.aBeeZee(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
              ),
              SizedBox(
                height: 0.01 * MediaQuery.of(context).size.height,
              ),
              AppTextField(
                decoration: InputDecoration(
                  hintText: '100000', hintStyle: GoogleFonts.aBeeZee(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey)),
                textFieldType: TextFieldType.OTHER,
                keyboardType: TextInputType.text,
                isPassword: false,
                controller: nominalCont,
                textStyle: GoogleFonts.aBeeZee(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])
              ),
              SizedBox(
                height: 0.01 * MediaQuery.of(context).size.height,
              ),
            ],
          ),
          10.height,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Keterangan',
                style: GoogleFonts.aBeeZee(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
              ),
              SizedBox(
                height: 0.01 * MediaQuery.of(context).size.height,
              ),
              AppTextField(
                decoration: InputDecoration(
                  hintText: 'Gaji Bulanan', hintStyle: GoogleFonts.aBeeZee(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey)),
                textFieldType: TextFieldType.OTHER,
                keyboardType: TextInputType.text,
                isPassword: false,
                controller: keteranganCont,
                textStyle: GoogleFonts.aBeeZee(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])
              ),
              SizedBox(
                height: 0.01 * MediaQuery.of(context).size.height,
              ),
            ],
            ),          
          CheckboxListTile(
            title: Text("Pemasukan"),
            value: tipeCont.text == 'pemasukan'?true:false,
            onChanged: (newValue) {
              setState(() {
                tipeCont.text = newValue == true?'pemasukan':'';
              });
            },
            controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
          ),
          CheckboxListTile(
            title: Text("Pengeluaran"),
            value:  tipeCont.text == 'pengeluaran'?true:false,
            onChanged: (newValue) {
              setState(() {
                 tipeCont.text = newValue == true?'pengeluaran':'';
              });
            },
            controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
          ),
          10.height,
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          SizedBox(width: 200, child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tanggal',
                style: GoogleFonts.aBeeZee(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
              ),
              SizedBox(
                height: 0.01 * MediaQuery.of(context).size.height,
              ),
              AppTextField(
                decoration: InputDecoration(
                  hintText: 'Pilih tanggal', hintStyle: GoogleFonts.aBeeZee(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey)),
                textFieldType: TextFieldType.OTHER,
                keyboardType: TextInputType.text,
                isPassword: false,
                controller: tanggalCont,
                textStyle: GoogleFonts.aBeeZee(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])
              ),
              SizedBox(
                height: 0.01 * MediaQuery.of(context).size.height,
              ),
            ],
          ),),
          IconButton(onPressed: (){
              _openDatePicker(context);
            }, icon: Icon(Icons.calendar_month, color: Colors.blue, size: 35,))
          ],),
          30.height,
          GestureDetector(
          onTap: ()async{
           await editWallet(widget.data['key'], nominalCont.text, keteranganCont.text, tanggalCont.text, tipeCont.text);
          },  
          child: Container(width: 200, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.blue[900]),
          child: Center(child: Text('Update Data', style: GoogleFonts.aBeeZee(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),),),
          ),),
          
        ],
      ),),)),
    );
  }
}