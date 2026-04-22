import Flutter
import UIKit
import GoogleMaps // <--- Añadido
import flutter_config // <--- Añadido

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 1. Extraemos la clave del archivo .env
    // Asegúrate de que en el .env se llame exactamente "Maps_API_KEY"
    let apiKey = FlutterConfig.fetchEnvVariable("Maps_API_KEY") as? String

    // 2. Proporcionamos la clave a Google Maps
    GMSServices.provideAPIKey(apiKey ?? "")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}