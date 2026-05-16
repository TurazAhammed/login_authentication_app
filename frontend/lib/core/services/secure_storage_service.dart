// Conditional export: use the IO/mobile implementation normally, and the
// web implementation when running in a browser. This keeps the public API
// (`SecureStorageService`) the same across platforms.
export 'secure_storage_service_io.dart'
    if (dart.library.html) 'secure_storage_service_web.dart';
