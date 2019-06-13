//
//  ViewController.swift
//  Project6b
//
//  Created by Dillon McElhinney on 6/13/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label1 = UILabel()
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.backgroundColor = .red
        label1.text = "THESE"
        label1.sizeToFit()

        let label2 = UILabel()
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.backgroundColor = .cyan
        label2.text = "ARE"
        label2.sizeToFit()

        let label3 = UILabel()
        label3.translatesAutoresizingMaskIntoConstraints = false
        label3.backgroundColor = .yellow
        label3.text = "SOME"
        label3.sizeToFit()

        let label4 = UILabel()
        label4.translatesAutoresizingMaskIntoConstraints = false
        label4.backgroundColor = .green
        label4.text = "AWESOME"
        label4.sizeToFit()

        let label5 = UILabel()
        label5.translatesAutoresizingMaskIntoConstraints = false
        label5.backgroundColor = .orange
        label5.text = "LABELS"
        label5.sizeToFit()

        view.addSubview(label1)
        view.addSubview(label2)
        view.addSubview(label3)
        view.addSubview(label4)
        view.addSubview(label5)
        
        let viewsDictionary = [
            "label1" : label1,
            "label2" : label2,
            "label3" : label3,
            "label4" : label4,
            "label5" : label5
        ]
        
        // Set horizontal constraints
        for label in viewsDictionary.keys {
            let constraints =
                NSLayoutConstraint.constraints(withVisualFormat: "H:|[\(label)]|",
                                               options: [],
                                               metrics: nil,
                                               views: viewsDictionary)
            view.addConstraints(constraints)
        }
        
        // Set vertical constraints
        let format = "V:|-36-[label1]-[label2]-[label3]-[label4]-[label5]"
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: format,
                                                         options: [],
                                                         metrics: nil,
                                                         views: viewsDictionary)
        view.addConstraints(constraints)
    }


}

