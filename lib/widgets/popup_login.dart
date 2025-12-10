import 'package:flutter/material.dart';
import 'package:moonbnd/constants.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onCancel;
  final VoidCallback onLogin;

  const CustomBottomSheet({
    Key? key,
    required this.title,
    required this.content,
    required this.onCancel,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, fontFamily: 'Inter',),
                  ),
                ),
                InkWell(
                    onTap: onCancel,
                    child: Icon(Icons.close))
              ],
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                content,
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500, fontFamily: 'Inter',),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    backgroundColor:Colors.white, // Optional: background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                      side: BorderSide(width: 1,color: Colors.black12)// Rectangular shape
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Optional: padding
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 5),
                    child: Text('Cancel',style: TextStyle(fontSize: 15,color:  Colors.grey[500]),),
                  ),
                ),
                SizedBox(width: 15,),

                TextButton(
                  onPressed: onLogin,
                  style: TextButton.styleFrom(
                    backgroundColor: kSecondaryColor, // Optional: background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                      // Rectangular shape
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Optional: padding
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 5),
                    child: Text('Login',style: TextStyle(color: Colors.white,fontSize: 15),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
