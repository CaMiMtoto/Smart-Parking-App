import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:parking_system/screens/payment_webView.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';

class ActiveParkingList extends StatefulWidget {
  const ActiveParkingList({super.key});

  @override
  State<ActiveParkingList> createState() => _ActiveParkingListState();
}

class _ActiveParkingListState extends State<ActiveParkingList> {
  List<dynamic> cars = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  String searchQuery = '';
  String? fromDate;
  String? toDate;
  int total = 0;

  final ScrollController _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    fetchCars(reset: true);
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showBackToTopButton) {
        setState(() {
          _showBackToTopButton = true;
        });
      } else if (_scrollController.offset <= 300 && _showBackToTopButton) {
        setState(() {
          _showBackToTopButton = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Call this after new data is loaded (like inside fetchCars)
  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> fetchCars({bool reset = false}) async {
    if (reset) {
      setState(() {
        currentPage = 1;
        cars.clear();
        hasMore = true;
        total = 0;
      });
    }

    setState(() => isLoading = true);

    final uri = Uri.parse('$baseUrl/parking/active').replace(
      queryParameters: {
        'page': '$currentPage',
        'search': searchQuery,
        if (fromDate != null) 'from': fromDate!,
        if (toDate != null) 'to': toDate!,
      },
    );
    var token = Provider.of<AuthProvider>(context, listen: false).token;
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'Application/json'},
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newItems = data['data'];

      setState(() {
        if (reset) {
          cars = newItems;
        } else {
          cars.addAll(newItems);
        }
        total = data['total'] ?? cars.length;
        currentPage++;
        hasMore = data['next_page_url'] != null;
        isLoading = false;
      });

      // If it's loading more (not resetting), scroll to bottom
      if (!reset) {
        scrollToBottom();
      }
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Failed to load cars')));
    }
  }

  Future<void> pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        fromDate = DateFormat('yyyy-MM-dd').format(picked.start);
        toDate = DateFormat('yyyy-MM-dd').format(picked.end);
      });
      fetchCars(reset: true);
    }
  }

  Widget buildCarTile(dynamic car) {
    final bool overstayed = car['overstayed'] ?? false;
    final int duration = car['duration_hours'] ?? 0;
    final String plate = car['plate_number'];
    final String entryTime = DateFormat(
      'dd MMM yyyy – hh:mm a',
    ).format(DateTime.parse(car['entry_time']));
    final int estimatedAmount = car['estimated_amount'];

    return Builder(
      // Needed to access context inside this widget
      builder: (context) {
        return Stack(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0.2,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Icon + Plate + Exit Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon(
                        //   FontAwesomeIcons.car,
                        //   color: overstayed ? Colors.red : Colors.blue,
                        //   size: 26,
                        // ),
                        // const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            plate,
                            style: TextStyle(
                              // fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  overstayed ? Colors.red[700] : null,
                            ),
                          ),
                        ),
                        MaterialButton(
                          onPressed: () {
                            showCheckoutModal(context, car);
                          },
                          color: Colors.red.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          elevation: 0,
                          child: Row(
                            children: [
                              const Text(
                                'Exit',
                                style: TextStyle(color: Colors.red),
                              ),
                              const SizedBox(width: 4),
                              // Icon(Icons.exit_to_app, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Text(
                      'Entry Time: $entryTime',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Duration: $duration hour${duration == 1 ? '' : 's'}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Est. Amount: ${Globals.numberFormat(estimatedAmount)} RWF',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  bool checkingOut = false;

  Future<void> checkOutCar(
    int carId,
    String selectedPayment, [
    String? phoneNumber,
  ]) async {
    var token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      var body = {
        'payment_method': selectedPayment,
        if (selectedPayment == 'momo') 'phone_number': phoneNumber,
      };
      print(body);
      setState(() {
        checkingOut = true;
      });
      final response = await http.post(
        Uri.parse('$baseUrl/parking/checkout/$carId'),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      var decodedData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final data = decodedData;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('✅ ${data['message']}')));
        Navigator.pop(context);
        // Refresh the list
        fetchCars(reset: true);
      } else if (response.statusCode == 302) {
        final redirectUrl = decodedData['redirect_url'];
        final data = decodedData['data'];
        print('Redirect to: $redirectUrl');
        Navigator.pop(context);
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebView(paymentUrl: redirectUrl,id:data['id']),
          ),
        );
        fetchCars(reset: true);
      } else {
        final error = decodedData;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ${error['message'] ?? 'Payment failed'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        checkingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          _showBackToTopButton
              ? FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                child: Icon(Icons.arrow_upward),
              )
              : null,
      body: RefreshIndicator(
        onRefresh: () => fetchCars(reset: true),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by plate number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          searchQuery = _searchController.text;
                        });
                        fetchCars(reset: true);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Total Cars: $total'),
                const SizedBox(height: 12),
              ],
            ),
            if (cars.isNotEmpty) ...cars.map((car) => buildCarTile(car)),
            if (isLoading)
              Center(child: CupertinoActivityIndicator())
            else if (hasMore)
              Center(
                child: ElevatedButton(
                  onPressed: fetchCars,
                  child: Text('Load More'),
                ),
              )
            else if (cars.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text("No cars found"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void showCheckoutModal(BuildContext context, dynamic car) {
    final formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController();
    String selectedPayment = 'cash';
    final int estimatedAmount = car['estimated_amount'];
    final String plate = car['plate_number'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check Out',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Please confirm your action"),
                    const SizedBox(height: 20),

                    // Amount field (disabled)
                    TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Plate Number',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        // fillColor: Colors.grey[200],
                      ),
                      initialValue: plate,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Amount to Pay (RWF)',
                        border: const OutlineInputBorder(),
                        filled: true,
                        // fillColor: Colors.grey[200],
                      ),
                      initialValue: Globals.numberFormat(estimatedAmount),
                    ),
                    const SizedBox(height: 20),

                    // Payment Method
                    Row(
                      children: [
                        Radio<String>(
                          value: 'cash',
                          groupValue: selectedPayment,
                          onChanged:
                              (val) =>
                                  setModalState(() => selectedPayment = val!),
                        ),
                        const Text('Cash'),
                        const SizedBox(width: 20),
                        Radio<String>(
                          value: 'momo',
                          groupValue: selectedPayment,
                          onChanged:
                              (val) =>
                                  setModalState(() => selectedPayment = val!),
                        ),
                        const Text('MoMo'),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // MoMo phone number input
                    if (selectedPayment == 'momo')
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'MoMo Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number required';
                          } else if (!RegExp(
                            r'^(07[2-8]\d{7})$',
                          ).hasMatch(value.trim())) {
                            return 'Invalid MTN number';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        checkingOut
                            ? const CupertinoActivityIndicator()
                            : ElevatedButton(
                              onPressed: () {
                                if (selectedPayment == 'momo' &&
                                    !formKey.currentState!.validate()) {
                                  return;
                                }

                                checkOutCar(
                                  car['id'],
                                  selectedPayment,
                                  phoneController.text.trim(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              child: const Text('Confirm'),
                            ),
                        SizedBox(width: 20),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
