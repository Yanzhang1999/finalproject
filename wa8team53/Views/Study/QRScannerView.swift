import SwiftUI
import AVFoundation


struct QRScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    @Binding var isShowingScanner: Bool
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let scannerVC = QRScannerViewController()
        scannerVC.delegate = context.coordinator
        return scannerVC
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QRScannerViewControllerDelegate {
        let parent: QRScannerView
        
        init(_ parent: QRScannerView) {
            self.parent = parent
        }
        
        func qrScanningSucceeded(code: String) {
            parent.scannedCode = code
            parent.isShowingScanner = false
        }
        
        func qrScanningFailed() {
            parent.isShowingScanner = false
        }
    }
}


class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: QRScannerViewControllerDelegate?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        // 首先请求相机权限
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard granted else {
                print("Camera permission denied")
                DispatchQueue.main.async {
                    self?.delegate?.qrScanningFailed()
                }
                return
            }
            
            // 获得权限后再设置相机
            DispatchQueue.main.async {
                self?.setupCameraSession()
            }
        }
    }
    
    private func setupCameraSession() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            delegate?.qrScanningSucceeded(code: stringValue)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
}


protocol QRScannerViewControllerDelegate: AnyObject {
    func qrScanningSucceeded(code: String)
    func qrScanningFailed()
}
