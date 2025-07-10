import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../controllers/auth_controller.dart';

class AuthRoutes {
  Router get router {
    final router = Router();

    // Register user
    router.post('/register', AuthController.register);

    // Login user
    router.post('/login', AuthController.login);

    // Get profile (protected)
    router.get('/profile', AuthController.getProfile);

    // Update profile (protected)
    router.put('/profile', AuthController.updateProfile);

    // Logout
    router.post('/logout', AuthController.logout);

    return router;
  }
}