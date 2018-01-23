//
//  ViewController.swift
//  PhotoLocator
//
//  Created by Giuseppe Valenti on 22/01/2018.
//  Copyright © 2018 Giuseppe Valenti. All rights reserved.
//

import UIKit
import Sparrow
import ALCameraViewController
import CoreLocation
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var username = ""
    let url = "mirkoghey.com"
    
    @IBOutlet weak var usrnameLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var coordsLbl: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    let locationManager = CLLocationManager()
    
    @IBAction func sendData(_ sender: Any) {
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.5) as Data?
        let url = try! URLRequest(url: URL(string:"www.mirkoghey.com")!, method: .post, headers: nil)
    
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData!, withName: "photo", fileName: "\(NSDate().timeIntervalSince1970)-\(self.username).jpg", mimeType: "image/jpeg")
                
        },
            with: url,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if((response.result.value) != nil) {
                            
                        } else {
                            
                        }
                    }
                case .failure( _):
                    break
                }
        }
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let savedUsr = UserDefaults.standard.string(forKey: "username"){
            if (!savedUsr.isEmpty){
                username = savedUsr
            }
        }
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        checkUsername()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.takePhoto(_:)))
        imageView.addGestureRecognizer(gestureRecognizer)
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(self.writeComment(_:)))
        descriptionText.addGestureRecognizer(gestureRecognizer2)
        descriptionText.isUserInteractionEnabled = true
        sendBtn.alpha = 0;
    }
    
    @objc func takePhoto(_ sender: UITapGestureRecognizer) {
        let cameraViewController = CameraViewController { [weak self] image, asset in
            // Do something with your image here.
            self?.imageView.image = image
            self?.dismiss(animated: true, completion: nil)
            
            if CLLocationManager.locationServicesEnabled() {
                self?.locationManager.delegate = self
                self?.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self?.locationManager.startUpdatingLocation()
            }
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    @objc func writeComment(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(style: UIAlertControllerStyle.alert, title: "Comment")
        let config: TextField.Config = { textField in
            textField.becomeFirstResponder()
            textField.textColor = .black
            textField.placeholder = "Type something"
            textField.borderWidth = 1
            textField.cornerRadius = 8
            textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
            textField.backgroundColor = nil
            textField.keyboardAppearance = .default
            textField.keyboardType = .default
            textField.returnKeyType = .done
            textField.action { textField in
                // validation and so on
            }
            textField.delegate = self
            textField.tag = 2
        }
        alert.addOneTextField(configuration: config)
        alert.addAction(title: "OK", style: .cancel)
        alert.show()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        coordsLbl.text = "@\nLAT: \(locValue.latitude)\nLNG: \(locValue.longitude)"
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.locationManager.stopUpdatingLocation()
        self.sendBtn.alpha = 1;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func checkPermission() {
//        let isAvailableCamera = SPRequestPermission.isAllowPermission(SPRequestPermissionType.camera)
//        let isAvailableLocation = SPRequestPermission.isAllowPermission(SPRequestPermissionType.locationWhenInUse)
//        if (!isAvailableCamera && !isAvailableLocation) {
            SPRequestPermission.dialog.interactive.present(on: self, with: [.camera, .locationWhenInUse])
//        }else{
//            if !isAvailableLocation {
//                SPRequestPermission.dialog.interactive.present(on: self, with: [.locationWhenInUse])
//            }else if !isAvailableCamera {
//                SPRequestPermission.dialog.interactive.present(on: self, with: [.camera]
//                )
//            }
//        }
    }

    func checkUsername() {
        if username.isEmpty {
            let alert = UIAlertController(style: UIAlertControllerStyle.alert, title: "Username")
            let config: TextField.Config = { textField in
                textField.becomeFirstResponder()
                textField.textColor = .black
                textField.placeholder = "Insert your username "
                textField.left(image: UIImage(named:"user"), color: .black)
                textField.leftViewPadding = 12
                textField.borderWidth = 1
                textField.cornerRadius = 8
                textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
                textField.autocorrectionType = .no
                textField.backgroundColor = nil
                textField.keyboardAppearance = .default
                textField.keyboardType = .default
                textField.returnKeyType = .done
                textField.action { textField in
                    // validation and so on
                }
                textField.delegate = self
                textField.tag = 1
            }
            alert.addOneTextField(configuration: config)
            alert.addAction(title: "OK", style: .cancel)
            alert.show()
        }else{
            self.usrnameLbl.text = "Welcome back \(username)"
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason){
        if(textField.tag == 1){
            print(textField.text!)
            usrnameLbl.text = "Welcome \(textField.text!)"
            username = textField.text!
            UserDefaults.standard.set(username, forKey: "username")
            checkPermission()
        }else{
            descriptionText.text = "\(textField.text!)"
            descriptionText.textColor = UIColor.black
        }
    }
}

