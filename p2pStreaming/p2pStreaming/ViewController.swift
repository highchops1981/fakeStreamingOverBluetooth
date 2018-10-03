import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    let sampleBufferDisplayLayer = AVSampleBufferDisplayLayer()
    var peerUtil:PeerUtil!

    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var startBtn: UIButton!
    
    @IBOutlet weak var advertisingBtn: UIButton!
    @IBOutlet weak var browsingBtn: UIButton!
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var remoteView: UIView!
    @IBOutlet weak var remoteImageVIew: UIImageView!
    
    var camera:Camera?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        peerUtil = PeerUtil.app()
        peerUtil.delegate = self
        
        let app = UIApplication.shared.delegate as! AppDelegate
        
        if app.initiator {
            
            browsingBtn.isHidden = false
            advertisingBtn.isHidden = true
            
        } else {
            
            browsingBtn.isHidden = true
            advertisingBtn.isHidden = false
            
        }

        camera = Camera()
        camera?.cameraDelegate = self
    }

    @IBAction func pushStartBtn(_ sender: Any) {
        peerUtil.startStream()
    }
    
    @IBAction func pushCameraBtn(_ sender: Any) {
        
        camera?.set()
        camera?.shot()
        
    }
    
    @IBAction func pushBrowsingBtn(_ sender: Any) {
        
        peerUtil.browsing()
        
    }
    
    @IBAction func pushAdvertisingBtn(_ sender: Any) {
        
        peerUtil.advertise()
        
    }
    
    func test<T>(fn: () throws -> T) -> T? {
        
        if let result = try? fn() {
            print("We got a result!")
            return result
        }
        else {
            print("There was an error")
            return nil
        }
    }
    
    
}

extension ViewController: CameraDelegate {
    
    func setLocalView(session:AVCaptureSession) {
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        localView.layer.addSublayer(previewLayer!)
        
        previewLayer?.position = CGPoint(x: self.localView.frame.width/2, y: self.localView.frame.height/2)
        previewLayer?.bounds = localView.frame
    }

}

extension ViewController: PeerDelegate {
    
    func peerConnected(displayName: String) {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Info", message: "MultipeerConnect ok", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { _ in
                
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func setRemoteView(sampleBuffer:CMSampleBuffer) {
        
        DispatchQueue.main.async {
            self.sampleBufferDisplayLayer.bounds = self.remoteView.frame
            self.sampleBufferDisplayLayer.enqueue(sampleBuffer)
            self.sampleBufferDisplayLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.remoteView.layer.addSublayer(self.sampleBufferDisplayLayer)
        }
        
    }
    
    func setRemoteView(image:UIImage) {
        
        DispatchQueue.main.async {
            self.remoteImageVIew.image = image
        }
        
    }
    
}


