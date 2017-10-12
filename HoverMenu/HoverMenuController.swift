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
    
    public weak var target: UIViewController?
    public weak var delegate: HoverMenuDelegate?
    lazy var defaultDelegate = DefaultHoverMenuDelegate()
    
    private var stackView: UIStackView?
    public var buttons = [HoverMenuButton](){
        willSet{
            if !isViewLoaded{ return }
            guard let bs = self.stackView?.arrangedSubviews.reversed() else {
                return
            }
            for b in bs{
                self.stackView?.removeArrangedSubview(b)
                b.removeFromSuperview()
            }
        }
        didSet{
            if !isViewLoaded{ return }
            self.view.frame.size = CGSize(width: self.width, height: self.height)
            self.preferredContentSize = self.view.frame.size
            
            for b in buttons{
                b.superVC = self
                self.stackView?.addArrangedSubview(b)
            }
        }
    }
    
    /// 表示の軸。default: .horizontal
    public var axis: UILayoutConstraintAxis = .horizontal {
        didSet{
            if oldValue == axis { return }
            if !isViewLoaded{ return }
            self.stackView?.axis = self.axis
            self.view.frame.size = CGSize(width: self.width, height: self.height)
            self.preferredContentSize = self.view.frame.size
        }
    }
    
    /// 矢印の方向 default: .up
    public var direction: HoverMenuPopoverArrowDirection = .up{
        didSet{
            if !isViewLoaded{ return }
            self.popoverPresentationController?.permittedArrowDirections = direction.getDirection()
            self.judgeSide_horizontal = [.down, .up, .both, .both][direction.rawValue]
            self.judgeSide_vertical = [.both, .both, .right, .left][direction.rawValue]
        }
    }
    
    /// 水平表示時の判定域
    public var judgeSide_horizontal: judgeSide_horizontal = .both
    
    /// 垂直表示時の判定域
    public var judgeSide_vertical: judgeSide_vertical = .both
    
    private var hoverButton: HoverMenuButton?
    
    private var presentSource: presentSource = .unknown
    
    /// Popoverの設定です。
    public var sourceRectView: (rect: CGRect, view: UIView)? {
        didSet{
            self.presentSource = .view
        }
    }
    
    /// Popoverの設定です。
    public var sourceBarButton: UIBarButtonItem? {
        didSet{
            self.presentSource = .barButton
        }
    }
    
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
    
    private enum presentSource{
        case view
        case barButton
        case unknown
    }
    
/** HoverMenuを作成する
    
 HoverMenuのオプション
    - buttons: ボタン
    - direction: 矢印の向き default: .up
    - axis: ボタンを並べる軸 default: .horizontal
    - judgeSide_...: 反応の域(axisに応じてそれぞれ1つずつ)
     
 - Parameters:
     - target: menuを表示するViewController
     - buttons: ボタンを指定
     - delegate: delegateを指定
 
 */
    public init(target: UIViewController?, buttons: [HoverMenuButton], delegate: HoverMenuDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.target = target
        self.buttons = buttons
        self.delegate = delegate ?? defaultDelegate
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        self.judgeSide_horizontal = [.down, .up, .both, .both][direction.rawValue]
        self.judgeSide_vertical = [.both, .both, .right, .left][direction.rawValue]
    }
    
    func releaseHover(){
        self.hoverButton?.alpha = 1.0
        self.hoverButton?.isHovered = false
        self.hoverButton = nil
    }
    
    private func hoverAction_horizontal(gesture: HoverGestureRecognizer){
        if gesture.moving.x || gesture.moving.y{
            
            if self.judgeSide_horizontal != .both{
                if self.judgeSide_horizontal == .down{
                    if gesture.location(in: self.view).y <= 0{
                        releaseHover()
                        return
                    }
                }
                else if self.judgeSide_horizontal == .up{
                    if gesture.location(in: self.view).y >= self.view.frame.height{
                        releaseHover()
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
            releaseHover()
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
                }
                else if self.judgeSide_vertical == .left{
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
            releaseHover()
        }
    }
    
    @objc func hoverAction(gesture: HoverGestureRecognizer){
        if gesture.state == .cancelled || gesture.state == .failed{
//            self.dismiss(animated: true, completion: nil)
            releaseHover()
            return
        }
        if gesture.state == .began{
            self.modalPresentationStyle = .popover
            self.popoverPresentationController?.delegate = delegate
            self.popoverPresentationController?.permittedArrowDirections = direction.getDirection()
            self.delegate?.hoverMenu(self, willPresentBy: gesture)
            
            switch self.presentSource{
            case .view:
                self.popoverPresentationController?.sourceRect = sourceRectView!.rect
                self.popoverPresentationController?.sourceView = sourceRectView!.view
            case .barButton:
                self.popoverPresentationController?.barButtonItem = sourceBarButton!
            case .unknown:
                fatalError("HoverMenu: popover表示用のsourceViewかbarbuttonItemを設定してください。")
            }
            self.target?.present(self, animated: true, completion: nil)
            return
        }
        if gesture.state == .changed{
            if self.axis == .horizontal{
                hoverAction_horizontal(gesture: gesture)
            }else if self.axis == .vertical{
                hoverAction_vertical(gesture: gesture)
            }
        }
        if gesture.state == .ended{
            if let source = gesture.view, source.point(inside: gesture.location(in: source), with: nil){
                return
            }
            
            self.dismiss(animated: true, completion: nil)
            if let button = self.hoverButton{
                button.handler?(button, gesture)
            }
            
            releaseHover()
        }
    }

}

public protocol HoverMenuDelegate: UIPopoverPresentationControllerDelegate{
    /// HoverMenuではUIModalPresentationStyle.noneを返してください。
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    
    func hoverMenu(_ hoverMenu: HoverMenuController, willPresentBy gesture: HoverGestureRecognizer)
}

extension HoverMenuDelegate{
    /// HoverMenuではUIModalPresentationStyle.noneを返してください。
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if controller.presentedViewController is HoverMenuController{
            //HoverMenuでは必ずnoneを返してください。iPhoneでもpopover表示をするためです。
            return .none
        }
        return controller.presentedViewController.modalPresentationStyle
    }
    
    func hoverMenu(_ hoverMenu: HoverMenuController, willPresentBy gesture: HoverGestureRecognizer){}
}

class DefaultHoverMenuDelegate: NSObject, HoverMenuDelegate{
    /// HoverMenuではUIModalPresentationStyle.noneを返してください。
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if controller.presentedViewController is HoverMenuController{
            //HoverMenuでは必ずnoneを返してください。iPhoneでもpopover表示をするためです。
            return .none
        }
        return controller.presentedViewController.modalPresentationStyle
    }
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
