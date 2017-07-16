//
//  HoverGestureRecognizer.swift
//  HoverMenu
//
//  Created by on0z on 2017/05/01.
//  Copyright © 2017年 on0z. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

public class HoverGestureRecognizer: UIGestureRecognizer {
    
    var firstPoint: CGPoint?
    var moving: (x: Bool, y: Bool) = (x: true, y: true)
    
    public init(target: HoverMenuController) {
        super.init(target: target, action: #selector(target.hoverAction(gesture:)))
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        defer { self.state = .began; self.moving = (true, true) }
        self.firstPoint = touches.first?.location(in: view)
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .changed
        self.moving = (
            Int(touches.first?.location(in: view).x ?? 0) / 2 != Int(touches.first?.previousLocation(in: view).x ?? 0) / 2,
            Int(touches.first?.location(in: view).y ?? 0) / 2 != Int(touches.first?.previousLocation(in: view).y ?? 0) / 2
        )
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .recognized
        self.moving = (false, false)
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .cancelled
        self.moving = (false, false)
    }
}
