import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kasirsuper/core/core.dart';
import 'package:kasirsuper/core/theme/quickpos_colors.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';

class PrinterPage extends StatefulWidget {
  const PrinterPage({super.key});

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  bool _connected = false;
  List<BluetoothInfo> _items = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    bool isConnected = await PrintBluetoothThermal.connectionStatus;
    setState(() {
      _connected = isConnected;
    });
  }

  Future<void> _getBluetooths() async {
    setState(() {
      _isScanning = true;
    });

    try {
      if (Platform.isAndroid) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();

        if (statuses[Permission.bluetoothScan]?.isDenied == true ||
            statuses[Permission.bluetoothConnect]?.isDenied == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin Bluetooth diperlukan')),
          );
          setState(() {
            _isScanning = false;
          });
          return;
        }
      }

      final List<BluetoothInfo> listResult = await PrintBluetoothThermal.pairedBluetooths;
      
      setState(() {
        _items = listResult;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memindai: $e')),
      );
    }
  }

  Future<void> _connect(String mac) async {
    setState(() {
      _isScanning = true;
    });

    try {
      final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
      setState(() {
        _connected = result;
        _isScanning = false;
      });
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printer terhubung')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghubungkan printer')),
        );
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  Future<void> _disconnect() async {
    try {
      final bool result = await PrintBluetoothThermal.disconnect;
      setState(() {
        _connected = !result;
      });
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printer diputuskan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memutuskan koneksi: $e')),
      );
    }
  }

  Future<void> _testPrint() async {
    if (!_connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan hubungkan printer terlebih dahulu')),
      );
      return;
    }

    try {
      bool isConnected = await PrintBluetoothThermal.connectionStatus;
      if (isConnected) {
        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 2, text: "KASIR SUPER\n"),
        );
        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 1, text: "Test Print Berhasil\n"),
        );
        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 1, text: "--------------------------------\n"),
        );
        await PrintBluetoothThermal.writeString(
          printText: PrintTextSize(size: 1, text: "Terima Kasih\n\n\n\n"),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printer terputus')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencetak: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickPOSColors.surface,
      appBar: AppBar(
        title: const Text('Pengaturan Printer'),
        backgroundColor: Colors.white,
        foregroundColor: QuickPOSColors.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getBluetooths,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _connected ? Icons.print : Icons.print_disabled,
                      color: _connected ? QuickPOSColors.secondary : QuickPOSColors.outline,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _connected ? 'Printer Terhubung' : 'Printer Terputus',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (_connected)
                  TextButton(
                    onPressed: _disconnect,
                    child: const Text('Putuskan'),
                  )
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_items.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bluetooth_searching, size: 64, color: QuickPOSColors.outlineVariant),
                    const SizedBox(height: 16),
                    const Text('Tekan tombol refresh untuk mencari printer', style: TextStyle(color: QuickPOSColors.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _getBluetooths,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: QuickPOSColors.primary,
                        foregroundColor: QuickPOSColors.onPrimary,
                      ),
                      child: const Text('Cari Perangkat'),
                    )
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: QuickPOSColors.outlineVariant.withOpacity(0.5)),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: QuickPOSColors.surfaceContainerHigh,
                        child: Icon(Icons.bluetooth, color: QuickPOSColors.primary),
                      ),
                      title: Text(item.name.isEmpty ? 'Unknown Device' : item.name),
                      subtitle: Text(item.macAdress),
                      trailing: ElevatedButton(
                        onPressed: () => _connect(item.macAdress),
                        child: const Text('Hubungkan'),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _connected ? _testPrint : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: _connected ? QuickPOSColors.secondary : QuickPOSColors.outlineVariant,
              foregroundColor: Colors.white,
            ),
            child: const Text('Test Print'),
          ),
        ),
      ),
    );
  }
}
