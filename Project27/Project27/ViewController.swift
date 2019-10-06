//
//  ViewController.swift
//  Project27
//
//  Created by Dillon McElhinney on 10/5/19.
//  Copyright © 2019 Dillon McElhinney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var currentDrawType = 0

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drawRectangle()
    }

    @IBAction func redraw(_ sender: Any) {
        currentDrawType += 1
        currentDrawType %= 6

        switch currentDrawType {
        case 0:
            drawRectangle()
        case 1:
            drawCircle()
        case 2:
            drawCheckerboard()
        case 3:
            drawRotatedSquares()
        case 4:
            drawLines()
        case 5:
            drawImagesAndText()

        default:
            break
        }
    }

    func drawRectangle() {
        let size = CGSize(width: 512,
                          height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let rectangle = CGRect(origin: .zero,
                                   size: size)
                .insetBy(dx: 10, dy: 10)

            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10)

            context.cgContext.addRect(rectangle)
            context.cgContext.drawPath(using: .stroke)
        }

        imageView.image = image
    }

    func drawCircle() {
        let size = CGSize(width: 512,
                          height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let rectangle = CGRect(origin: .zero,
                                   size: size)
                .insetBy(dx: 10, dy: 10)

            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.setLineWidth(10)

            context.cgContext.addEllipse(in: rectangle)
            context.cgContext.drawPath(using: .stroke)
        }

        imageView.image = image
    }

    func drawCheckerboard() {
        let size = CGSize(width: 512,
                          height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            context.cgContext.setFillColor(UIColor.black.cgColor)

            for row in 0..<8 {
                for col in 0..<8 {
                    if (row + col) % 2 == 0 {
                        context.cgContext.fill(CGRect(x: col * 64,
                                                      y: row * 64,
                                                      width: 64,
                                                      height: 64))
                    }
                }
            }
        }
        imageView.image = image
    }

    func drawRotatedSquares() {
        let size = CGSize(width: 512,
                          height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            context.cgContext.translateBy(x: 256, y: 256)

            let rotations = 100
            let amount = Double.pi / Double(rotations)

            for _ in 0 ..< rotations {
                context.cgContext.rotate(by: CGFloat(amount))
                let rect = CGRect(x: -128,
                                  y: -128,
                                  width: 256,
                                  height: 256)
                context.cgContext.addRect(rect)
            }

            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.strokePath()
        }

        imageView.image = image
    }

    func drawLines() {
        let size = CGSize(width: 512,
                          height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            context.cgContext.translateBy(x: 256, y: 256)

            var first = true
            var length: CGFloat = 256

            for _ in 0 ..< 256 {
                context.cgContext.rotate(by: .pi / 2)
                let point = CGPoint(x: length, y: 50)
                if first {

                    context.cgContext.move(to: point)
                    first = false
                } else {
                    context.cgContext.addLine(to: point)
                }

                length *= 0.99
            }

            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            context.cgContext.strokePath()
        }

        imageView.image = image
    }

    func drawImagesAndText() {

        let size = CGSize(width: 512,
                          height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle
            ]

            let string = """
                         The best-laid schemes o'
                         mice an' men gang aft agley
                         """
            let attributedString = NSAttributedString(string: string,
                                                      attributes: attrs)

            let stringRect = CGRect(x: 32,
                                    y: 32,
                                    width: 448,
                                    height: 448)
            attributedString.draw(with: stringRect,
                                  options: .usesLineFragmentOrigin,
                                  context: nil)

            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }

        imageView.image = image
    }
    
}

