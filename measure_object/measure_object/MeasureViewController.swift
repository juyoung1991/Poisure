//
//  SecondViewController.swift
//  measure_object
//
//  Created by Ju Young Kim on 2016. 12. 26..
//  Copyright © 2016년 Ju Young Kim. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

class MeasureViewController: UIViewController, AVCapturePhotoCaptureDelegate{
    let captureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice? //Should be my iphone8
    var previewLayer:AVCaptureVideoPreviewLayer?
    let stillImageOutput = AVCapturePhotoOutput()
    var camera_height = 0.0
    var usingMeter:Bool = true
    
    var layerArray = NSMutableArray()
    var width_subViewArray = NSMutableArray()
    @IBOutlet weak var camera_view: UIView!
    
    var motion_manager = CMMotionManager()
    
    var obj_angle:Double = 0.0
    var obj_dist:Double = 0.0
    var obj_height:Double = 0.0
    var obj_width:Double = 0.0
    var prev_yaw_sign:Double = 0.0
    var after_yaw_sign:Double = 0.0
    var done_dist = false
    let width_frame = Adj_frame()
    
    @IBOutlet weak var distance_label: UITextField!
    @IBOutlet weak var height_label: UITextField!
    @IBOutlet weak var width_label: UITextField!
    
    @IBOutlet weak var distance_btn: UIButton!
    @IBOutlet weak var height_btn: UIButton!
    @IBOutlet weak var width_btn: UIButton!
    
    @IBOutlet weak var dist_unit: UILabel!
    @IBOutlet weak var height_unit: UILabel!
    @IBOutlet weak var width_unit: UILabel!
    @IBOutlet weak var capture_btn: UIButton!
    @IBOutlet weak var restart_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        distance_label.text = ""
        height_label.text = ""
        width_label.text = ""
        distance_btn.isEnabled = true
        distance_btn.layer.backgroundColor = UIColor.init(red: 51/255, green: 153/255, blue: 1, alpha: 1).cgColor
        distance_btn.layer.cornerRadius = 6
        height_btn.isEnabled = false
        height_btn.layer.backgroundColor = UIColor.gray.cgColor
        height_btn.layer.cornerRadius = 6
        width_btn.isEnabled = false
        width_btn.layer.backgroundColor = UIColor.gray.cgColor
        width_btn.layer.cornerRadius = 6
        self.previewLayer?.opacity = 1.0
        self.restart_btn.setTitleColor(UIColor.red, for: .normal)
        if(self.camera_view.subviews != nil){
            for view in self.camera_view.subviews{
                view.removeFromSuperview()
            }
        }
        if(self.camera_view.layer.sublayers != nil){
            for layer in self.camera_view.layer.sublayers!{
                if(layerArray.contains(layer)){
                    layer.removeFromSuperlayer()
                    layerArray.remove(layer)
                }
            }
        }
        if(usingMeter){
            dist_unit.text = "m"
            height_unit.text = "m"
            width_unit.text = "m"
        }else{
            dist_unit.text = "ft"
            height_unit.text = "ft"
            width_unit.text = "ft"
        }
        
