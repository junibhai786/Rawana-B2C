import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddCouponScreen extends StatelessWidget {
  const AddCouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Coupon'.tr),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('General'.tr,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Coupon Code*'.tr,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
              SizedBox(
                height: 4,
              ),
              _buildTextField('Unique Code'.tr),
              SizedBox(height: 16),
              Text('Coupon Name*'.tr,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
              SizedBox(
                height: 4,
              ),
              _buildTextField('Name'.tr),
              SizedBox(height: 16),
              Text('Coupon Amount*'.tr,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
              SizedBox(height: 4),
              _buildTextField('0', isNumeric: true),
              SizedBox(height: 16),
              Text('Discount Type'.tr,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
              SizedBox(
                height: 4,
              ),
              _buildDropdown('Discount Type', ['Amount', 'Percentage']),
              SizedBox(height: 16),
              Text('End Date',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
              SizedBox(
                height: 4,
              ),
              _buildTextField('2023-12-12 00:00:00', isDate: true),
              SizedBox(height: 20),
              Text('Usage Restriction'.tr,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Minimum Speed'.tr,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
              SizedBox(height: 4),
              _buildTextField('No Minimum'.tr, isNumeric: true),
              Text('The Minimum Spend does not include any Booking fee'.tr,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(137, 129, 141, 1))),
              SizedBox(height: 16),
              Text('Maximum Speed'.tr,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
              SizedBox(height: 4),
              _buildTextField('No Maximum'.tr, isNumeric: true),
              Text('The Maximum Spend does not include any Booking fee'.tr,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(137, 129, 141, 1))),
              SizedBox(height: 16),
              Text('Only for services'.tr,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
              SizedBox(height: 4),
              _buildDropdown('Select Services'.tr,
                  ['Select Services', 'Service 1', 'Service 2']),
              SizedBox(height: 20),
              Text('Usage Limits'.tr,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Usage Limit per Coupon'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  )),
              SizedBox(
                height: 4,
              ),
              _buildTextField('Unlimited Usage'.tr),
              SizedBox(height: 16),
              Text('Usage Limit per User'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  )),
              SizedBox(
                height: 4,
              ),
              _buildTextField('Unlimited Usage'.tr),
              SizedBox(
                height: 16,
              ),
              Text(
                'Featured Image'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              SizedBox(
                width: 200,
                child: TextIconButtom(
                  press: () {},
                  icon: Icon(
                    Icons.upload,
                    color: Colors.white,
                  ),
                  text: "Upload Image".tr,
                ),
              ),
              SizedBox(height: 20),
              Text('Publish'.tr,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildRadioButton('Publish', 'Draft'),
              SizedBox(height: 20),
              Text('Featured Image'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w400,
                  )),
              SizedBox(
                height: 8,
              ),
              SizedBox(
                width: 200,
                child: TextIconButtom(
                  press: () {},
                  icon: Icon(
                    Icons.upload,
                    color: Colors.white,
                  ),
                  text: "Upload Image".tr,
                ),
              ),
              // 1:54
              SizedBox(
                height: 20,
              ),
              TertiaryButton(
                press: () {},
                text: 'Save & Next'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint,
      {bool isNumeric = false, bool isDate = false}) {
    return TextField(
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (value) {},
    );
  }

  Widget _buildRadioButton(String option1, String option2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Radio(value: option1, groupValue: 'Publish', onChanged: (value) {}),
            Text(option1),
          ],
        ),
        Row(
          children: [
            Radio(value: option2, groupValue: 'Publish', onChanged: (value) {}),
            Text(option2),
          ],
        ),
      ],
    );
  }
}
