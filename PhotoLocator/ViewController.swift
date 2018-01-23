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

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var username = ""
    @IBOutlet weak var usrnameLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var coordsLbl: UILabel!
    
    let locationManager = CLLocationManager()
    

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

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        coordsLbl.text = "@\nLAT: \(locValue.latitude)\nLNG: \(locValue.longitude)"
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.locationManager.stopUpdatingLocation()
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
            }
            alert.addOneTextField(configuration: config)
            alert.addAction(title: "OK", style: .cancel)
            alert.show()
        }else{
            self.usrnameLbl.text = "Welcome back \(username)"
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason){
        print(textField.text!)
        usrnameLbl.text = "Welcome \(textField.text!)"
        username = textField.text!
        UserDefaults.standard.set(username, forKey: "username")
        checkPermission()
    }
}

