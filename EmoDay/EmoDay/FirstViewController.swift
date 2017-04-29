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

class FirstViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {
    
    let doneButton = UIButton()
    let clearButton = UIButton()
    let imageView = UIImageView()
    var currentImage: UIImage?

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
        doneButton.frame = CGRect(x: view.bounds.width/2 - 80, y: view.bounds.height-140, width: 80, height: 80)
        clearButton.frame = CGRect(x: view.bounds.width/2, y: view.bounds.height-140, width: 80, height: 80)
        
        view.addSubview(doneButton)
        view.addSubview(clearButton)
        currentImage = photo
    }
    
    func done() {
        if let currentImage = self.currentImage,
           let imageData = UIImagePNGRepresentation(currentImage) {
            Alamofire.upload(imageData, to: "http://192.168.1.11:8000").response {
                response in
                print(response.data)
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