        let devices = AVCaptureDevice.devices()
        //Go through all available devices and get the back camera
        for device in devices! {
            if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)){
                if((device as AnyObject).position == AVCaptureDevicePosition.back){
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        if(captureDevice != nil){
            beginSession()
            draw_cam_focus_lines(start: CGPoint(x: self.camera_view.frame.width/2, y: self.camera_view.frame.height/2 - 60), end: CGPoint(x: self.camera_view.frame.width/2, y: self.camera_view.frame.height/2 - 15))
            draw_cam_focus_lines(start: CGPoint(x: self.camera_view.frame.width/2, y: self.camera_view.frame.height/2 + 60), end: CGPoint(x: self.camera_view.frame.width/2, y: self.camera_view.frame.height/2 + 15))
            draw_cam_focus_lines(start: CGPoint(x: self.camera_view.frame.width/2 + 60, y: self.camera_view.frame.height/2), end: CGPoint(x: self.camera_view.frame.width/2 + 15, y: self.camera_view.frame.height/2))
            draw_cam_focus_lines(start: CGPoint(x: self.camera_view.frame.width/2 - 60, y: self.camera_view.frame.height/2), end: CGPoint(x: self.camera_view.frame.width/2 - 15, y: self.camera_view.frame.height/2))
            draw_cam_focus_point()
        }
        if(motion_manager.isGyroAvailable){
            start_motion_update()
        }
    }
    
    @IBAction func capture_image(_ sender: Any) {
        let settingForMonitoring = AVCapturePhotoSettings()
        settingForMonitoring.flashMode = .auto
        settingForMonitoring.isAutoStillImageStabilizationEnabled = true
        settingForMonitoring.isHighResolutionPhotoEnabled = false
        stillImageOutput.capturePhoto(with: settingForMonitoring, delegate: self)
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let image = UIImage(data: photoData!)
            let point = CGPoint(x: (image?.size.width)! * 0.3, y: (image?.size.height)! * 0.8)
            var new_image:UIImage = (image?.addOverlay(dist: NSString(format: "%.2f", self.obj_dist) as String, width: NSString(format: "%.2f", self.obj_width) as String, height: NSString(format: "%.2f", self.obj_height) as String, startPoint: point))!
            UIImageWriteToSavedPhotosAlbum(new_image, nil, nil, nil)
        }
    }
    
    @IBAction func fix_dist(_ sender: Any) {
        done_dist = true
        print(prev_yaw_sign)
        end_motion_update()
        self.obj_dist = tan(self.obj_angle) * self.camera_height
        distance_label.text = NSString(format: "%.2f", obj_dist) as String
        distance_btn.isEnabled = false
        distance_btn.layer.backgroundColor = UIColor.gray.cgColor
        height_btn.layer.backgroundColor = UIColor.init(red: 51/255, green: 153/255, blue: 1, alpha: 1).cgColor
        height_btn.isEnabled = true
        start_motion_update()
    }
    
    @IBAction func fix_height(_ sender: Any) {
        end_motion_update()
        print(after_yaw_sign)
        if(after_yaw_sign != prev_yaw_sign){
            let d = self.obj_dist / tan(self.obj_angle)
            self.obj_height = self.camera_height + d
            height_label.text = NSString(format: "%.2f", self.obj_height) as String
            height_btn.isEnabled = false
            height_btn.layer.backgroundColor = UIColor.gray.cgColor
            width_btn.isEnabled = true
            width_btn.layer.backgroundColor = UIColor.init(red: 51/255, green: 153/255, blue: 1, alpha: 1).cgColor
        }else if(after_yaw_sign == prev_yaw_sign){
            let d = self.obj_dist / tan(self.obj_angle)
            self.obj_height = self.camera_height - d
            height_label.text = NSString(format: "%.2f", self.obj_height) as String
            height_btn.isEnabled = false
            height_btn.layer.backgroundColor = UIColor.gray.cgColor
            width_btn.isEnabled = true
            width_btn.layer.backgroundColor = UIColor.init(red: 51/255, green: 153/255, blue: 1, alpha: 1).cgColor
        }else if(self.obj_angle == M_PI/2){
            height_label.text = NSString(format: "%.2f", self.camera_height) as String
            height_btn.isEnabled = false
            height_btn.layer.backgroundColor = UIColor.gray.cgColor
            width_btn.isEnabled = true
            width_btn.layer.backgroundColor = UIColor.init(red: 51/255, green: 153/255, blue: 1, alpha: 1).cgColor
        }
        
        create_adj_frame()
    }
    
    @IBAction func fix_width(_ sender: Any) {
        self.obj_width = (self.obj_height / Double(self.width_frame.frame.size.height)) * Double(self.width_frame.frame.size.width)
        width_label.text = NSString(format: "%.2f", self.obj_width) as String
        width_btn.isEnabled = false
        width_btn.layer.backgroundColor = UIColor.gray.cgColor
        print(self.camera_view.subviews)
        print(width_subViewArray)
        for subview in self.camera_view.subviews{
            if(width_subViewArray.contains(subview)){
                subview.removeFromSuperview()
            }
        }
    }
    
    func create_adj_frame(){
        delete_cam_shapes()
        self.camera_view.layer.shouldRasterize = false
        let screen_size:CGRect = self.camera_view.bounds
        let blur_view = UIView()
        blur_view.frame = screen_size
        blur_view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.camera_view.addSubview(blur_view)
        
        let width_frame_size:CGRect = CGRect(x: self.camera_view.frame.width * 0.2, y: self.camera_view.frame.height * 0.2, width: self.camera_view.frame.width * 0.3, height: self.camera_view.frame.height * 0.3)
        width_frame.frame = width_frame_size
        width_frame.layer.borderWidth = 4
        width_frame.layer.borderColor = UIColor.gray.cgColor
        width_frame.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        self.camera_view.addSubview(width_frame)
        
        self.width_subViewArray.add(blur_view)
        self.width_subViewArray.add(width_frame)
        
    }
    
    func start_motion_update(){
        self.motion_manager.deviceMotionUpdateInterval = 0.2
        self.motion_manager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { (device_motion, error) in
            self.outputCameraAngle()
        })
    }
    
    func end_motion_update(){
        self.motion_manager.stopDeviceMotionUpdates()
    }
    
    func outputCameraAngle(){
        var attitude = CMAttitude()
        var motion = CMDeviceMotion()
        motion = self.motion_manager.deviceMotion!
        attitude = motion.attitude
        self.obj_angle = attitude.pitch
        if(done_dist){
            self.after_yaw_sign = copysign(1.0, attitude.yaw)
        }else{
            self.prev_yaw_sign = copysign(1.0, attitude.yaw)
        }
    }
    
    func beginSession() {
        var err :NSError? = nil
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if(captureSession.canAddInput(input)){
                captureSession.addInput(input);
                if(captureSession.canAddOutput(stillImageOutput)){
                    captureSession.addOutput(stillImageOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    self.camera_view.layer.addSublayer(previewLayer!)
                    previewLayer?.frame = self.camera_view.layer.frame
                    var bounds:CGRect = self.camera_view.layer.bounds
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    previewLayer?.bounds = bounds
                    previewLayer?.position = CGPoint(x: bounds.midX, y: bounds.midY)
                    captureSession.startRunning()
                }
            }
        }
        catch{
            print("exception!");
        }
    }
    
    func draw_cam_focus_lines(start: CGPoint, end: CGPoint){
        //Upward line
        let line = UIBezierPath()
        line.move(to: start)
        line.addLine(to: end)
        
        var shapeLayer = CAShapeLayer()
        shapeLayer.path = line.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 4.0
        self.camera_view.layer.addSublayer(shapeLayer)
        self.layerArray.add(shapeLayer)
        
    }
    
    func delete_cam_shapes(){
        self.camera_view.layer.sublayers?.forEach({ (layer) in
            if(layerArray.contains(layer)){
                layer.removeFromSuperlayer()
                layerArray.remove(layer)
            }
        })
    }
    
    func draw_cam_focus_point(){
        let circlePath = UIBezierPath(arcCenter:
            CGPoint(x: self.camera_view.frame.width/2, y: self.camera_view.frame.height/2), radius: CGFloat(5), startAngle: CGFloat(0), endAngle: CGFloat(M_PI * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.red.cgColor
        self.camera_view.layer.addSublayer(shapeLayer)
        self.layerArray.add(shapeLayer)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

