import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HouseCard extends ConsumerStatefulWidget {
  const HouseCard({required this.house, super.key});
  final Map<String, dynamic> house;

  @override
  ConsumerState<HouseCard> createState() => _StateHouseCard();
}

class _StateHouseCard extends ConsumerState<HouseCard> {
  bool isBooking = false;
  String? selectedPayment;

  Future<void> bookHouse() async {
    setState(() => isBooking = true);

    String? landlordId = widget.house["landlordId"] as String?;
    String? houseId = widget.house["id"] as String?;

    print("House Data: ${widget.house}");



    // Check for null values
    if (landlordId == null || houseId == null) {
      print("Error: LandlordId or HouseId is null");
      setState(() => isBooking = false);
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("Landlords")
          .doc(landlordId)
          .collection("Houses")
          .doc(houseId)
          .update({"isBooked": true});

      setState(() {
        widget.house["isBooked"] = true;
      });

      _showPaymentOptions();
    } catch (e) {
      print("Error booking house: $e");
    }

    setState(() => isBooking = false);
  }




  Future<void> cancelBooking() async {
    setState(() => isBooking = true);

    String landlordId = widget.house["LandlordId"];
    String houseId = widget.house["HouseId"];

    try {
      await FirebaseFirestore.instance
          .collection("Landlords")
          .doc(landlordId)
          .collection("Houses")
          .doc(houseId)
          .update({"isBooked": false});

      setState(() {
        widget.house["isBooked"] = false;
      });
    } catch (e) {
      print("Error cancelling booking: $e");
    }

    setState(() => isBooking = false);
  }

  void _showPaymentOptions() {
    double housePrice = widget.house["House Price"] ?? 0.0;
    double monthlyPayment = housePrice;
    double semesterPayment = housePrice * 4;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Payment Option"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Pay for the first month - Ksh $monthlyPayment"),
              leading: Radio<String>(
                value: "first_month",
                groupValue: selectedPayment,
                onChanged: (value) {
                  setState(() => selectedPayment = value);
                  Navigator.pop(context);
                  print("You selected: Pay for the first month");
                },
              ),
            ),
            ListTile(
              title: Text("Pay per semester - Ksh $semesterPayment"),
              leading: Radio<String>(
                value: "semester",
                groupValue: selectedPayment,
                onChanged: (value) {
                  setState(() => selectedPayment = value);
                  Navigator.pop(context);
                  print("You selected: Pay per semester");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => bookHouse(),
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width > 600
                ? 600
                : MediaQuery.of(context).size.width * 0.9,
          ),
          child: Card(
            elevation: 4,
            margin: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.house.containsKey("Images") && widget.house["Images"] is List)
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        itemCount: widget.house["Images"].length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.house["Images"][index],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),




                  SizedBox(height: 8),
                  Text("🏠 ${"House Name "+widget.house["House Name"]}\t\t-\t\t Ksh  ${widget.house["House Price"]}  per month",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("📍 ${widget.house["Location"]}"),
                  Text("📏 ${widget.house["House Size"]}"),
                  Text("📝 ${widget.house["Description"]}"),
                  if (widget.house.containsKey("Available Amenities"))
                    Text("🔹 Amenities: ${widget.house["Available Amenities"]?.join(", ") ?? "N/A"}"),
                  SizedBox(height: 10),
                  if (widget.house["isBooked"] == true)
                    ElevatedButton(
                      onPressed: cancelBooking,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("Booking"),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
