import 'package:flutter/material.dart';
import 'package:sugenix/models/doctor.dart';

class DoctorDetailsScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0C4556)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Color(0xFF0C4556)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDoctorProfile(),
            _buildStatistics(),
            _buildServiceInfo(),
            _buildBookNowButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorProfile() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF0C4556),
            child: Text(
              doctor.name.split(' ').map((e) => e[0]).join(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            doctor.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C4556),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            doctor.specialization,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 5),
              Text(
                doctor.rating.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            "${doctor.totalBookings} Booking",
            Icons.calendar_today,
          ),
          _buildStatItem("${doctor.totalPatients} Patient", Icons.people),
          _buildStatItem("${doctor.likes} Likes", Icons.favorite),
        ],
      ),
    );
  }

  Widget _buildStatItem(String text, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0C4556), size: 30),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Service Info",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C4556),
            ),
          ),
          const SizedBox(height: 15),
          _buildServiceItem("• Comprehensive diabetes management"),
          _buildServiceItem("• Blood sugar monitoring guidance"),
          _buildServiceItem("• Personalized diet plans"),
          _buildServiceItem("• Medication management"),
          _buildServiceItem("• Emergency consultation"),
          _buildServiceItem("• Follow-up care"),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildBookNowButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentBookingScreen(doctor: doctor),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C4556),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Book Now",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class AppointmentBookingScreen extends StatefulWidget {
  final Doctor doctor;

  const AppointmentBookingScreen({super.key, required this.doctor});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  String _selectedDate = "Today, 25 Feb";
  String _selectedTime = "3:00 PM";
  final _patientNameController = TextEditingController();
  final _mobileController = TextEditingController();
  String _selectedPatient = "My Self";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0C4556)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Recent Time",
          style: TextStyle(
            color: Color(0xFF0C4556),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Color(0xFF0C4556)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDoctorCard(),
            const SizedBox(height: 20),
            _buildDateSelector(),
            const SizedBox(height: 20),
            _buildTimeSlots(),
            const SizedBox(height: 20),
            _buildAppointmentFor(),
            const SizedBox(height: 20),
            _buildPatientSelection(),
            const SizedBox(height: 30),
            _buildNextButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF0C4556),
            child: Text(
              widget.doctor.name.split(' ').map((e) => e[0]).join(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.doctor.specialization,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.doctor.rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final dates = ["Yesterday, 24 Feb", "Today, 25 Feb", "Tomorrow, 26 Feb"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Date",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0C4556),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: dates.map((date) {
            final isSelected = date == _selectedDate;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0C4556)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    date,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Available Time",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0C4556),
          ),
        ),
        const SizedBox(height: 15),
        _buildTimeSlotSection("Afternoon Slots", [
          "12:00 PM",
          "12:30 PM",
          "1:00 PM",
          "1:30 PM",
          "2:00 PM",
          "2:30 PM",
          "3:00 PM",
          "3:30 PM",
          "4:00 PM",
          "4:30 PM",
          "5:00 PM",
        ]),
        const SizedBox(height: 20),
        _buildTimeSlotSection("Evening Slots", [
          "6:00 PM",
          "6:30 PM",
          "7:00 PM",
          "7:30 PM",
          "8:00 PM",
          "8:30 PM",
          "9:00 PM",
        ]),
      ],
    );
  }

  Widget _buildTimeSlotSection(String title, List<String> times) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: times.map((time) {
            final isSelected = time == _selectedTime;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTime = time;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0C4556)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAppointmentFor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Appointment For",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0C4556),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _patientNameController,
          decoration: InputDecoration(
            hintText: "Patient Name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _mobileController,
          decoration: InputDecoration(
            hintText: "Mobile Number",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Who is this patient?",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0C4556),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildPatientOption("My Self", "My Self"),
            const SizedBox(width: 15),
            _buildPatientOption("My Child", "My Child"),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () {
                // Handle add new patient
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0C4556)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "+ Add",
                  style: TextStyle(
                    color: Color(0xFF0C4556),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientOption(String text, String value) {
    final isSelected = _selectedPatient == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPatient = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0C4556) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          _showConfirmationDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C4556),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Next",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            const Text(
              "Thank You! Your Appointment Successful!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C4556),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              "Your appointment with ${widget.doctor.name} is on ${_selectedDate} at $_selectedTime",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C4556),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
