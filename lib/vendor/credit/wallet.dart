import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/data_models/all_space_item_screen.dart';
import 'package:moonbnd/vendor/credit/buycredit.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatefulWidget {
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool loading = true;
  bool loading1 = true;
  bool loading2 = true;

  @override
  void initState() {
    super.initState();
    fetchwalletdata();
  }

  Future<void> fetchwalletdata() async {
    setState(() {
      loading = true;
    });
    try {
      final provider = Provider.of<VendorAuthProvider>(context, listen: false);
      await provider.alltransactionvendor();
      await provider.Creditbalances();
      await provider.Pendingcredit();
    } catch (e) {
      print("error $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  String formatDateTime(String? dateString) {
    if (dateString == null) return 'Invalid Date';

    // Parse the input date string
    DateTime parsedDate = DateTime.parse(dateString);

    // Convert to UTC (if needed)
    DateTime times = DateTime.utc(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      parsedDate.hour,
      parsedDate.minute,
      parsedDate.second,
    );

    // Format the date and time
    String formattedDate =
        "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    String formattedTime =
        "${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}";

    // Calculate the time difference
    Duration difference = DateTime.now().difference(times);
    int days = difference.inDays;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;

    // Build the "time ago" string
    StringBuffer result = StringBuffer();

    if (days > 0) result.write('$days day${days > 1 ? 's' : ''} ');
    if (hours > 0) result.write('$hours hour${hours > 1 ? 's' : ''} ');
    if (minutes > 0) result.write('$minutes minute${minutes > 1 ? 's' : ''} ');

    result.write(' ago');

    // Combine the formatted date and time with the "time ago" result
    return "$formattedDate $formattedTime ";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorAuthProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.black,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Wallet',style: GoogleFonts.spaceGrotesk(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18
        ),
        ),
        centerTitle: true,
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(color: kSecondaryColor),
            )
          : RefreshIndicator(
              onRefresh: fetchwalletdata,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(
                        height: 32,
                      ),
                      // Credit Balance and Pending Credit
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildBalanceCard(
                                'CREDIT BALANCE'.tr,
                                provider.creditbalances?.data?.creditBalance ??
                                    "0"),
                            SizedBox(
                              height: 10,
                            ),
                            _buildBalanceCard(
                                'PENDING CREDIT'.tr,
                                provider.pendingcredit?.totalPendingAmount
                                        .toString() ??
                                    "0"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Latest Transactions Header
                      Text(
                        'Latest Transactions'.tr,
                        style: GoogleFonts.spaceGrotesk(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 18
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Transactions List

                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: provider.alltrasaction?.data
                            ?.length, // Change this to your list length
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5.0), // Reduced margin
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                padding: const EdgeInsets.all(
                                    3.0), // Slightly increased padding for better spacing
                                child: GridView.count(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.5,
                                  crossAxisSpacing:
                                      4.0, // Reduced horizontal spacing
                                  mainAxisSpacing:
                                      2.0, // Reduced vertical spacing
                                  children: [
                                    _buildTransactionGridItem(
                                        'Type'.tr,
                                        provider.alltrasaction?.data?[index]
                                                .type ??
                                            ""),
                                    _buildTransactionGridItem(
                                        'Amount'.tr,
                                        provider.alltrasaction?.data?[index]
                                                .amount ??
                                            ""),
                                    _buildTransactionGridItem(
                                        'Gateway'.tr,
                                        provider.alltrasaction?.data?[index]
                                                .payment?.paymentGateway ??
                                            ""),
                                    _buildTransactionGridItem(
                                        'Date'.tr,
                                        formatDateTime(provider.alltrasaction
                                                ?.data?[index].createdAt ??
                                            "")),
                                    _buildTransactionGridItem(
                                        'Description'.tr, ""),
                                    _buildTransactionGridItem(
                                        'Status'.tr,
                                        provider.alltrasaction?.data?[index]
                                                    .status ==
                                                null
                                            ? "pending".tr
                                            : provider.alltrasaction
                                                    ?.data?[index].status ??
                                                "",
                                        isStatus: true),
                                  ],
                                ),
                              ));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        child: TertiaryButton(
          text: "+ Buy Credit".tr,
          press: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BuyCreditsScreen(),
              ),
            );
          },
        ),
      ),
      ),
    );
  }

  // Balance Card Widget
  Widget _buildBalanceCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 18
            )
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontFamily: "intern",
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

// ... existing code ...
  // Widget _buildTransactionCard2() {
  //   return
  // }

  Widget _buildTransactionGridItem(String label, String value,
      {bool isStatus = false}) {
    return Container(
      padding: const EdgeInsets.all(10), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Make column size minimum
        children: [
          Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 14,
                fontFamily: "intern"),
          ),
          const SizedBox(height: 3), // Slight space for better readability
          isStatus
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2), // Reduced padding
                  decoration: BoxDecoration(
                    color: kSecondaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      fontFamily: "intern"), // Reduced font size for value text
                ),
        ],
      ),
    );
  }

  // Grid Item Widget
  Widget _buildTransactionCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransactionRow('Type', 'Deposit'),
            _buildTransactionRow('Amount', '1150'),
            _buildTransactionRow('Gateway', 'Offline Payment'),
            _buildTransactionRow('Date', '10/12/2024, 09:22'),
            _buildTransactionRow('Description', 'Lorem Ipsum'),
            const SizedBox(height: 8), // Add space between rows and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: kSecondaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Completed'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// ... existing code ...
  Widget _buildTransactionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          Text(value),
        ],
      ),
    );
  }
}
