import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

void main() {
  runApp(MaterialApp(
    home: EventManagementApp(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.red,
      scaffoldBackgroundColor: Colors.red[50],
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 219, 207, 206),
          textStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        bodyLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
    ),
  ));
}

// Event Model
class Event {
  String title;
  String description;
  String date;
  String location;
  int capacity;
  int ticketsSold;
  double ticketPrice;
  List<Attendee> attendees = [];

  Event({
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.capacity,
    required this.ticketPrice,
    this.ticketsSold = 0,
  });

  int get remainingTickets => capacity - ticketsSold;
  double get revenue => ticketsSold * ticketPrice;
}

// Attendee Model
class Attendee {
  String name;
  int age;
  String gender;
  String email;
  String phone;

  Attendee({
    required this.name,
    required this.age,
    required this.gender,
    required this.email,
    required this.phone,
  });
}

// Main App
class EventManagementApp extends StatefulWidget {
  @override
  _EventManagementAppState createState() => _EventManagementAppState();
}

class _EventManagementAppState extends State<EventManagementApp> {
  final List<Event> _events = [];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _searchController = TextEditingController();

  // Filtered events
  List<Event> get _filteredEvents {
    if (_searchController.text.isEmpty) return _events;
    return _events
        .where((e) =>
            e.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            e.date.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
  }

  // Add Event
  void _addEvent() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _capacityController.text.isEmpty ||
        _priceController.text.isEmpty) return;

    setState(() {
      _events.add(Event(
        title: _titleController.text,
        description: _descriptionController.text,
        date: _dateController.text,
        location: _locationController.text,
        capacity: int.parse(_capacityController.text),
        ticketPrice: double.parse(_priceController.text),
      ));
    });

