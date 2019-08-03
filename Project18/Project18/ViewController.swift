//
//  ViewController.swift
//  Project18
//
//  Created by Dillon McElhinney on 8/2/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 1...100 {
            print("Got number \(i)")
        }

        print("Hello Bob")
        // prints "Hello Bob"

        print("Hello", "Bob")
        // prints "Hello Bob"

        let name = "Bob"
        print("Hello \(name)")
        // prints "Hello Bob"

        print("Hello", name)
        // prints "Hello Bob"

        print("Hello", name, separator: "-")
        // prints "Hello-Bob"

        print("Hello", name, terminator: ".\n")
        // prints "Hello Bob."

        assert(name == "Bob", "Who are we even talking to?")

        assert(1 == 1, "Something is wrong with the world")

        assert(1 == 2, "Something is wrong with my math")
    }


}

