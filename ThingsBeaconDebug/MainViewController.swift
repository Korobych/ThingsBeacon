//
//  ViewController.swift
//  ThingsBeaconDebug
//
//  Created by Sergey Korobin on 12.05.2018.
//  Copyright © 2018 SergeyKorobin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var broadcastButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        broadcastButton.layer.cornerRadius = broadcastButton.frame.width / 1.75
        broadcastButton.clipsToBounds = true
        // Do any additional setup after loading the view, typically from a nib.
    }

}

