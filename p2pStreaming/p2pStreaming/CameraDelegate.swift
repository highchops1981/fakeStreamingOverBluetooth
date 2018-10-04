import UIKit
import AVFoundation
import Photos
import MultipeerConnectivity

protocol CameraDelegate {
    func setLocalView(session:AVCaptureSession)
    func setRemoteView2(image:UIImage)
}

extension CameraDelegate {
    func setLocalView(session:AVCaptureSession) {}
    func setRemoteView2(image:UIImage) {}
}

class Camera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
    let captureOutput = AVCaptureVideoDataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var isRecording = false
    var numOfCapture = 0
    //var connection:AVCaptureConnection? = nil
    //var outputStream:OutputStream? = nil
    var sender:PeerUtil? = nil
    
    var cameraDelegate: CameraDelegate?
    
//    func createOutputStream(os: OutputStream) {
//
//        outputStream = os
//
//    }
    
    func set() {

        if let app = PeerUtil.app() {
            sender = app
        }

        do {
            
            //NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
            //NotificationCenter.default.addObserver(self, selector: #selector(cahngeOrientation(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
            
            let videoInput = try AVCaptureDeviceInput(device: videoDevice!) as AVCaptureDeviceInput
            captureSession.addInput(videoInput)
            captureSession.addOutput(captureOutput)
            //connection = self.captureOutput.connection(with: AVMediaType.video)
            //connection?.videoOrientation = appOrientation()
            captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
            captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String : Int(kCVPixelFormatType_32BGRA)]
            captureOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue.main)
            captureOutput.alwaysDiscardsLateVideoFrames = true
            
        }
        catch{
        }
    }
        
    
    func shot() {
        
        if !isRecording {
            captureSession.startRunning()
            isRecording = true
            
            cameraDelegate?.setLocalView(session:captureSession)

        }
        
    }
    
    func stop() {
        
        if isRecording {
            captureSession.stopRunning()
            isRecording = false
        }
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        //if numOfCapture == 1 {
        
            guard let image:UIImage = self.captureImage(sampleBuffer: sampleBuffer) else {
                return
            }
        
        
            //cameraDelegate?.setRemoteView2(image:image)
        
            if let imageData = image.jpegData(compressionQuality: 0.0) {
                
                let encodeString:String = imageData.base64EncodedString(options: [])
                let data = encodeString.data(using: .utf8)
                
                sender?.send(data: data!)
                
            }
            
            numOfCapture = 0
            
        //}
        
        numOfCapture = numOfCapture + 1
        
    }

    func captureImage(sampleBuffer:CMSampleBuffer) -> UIImage?{
        
        guard let imageBuffer:CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        guard let baseAddress:UnsafeMutableRawPointer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0) else {
            return nil
        }
        
        let bytesPerRow:Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width:Int = CVPixelBufferGetWidth(imageBuffer)
        let height:Int = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let newContext:CGContext = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace,  bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue|CGBitmapInfo.byteOrder32Little.rawValue) else {
            return nil
        }
        
        guard let imageRef:CGImage = newContext.makeImage() else {
            return nil
        }
        
        // キャプチャーされる画像は常に上下反転している。
        // UIImageOrientationは画像のメタデータである方向を設定している。.downを設定することで、方向を3(180°回転)に設定する。
        //let deviceOrientation = UIDevice.current.orientation.rawValue == 3 ? UIImage.Orientation.down : UIImage.Orientation.down
        
        let resultImage = UIImage(cgImage: imageRef, scale: 0.0, orientation:UIImage.Orientation.right)
        
        return resultImage
    }
    
//    func appOrientation() -> AVCaptureVideoOrientation {
//
//        switch UIApplication.shared.statusBarOrientation {
//        case UIInterfaceOrientation.landscapeLeft:
//            return AVCaptureVideoOrientation.landscapeLeft
//        case UIInterfaceOrientation.landscapeRight:
//            return AVCaptureVideoOrientation.landscapeRight
//        default:
//            return AVCaptureVideoOrientation.landscapeRight
//        }
//
//    }
    
//    @objc
//    func cahngeOrientation(_ notify:Notification) {
//        
//        connection?.videoOrientation = appOrientation()
//        
//    }
    
}
