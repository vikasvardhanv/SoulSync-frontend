import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let faceChannelName = "soulsync/face_check"
  private let faceBridge = FaceCheckBridge()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: faceChannelName, binaryMessenger: controller.binaryMessenger)
      faceBridge.register(channel: channel)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

final class FaceCheckBridge {
  private var sdkInitialized = false
  private typealias ActivationFn = @convention(c) (AnyObject, Selector, NSString) -> Int32
  private typealias InitFn = @convention(c) (AnyObject, Selector) -> Int32
  private typealias FaceDetectionFn = @convention(c) (AnyObject, Selector, UIImage) -> AnyObject?
  private typealias TemplateExtractionFn = @convention(c) (AnyObject, Selector, UIImage, NSObject) -> AnyObject?
  private typealias SimilarityFn = @convention(c) (AnyObject, Selector, NSData, NSData) -> Float

  func register(channel: FlutterMethodChannel) {
    channel.setMethodCallHandler(handleCall)
  }

  private func handleCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initializeSdk":
      handleInitialize(call: call, result: result)
    case "performFaceCheck":
      handleFaceCheck(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleInitialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let activationKey = args["activationKey"] as? String,
          !activationKey.isEmpty else {
      result(FlutterError(code: "missing_activation_key", message: "Activation key is required.", details: nil))
      return
    }

    let initResult = initializeSdkIfNeeded(activationKey: activationKey)
    if initResult.success {
      result(["success": true])
    } else {
      result(FlutterError(code: initResult.code, message: initResult.message, details: nil))
    }
  }

  private func handleFaceCheck(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let activationKey = args["activationKey"] as? String,
          let referencePath = args["referenceImagePath"] as? String,
          let selfiePath = args["selfieImagePath"] as? String else {
      result(FlutterError(code: "invalid_args", message: "Missing face-check arguments.", details: nil))
      return
    }

    let similarityThreshold = (args["similarityThreshold"] as? NSNumber)?.doubleValue ?? 0.82
    let livenessThreshold = (args["livenessThreshold"] as? NSNumber)?.doubleValue ?? 0.70

    let initResult = initializeSdkIfNeeded(activationKey: activationKey)
    guard initResult.success else {
      result(FlutterError(code: initResult.code, message: initResult.message, details: nil))
      return
    }

    guard let referenceImage = UIImage(contentsOfFile: referencePath),
          let selfieImage = UIImage(contentsOfFile: selfiePath) else {
      result(FlutterError(code: "invalid_images", message: "Unable to load input images for face check.", details: nil))
      return
    }

    guard let sdkClass = loadFaceSdkClass() else {
      result(FlutterError(
        code: "sdk_not_linked",
        message: "Face SDK not linked. Add facesdk.framework from Faceplugin.",
        details: nil
      ))
      return
    }

    guard let referenceFaces = invokeFaceDetection(sdkClass: sdkClass, image: referenceImage),
          let selfieFaces = invokeFaceDetection(sdkClass: sdkClass, image: selfieImage) else {
      result(FlutterError(code: "face_detect_failed", message: "Face detection failed.", details: nil))
      return
    }

    guard let referenceBox = referenceFaces.first else {
      result(["verified": false, "similarity": 0.0, "liveness": 0.0, "reason": "No face in profile photo"])
      return
    }

    guard let selfieBox = selfieFaces.max(by: { faceLiveness($0) < faceLiveness($1) }) else {
      result(["verified": false, "similarity": 0.0, "liveness": 0.0, "reason": "No face in selfie"])
      return
    }

    let liveness = faceLiveness(selfieBox)
    guard liveness >= livenessThreshold else {
      result([
        "verified": false,
        "similarity": 0.0,
        "liveness": liveness,
        "reason": "Liveness check failed"
      ])
      return
    }

    guard let template1 = invokeTemplateExtraction(sdkClass: sdkClass, image: referenceImage, faceBox: referenceBox),
          let template2 = invokeTemplateExtraction(sdkClass: sdkClass, image: selfieImage, faceBox: selfieBox) else {
      result(FlutterError(code: "template_extraction_failed", message: "Template extraction failed.", details: nil))
      return
    }

    guard let similarity = invokeSimilarity(sdkClass: sdkClass, template1: template1, template2: template2) else {
      result(FlutterError(code: "similarity_failed", message: "Similarity calculation failed.", details: nil))
      return
    }

    result([
      "verified": similarity >= similarityThreshold,
      "similarity": similarity,
      "liveness": liveness,
      "reason": similarity >= similarityThreshold ? "Verification passed" : "Face mismatch"
    ])
  }