    _titleController.clear();
    _descriptionController.clear();
    _dateController.clear();
    _locationController.clear();
    _capacityController.clear();
    _priceController.clear();
  }

  // Update Event
  void _updateEvent(int index) {
    final event = _events[index];
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _dateController.text = event.date;
    _locationController.text = event.location;
    _capacityController.text = event.capacity.toString();
    _priceController.text = event.ticketPrice.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Event", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _titleController, decoration: InputDecoration(labelText: "Event Title", filled: true, fillColor: Colors.white.withOpacity(0.8))),
              TextField(controller: _descriptionController, decoration: InputDecoration(labelText: "Description", filled: true, fillColor: Colors.white.withOpacity(0.8))),
              TextField(controller: _dateController, decoration: InputDecoration(labelText: "Date", filled: true, fillColor: Colors.white.withOpacity(0.8))),
              TextField(controller: _locationController, decoration: InputDecoration(labelText: "Location", filled: true, fillColor: Colors.white.withOpacity(0.8))),
              TextField(controller: _capacityController, decoration: InputDecoration(labelText: "Total Tickets", filled: true, fillColor: Colors.white.withOpacity(0.8)), keyboardType: TextInputType.number),
              TextField(controller: _priceController, decoration: InputDecoration(labelText: "Ticket Price", filled: true, fillColor: Colors.white.withOpacity(0.8)), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                event.title = _titleController.text;
                event.description = _descriptionController.text;
                event.date = _dateController.text;
                event.location = _locationController.text;
                event.capacity = int.parse(_capacityController.text);
                event.ticketPrice = double.parse(_priceController.text);
              });
              _titleController.clear();
              _descriptionController.clear();
              _dateController.clear();
              _locationController.clear();
              _capacityController.clear();
              _priceController.clear();
              Navigator.pop(context);
            },
            child: Text("Update", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Delete Event
  void _deleteEvent(int index) {
    setState(() {
      _events.removeAt(index);
    });
  }

  // Register Attendee
  void _registerAttendee(Event event) {
    if (event.remainingTickets <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No remaining tickets for this event!", style: TextStyle(fontWeight: FontWeight.bold))),
      );
      return;
    }

    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final genderController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Register Attendee", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Name", filled: true, fillColor: Colors.white.withOpacity(0.8))),
              TextField(controller: ageController, decoration: InputDecoration(labelText: "Age", filled: true, fillColor: Colors.white.withOpacity(0.8)), keyboardType: TextInputType.number),
              TextField(controller: genderController, decoration: InputDecoration(labelText: "Gender", filled: true, fillColor: Colors.white.withOpacity(0.8))),
              TextField(controller: emailController, decoration: InputDecoration(labelText: "Email", filled: true, fillColor: Colors.white.withOpacity(0.8))),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone Number", filled: true, fillColor: Colors.white.withOpacity(0.8)), keyboardType: TextInputType.phone),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  ageController.text.isEmpty ||
                  genderController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  phoneController.text.isEmpty) return;

              setState(() {
                event.attendees.add(Attendee(
                  name: nameController.text,
                  age: int.parse(ageController.text),
                  gender: genderController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                ));
                event.ticketsSold++;
              });
              Navigator.pop(context);
            },
            child: Text("Register", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // View Attendees
  void _viewAttendees(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${event.title} Attendees", style: TextStyle(fontWeight: FontWeight.bold)),
        content: event.attendees.isEmpty
            ? Text("No attendees registered.", style: TextStyle(fontWeight: FontWeight.bold))
            : SingleChildScrollView(
                child: Column(
                  children: event.attendees
                      .map((a) => ListTile(
                            title: Text("${a.name} (${a.gender}, ${a.age})", style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Email: ${a.email}\nPhone: ${a.phone}", style: TextStyle(fontWeight: FontWeight.bold)),
                          ))
                      .toList(),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // View Reports
  void _viewReports() {
    double totalRevenue = _events.fold(0, (sum, e) => sum + e.revenue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ticket Sales & Revenue Report", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              ..._events.map((event) => Card(
                    color: Colors.red[100]?.withOpacity(0.8),
                    child: ListTile(
                      title: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          "Total Tickets: ${event.capacity}\nTickets Sold: ${event.ticketsSold}\nRemaining Tickets: ${event.remainingTickets}\nRevenue: \$${event.revenue.toStringAsFixed(2)}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )),
              SizedBox(height: 10),
              Text("Total Revenue from All Events: \$${totalRevenue.toStringAsFixed(2)}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // CSV Import
  void _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result != null) {
      final fileBytes = result.files.first.bytes;
      if (fileBytes != null) {
        final csvString = utf8.decode(fileBytes);
        final rows = const CsvToListConverter().convert(csvString, eol: '\n');
        for (var row in rows.skip(1)) {
          if (row.length < 6) continue; // expecting 6 columns: title, desc, date, loc, capacity, price
          setState(() {
            _events.add(Event(
              title: row[0].toString(),
              description: row[1].toString(),
              
              date: row[2].toString(),
              location: row[3].toString(),
              capacity: int.tryParse(row[4].toString()) ?? 0,
              ticketPrice: double.tryParse(row[5].toString()) ?? 0,
            ));
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Management", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: _viewReports,
            tooltip: "View Reports",
          ),
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: _importCSV,
            tooltip: "Import CSV",
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade50, Colors.red.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: "Search by Title or Date",
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 10),
                TextField(controller: _titleController, decoration: InputDecoration(labelText: "Event Title", filled: true, fillColor: Colors.white.withOpacity(0.8))),
                TextField(controller: _descriptionController, decoration: InputDecoration(labelText: "Description", filled: true, fillColor: Colors.white.withOpacity(0.8))),
                TextField(controller: _dateController, decoration: InputDecoration(labelText: "Date", filled: true, fillColor: Colors.white.withOpacity(0.8))),
                TextField(controller: _locationController, decoration: InputDecoration(labelText: "Location", filled: true, fillColor: Colors.white.withOpacity(0.8))),
                TextField(controller: _capacityController, decoration: InputDecoration(labelText: "Total Tickets", filled: true, fillColor: Colors.white.withOpacity(0.8)), keyboardType: TextInputType.number),
                TextField(controller: _priceController, decoration: InputDecoration(labelText: "Ticket Price", filled: true, fillColor: Colors.white.withOpacity(0.8)), keyboardType: TextInputType.number),
                SizedBox(height: 10),
                ElevatedButton(onPressed: _addEvent, child: Text("Add Event")),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = _filteredEvents[index];
                      return Card(
                        color: Colors.red[100]?.withOpacity(0.8),
                        child: ListTile(
                          title: Text(event.title, style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            "${event.description}\nDate: ${event.date}\nLocation: ${event.location}\nTotal Tickets: ${event.capacity}\nTickets Sold: ${event.ticketsSold}\nRemaining Tickets: ${event.remainingTickets}\nTicket Price: \$${event.ticketPrice.toStringAsFixed(2)}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: Icon(Icons.edit, color: Colors.orange), onPressed: () => _updateEvent(_events.indexOf(event))),
                              IconButton(icon: Icon(Icons.person_add, color: Colors.blue), onPressed: () => _registerAttendee(event)),
                              IconButton(icon: Icon(Icons.list, color: Colors.green), onPressed: () => _viewAttendees(event)),
                              IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteEvent(_events.indexOf(event))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}