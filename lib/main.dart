import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check-in App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });

    return Scaffold(
      body: Center(
        child: Text(
          'Booking App',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

Map<String, String> users = {};
String? currentUser;
List<Map<String, dynamic>> reservations = [];
List<Map<String, String>> checkHistory = [];

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRegister = false;

  void handleLogin() {
    final email = emailController.text;
    final pass = passwordController.text;

    if (isRegister) {
      users[email] = pass;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Akun berhasil dibuat')));
    } else {
      if (users[email] == pass) {
        currentUser = email;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login gagal')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isRegister ? 'Daftar' : 'Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: handleLogin, child: Text(isRegister ? 'Daftar' : 'Login')),
            TextButton(onPressed: () => setState(() => isRegister = !isRegister), child: Text(isRegister ? 'Sudah punya akun? Login' : 'Belum punya akun? Daftar')),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  final pages = [SearchPage(), ReservationPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Reservasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final locationController = TextEditingController();
  final dateController = TextEditingController();
  final peopleController = TextEditingController();
  bool isFlight = true;
  String selectedRoomType = 'Single';
  List<Map<String, dynamic>> hasilPencarian = [];

  void pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => dateController.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  void cariPilihan() {
    final lokasi = locationController.text;
    if (lokasi.isEmpty || dateController.text.isEmpty || peopleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Isi semua data')));
      return;
    }
    final random = Random();
    final hargaDasar = isFlight ? 900000 : 500000;
    hasilPencarian = List.generate(3, (index) {
      final penyesuaian = random.nextInt(200000);
      final waktu = DateFormat('HH:mm').format(DateTime.now().add(Duration(hours: index + 1)));
      return {
        'lokasi': lokasi,
        'tanggal': dateController.text,
        'harga': hargaDasar + penyesuaian,
        'jam': waktu,
      };
    });
    setState(() {});
  }

  void pesan(Map<String, dynamic> data) {
    final jumlahOrang = peopleController.text;
    final item = {
      'name': isFlight ? 'Tiket ke ${data['lokasi']}' : 'Hotel di ${data['lokasi']}',
      'tanggal': data['tanggal'],
      'harga': data['harga'].toString(),
      'jam': data['jam'],
      'orang': jumlahOrang,
    };
    if (!isFlight) item['kamar'] = selectedRoomType;
    reservations.add(item);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil memesan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cari Tiket / Hotel')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: locationController, decoration: InputDecoration(labelText: 'Lokasi')),
            TextField(controller: dateController, readOnly: true, onTap: pickDate, decoration: InputDecoration(labelText: 'Tanggal')),
            TextField(controller: peopleController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Jumlah Orang')),
            Row(
              children: [
                ChoiceChip(label: Text('Tiket'), selected: isFlight, onSelected: (_) => setState(() => isFlight = true)),
                SizedBox(width: 10),
                ChoiceChip(label: Text('Hotel'), selected: !isFlight, onSelected: (_) => setState(() => isFlight = false)),
              ],
            ),
            if (!isFlight)
              DropdownButtonFormField<String>(
                value: selectedRoomType,
                items: ['Single', 'Double', 'Suite'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => selectedRoomType = val!),
                decoration: InputDecoration(labelText: 'Tipe Kamar'),
              ),
            ElevatedButton(onPressed: cariPilihan, child: Text('Cari')),
            Divider(),
            ...hasilPencarian.map((data) => ListTile(
              title: Text('${isFlight ? 'Tiket ke' : 'Hotel di'} ${data['lokasi']}'),
              subtitle: Text('Rp ${NumberFormat('#,###', 'id_ID').format(data['harga'])}\nWaktu: ${data['jam']}'),
              trailing: ElevatedButton(onPressed: () => pesan(data), child: Text('Booking')),
            )),
            if (hasilPencarian.isEmpty) Text('Belum ada hasil. Silakan cari.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ReservationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reservasi')),
      body: ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, i) {
          final res = reservations[i];
          return ListTile(
            title: Text(res['name']),
            subtitle: Text(
              'Tanggal: ${res['tanggal']}\n'
              'Jam: ${res['jam']}\n'
              'Harga: Rp${res['harga']}\n'
              'Jumlah Orang: ${res['orang']}\n'
              '${res.containsKey('kamar') ? 'Tipe Kamar: ${res['kamar']}' : ''}',
            ),
          );
        },
      ),
    );
  }
}
class ProfilePage extends StatelessWidget {
  final nameController = TextEditingController();

  void showEditNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Nama'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: 'Nama baru'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nama diperbarui')));
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void showHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Riwayat Check-in/Out'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: checkHistory.map((h) => ListTile(
              title: Text('Check-in: ${h['checkin']}'),
              subtitle: Text('Check-out: ${h['checkout']}, Durasi: ${h['durasi']}'),
            )).toList(),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Tutup'))],
      ),
    );
  }

  void logout(BuildContext context) {
    currentUser = null;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $currentUser', style: TextStyle(fontSize: 18)),
            ElevatedButton(onPressed: () => showEditNameDialog(context), child: Text('Edit Nama')),
            ElevatedButton(onPressed: () => showHistory(context), child: Text('Riwayat Check-in/Out')),
            ElevatedButton(
              onPressed: () => logout(context),
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

// ... (bagian lainnya tetap seperti sebelumnya)
