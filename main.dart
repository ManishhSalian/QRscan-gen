import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

//void main() => runApp(MaterialApp(home: QRScannerApp()));

void main() => runApp(MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.blue, // Change the primary color to blue
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch:
              Colors.cyan, // Change the primary swatch to light green
        ),
        fontFamily:
            'YourCustomFont', // Replace 'YourCustomFont' with your custom font
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          // Customize other text styles as needed
        ),
      ),
      home: QRScannerApp(),
    ));

class QRScannerApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScannerAppState();
}

class _QRScannerAppState extends State<QRScannerApp> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isScanning = false;
  int _selectedTabIndex = 0; // Index for the selected tab

  TextEditingController resultController =
      TextEditingController(); // Text controller for displaying the result
  TextEditingController qrTextController =
      TextEditingController(); // Text controller for QR Code generator

  @override
  void initState() {
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    resultController.dispose(); // Dispose of the text controller
    qrTextController.dispose(); // Dispose of the QR text controller
    super.dispose();
  }

  void startScanning() {
    setState(() {
      isScanning = true;
    });
    controller!.resumeCamera();
  }

  void stopScanning() {
    setState(() {
      isScanning = false;
    });
    controller!.pauseCamera();
  }

  void clearResult() {
    setState(() {
      result = null;
      resultController.text = ''; // Clear the result in the text box
    });
  }

  // Function to handle tab changes
  void onTabTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
      ),
      body: _selectedTabIndex == 0
          ? buildScannerView() // Display scanner view when on the "Scanner" tab
          : buildGeneratorView(), // Display generator view when on the "Generator" tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: onTabTapped, // Function to handle tab changes
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera), // Icon for the "Scanner" tab
            label: 'Scanner', // Label for the "Scanner" tab
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code), // Icon for the "Generator" tab
            label: 'Generator', // Label for the "Generator" tab
          ),
        ],
      ),
    );
  }

  Widget buildScannerView() {
    return Column(
      children: <Widget>[
        SizedBox(height: 20),
        Text(
          'QR Code Scanner',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'Place QR code in the area',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Center(
          // Center the QR Scanner box
          child: Container(
            width: 300, // Adjust the width as needed
            height: 300, // Adjust the height as needed
            alignment: Alignment.center, // Center the camera box
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ),
        SizedBox(height: 20),
        if (!isScanning)
          ElevatedButton(
            onPressed: startScanning,
            child: Text('Start Scanning'),
          ),
        if (result != null)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: resultController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'QR Code Data',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: clearResult,
                child: Text('Clear Result'),
              ),
            ],
          ),
      ],
    );
  }

  Widget buildGeneratorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'QR Code Generator',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: qrTextController,
            decoration: InputDecoration(
              labelText: 'Enter text for QR Code',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            generateQRCode(qrTextController.text);
          },
          child: Text('Generate QR Code'),
        ),
        SizedBox(height: 20),
        if (qrTextController.text.trim().isNotEmpty)
          Column(
            children: [
              Container(
                  width: 200, // Adjust the width as needed
                  height: 200, // Adjust the height as needed
                  child: QrImageView(
                    data: qrTextController.text,
                  )),
              SizedBox(height: 10),
              Text(
                'Generated QR Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        resultController.text =
            result?.code ?? ''; // Update the text box with the result
      });
    });
  }

  void generateQRCode(String data) {
    setState(() {
      resultController.text =
          data; // Update the text box with the generated QR code data
    });
  }
}
