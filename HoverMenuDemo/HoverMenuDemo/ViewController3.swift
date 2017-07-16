//
//  ThirdViewController.swift
//  HoverMenuDemo
//
//  Created by on0z on 2017/07/16.
//  Copyright © 2017年 on0z. All rights reserved.
//

import UIKit
import HoverMenu

class ViewController3: UIViewController {
    var menu: HoverMenuController?
    
    @IBOutlet weak var button: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.menu = {
            //ボタンを作成
            let button1 = HoverMenuButton(size: (50, 30),
                                          setView: {$0.backgroundColor = UIColor.red},
                                          handler: {_,_ in print("didTap Red!")})
            let button2 = HoverMenuButton(size: (50, 30),
                                          setView: {$0.backgroundColor = UIColor.blue},
                                          handler: {_,_ in print("didTap Blue!")})
            //メニューを作成
            let menu = HoverMenuController(target: self, buttons: [button1, button2], delegate: nil)
            //方向を指定
            menu.direction = .up
            //軸を指定
            menu.axis = .horizontal
            //popover用sourceRect, sourceViewを指定
            menu.sourceRectView = (rect: CGRect(origin: self.view.center, size: CGSize.zero),
                                   view: self.view)
            
            return menu
        }()
        
        //ボタンにジェスチャを設定
        let gesture = HoverGestureRecognizer(target: menu!)
        button.addGestureRecognizer(gesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

