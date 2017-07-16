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
    
    @IBOutlet weak var stackView: UIStackView!
    
    let hvSeg = UISegmentedControl(items: ["horizontal", "vertical"])
    let dirSeg = UISegmentedControl(items: ["up", "down", "left", "right"])
    let genButton = UIButton(type: UIButtonType.system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hvSeg.selectedSegmentIndex = 0
        dirSeg.selectedSegmentIndex = 0
        genButton.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        genButton.setTitle("Generate", for: .normal)
        genButton.addTarget(self, action: #selector(self.generate), for: .touchUpInside)
        
        self.stackView.addArrangedSubview(hvSeg)
        self.stackView.addArrangedSubview(dirSeg)
        self.stackView.addArrangedSubview(genButton)
        self.view.addSubview(self.stackView)
    }
    
    func generate(){
        let secondView = self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        
        //ボタンを作成
        let button1 = HoverMenuButton(size: (50, 30),
                                      setView: {$0.backgroundColor = UIColor.red},
                                      handler: {_,_ in print("didTap Red!")})
        let button2 = HoverMenuButton(size: (50, 30),
                                      setView: {$0.backgroundColor = UIColor.blue},
                                      handler: {_,_ in print("didTap Blue!")})
        //メニューを作成
        let menu = HoverMenuController(target: secondView, buttons: [button1, button2], delegate: secondView)
        //方向を指定
        menu.direction = HoverMenuPopoverArrowDirection(rawValue: self.dirSeg.selectedSegmentIndex)!
        //軸を指定
        menu.axis = UILayoutConstraintAxis(rawValue: self.hvSeg.selectedSegmentIndex)!
        
        secondView.menu = menu
        self.navigationController?.pushViewController(secondView, animated: true)
    }
}

class SecondViewController: UIViewController{
    var menu: HoverMenuController?
    
    @IBOutlet weak var button: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ボタンにジェスチャを設定
        let gesture = HoverGestureRecognizer(target: menu!)
        button.addGestureRecognizer(gesture)
    }
}

extension SecondViewController: HoverMenuDelegate{
    //必須
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if controller.presentedViewController is HoverMenuController{
            //HoverMenuでは必ずnoneを返してください。iPhoneでもpopover表示をするためです。
            return .none
        }
        return controller.presentedViewController.modalPresentationStyle
    }
    
    func hoverMenu(_ hoverMenu: HoverMenuController, willPresentBy gesture: HoverGestureRecognizer) {
        hoverMenu.setSource(rect: CGRect(origin: gesture.location(in: self.view), size: CGSize.zero), view: self.view)
    }
}
