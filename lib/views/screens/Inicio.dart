import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InicioView extends StatelessWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/imagenes/pollo.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.60)),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Logo circular
                Center(
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.shade600,
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/imagenes/logo.png', // <-- cámbialo
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const Spacer(),

                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    '¡Bienvenido Mesero!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // Botón "Iniciar"
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 24.0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.goNamed('login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade600,
                        foregroundColor: Colors.black,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 4,
                      ),
                      child: const Text('Iniciar'),
                    ),
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
