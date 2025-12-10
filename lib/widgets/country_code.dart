import 'package:country_picker/country_picker.dart';

import 'package:flutter/material.dart';

void countryCodeBottomSheet(
    Function callBack, bool showPhoneCode, BuildContext context) {
  return showCountryPicker(
    context: context,
    showPhoneCode: showPhoneCode,
    // countryFilter: countryFilters,
    countryListTheme: CountryListThemeData(
      flagSize: 25,
      backgroundColor: Colors.white,
      textStyle: const TextStyle(
        fontSize: 16,
      ),
      // bottomSheetHeight: Constants.navigatorKey.currentContext!.height / 1.6,
      // Optional. Country list modal height
      //Optional. Sets the border radius for the bottomsheet.
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),

      //Optional. Styles the search field.
      inputDecoration: InputDecoration(
        hintText: 'Search here',
        // hintStyle: Constants
        //     .navigatorKey.currentContext!.textTheme.labelLarge!
        //     .copyWith(
        //   color: AppTheme.greyColorLight2,
        // ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        // border: defaultBorderTextField(),
        // focusedBorder: defaultBorderTextField(),
        // errorBorder: defaultBorderTextField(),
        // enabledBorder: defaultBorderTextField()
      ),
    ),
    onSelect: (country) => callBack(country),
  );
}
