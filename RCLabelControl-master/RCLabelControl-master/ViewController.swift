//
//  ViewController.swift
//  RCLabelControl-master
//
//  Created by Developer on 2016/12/22.
//  Copyright © 2016年 Beijing Haitao International Travel Service Co., Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let rect = CGRect(x: 0, y: 100, width: 320, height: 40)
        let c = RCLabelControlBar(frame: rect)
        c.itemColor = .red
        c.itemSelectedColor = .blue
        c.isWidthEqualy = true
        c.itemTitles = ["AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "GGGG", "HHHH", "JJJJ"]
        view.addSubview(c)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