  private func initializeSdkIfNeeded(activationKey: String) -> (success: Bool, code: String, message: String) {
    if sdkInitialized {
      return (true, "", "")
    }

    guard let sdkClass = loadFaceSdkClass() else {
      return (false, "sdk_not_linked", "Face SDK not linked. Add facesdk.framework from Faceplugin.")
    }

    let activationSelector = NSSelectorFromString("setActivation:")
    guard (sdkClass as AnyObject).responds(to: activationSelector) else {
      return (false, "sdk_api_mismatch", "Face SDK setActivation API not found.")
    }
    let activationImpl = (sdkClass as AnyObject).method(for: activationSelector)
    let activationFn = unsafeBitCast(activationImpl, to: ActivationFn.self)
    let activationCode = activationFn(sdkClass as AnyObject, activationSelector, activationKey as NSString)
    if activationCode != 0 {
      return (false, "activation_failed", "Face SDK activation failed with code \(activationCode).")
    }

    let initSelector = NSSelectorFromString("initSDK")
    guard (sdkClass as AnyObject).responds(to: initSelector) else {
      return (false, "sdk_api_mismatch", "Face SDK initSDK API not found.")
    }
    let initImpl = (sdkClass as AnyObject).method(for: initSelector)
    let initFn = unsafeBitCast(initImpl, to: InitFn.self)
    let initCode = initFn(sdkClass as AnyObject, initSelector)
    if initCode != 0 {
      return (false, "init_failed", "Face SDK init failed with code \(initCode).")
    }

    sdkInitialized = true
    return (true, "", "")
  }

  private func loadFaceSdkClass() -> AnyClass? {
    NSClassFromString("FaceSDK") ?? NSClassFromString("facesdk.FaceSDK")
  }

  private func invokeFaceDetection(sdkClass: AnyClass, image: UIImage) -> [NSObject]? {
    let selector = NSSelectorFromString("faceDetection:")
    guard (sdkClass as AnyObject).responds(to: selector) else { return nil }
    let detectionImpl = (sdkClass as AnyObject).method(for: selector)
    let detectionFn = unsafeBitCast(detectionImpl, to: FaceDetectionFn.self)
    let result = detectionFn(sdkClass as AnyObject, selector, image)
    return result as? [NSObject]
  }

  private func invokeTemplateExtraction(sdkClass: AnyClass, image: UIImage, faceBox: NSObject) -> Data? {
    let selector = NSSelectorFromString("templateExtraction:faceBox:")
    guard (sdkClass as AnyObject).responds(to: selector) else { return nil }
    let templateImpl = (sdkClass as AnyObject).method(for: selector)
    let templateFn = unsafeBitCast(templateImpl, to: TemplateExtractionFn.self)
    let result = templateFn(sdkClass as AnyObject, selector, image, faceBox)
    if let data = result as? Data {
      return data
    }
    if let nsData = result as? NSData {
      return Data(referencing: nsData)
    }
    return nil
  }

  private func invokeSimilarity(sdkClass: AnyClass, template1: Data, template2: Data) -> Double? {
    let selector = NSSelectorFromString("similarityCalculation:templates2:")
    guard (sdkClass as AnyObject).responds(to: selector) else { return nil }
    let similarityImpl = (sdkClass as AnyObject).method(for: selector)
    let similarityFn = unsafeBitCast(similarityImpl, to: SimilarityFn.self)
    let score = similarityFn(sdkClass as AnyObject, selector, template1 as NSData, template2 as NSData)
    return Double(score)
  }

  private func faceLiveness(_ faceBox: NSObject) -> Double {
    if let score = faceBox.value(forKey: "liveness") as? NSNumber {
      return score.doubleValue
    }
    return 0.0
  }
}
