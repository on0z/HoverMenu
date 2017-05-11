//
//  HoverMenuControllerViewController.swift
//  HoverMenu
//
//  Created by on0z on 2017/05/01.
//  Copyright © 2017年 on0z. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
public class HoverMenuController: UIViewController {
    
    private var stackView: UIStackView?
    public var buttons = [HoverMenuButton]()
    
    public var axis: UILayoutConstraintAxis = .horizontal
    public var judgeSide_horizontal: judgeSide_horizontal = .both
    public var judgeSide_vertical: judgeSide_vertical = .both
    
    private var hoverButton: HoverMenuButton?
    
    private var width: Int {
        get{
            if self.axis == .horizontal{
                var rtn = 10;
                self.buttons.forEach({
                    rtn += Int($0.frame.size.width)
                })
                rtn += 4 * self.buttons.count
                return rtn
            }else{
                let rtn = 60;
                let tmp = Int(self.buttons.map{$0.frame.size.width}.max() ?? 50) + 10
                return rtn > tmp ? rtn : tmp
            }
        }
    }
    private var height: Int {
        get{
            if axis == .horizontal{
                let rtn = 40;
                let tmp = Int(self.buttons.map{$0.frame.size.height}.max() ?? 30) + 10
                return rtn > tmp ? rtn : tmp
            }else{
                var rtn = 10;
                self.buttons.forEach({
                    rtn += Int($0.frame.size.height)
                })
                rtn += 4 * self.buttons.count
                return rtn
            }
        }
    }
    
    public enum judgeSide_horizontal{
        case both
        case up
        case down
    }
    
    public enum judgeSide_vertical{
        case both
        case left
        case right
    }
    
/** HoverMenuを作成する
    
     HoverMenuのオプション
     - buttons: ボタン
     - axis: ボタンを並べる軸
     - judgeSide_...: 反応の域(軸に応じてそれぞれ1つずつ)
     
 - Parameters:
     - buttons: ボタンを指定
     - direction: Popoverの矢の向きを指定
     - delegate: delegateを指定してください
 
 */
    public init(buttons: [HoverMenuButton], direction: HoverMenuPopoverArrowDirection, delegate: HoverMenuDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .popover
        self.buttons = buttons
        self.popoverPresentationController?.permittedArrowDirections = direction.getDirection()
        self.popoverPresentationController?.delegate = delegate
        self.judgeSide_horizontal = [.down, .up, .both, .both][direction.rawValue]
        self.judgeSide_vertical = [.both, .both, .right, .left][direction.rawValue]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Popoverの設定です。
    public func setSource(rect: CGRect, view: UIView){
        self.popoverPresentationController?.sourceRect = rect
        self.popoverPresentationController?.sourceView = view
    }
    
    /// Popoverの設定です。
    public func setSource(barButton: UIBarButtonItem){
        self.popoverPresentationController?.barButtonItem = barButton
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.frame.size = CGSize(width: self.width, height: self.height)
        self.preferredContentSize = self.view.frame.size
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        self.stackView = UIStackView(frame: CGRect.zero/*CGRect(x: 5, y: 7, width: 52*(self.buttons?.count ?? 0), height: 30)*/)
        guard let stackView = self.stackView else { return }
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        self.view.centerXAnchor.constraint(equalTo: stackView.centerXAnchor).isActive = true
        self.view.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -5).isActive = true
//        self.view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 5).isActive = true
        self.view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -5).isActive = true
//        self.view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 5).isActive = true
        
        self.stackView?.axis = self.axis//.horizontal
        self.stackView?.alignment = .center
        self.stackView?.distribution = .equalSpacing
        self.stackView?.backgroundColor = UIColor.yellow
        
