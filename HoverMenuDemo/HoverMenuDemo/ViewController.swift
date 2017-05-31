//
//  ViewController.swift
//  HoverMenuSample
//
//  Created by on0z on 2017/05/01.
//  Copyright © 2017年 on0z. All rights reserved.
//

import UIKit
import HoverMenu

class ViewController: UIViewController{
    
    //変数を作成
    var menu: HoverMenuController?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var button: UIView!
    let hvSeg = UISegmentedControl(items: ["horizontal", "vertical"])
    let dirSeg = UISegmentedControl(items: ["up", "down", "left", "right"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //menuを出すボタンを作成
        button.backgroundColor = UIColor.black
        //ボタンにジェスチャを設定
        let gesture = HoverGestureRecognizer(target: self, action: #selector(self.hover(gesture:)))
        button.addGestureRecognizer(gesture)
        self.view.addSubview(button)
        
        hvSeg.selectedSegmentIndex = 0
        dirSeg.selectedSegmentIndex = 0
        
        self.stackView.addArrangedSubview(hvSeg)
        self.stackView.addArrangedSubview(dirSeg)
        self.view.addSubview(self.stackView)
    }
    
    // この関数内で必ずHoverMenuControllerのhoverAction(gesture:)メソッドを呼び出すこと。
    func hover(gesture: HoverGestureRecognizer){
        // 必ず state == .began の時に表示すること。
        if gesture.state == .began{
            //メニュー内のボタンを設定
            let button1 = HoverMenuButton(size: (50, 30),
                                          setView: {$0.backgroundColor = UIColor.red},
                                          handler: {_,_ in print("didTap Red!")})
            
            let button2 = HoverMenuButton(size: (50, 30),
                                          setView: {$0.backgroundColor = UIColor.blue},
                                          handler: {_,_ in print("didTap Blue!")})
            let direction: HoverMenuPopoverArrowDirection = HoverMenuPopoverArrowDirection(rawValue: dirSeg.selectedSegmentIndex)!
            self.menu = HoverMenuController(buttons: [button1, button2], direction: direction, delegate: self)
            menu?.setSource(rect: CGRect(origin: gesture.location(in: self.view), size: CGSize.zero), view: self.view)
            menu?.axis = UILayoutConstraintAxis(rawValue: hvSeg.selectedSegmentIndex)!
            
            self.present(menu!, animated: true, completion: nil)
        }
        if let menu = self.menu{
            //↓必ず呼び出してください
            menu.hoverAction(gesture: gesture)
        }
    }
}

//必須
extension ViewController: HoverMenuDelegate{
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if controller.presentedViewController is HoverMenuController{
            //HoverMenuでは必ずnoneを返してください。iPhoneでもpopover表示をするためです。
            return .none
        }
        return controller.presentedViewController.modalPresentationStyle
    }
}
