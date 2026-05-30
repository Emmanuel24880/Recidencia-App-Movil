import 'package:app_movil_1/models/producto.dart';
import 'package:app_movil_1/views/screens/cartview.dart';
import 'package:app_movil_1/views/screens/cobro_view.dart';
import 'package:app_movil_1/views/screens/home.dart';
import 'package:app_movil_1/views/screens/productView.dart';
import 'package:app_movil_1/views/screens/qr_scanner_view.dart';
import 'package:go_router/go_router.dart';
import '../views/screens/inicio.dart';
import '../views/screens/login.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'inicio',
      builder: (context, state) => const InicioView(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) {
        final user = state.extra as Map<String, dynamic>;
        return HomeScreen(user: user);
      },
    ),
    GoRoute(
      path: '/productview',
      name: 'productview',
      builder: (context, state) {
        final producto = state.extra as Producto;
        return ProductView(producto: producto);
      },
    ),
    GoRoute(
      path: '/cartview',
      name: 'cartview',
      builder: (context, state) => const CartView(),
    ),
    GoRoute(
      path: '/qr',
      name: 'qr',
      builder: (context, state) {
        final user = state.extra as Map<String, dynamic>;
        return QRScannerView(user: user);
      },
    ),
    GoRoute(
      path: '/cobro',
      name: 'cobro',
      builder: (context, state) => const CobroView(),
    ),
  ],
);
