import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/BloodProvider.dart';
import '../home/RequestBloodForm.dart';
import '../../utils/Config.dart';
import '../../utils/Constants.dart';
import 'DonorProfileScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchDonorScreen extends StatefulWidget {
  final String bloodGroup;
  const SearchDonorScreen({super.key, required this.bloodGroup});

  @override
  State<SearchDonorScreen> createState() => _SearchDonorScreenState();
}

class _SearchDonorScreenState extends State<SearchDonorScreen> {
  final _searchController = TextEditingController();
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Fetch latest cities when search screen opens so newly added cities appear
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BloodProvider>(context, listen: false).fetchCitiesAndBloodGroups();
    });
  }

  void _onSearch(String city) {
    if (city.trim().isEmpty) return;
    setState(() => _hasSearched = true);
    Provider.of<BloodProvider>(context, listen: false).fetchDonors(
      bloodGroup: widget.bloodGroup,
      city: city.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blood = Provider.of<BloodProvider>(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Search ${widget.bloodGroup} Donors', 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                final citiesList = blood.cities;
                if (textEditingValue.text.isEmpty) {
                  return citiesList;
                }
                return citiesList.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _searchController.text = selection;
                _onSearch(selection);
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Enter City (e.g. Bahawalpur)',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.red),
                      onPressed: () => _onSearch(controller.text),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onSubmitted: _onSearch,
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 6.0,
                    shadowColor: Colors.black.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        border: Border.all(color: Colors.grey.withOpacity(0.15)),
                      ),
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return ListTile(
                            leading: const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
                            title: Text(
                              option,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            dense: true,
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: !_hasSearched
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_rounded, size: 100, color: Colors.grey[200]),
                        const SizedBox(height: 16),
                        const Text('Search donors by city', 
                            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                : blood.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.red))
                    : blood.donors.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, size: 60, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text('No ${widget.bloodGroup} donors found in this city.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: blood.donors.length,
                            itemBuilder: (context, index) {
                              final donor = blood.donors[index];
                              String? imageUrl = donor.fullImageUrl;

                              final hasPending = donor.hasPendingRequest;
                              final isUnavailable = !donor.available;
                              final isDisabled = hasPending || isUnavailable;
                              
                              String buttonText = 'Details';
                              if (hasPending) buttonText = 'Pending';
                              else if (isUnavailable) buttonText = 'Off';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                                child: Opacity(
                                  opacity: isDisabled ? 0.6 : 1.0,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                                        image: imageUrl != null
                                            ? DecorationImage(
                                                image: CachedNetworkImageProvider(imageUrl), 
                                                fit: BoxFit.cover,
                                                colorFilter: isDisabled 
                                                    ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                                                    : null,
                                              )
                                            : null,
                                      ),
                                      child: imageUrl == null 
                                          ? const Icon(Icons.person, color: Colors.grey) 
                                          : null,
                                    ),
                                    title: Text(donor.fullName ?? 'Donor', 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(donor.city ?? 'N/A', style: const TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: ElevatedButton(
                                      onPressed: isDisabled ? null : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DonorProfileScreen(donor: donor, bloodGroup: widget.bloodGroup),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDisabled ? Colors.grey[200] : Colors.white,
                                        foregroundColor: isDisabled ? Colors.grey : Colors.red,
                                        side: BorderSide(color: isDisabled ? Colors.transparent : Colors.red),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: Text(buttonText),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
