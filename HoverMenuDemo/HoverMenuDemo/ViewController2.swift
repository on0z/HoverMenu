//
//  ViewController2.swift
//  HoverMenuDemo
//
//  Created by on0z on 2017/07/16.
//  Copyright © 2017年 on0z. All rights reserved.
//

import UIKit
import HoverMenu

class ViewController2: UIViewController {
    var menu: HoverMenuController?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var button: UIView!
    
    let hvSeg = UISegmentedControl(items: ["horizontal", "vertical"])
    let dirSeg = UISegmentedControl(items: ["up", "down", "left", "right"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hvSeg.selectedSegmentIndex = 0
        dirSeg.selectedSegmentIndex = 0
        
        self.stackView.addArrangedSubview(hvSeg)
        self.stackView.addArrangedSubview(dirSeg)
        self.view.addSubview(self.stackView)
        
        self.menu = {
            //ボタンを作成
            let button1 = HoverMenuButton(size: (50,30),
                                          setView: { $0.backgroundColor = UIColor.red },
                                          handler: {_,_ in print("didTap Red!")})
            let button2 = HoverMenuButton(//size: (50,30),
                                          setView: {
                                            let label = { () -> UILabel in
                                                let l = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
                                                l.text = "ボタン2"
                                                l.textColor = UIColor.white
                                                l.sizeToFit()
                                                return l
                                            }()
                                            $0.backgroundColor = UIColor.blue
                                            $0.addSubview(label)
                                            $0.setSize(width: label.frame.size.width, height: 30) // You can also set the size within the setView parameter. (But deprecated)
                                            label.center = $0.center
            },
                                          handler: {_,_ in print("didTap Blue!")})
            //メニューを作成
            let menu = HoverMenuController(target: self, buttons: [button1, button2], delegate: self)
            
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

extension ViewController2: HoverMenuDelegate{
    //必須
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if controller.presentedViewController is HoverMenuController{
            //HoverMenuでは必ずnoneを返してください。iPhoneでもpopover表示をするためです。
            return .none
        }
        return controller.presentedViewController.modalPresentationStyle
    }

    func hoverMenu(_ hoverMenu: HoverMenuController, willPresentBy gesture: HoverGestureRecognizer) {
        //方向を指定
        hoverMenu.direction = HoverMenuPopoverArrowDirection(rawValue: self.dirSeg.selectedSegmentIndex)!
        //軸を指定
        hoverMenu.axis = UILayoutConstraintAxis(rawValue: self.hvSeg.selectedSegmentIndex)!
        //popover用sourceRect, sourceViewを指定
        hoverMenu.sourceRectView = (rect: CGRect(origin: gesture.location(in: self.view), size: CGSize.zero), view: self.view)
    }
}