        for b in buttons{
            b.superVC = self
            self.stackView?.addArrangedSubview(b)
        }
    }
    
    private func hoverAction_horizontal(gesture: HoverGestureRecognizer){
        if gesture.moving.x || gesture.moving.y{
            
            if self.judgeSide_horizontal != .both{
                if self.judgeSide_horizontal == .down{
                    if gesture.location(in: self.view).y <= 0{
                        self.hoverButton?.alpha = 1.0
                        self.hoverButton?.isHovered = false
                        self.hoverButton = nil
                        return
                    }
                }else if self.judgeSide_horizontal == .up{
                    if gesture.location(in: self.view).y >= self.view.frame.height{
                        self.hoverButton?.alpha = 1.0
                        self.hoverButton?.isHovered = false
                        self.hoverButton = nil
                        return
                    }
                }
            }
            for b in self.buttons{
                if b.frame.origin.x <= gesture.location(in: self.stackView).x && gesture.location(in: self.stackView).x <= b.frame.origin.x + b.frame.size.width{
                    if b !== hoverButton{
                        self.hoverButton?.alpha = 1.0
                        self.hoverButton?.isHovered = false
                        self.hoverButton = b
                        b.alpha = 0.6
                        self.hoverButton?.isHovered = true
                        if #available(iOS 10.0, *) {
                            let generator = UISelectionFeedbackGenerator()
                            generator.prepare()
                            generator.selectionChanged()
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    return
                }
            }
            self.hoverButton?.alpha = 1.0
            self.hoverButton?.isHovered = false
            self.hoverButton = nil
        }
        if gesture.state == .ended{
            
            guard let point = gesture.firstPoint else { self.dismiss(animated: true, completion: nil); return }
            let difference_x = gesture.location(in: gesture.view).x - point.x
            let difference_y = gesture.location(in: gesture.view).y - point.y
            if (-10 <= difference_x && difference_x <= 10) && (-10 <= difference_y && difference_y <= 10){
                return
            }
            self.dismiss(animated: true, completion: nil)
            guard let button = self.hoverButton else{ return }
            button.handler?(button, gesture)
        }
    }

    private func hoverAction_vertical(gesture: HoverGestureRecognizer){
        if gesture.moving.x || gesture.moving.y{
            
            if self.judgeSide_vertical != .both{
                if self.judgeSide_vertical == .right{
                    if gesture.location(in: self.view).x <= 0{
                        self.hoverButton?.alpha = 1.0
                        self.hoverButton?.isHovered = false
                        self.hoverButton = nil
                        return
                    }
                }else if self.judgeSide_vertical == .left{
                    if gesture.location(in: self.view).x >= self.view.frame.width{
                        self.hoverButton?.alpha = 1.0
                        self.hoverButton?.isHovered = false
                        self.hoverButton = nil
                        return
                    }
                }
            }
            for b in self.buttons{
                if b.frame.origin.y <= gesture.location(in: self.stackView).y && gesture.location(in: self.stackView).y <= b.frame.origin.y + b.frame.size.height{
                    if b !== hoverButton{
                        self.hoverButton?.alpha = 1.0
                        self.hoverButton?.isHovered = false
                        self.hoverButton = b
                        b.alpha = 0.6
                        self.hoverButton?.isHovered = true
                        if #available(iOS 10.0, *) {
                            let generator = UISelectionFeedbackGenerator()
                            generator.prepare()
                            generator.selectionChanged()
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    return
                }
            }
            self.hoverButton?.alpha = 1.0
            self.hoverButton?.isHovered = false
            self.hoverButton = nil
        }
        if gesture.state == .ended{
            
            guard let point = gesture.firstPoint else { self.dismiss(animated: true, completion: nil); return }
            let difference_x = gesture.location(in: gesture.view).x - point.x
            let difference_y = gesture.location(in: gesture.view).y - point.y
            if (-10 <= difference_x && difference_x <= 10) && (-10 <= difference_y && difference_y <= 10){
                return
            }
            self.dismiss(animated: true, completion: nil)
            guard let button = self.hoverButton else{ return }
            button.handler?(button, gesture)
            
        }
    }
    
    public func hoverAction(gesture: HoverGestureRecognizer){
        if self.axis == .horizontal{
            hoverAction_horizontal(gesture: gesture)
        }else if self.axis == .vertical{
            hoverAction_vertical(gesture: gesture)
        }
    }

}

public protocol HoverMenuDelegate: UIPopoverPresentationControllerDelegate{
    /// HoverMenuではUIModalPresentationStyle.noneを返してください。
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
}

public enum HoverMenuPopoverArrowDirection: Int{
    case up = 0
    case down = 1
    case left = 2
    case right = 3
    
    func getDirection() -> UIPopoverArrowDirection{
        switch self{
        case .up:
            return UIPopoverArrowDirection.up
        case .down:
            return UIPopoverArrowDirection.down
        case .left:
            return UIPopoverArrowDirection.left
        case .right:
            return UIPopoverArrowDirection.right
        }
    }
}
