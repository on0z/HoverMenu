//
//  ViewController4.swift
//  HoverMenuDemo
//
//  Created by on0z on 2017/07/18.
//  Copyright © 2017年 on0z. All rights reserved.
//

import UIKit
import HoverMenu

class ViewController4: UIViewController {
    
    var menu: HoverMenuController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.menu = {
            var buttons = [HoverMenuButton]()
            for i in 0..<5{
                buttons.append(
                    HoverMenuButton(size: (100, 30),
                                    setView: {
                                        let label: UILabel = { (superview: HoverMenuButton) -> UILabel in
                                            let l = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
                                            l.text = "button\(i)"
                                            l.textAlignment = .center
                                            l.center = superview.center
                                            return l
                                        }($0)
                                        $0.addSubview(label)
                                    },
                                    handler: {_,_ in print("Taped \(i)!") })
                )
            }
            let _menu = HoverMenuController(target: self, buttons: buttons, delegate: nil)
            _menu.axis = .vertical
            return _menu
        }()
        
        let barButton: UIBarButtonItem = {
            let label: UILabel = {
                let l = UILabel(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                l.text = "ボタン"
                l.sizeToFit()
                return l
            }()
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            view.backgroundColor = UIColor.clear
            view.frame.size.width = label.frame.size.width
            view.addSubview(label)
            label.center = view.center
            
            let gesture = HoverGestureRecognizer(target: menu)
            view.addGestureRecognizer(gesture)
            return UIBarButtonItem(customView: view)
        }()
        
        self.menu.sourceBarButton = barButton
        
        self.navigationItem.rightBarButtonItem = barButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
