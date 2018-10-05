import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var advertisingBtn: UIButton!
    @IBOutlet weak var browsingBtn: UIButton!
    
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var remoteView: UIView!
    @IBOutlet weak var remoteImageVIew: UIImageView!
    
    @IBOutlet weak var coverView: UIView!
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    let sampleBufferDisplayLayer = AVSampleBufferDisplayLayer()
    
    var peerUtil:PeerUtil!
    var camera:Camera?
    
    let w:CGFloat = 30.0
    let h:CGFloat = 40.0
    var x:CGFloat = 0.0
    var y:CGFloat = 0.0
    
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
        
        localView.isHidden = true
        remoteView.isHidden = true

        camera = Camera()
        camera?.cameraDelegate = self
    }

    @IBAction func pushAllStopBtn(_ sender: Any) {
        
        //ui制御
        let subviews = coverView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        self.x = 0
        self.y = 0
        coverView.isHidden = false
        
        camera?.stop()
        peerUtil.session?.disconnect()
        peerUtil.stopAdvertise()
        peerUtil.stopBrowsering()
        self.localView.isHidden = true
        self.remoteView.isHidden = true
        self.remoteImageVIew.image = nil
        
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
    
    func setRemoteView2(image:UIImage) {
        
        DispatchQueue.main.async {
            self.localView.isHidden = true
            self.remoteView.isHidden = false
            self.remoteImageVIew.image = image
        }
        
    }
    
    func setLocalView(session:AVCaptureSession) {
        
        DispatchQueue.main.async {
            self.localView.isHidden = false
            self.remoteView.isHidden = true
            
            self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
            self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
            self.previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            
            self.localView.layer.insertSublayer(self.previewLayer!, at: 0)
            
            self.previewLayer?.position = CGPoint(x: self.localView.frame.width/2, y: self.localView.frame.height/2)
            self.previewLayer?.bounds = self.localView.frame
        }
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
        
        localView.isHidden = true
        remoteView.isHidden = false
        
        DispatchQueue.main.async {
            self.sampleBufferDisplayLayer.bounds = self.remoteView.frame
            self.sampleBufferDisplayLayer.enqueue(sampleBuffer)
            self.sampleBufferDisplayLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.remoteView.layer.addSublayer(self.sampleBufferDisplayLayer)
        }
        
    }
    
    func setRemoteView(image:UIImage) {
        
        DispatchQueue.main.async {

            if self.y > self.view.frame.height {
                
                if self.remoteView.isHidden {
                    UIView.transition(with: self.coverView, duration: 1.0, options: [.transitionCurlUp], animations: { () in
                        
                        self.coverView.isHidden = true
                        
                    }, completion: { (bool) in
                    })
                }
                
                self.localView.isHidden = true
                self.remoteView.isHidden = false
                self.remoteImageVIew.layer.contentsGravity = CALayerContentsGravity.resizeAspect
                self.remoteImageVIew.image = image

            } else {
                
                let imageView = UIImageView(frame: CGRect(x: self.x, y: self.y, width: self.w, height: self.h))
                imageView.image = image
                self.coverView.addSubview(imageView)
                self.x = self.x + self.w
                if self.x > self.coverView.frame.width {
                    self.x = 0
                    self.y = self.y + self.h
                }
 
            }
            
        }
        
    }
    
}


