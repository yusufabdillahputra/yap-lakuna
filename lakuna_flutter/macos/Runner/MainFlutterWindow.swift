import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  /// Kanal `lakuna/window` (lihat `ExitGuard` di Dart, F1-02c).
  private var windowChannel: FlutterMethodChannel?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    windowChannel = FlutterMethodChannel(
      name: "lakuna/window",
      binaryMessenger: flutterViewController.engine.binaryMessenger)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  /// Tombol tutup jendela bertanya ke Flutter dulu selagi jendela masih
  /// tampil (F1-02c): `false` = dibatalkan atau dialog masih terbuka, jendela
  /// tetap; selain itu (diizinkan, belum masuk, galat) aplikasi keluar.
  override func performClose(_ sender: Any?) {
    guard let channel = windowChannel else {
      NSApp.terminate(sender)
      return
    }
    channel.invokeMethod("requestClose", arguments: nil) { result in
      if let allowed = result as? Bool, !allowed { return }
      NSApp.terminate(nil)
    }
  }
}
