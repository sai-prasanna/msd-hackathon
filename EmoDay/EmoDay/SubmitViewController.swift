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
import Pantry


struct Record: Storable {
    let photoEmotion: Emotion
    let textEmotion: Emotion
    let data: NSData
    let date: NSDate
    let text: String
    
    init (photoEmotion: Emotion, textEmotion: Emotion, data: NSData, date: NSDate, text: String) {
        self.photoEmotion = photoEmotion
        self.textEmotion = textEmotion
        self.data = data
        self.date = date
        self.text = text
    }
    
    init(warehouse record: Warehouseable) {
        self.photoEmotion = Emotion(rawValue: record.get("pemotion")!)!
        self.textEmotion = Emotion(rawValue: record.get("temotion")!)!

        let bas64String: String = record.get("data") ?? ""
        let decodedData = NSData(base64Encoded: bas64String, options: NSData.Base64DecodingOptions(rawValue: 0))

        self.data = decodedData!
        self.date = NSDate(timeIntervalSince1970: record.get("date")!)
        self.text = record.get("text") ?? ""
        
    }
    
    func toDictionary() -> [String : Any] {
        
        let dataString = data.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        return [
            "pemotion": photoEmotion.rawValue,
            "temotion": textEmotion.rawValue,
            "data": dataString,
            "date": self.date.timeIntervalSince1970,
            "text": self.text
        ]
    }

}

enum Emotion: Int {
    case  sad, happy, anger
    var message :String {
        switch(self) {
        case .happy:
            return "You Look 😀, how was your day?"
        case .sad:
            return "You Look ☹️, how was your day?"
        case .anger:
            return "You look 😡, how was you day?"
        }
    
    }
    var textEmote :String {
        switch(self) {
        case .happy:
            return "Hey! you sound happy, Have a nice day"
        case .sad:
            return "This too shall pass. Be Happy :)"
        case .anger:
            return "Take a chill pill for your anger."
        }
        
    }
    
    var emoticon :String {
        switch(self) {
        case .happy:
            return "😀"
        case .sad:
            return "☹️"
        case .anger:
            return "😡"
        }
    }
}

class SubmitViewController: UIViewController {
    
    var image: UIImage!
    var imageEmotion: Emotion!
    var textView: UITextView!
    let saveButton = UIButton()
    let loader = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log your Day!"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "<", style: .done, target: self, action: #selector(SubmitViewController.done))
        
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.white
        
        let imageView = UIImageView(frame: CGRect(x: 5, y: 70, width: 100, height: 100))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        let label = UILabel(frame: CGRect(x: 110, y: 100, width: view.bounds.width-100, height: 50))
        label.text = imageEmotion.message
        label.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(label)
        
        textView = UITextView(frame: CGRect(x: 5, y: 185, width: view.bounds.width-10, height: 100))
        textView.layer.cornerRadius = 5
        textView.layer.borderColor = UIColor.purple.cgColor
        textView.layer.borderWidth = 1
        view.addSubview(textView)
        
        textView.backgroundColor = UIColor.white
        saveButton.frame = CGRect(x: 5, y: 300, width: view.bounds.width-20, height: 55)
        saveButton.setTitle("Save", for: .normal)
        view.addSubview(saveButton)
        
        saveButton.setTitleColor(UIColor.purple, for: .normal)
        saveButton.addTarget(self, action: #selector(SubmitViewController.submit), for: .touchUpInside)
        
        loader.frame = CGRect(x: view.bounds.width/2, y: 320, width: 44, height: 44)
        loader.color = UIColor.purple
        loader.startAnimating()
        
    }
    
    func done() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func submit() {
        let textData = textView.text.data(using: String.Encoding.utf8)!
        
        saveButton.removeFromSuperview()
        view.addSubview(loader)
        
        Alamofire.upload(textData, to: "http://192.168.43.244:8080").responseString {
            response in
           
            self.loader.removeFromSuperview()
            self.view.addSubview(self.saveButton)
            
            switch(response.result) {
            case .success(let textEmotion):
                let piped = textEmotion.components(separatedBy: "|")
                if piped.count == 3 {
                    
                    let emotionText = piped[1]
                    let tEmotion = convert1(message: emotionText)
                    
                    //let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
                    
                    let now: NSDate! = NSDate()
                    
                    if let records:[Record] = Pantry.unpack("records") {
                        let record = Record(photoEmotion: self.imageEmotion,textEmotion: tEmotion, data: UIImagePNGRepresentation(self.image)! as NSData, date: now, text: self.textView.text)
                        
                        var updatedRecords: [Record] = []
                        
                        updatedRecords.append(contentsOf: records)
                        updatedRecords.append(record)
                        
                        Pantry.pack(updatedRecords, key: "records")
                    } else {
                        let record = Record(photoEmotion: self.imageEmotion,textEmotion: tEmotion, data: UIImagePNGRepresentation(self.image)! as NSData, date: now, text: self.textView.text)
                        Pantry.pack([record], key: "records")
                    }
                    
                    // Show the message.
                    self.presentingViewController?.dismiss(animated: true, completion: {
                        let view = MessageView.viewFromNib(layout: .MessageView)
                        view.configureTheme(.success)
                        view.configureDropShadow()
                        view.button?.isHidden = true
                        view.configureContent(title: tEmotion.textEmote, body: "", iconText: "")
                        var config = SwiftMessages.Config()
                        // Disable the default auto-hiding behavior.
                        config.duration = .forever
                        
                        // Dim the background like a popover view. Hide when the background is tapped.
                        config.dimMode = .gray(interactive: true)
                        SwiftMessages.show(config: config, view: view)
                        
                    })
                } else {
                    let view = MessageView.viewFromNib(layout: .MessageView)
                    view.configureTheme(.error)
                    view.button?.isHidden = true
                    view.configureDropShadow()
                    view.configureContent(title: "Error", body: "Unable to analyze text!", iconText: "")
                   
                    SwiftMessages.show(view: view)
                }
                
            case .failure(let error):
                let view = MessageView.viewFromNib(layout: .MessageView)
                view.configureTheme(.error)
                view.button?.isHidden = true
                view.configureDropShadow()
                
                view.configureContent(title: "Error", body: error.localizedDescription, iconText: "")

            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}




func convert(message: String) -> Emotion {
    let msg = message.lowercased()
    switch (msg) {

        case "happy":
            return .happy
        case "sad":
            return .sad
        case "angry":
            return .anger
        default:
            return .happy
    }
}

func convert1(message: String) -> Emotion {
    let msg = message.lowercased()
    switch (msg) {
    case "happy", "surprised", "neutral":
        return .happy
    case "sad", "fear":
        return .sad
    case "anger", "disgust":
        return .anger
    default:
        return .happy
    }
}
