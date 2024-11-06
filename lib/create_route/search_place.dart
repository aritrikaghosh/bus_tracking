import 'package:flutter/material.dart';
import 'package:vit_bus_tracking/api_calls.dart';
import 'package:vit_bus_tracking/model/place.dart';
import 'package:vit_bus_tracking/utils/show_snackbar.dart';

class SearchPlace extends StatefulWidget {
  const SearchPlace({super.key});

  @override
  State<SearchPlace> createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace> {
  final _formKey = GlobalKey<FormState>();

  List<Place> listOfPlaces = [];
  String placeName = "";
  bool circularProgressIndicatorFlag = false;

  Widget listPlaces() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...listOfPlaces.map(
            (e) => ListTile(
              title: Text(e.name),
              onTap: () {
                Navigator.of(context).pop(e);
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        alignment: Alignment.center,

        // giving a padding for appearance
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05),

        // column for the actual data
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                key: _formKey,

                enabled: !circularProgressIndicatorFlag,

                // giving the cursor the color
                cursorColor: Theme.of(context).colorScheme.primary,

                // setting the auto focus as true
                autofocus: true,

                // giving the underline color
                decoration: InputDecoration(
                  // hint text to add the city name
                  hintText: "Place Name",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  // giving a suffix icon to search the data and easing our work
                  suffixIcon: IconButton(
                    // giving a search icon
                    icon: Icon(
                      Icons.search_sharp,
                      color: Theme.of(context).colorScheme.primary,
                    ),

                    disabledColor: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.8),
                    onPressed: circularProgressIndicatorFlag
                        ? null
                        : () async {
                            if (placeName.trim().isEmpty) {
                              ShowSnackBar().showSnackBar(
                                message: "Please Enter Place Name",
                                context: context,
                              );
                            } else if (placeName.trim().length <= 4) {
                              ShowSnackBar().showSnackBar(
                                message: "Please give a longer name",
                                context: context,
                              );
                            } else {
                              setState(
                                () {
                                  circularProgressIndicatorFlag = true;
                                },
                              );

                              FocusManager.instance.primaryFocus?.unfocus();

                              listOfPlaces = await ApiCalls().getCitiesName(
                                placeName: placeName.trim(),
                              );

                              setState(
                                () {
                                  circularProgressIndicatorFlag = false;
                                },
                              );
                            }
                          },
                  ),
                ),
                onChanged: ((value) {
                  placeName = value;
                }),
              ),
              const SizedBox(height: 10),
              Container(
                child: circularProgressIndicatorFlag
                    ? const CircularProgressIndicator.adaptive()
                    : listPlaces(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
