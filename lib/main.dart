import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TourBuzzApp());
}

class TourBuzzApp extends StatelessWidget {
  const TourBuzzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TourBuzz BD Seat Booking',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const SeatBookingScreen(),
    );
  }
}

class SeatBookingScreen extends StatefulWidget {
  const SeatBookingScreen({super.key});

  @override
  State<SeatBookingScreen> createState() => _SeatBookingScreenState();
}

class _SeatBookingScreenState extends State<SeatBookingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TourBuzz BD - সিট বুকিং'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('seats').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var seats = snapshot.data!.docs;

          if (seats.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: _initializeSeats,
                child: const Text('বাসের সিট লেআউট লোড করুন'),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: seats.length,
            itemBuilder: (context, index) {
              var seat = seats[index];
              bool isBooked = seat['isBooked'] ?? false;
              String seatName = seat['seatName'] ?? '';

              return GestureDetector(
                onTap: () => _toggleSeatBooking(seat.id, isBooked),
                child: Container(
                  decoration: BoxDecoration(
                    color: isBooked ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      seatName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _initializeSeats() {
    List<String> seatNames = [
      'A1', 'A2', 'A3', 'A4',
      'B1', 'B2', 'B3', 'B4',
      'C1', 'C2', 'C3', 'C4',
      'D1', 'D2', 'D3', 'D4'
    ];

    for (var name in seatNames) {
      _firestore.collection('seats').add({
        'seatName': name,
        'isBooked': false,
      });
    }
  }

  void _toggleSeatBooking(String docId, bool currentStatus) {
    _firestore.collection('seats').doc(docId).update({
      'isBooked': !currentStatus,
    });
  }
}
