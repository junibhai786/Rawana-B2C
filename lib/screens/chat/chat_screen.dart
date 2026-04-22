import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../data_models/chatscreen_data.dart';
import '../../widgets/tertiary_button.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(
                "assets/haven/avatar_2.jpg",
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Text(
                "Jawire",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  fontFamily: 'Inter'.tr,
                ),
              ),
            ),
          ],
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.more_vert,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: //room image & name
              Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                //image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    "assets/haven/resort_1.jpg",
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                //room name
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Cupaniccodo St Buno's Garden, Komet Indonesia",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter'.tr,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Spacer(),
                        //inquiry

                        Text(
                          "Inquiry: Nov 20 - 25",
                          style: TextStyle(
                            fontSize: 12,
                            color: kColor1,
                            fontFamily: 'Inter'.tr,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //messages list
                  ListView.builder(
                    itemCount: demoChatScreenData.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ChatItem(
                        dataSrc: demoChatScreenData[index],
                      );
                    },
                  ),
                  const SizedBox(
                    height: 116,
                  )
                ],
              ),
            ),
          ),

          //Text input box
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 129,
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 20,
              ),
              color: kBackgroundColor,
              child: Column(
                children: [
                  //chat text box
                  TextFormField(
                    cursorColor: kColor1,
                    style: TextStyle(
                      color: kColor1,
                      fontFamily: 'Inter'.tr,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: outlineInputBorder(),
                      focusedBorder: outlineInputBorder(),
                      border: outlineInputBorder(),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //attach button
                          Icon(
                            Icons.attach_file,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                          const SizedBox(
                            width: 8,
                          ),

                          //camera button
                          Icon(
                            Icons.photo_camera,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                        ],
                      ),
                      contentPadding: const EdgeInsets.only(
                        top: 12,
                        bottom: 12,
                        right: 11,
                        left: 16,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  //Request to Book
                  TertiaryButton(
                    text: "Request to Book",
                    press: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//chat item

class ChatItem extends StatelessWidget {
  const ChatItem({
    super.key,
    required this.dataSrc,
  });

  final ChatScreenData dataSrc;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        //top: 10,
        bottom: 16,
      ),
      child: Align(
        alignment: (dataSrc.messageType == "receiver"
            ? Alignment.topLeft
            : Alignment.topRight),
        child: Container(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.82),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: (dataSrc.messageType == "receiver"
                ? Colors.grey.shade100
                : kSecondaryColor.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              //chat content
              Text(
                dataSrc.messageContent,
                style: TextStyle(
                  fontSize: 12,
                  color: kPrimaryColor,
                  fontFamily: 'Inter'.tr,
                ),
              ),

              //time
              dataSrc.messageType == "receiver"
                  ? Text(
                      dataSrc.time,
                      style: TextStyle(
                        fontSize: 10,
                        color: kColor1,
                        fontFamily: 'Inter'.tr,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          dataSrc.time,
                          style: TextStyle(
                            fontSize: 10,
                            color: kColor1,
                            fontFamily: 'Inter'.tr,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        const Icon(
                          Icons.done_all,
                          color: AppColors.primary,
                          size: 12,
                        )
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(50),
    borderSide: BorderSide(color: Colors.grey.shade400),
  );
}

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        