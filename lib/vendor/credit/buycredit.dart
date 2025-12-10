import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';
import 'package:provider/provider.dart';

class BuyCreditsScreen extends StatefulWidget {
  @override
  State<BuyCreditsScreen> createState() => _BuyCreditsScreenState();
}

class _BuyCreditsScreenState extends State<BuyCreditsScreen> {
  int? selectedOption = 0;
  bool isOfflinePayment = false;
  bool acceptTerms = false;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    Provider.of<VendorAuthProvider>(context, listen: false)
        .fetchbuycredit()
        .then((value) {
      loading = false;
    });
  }

  final List<Map<String, String>> creditOptions = [
    {'title': '\$100', 'price': 'Price: \$100', 'credit': 'Credit: 100'},
    {'title': 'Bonus 10%', 'price': 'Price: \$500', 'credit': 'Credit: 550'},
    {'title': 'Bonus 15%', 'price': 'Price: \$1000', 'credit': 'Credit: 1150'},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorAuthProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(color: kSecondaryColor),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Buy Credits'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: "inter",
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Credit Options
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.buycredit?.data?.length,
                      itemBuilder: (context, index) {
                        return _buildCreditOption(
                            index,
                            provider.buycredit?.data?[index].name ?? "",
                            provider.buycredit?.data?[index].amount
                                    .toString() ??
                                "",
                            provider.buycredit?.data?[index].credit
                                    .toString() ??
                                "");
                      },
                    ),
                  ),
                  // Select Payment Method
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Select Payment Method'.tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 22),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isOfflinePayment = !isOfflinePayment;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isOfflinePayment
                                            ? kSecondaryColor
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Offline Payment'.tr,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Terms and Conditions
                          Align(
                            alignment: Alignment.topLeft,
                            child: CheckboxListTile(
                              value: acceptTerms,
                              onChanged: (value) {
                                setState(() {
                                  acceptTerms = value!;
                                });
                              },
                              title: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'I have read and accept the'.tr,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Terms & Conditions'.tr,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        child: ElevatedButton(
          onPressed: () {
            provider.postpaymentmethod(
                depositoption: selectedOption.toString(),
                paymentgateway:
                    isOfflinePayment == true ? "offline_payment" : "",
                termconditions: acceptTerms == true ? "on" : "");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kSecondaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Process Now'.tr,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildCreditOption(
      int index, String title, String price, String credit) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: RadioListTile<int>(
          value: index,
          groupValue: selectedOption,
          onChanged: (value) {
            setState(() {
              selectedOption = value!;
            });
          },
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'inter',
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "${'Price :'.tr} \$${price}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'inter',
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${'Credit :'.tr} ${credit}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
