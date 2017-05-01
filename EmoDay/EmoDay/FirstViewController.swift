//
//  FirstViewController.swift
//  EmoDay
//
//  Created by Sai Prasanna on 29/04/17.
//  Copyright © 2017 Sai Prasanna. All rights reserved.
//

import UIKit
import SwiftyCam
import Alamofire
import SwiftMessages

class FirstViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {
    
    let doneButton = UIButton()
    let clearButton = UIButton()
    let imageView = UIImageView()
    var currentImage: UIImage?
    let loadinIndicatorBackground = UIView()
    let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    override func viewDidLoad() {
        
        super.viewDidLoad()
        cameraDelegate = self
        defaultCamera = .front
        
        let button = SwiftyCamButton(frame: CGRect(x: view.bounds.width/2-40, y: view.bounds.height-140, width: 80, height: 80))
        button.delegate = self
        view.addSubview(button)
        button.setTitle("O", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 50)
        button.autoresizingMask = [.flexibleTopMargin]

        doneButton.setTitle("✓", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 50)
        doneButton.autoresizingMask = [.flexibleTopMargin]
        doneButton.addTarget(self, action: #selector(FirstViewController.done), for: .touchDown)

        
        clearButton.setTitle("x", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 50)
        clearButton.addTarget(self, action: #selector(FirstViewController.clear), for: .touchDown)
        clearButton.autoresizingMask = [.flexibleTopMargin]
        
        loadinIndicatorBackground.frame = view.bounds
        loadinIndicatorBackground.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        loadingIndicator.frame = CGRect(x: view.frame.width/2 - 22, y: view.frame.height/2 - 22, width: 44, height: 44)
        loadinIndicatorBackground.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        imageView.frame = view.frame
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.image = photo
        view.addSubview(imageView)
        doneButton.frame = CGRect(x: view.bounds.width/2, y: view.bounds.height-140, width: 80, height: 80)
        clearButton.frame = CGRect(x: view.bounds.width/2 - 80, y: view.bounds.height-140, width: 80, height: 80)

        
        view.addSubview(doneButton)
        view.addSubview(clearButton)
        currentImage = photo
    }
    
    func done() {
        if let currentImage = self.currentImage,
           let imageData = UIImagePNGRepresentation(currentImage) {
            
            view.addSubview(loadinIndicatorBackground)
            
            Alamofire.upload(imageData, to: "http://192.168.43.154:8080").responseString {
                response in
                
                self.loadinIndicatorBackground.removeFromSuperview()
                
                switch(response.result) {
                case .success(let emotion):
                    let piped = emotion.components(separatedBy: "|")
                    if piped.count >= 2 {
                        let emotionText = piped[1]
                        let iEmotion = convert(message: emotionText)
                        let submitVc = SubmitViewController(nibName: nil, bundle: nil)
                        submitVc.image = currentImage
                        submitVc.imageEmotion = iEmotion
                        let nav = UINavigationController(rootViewController: submitVc)
                        nav.navigationBar.backgroundColor = UIColor.purple
                        self.clear()
                        self.present(nav, animated: true, completion: nil)
                    } else {
                        let view = MessageView.viewFromNib(layout: .MessageView)
                        view.configureTheme(.error)
                        view.button?.isHidden = true
                        view.configureDropShadow()
                        view.configureContent(title: "Error", body: "Unable to detect face!", iconText: "")
                        SwiftMessages.show(view: view)
                    }
                
                case .failure(let error):
                    let view = MessageView.viewFromNib(layout: .MessageView)
                    view.configureTheme(.error)
                    view.button?.isHidden = true
                    view.configureDropShadow()
                    view.configureContent(title: "Error", body: error.localizedDescription, iconText: "")
                    SwiftMessages.show(view: view)
                }
            }
        }
    }
    
    func clear() {
        currentImage = nil
        doneButton.removeFromSuperview()
        clearButton.removeFromSuperview()
        imageView.removeFromSuperview()
    }
}

