//
//  ViewController.swift
//  JT3DModel
//
//  Created by 谭振杰 on 2017/9/21.
//  Copyright © 2017年 谭振杰. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cubeFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        let cubeView = JT3DModel.cube3D(with: cubeFrame, side: 100, autoAnimate: false)
        self.view.addSubview(cubeView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

