import Flutter
import UIKit

/// Platform channel bridge between Flutter and the native Azure AI Face Liveness SDK.
///
/// The Azure Face Liveness SDK for iOS requires:
///   1. An access token obtained from a backend session creation endpoint.
///   2. A ViewController-based UI that guides the user through head movement
///      and lighting checks for Presentation Attack Detection (PAD).
///   3. A verification payload returned asynchronously via delegate callback.
///
/// Implementation steps (requires AzureAIFaceSDK pod):
///   1. Add `pod 'AzureAIFaceSDK'` to the Podfile.
///   2. Create a `LivenessWithVerifySessionViewController` with the access token.
///   3. Present the view controller and handle the delegate callback to
///      obtain the verifySessionId and the encrypted verification payload.
class AzureLivenessPlugin: NSObject, FlutterPlugin {

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.dogsafield.dogsafield/azure_liveness",
            binaryMessenger: registrar.messenger()
        )
        let instance = AzureLivenessPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startLivenessSession":
            guard let args = call.arguments as? [String: Any],
                  let authToken = args["authToken"] as? String else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "authToken is required",
                    details: nil
                ))
                return
            }
            startLivenessSession(authToken: authToken, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startLivenessSession(authToken: String, result: @escaping FlutterResult) {
        // Native Azure Face Liveness SDK integration:
        //
        // 1. Initialize the SDK:
        //    let sdk = FaceLivenessSessionController(
        //        authToken: authToken,
        //        delegate: self
        //    )
        //
        // 2. Present the liveness camera UI from the root view controller:
        //    guard let controller = UIApplication.shared
        //        .keyWindow?.rootViewController else { return }
        //    controller.present(sdk, animated: true)
        //
        // 3. Handle the delegate callback:
        //    func livenessSessionController(
        //        _ controller: FaceLivenessSessionController,
        //        didCompleteWithResult result: LivenessWithVerifySessionResult
        //    ) {
        //        let verifySessionId = result.sessionId
        //        let payload = result.encryptedVerificationPayload
        //        // forward back to Flutter via result(verifySessionId)
        //    }
        //
        // This stub returns the authToken as a simulated verifySessionId.
        result(authToken)
    }
}
