//
//  UIView+Constraints.swift
//  StudySwipe
//
//  Created by Dillon McElhinney on 7/1/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Adds the view it is called on to the given view and constrains it to fill that view, with options to use the view's safe area and offsets from each side.
    func constrainToFill(_ view: UIView, safeArea: Bool = false, top: CGFloat = 0.0, bottom: CGFloat = 0.0, leading: CGFloat = 0.0, trailing: CGFloat = 0.0) {
        
        addAsSubviewWithConstraintsOf(view)
        
        let topAnchor = safeArea ? view.safeAreaLayoutGuide.topAnchor : view.topAnchor
        let bottomAnchor = safeArea ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor
        let leadingAnchor = safeArea ? view.safeAreaLayoutGuide.leadingAnchor : view.leadingAnchor
        let trailingAnchor = safeArea ? view.safeAreaLayoutGuide.trailingAnchor : view.trailingAnchor
        
        self.topAnchor.constraint(equalTo: topAnchor, constant: top).isActive = true
        bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom).isActive = true
        self.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading).isActive = true
        trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailing).isActive = true
    }
    
    /// Adds the view it is called on to the given view and optionally constrains it to each anchor that is given a value, with an option to use the view's safe area. **It is possible to define conflicting constraints, beware.**
    func constrainToSuperView(_ view: UIView, safeArea: Bool = true, top: CGFloat? = nil, bottom: CGFloat? = nil, leading: CGFloat? = nil, trailing: CGFloat? = nil, centerX: CGFloat? = nil, centerY: CGFloat? = nil, equalHeight: CGFloat? = nil, equalWidth: CGFloat? = nil, height: CGFloat? = nil, width: CGFloat? = nil) {
        
        addAsSubviewWithConstraintsOf(view)
        
        if let top = top {
            let topAnchor = safeArea ? view.safeAreaLayoutGuide.topAnchor : view.topAnchor
            self.topAnchor.constraint(equalTo: topAnchor, constant: top).isActive = true
        }
        
        if let bottom = bottom {
            let bottomAnchor = safeArea ? view.safeAreaLayoutGuide.bottomAnchor : view.bottomAnchor
            bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom).isActive = true
        }
        
        if let leading = leading {
            let leadingAnchor = safeArea ? view.safeAreaLayoutGuide.leadingAnchor : view.leadingAnchor
            self.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading).isActive = true
        }
        
        if let trailing = trailing {
            let trailingAnchor = safeArea ? view.safeAreaLayoutGuide.trailingAnchor : view.trailingAnchor
            trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailing).isActive = true
        }
        
        if let centerX = centerX {
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: centerX).isActive = true
        }
        
        if let centerY = centerY {
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: centerY).isActive = true
        }
        
        if let equalHeight = equalHeight {
            let heightAnchor = safeArea ? view.safeAreaLayoutGuide.heightAnchor : view.heightAnchor
            self.heightAnchor.constraint(equalTo: heightAnchor, constant: equalHeight).isActive = true
        }
        
        if let equalWidth = equalWidth {
            let widthAnchor = safeArea ? view.safeAreaLayoutGuide.widthAnchor : view.widthAnchor
            self.widthAnchor.constraint(equalTo: widthAnchor, constant: equalWidth).isActive = true
        }
        
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
    }
    
    /// Constrains the view it is called on to the given view by with the non nil anchors and the given offsets. **Must be siblings in the view hierarchy. It is possible to define conflicting constraints, beware.**
    func constrainToSiblingView(_ view: UIView, top: CGFloat? = nil, bottom: CGFloat? = nil, leading: CGFloat? = nil, trailing: CGFloat? = nil, below: CGFloat? = nil, above: CGFloat? = nil, behind: CGFloat? = nil, before: CGFloat? = nil, centerX: CGFloat? = nil, centerY: CGFloat? = nil, equalHeight: CGFloat? = nil, equalWidth: CGFloat? = nil, height: CGFloat? = nil, width: CGFloat? = nil) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
        }
        
        if let bottom = bottom {
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottom).isActive = true
        }
        
        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading).isActive = true
        }
        
        if let trailing = trailing {
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: trailing).isActive = true
        }
        
        if let below = below {
            self.topAnchor.constraint(equalTo: view.bottomAnchor, constant: below).isActive = true
        }
        
        if let above = above {
            view.topAnchor.constraint(equalTo: self.bottomAnchor, constant: above).isActive = true
        }
        
        if let behind = behind {
            self.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: behind).isActive = true
        }
        
        if let before = before {
            view.leadingAnchor.constraint(equalTo: self.trailingAnchor, constant: before).isActive = true
        }
        
        if let centerX = centerX {
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: centerX).isActive = true
        }
        
        if let centerY = centerY {
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: centerY).isActive = true
        }
        
        if let equalWidth = equalWidth {
            self.widthAnchor.constraint(equalTo: view.widthAnchor, constant: equalWidth).isActive = true
        }
        
        if let equalHeight = equalHeight {
            self.heightAnchor.constraint(equalTo: view.heightAnchor, constant: equalHeight).isActive = true
        }
        
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
    }
    
    /// Constrains the view it is called on to the given height, width, and or aspect ratio. **It is possible to define conflicting constraints, beware.**
    func constrain(height: CGFloat? = nil, width: CGFloat? = nil, aspectWidth: CGFloat? = nil) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        if let aspect = aspectWidth {
            self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: aspect).isActive = true
        }
        
    }
    
    /// Adds the view it is called on as a subview of the given view and constrains it to the center, with optional offsets.
    func constrainToCenterIn(_ view: UIView, xOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        
        addAsSubviewWithConstraintsOf(view)
        
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: xOffset).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yOffset).isActive = true
    }
    
    /// Adds the view it is called on as a subview of the given view and turns translatesAutoresizingMaskIntoConstraints off
    private func addAsSubviewWithConstraintsOf(_ view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.removeFromSuperview()
        view.addSubview(self)
    }
}
