import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'dart:convert';
import '../../URL.dart';
import '../Patient/HomeScreenP.dart';

class PinScreen extends StatefulWidget {

  final String? mobileNumber;
  const PinScreen({required this.mobileNumber});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {

  late String generatedOtpStr = "";

  Future<void> VerifyOtp() async {

      final digits = widget.mobileNumber;
      final response = await http.get(
          Uri.parse('${URL.baseUrl}/get_users/$digits'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        var generated_otp = jsonData['otp'];

        setState(() {
          generatedOtpStr = generated_otp.toString();
        });

      }else{
        Toast.show(
          "Server Error Try Again",
          duration: Toast.lengthShort,
          gravity: Toast.bottom,
          backgroundRadius: 8.0,
        );
      }
    }

    @override
  void initState() {
      VerifyOtp();
  }

  @override
  Widget build(BuildContext context) {

    ToastContext().init(context);

    return Scaffold(
      body: SafeArea(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Your PIN",style: GoogleFonts.inter(
                textStyle: const TextStyle(
                    color: Color(0xff6373CC),
                    fontWeight: FontWeight.bold,
                    fontSize: 48),
              ),textAlign: TextAlign.center,),
              Text(generatedOtpStr.isEmpty ? "" : generatedOtpStr ,
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                        color: Color(0xffF86851),
                        fontWeight: FontWeight.bold,
                        fontSize: 100),
                  ),textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: ElevatedButton(
                  onPressed: ()  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreenP(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6373CC),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(MediaQuery.of(context).size.width, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 16,
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
