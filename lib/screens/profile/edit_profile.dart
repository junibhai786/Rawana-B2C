// ignore_for_file: library_private_types_in_public_api, sort_child_properties_last, prefer__ructors, prefer__literals_to_create_immutables, curly_braces_in_flow_control_structures, prefer_const_constructors

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/auth_provider.dart';

import 'package:moonbnd/constants.dart';

class EditProfile extends StatefulWidget {
  EditProfile({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfile> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  bool isEditingUsername = false;
  bool isEditingEmail = false; // This will remain false
  bool isEditingFirstName = false;
  bool isEditingLastName = false;
  bool isEditingPhoneNumber = false;
  bool isEditingBirthday = false;
  bool isEditingAboutYourself = false;
  bool isEditingAddress1 = false;
  bool isEditingAddress2 = false;
  bool isEditingCity = false;
  bool isEditingState = false;
  bool isEditingCountry = false;
  bool isEditingZipCode = false;

  TextEditingController usernameController =
      TextEditingController(text: "SarahJones");
  TextEditingController emailController =
      TextEditingController(text: "Sarah@gmail.com");
  TextEditingController firstNameController =
      TextEditingController(text: "Sarah");
  TextEditingController lastNameController =
      TextEditingController(text: "Jones");
  TextEditingController phoneNumberController =
      TextEditingController(text: "1234567890");
  TextEditingController birthdayController =
      TextEditingController(text: "09/12/1999");
  // ignore: non_ant_identifier_names
  TextEditingController aboutController =
      TextEditingController(text: "lorem ipsum");

  TextEditingController address1Controller =
      TextEditingController(text: "123 Main St");
  TextEditingController address2Controller =
      TextEditingController(text: "Apt 4B");
  TextEditingController cityController =
      TextEditingController(text: "New York");
  TextEditingController stateController = TextEditingController(text: "NY");
  TextEditingController countryController = TextEditingController(text: "USA");
  TextEditingController zipCodeController =
      TextEditingController(text: "10001");

  Future<void> _pickImage() async {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      setState(() {
        isLoading = true;
      });
      await provider.changeProfilePic(pickedFile.path).then((value) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AuthProvider>(context, listen: false);

    usernameController = TextEditingController(
        text:
            "${provider.myProfile?.data?.firstName} ${provider.myProfile?.data?.lastName}");
    emailController =
        TextEditingController(text: provider.myProfile?.data?.email ?? "");
    firstNameController =
        TextEditingController(text: provider.myProfile?.data?.firstName ?? "");
    lastNameController =
        TextEditingController(text: provider.myProfile?.data?.lastName ?? "");
    phoneNumberController =
        TextEditingController(text: provider.myProfile?.data?.phone ?? "");
    birthdayController =
        TextEditingController(text: provider.myProfile?.data?.birthday ?? "");
    aboutController =
        TextEditingController(text: provider.myProfile?.data?.bio ?? "");
    address1Controller =
        TextEditingController(text: provider.myProfile?.data?.address ?? "");
    address2Controller =
        TextEditingController(text: provider.myProfile?.data?.address2 ?? "");
    cityController =
        TextEditingController(text: provider.myProfile?.data?.city ?? "");
    stateController =
        TextEditingController(text: provider.myProfile?.data?.state ?? "");
    countryController =
        TextEditingController(text: provider.myProfile?.data?.country ?? "");
    zipCodeController = TextEditingController(
        text: provider.myProfile?.data?.zipCode.toString() ?? "");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile'.tr,
           style:  GoogleFonts.spaceGrotesk(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 18
            )
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              provider.myProfile?.data?.avatarUrl != null
                                  ? NetworkImage(
                                      provider.myProfile!.data!.avatarUrl!)
                                  : _profileImage != null
                                      ? FileImage(_profileImage!)
                                          as ImageProvider<Object>
                                      : const NetworkImage(
                                          'https://via.placeholder.com/150'),
                          // Placeholder image
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 15,
                              child: Icon(Icons.edit,
                                  size: 15, color: kPrimaryColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    //  Text(
                    //   'My Profile',
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.w600,
                    //       fontSize: 24,
                    // fontFamily: 'Inter'.tr,
                    //       color: kPrimaryColor),
                    // ),
                    SizedBox(height: 25),

                    Text(
                      'Personal Information'.tr,
                      style: GoogleFonts.spaceGrotesk(
                       color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 18
                      )
                    ),
                    SizedBox(height: 10),
                    buildEditableField(
                      "Username".tr,
                      userNameEdit: false,
                      usernameController,
                      onPress: () async {},
                      false,
                      onEdit: () => setState(() => isEditingUsername = true),
                      onCancel: () => setState(() => isEditingUsername = false),
                    ),
                    Divider(thickness: 1),
                    // Email field is not editable, no Edit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "E-mail".tr,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          )
                        ),
                        // No Edit button for email
                      ],
                    ),
                    Text(
                      emailController.text,
                      style: TextStyle(
                        color: grey,
                        fontFamily: 'Inter'.tr,
                      ),
                    ),
                    Divider(thickness: 1),
                    buildEditableField(
                      "First name".tr,
                      firstNameController,
                      isEditingFirstName,
                      onPress: () async {
                        log("message");
                        setState(() {
                          isLoading = true;
                        });
                        bool check = await provider.updateProfile(
                          address2: address2Controller.value.text,
                          address: address1Controller.value.text,
                          bio: aboutController.value.text,
                          birthday: birthdayController.value.text,
                          city: cityController.value.text,
                          country: countryController.value.text,
                          firstName: firstNameController.value.text,
                          lastName: lastNameController.value.text,
                          phone: phoneNumberController.value.text,
                          state: stateController.value.text,
                          zipCode: zipCodeController.value.text,
                        );

                        setState(() {
                          isLoading = false;
                        });
                        if (check) {
                          Navigator.of(context).pop();
                        }
                      },
                      onEdit: () => setState(() => isEditingFirstName = true),
                      onCancel: () =>
                          setState(() => isEditingFirstName = false),
                    ),
                    Divider(thickness: 1),
                    buildEditableField(
                      "Last name".tr,
                      onPress: () async {
                        log("message");
                        setState(() {
                          isLoading = true;
                        });
                        bool check = await provider.updateProfile(
                          address2: address2Controller.value.text,
                          address: address1Controller.value.text,
                          birthday: birthdayController.value.text,
                          city: cityController.value.text,
                          country: countryController.value.text,
                          bio: aboutController.value.text,
                          firstName: firstNameController.value.text,
                          lastName: lastNameController.value.text,
                          phone: phoneNumberController.value.text,
                          state: stateController.value.text,
                          zipCode: zipCodeController.value.text,
                        );

                        setState(() {
                          isLoading = false;
                        });
                        if (check) {
                          Navigator.of(context).pop();
                        }
                      },
                      lastNameController,
                      isEditingLastName,
                      onEdit: () => setState(() => isEditingLastName = true),
                      onCancel: () => setState(() => isEditingLastName = false),
                    ),
                    Divider(thickness: 1),
                    buildEditableField(
                        "Phone number".tr,
                        phoneNumberController,
                        onPress: () async {
                          log("message");
                          setState(() {
                            isLoading = true;
                          });
                          bool check = await provider.updateProfile(
                            address2: address2Controller.value.text,
                            address: address1Controller.value.text,
                            birthday: birthdayController.value.text,
                            city: cityController.value.text,
                            bio: aboutController.value.text,
                            country: countryController.value.text,
                            firstName: firstNameController.value.text,
                            lastName: lastNameController.value.text,
                            phone: phoneNumberController.value.text,
                            state: stateController.value.text,
                            zipCode: zipCodeController.value.text,
                          );

                          setState(() {
                            isLoading = false;
                          });
                          if (check) {
                            Navigator.of(context).pop();
                          }
                        },
                        isEditingPhoneNumber,
                        onEdit: () =>
                            setState(() => isEditingPhoneNumber = true),
                        onCancel: () =>
                            setState(() => isEditingPhoneNumber = false),
                        keyboardtype: TextInputType.phone),
                    Divider(thickness: 1),
                    buildEditableField(
                      "Birthday".tr,
                      birthdayController,
                      isEditingBirthday,
                      onPress: () async {
                        log("message");
                        setState(() {
                          isLoading = true;
                        });
                        bool check = await provider.updateProfile(
                          address2: address2Controller.value.text,
                          address: address1Controller.value.text,
                          birthday: birthdayController.value.text,
                          city: cityController.value.text,
                          bio: aboutController.value.text,
                          country: countryController.value.text,
                          firstName: firstNameController.value.text,
                          lastName: lastNameController.value.text,
                          phone: phoneNumberController.value.text,
                          state: stateController.value.text,
                          zipCode: zipCodeController.value.text,
                        );

                        setState(() {
                          isLoading = false;
                        });
                        if (check) {
                          Navigator.of(context).pop();
                        }
                      },
                      onEdit: () => setState(() => isEditingBirthday = true),
                      onCancel: () => setState(() => isEditingBirthday = false),
                    ),
                    Divider(thickness: 1),
                    buildEditableField(
                      "About yourself".tr,
                      aboutController,
                      isEditingAboutYourself,
                      onPress: () async {
                        log("message");
                        setState(() {
                          isLoading = true;
                        });
                        bool check = await provider.updateProfile(
                          address2: address2Controller.value.text,
                          address: address1Controller.value.text,
                          birthday: birthdayController.value.text,
                          bio: aboutController.value.text,
                          city: cityController.value.text,
                          country: countryController.value.text,
                          firstName: firstNameController.value.text,
                          lastName: lastNameController.value.text,
                          phone: phoneNumberController.value.text,
                          state: stateController.value.text,
                          zipCode: zipCodeController.value.text,
                        );

                        setState(() {
                          isLoading = false;
                        });
                        if (check) {
                          Navigator.of(context).pop();
                        }
                      },
                      onEdit: () =>
                          setState(() => isEditingAboutYourself = true),
                      onCancel: () =>
                          setState(() => isEditingAboutYourself = false),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Location Information'.tr,
                      style: GoogleFonts.spaceGrotesk(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 18
                      )
                    ),
                    SizedBox(height: 20),
                    buildEditableField(
                      "Address Line 1".tr,
                      address1Controller,
                      onPress: () async {
                        log("message");
                        setState(() {
                          isLoading = true;
                        });
                        bool check = await provider.updateProfile(
                          address2: address2Controller.value.text,
                          address: address1Controller.value.text,
                          birthday: birthdayController.value.text,
                          city: cityController.value.text,
                          country: countryController.value.text,
                          bio: aboutController.value.text,
                          firstName: firstNameController.value.text,
                          lastName: lastNameController.value.text,
                          phone: phoneNumberController.value.text,
                          state: stateController.value.text,
                          zipCode: zipCodeController.value.text,
                        );

                        setState(() {
                          isLoading = false;
                        });
                        if (check) {
                          Navigator.of(context).pop();
                        }
                      },
                      isEditingAddress1,
                      onEdit: () => setState(() => isEditingAddress1 = true),
                      onCancel: () => setState(() => isEditingAddress1 = false),
                    ),
                    Divider(thickness: 1),
                    buildEditableField(
                      "Address Line 2".tr,
                      address2Controller,
                      onPress: () async {
                        log("message");
                        setState(() {
                          isLoading = true;
                        });
                        bool check = await provider.updateProfile(
                          address2: address2Controller.value.text,
                          address: address1Controller.value.text,
                          birthday: birthdayController.value.text,
                          city: cityController.value.text,
                          country: countryController.value.text,
                          firstName: firstNameController.value.text,
                          bio: aboutController.value.text,
                          lastName: lastNameController.value.text,
                          phone: phoneNumberController.value.text,
                          state: stateController.value.text,
                          zipCode: zipCodeController.value.text,
                        );

                        setState(() {
                          isLoading = false;
                        });
                        if (check) {
                          Navigator.of(context).pop();
                        }
                      },
                      isEditingAddress2,
                      onEdit: () => setState(() => isEditingAddress2 = true),
                      onCancel: () => setState(() => isEditingAddress2 = false),
                    ),
                    Divider(thickness: 1),
                    buildEditableField(
                      "City".tr,
                      cityController,
                      onPress: () async {
                        log("message");
                        setState(() {
                          isLoading = true;
                        });
                        bool check = await provider.updateProfile(
                          address2: address2Controller.value.text,
                          address: address1Controller.value.text,
                          birthday: birthdayController.value.text,
                          city: cityController.value.text,
                          country: countryController.value.text,
                          firstName: firstNameController.value.text,
                          lastName: lastNameController.value.text,
                          phone: phoneNumberController.value.text,
                          bio: aboutController.value.text,
                          state: stateController.value.text,
                          zipCode: zipCodeController.value.text,
                        );

                        setState(() {
                          isLoading = false;
                        });
                        if (check) {
                          Navigator.of(context).pop();
                        }
                      },
                      isEditingCity,
                      onEdit: () => setState(() => isEditingCity = true),
                      onCancel: () => setState(() => isEditingCity = false),
                    ),
                    Divider(thickness: 1),
                    buildEditableField(
                      "State".tr,
                      stateController,
                      onPress: () async {
                        log("message");
                        setState(() {
                          isLoading = true;
                        });
                        bool check = await provider.updateProfile(
                          address2: address2Controller.value.text,
                          address: address1Controller.value.text,
                          birthday: birthdayController.value.text,
                          city: cityController.value.text,
                          country: countryController.value.text,
                          firstName: firstNameController.value.text,
                          lastName: lastNameController.value.text,
                          bio: aboutController.value.text,
                          phone: phoneNumberController.value.text,
                          state: stateController.value.text,
                          zipCode: zipCodeController.value.text,
                        );

                        setState(() {
                          isLoading = false;
                        });
                        if (check) {
                          Navigator.of(context).pop();
                        }
                      },
                      isEditingState,
                      onEdit: () => setState(() => isEditingState = true),
                      onCancel: () => setState(() => isEditingState = false),
                    ),
                    Divider(thickness: 1),
                    buildEditableField(
                      "Country".tr,
                      onPress: () async {
                        log("message");
                        setState(() {
                          isLoading = true;
                        });
                        bool check = await provider.updateProfile(
                          address2: address2Controller.value.text,
                          address: address1Controller.value.text,
                          birthday: birthdayController.value.text,
                          city: cityController.value.text,
                          country: countryController.value.text,
                          bio: aboutController.value.text,
                          firstName: firstNameController.value.text,
                          lastName: lastNameController.value.text,
                          phone: phoneNumberController.value.text,
                          state: stateController.value.text,
                          zipCode: zipCodeController.value.text,
                        );

                        setState(() {
                          isLoading = false;
                        });
                        if (check) {
                          Navigator.of(context).pop();
                        }
                      },
                      countryController,
                      isEditingCountry,
                      onEdit: () => setState(() => isEditingCountry = true),
                      onCancel: () => setState(() => isEditingCountry = false),
                    ),
                    Divider(thickness: 1),
                    buildEditableField(
                      "Zip Code".tr,
                      onPress: () async {
                        log("message");
                        setState(() {
                          isLoading = true;
                        });
                        bool check = await provider.updateProfile(
                          address2: address2Controller.value.text,
                          address: address1Controller.value.text,
                          birthday: birthdayController.value.text,
                          city: cityController.value.text,
                          country: countryController.value.text,
                          firstName: firstNameController.value.text,
                          lastName: lastNameController.value.text,
                          phone: phoneNumberController.value.text,
                          state: stateController.value.text,
                          zipCode: zipCodeController.value.text,
                          bio: aboutController.value.text,
                        );

                        setState(() {
                          isLoading = false;
                        });
                        if (check) {
                          Navigator.of(context).pop();
                        }
                      },
                      zipCodeController,
                      isEditingZipCode,
                      onEdit: () => setState(() => isEditingZipCode = true),
                      onCancel: () => setState(() => isEditingZipCode = false),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildEditableField(
    String label,
    TextEditingController controller,
    bool isEditing, {
    VoidCallback? onEdit,
    VoidCallback? onCancel,
    VoidCallback? onPress,
    TextInputType? keyboardtype,
    bool userNameEdit = true,
  }) {
    final provider = Provider.of<AuthProvider>(context, listen: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style:GoogleFonts.spaceGrotesk(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              )
            ),
            if (!isEditing && label != "E-mail")
              if (userNameEdit)
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                        fontFamily: 'Inter'.tr,
                        decoration: TextDecoration.underline,
                        color: kPrimaryColor),
                  ),
                  child: Text(
                    'Edit'.tr,
                    style:
                        TextStyle(fontFamily: 'Inter'.tr, color: kPrimaryColor),
                  ),
                ),
            if (isEditing)
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                      fontFamily: 'Inter'.tr,
                      decoration: TextDecoration.underline,
                      color: kPrimaryColor),
                ),
                child:
                    Text('Cancel'.tr, style: TextStyle(color: kPrimaryColor)),
              ),
          ],
        ),
        if (isEditing)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                keyboardType: keyboardtype ?? TextInputType.name,
                controller: controller,
                inputFormatters: [
                  if (keyboardtype == TextInputType.phone)
                    FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  hintText: label,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: kSecondaryColor, width: 1),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                  onPressed: onPress,
                  child: Text('Save'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor, // Save button color
                    fixedSize: Size(100, 40), // Width and height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                  )),
            ],
          )
        else
          Text(
            controller.text,
            style: TextStyle(fontFamily: 'Inter'.tr, color: grey),
          ),
      ],
    );
  }
}
