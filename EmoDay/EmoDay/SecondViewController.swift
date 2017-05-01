//
//  SecondViewController.swift
//  EmoDay
//
//  Created by Sai Prasanna on 29/04/17.
//  Copyright © 2017 Sai Prasanna. All rights reserved.
//

import UIKit
import Pantry

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView()
    var records = [Record]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = CGRect(x: 0, y: 55, width: view.bounds.width, height: view.bounds.height-55)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.tableFooterView = UIView()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view, typically from a nib.
        if let records:[Record] = Pantry.unpack("records") {
            self.records = records
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        let record = records[indexPath.row]
        
        
        let timestamp = DateFormatter.localizedString(from: record.date as Date, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)

        
        cell.date.text = record.date.description
        let angle =  CGFloat(M_PI_2)
        let tr = CGAffineTransform.identity.rotated(by: angle)
        cell.imageView1.transform = tr
        
        cell.imageView1.image = UIImage(data: record.data as Data)!
        cell.imageView1.contentMode = .scaleAspectFit
        cell.textLabel1.text = record.text
        cell.imageticon.text = record.photoEmotion.emoticon
        cell.textoticon.text = record.textEmotion.emoticon
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}

class CustomCell: UITableViewCell {
    
    let imageView1 = UIImageView()
    let textLabel1 = UILabel()
    let imageticon = UILabel()
    let textoticon = UILabel()
    let date = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imageView1)
        contentView.addSubview(date)
        contentView.addSubview(textLabel1)
        contentView.addSubview(imageticon)
        contentView.addSubview(textoticon)
        textLabel1.textAlignment = .right
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        date.frame = CGRect(x: contentView.bounds.width-300, y: 0, width: 300, height: 15)
        imageView1.frame = CGRect(x: 10, y: 20, width: 80, height: 80)
        textLabel1.frame = CGRect(x: 100, y: 40, width: contentView.bounds.width - 130, height: 70)
        imageticon.frame = CGRect(x: 30, y: 80, width: 80, height: 80)
        textoticon.frame = CGRect(x: contentView.bounds.width - 50, y: 80, width: 30, height: 80)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
