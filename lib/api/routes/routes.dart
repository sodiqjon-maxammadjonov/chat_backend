// lib/api/routes.dart

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../controller/auth/auth_controller.dart';
import '../middleware/auth/auth_middleware.dart';

class ApiRoutes {
  final AuthController _authController;
  final AuthMiddleware _authMiddleware;

  ApiRoutes(this._authController, this._authMiddleware);

  Router get router {
    final router = Router();

    // Asosiy guruh: Barcha so'rovlar `/api/` bilan boshlanadi. Masalan: http://localhost:8080/api/auth/register
    router.mount('/api/', _buildApiRouter());

    return router;
  }

  Router _buildApiRouter() {
    final apiRouter = Router();

    // Auth guruhini qo'shish: `/api/auth/`
    apiRouter.mount('/auth/', _buildAuthRouter());

    // boshqa guruhlar ham qo'shilishi mumkin:
    // apiRouter.mount('/chat/', _buildChatRouter());
    // apiRouter.mount('/users/', _buildUsersRouter());

    return apiRouter;
  }

  Router _buildAuthRouter() {
    final authRouter = Router();

    authRouter.post('/register', _authController.register);
    authRouter.post('/login', _authController.login);


    final protectedHandler = Pipeline()
        .addMiddleware(_authMiddleware())
        .addHandler(_authController.getProfile);

    authRouter.get('/profile', protectedHandler);

    return authRouter;
  }
}