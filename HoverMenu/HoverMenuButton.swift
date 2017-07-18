//
//  HoverMenuButton.swift
//  HoverMenu
//
//  Created by on0z on 2017/05/01.
//  Copyright © 2017年 on0z. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
public class HoverMenuButton: UIView {
    
    weak var superVC: HoverMenuController?
    public var handler: ((HoverMenuButton, UIGestureRecognizer) -> Void)?
    var isHovered: Bool = false
    
/** HoverMenuButtonを作成する
 
 - Parameters:
    - size: ボタンのサイズを指定する
    - setView: ボタンの見た目を指定する
    - handler: ボタンを押された時に実行する処理を指定する。
 */
    public init(size: (width: CGFloat, height: CGFloat) = (0, 0), setView: @escaping ((HoverMenuButton) -> Void), handler: @escaping ((HoverMenuButton, UIGestureRecognizer) -> Void)){
        super.init(frame: CGRect.zero)
        self.setSize(width: size.width, height: size.height)
        setView(self)
        self.handler = handler
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTap(gesture:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTap(gesture: UITapGestureRecognizer){
        guard let handler = self.handler else { return }
        guard let vc = self.superVC else { return }
        vc.dismiss(animated: true, completion: nil)
        handler(self, gesture)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var widthAnchorConstraint: NSLayoutConstraint?
    var heightAnchorConstraint: NSLayoutConstraint?
    
    public func setSize(width: CGFloat, height: CGFloat){
        self.frame.size.width = width
        self.frame.size.height = height
        
        widthAnchorConstraint?.isActive = false
        widthAnchorConstraint = self.widthAnchor.constraint(equalToConstant: width)
        widthAnchorConstraint?.isActive = true
        
        heightAnchorConstraint?.isActive = false
        heightAnchorConstraint = self.heightAnchor.constraint(equalToConstant: height)
        heightAnchorConstraint?.isActive = true
    }
    
}
