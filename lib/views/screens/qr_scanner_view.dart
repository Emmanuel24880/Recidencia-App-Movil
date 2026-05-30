import 'package:app_movil_1/controllers/mesa_controller.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class QRScannerView extends StatefulWidget {
  final Map<String, dynamic> user;

  const QRScannerView({super.key, required this.user});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  bool scanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (scanned) return;

    final barcode = capture.barcodes.first;
    final String? code = barcode.rawValue;

    if (code != null) {
      scanned = true;

      try {
        int mesa = int.parse(code);

        //GUARDAR MESA EN PROVIDER
        final mesaController = context.read<MesaController>();
        mesaController.agregarMesa(mesa);
        mesaController.seleccionarMesa(mesa);

        //REGRESAR AL HOME
        context.go('/home', extra: widget.user);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("QR inválido")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escanear Mesa"),
        backgroundColor: Colors.amber,
      ),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),

          // Marco visual
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
