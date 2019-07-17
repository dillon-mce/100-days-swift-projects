//
//  ViewController.swift
//  Project15
//
//  Created by Dillon McElhinney on 7/17/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var imageView: UIImageView!
    var currentAnimation = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        imageView = UIImageView(image: UIImage(named: "penguin"))
        imageView.center = CGPoint(x: 512, y: 384)
        view.addSubview(imageView)
    }

    @IBAction func tapped(_ sender: UIButton) {
        sender.isHidden = true

        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 5,
                       options: [],
                       animations: {
            switch self.currentAnimation {
            case 0:
                self.imageView.transform = CGAffineTransform(scaleX: 2,
                                                             y: 2)
            case 2:
                self.imageView.transform = CGAffineTransform(translationX: -256,
                                                             y: -256)
            case 4:
                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            case 6:
                self.imageView.alpha = 0.1
                self.imageView.backgroundColor = .green
            case 7:
                self.imageView.alpha = 1
                self.imageView.backgroundColor = .clear
            default:
                self.imageView.transform = .identity
            }
        }) { _ in
            sender.isHidden = false
        }
        
        currentAnimation += 1
        currentAnimation %= 8
        
        
    }
    
}

