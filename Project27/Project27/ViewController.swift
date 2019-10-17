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
        currentDrawType %= 8

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
        case 6:
            drawEmoji()
        case 7:
            drawTWIN()
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

    func drawEmoji() {
        let size = CGSize(width: 512,
                          height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let rectangle = CGRect(origin: .zero,
                                   size: size)
                .insetBy(dx: 10, dy: 10)
            let cgContext = context.cgContext

            // Draw base yellow circle
            let path = UIBezierPath(ovalIn: rectangle)
            path.addClip()

            let colorspace = CGColorSpace(name: CGColorSpace.sRGB)
            let colors = [UIColor.yellow.cgColor,
                          UIColor.orange.cgColor]
            let locations: [CGFloat] = [0.5, 1.0]

            guard let gradient = CGGradient(colorsSpace: colorspace,
                                            colors: colors as CFArray,
                                            locations: locations)
                else { return }

            cgContext.clip()
            let center = CGPoint(x: size.width/2,
                                 y: size.height/2)

            cgContext.drawRadialGradient(gradient,
                                         startCenter: center,
                                         startRadius: 0,
                                         endCenter: center,
                                         endRadius: size.width*0.65,
                                         options: CGGradientDrawingOptions())

            // Add eyes
            let eyeOneRect = CGRect(x: 160,
                                    y: 155,
                                    width: 50,
                                    height: 70)
            cgContext.addEllipse(in: eyeOneRect)

            let eyeTwoRect = CGRect(x: size.width-210,
                                    y: 155,
                                    width: 50,
                                    height: 70)
            cgContext.addEllipse(in: eyeTwoRect)

            // Add mouth
            let mouthStart = CGPoint(x: 80, y: 290)
            let mouthEnd = CGPoint(x: size.width-80, y: 290)
            cgContext.move(to: mouthStart)
            cgContext.addCurve(to: mouthEnd,
                               control1: CGPoint(x: 100, y: 320),
                               control2: CGPoint(x: size.width-100, y: 320))

            cgContext.addCurve(to: mouthStart,
                               control1: CGPoint(x: size.width-140, y: 480),
                               control2: CGPoint(x: 140, y: 480))

            cgContext.setFillColor(UIColor.brown.cgColor)

            cgContext.drawPath(using: .fill)
        }

        imageView.image = image
    }

    func drawTWIN() {
        let size = CGSize(width: 512,
                          height: 512)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let cgContext = context.cgContext

            let xOffset = 50
            // T
            cgContext.move(to: CGPoint(x: 50 + xOffset, y: 160))
            cgContext.addLine(to: CGPoint(x: 130 + xOffset, y: 160))
            cgContext.move(to: CGPoint(x: 90 + xOffset, y: 160))
            cgContext.addLine(to: CGPoint(x: 90 + xOffset, y: 300))

            // W
            cgContext.move(to: CGPoint(x: 136 + xOffset, y: 160))
            cgContext.addLine(to: CGPoint(x: 156 + xOffset, y: 290))
            cgContext.addLine(to: CGPoint(x: 176 + xOffset, y: 180))
            cgContext.addLine(to: CGPoint(x: 196 + xOffset, y: 290))
            cgContext.addLine(to: CGPoint(x: 216 + xOffset, y: 160))

            // I
            cgContext.move(to: CGPoint(x: 232 + xOffset, y: 160))
            cgContext.addLine(to: CGPoint(x: 232 + xOffset, y: 300))

            // N
            cgContext.move(to: CGPoint(x: 248 + xOffset, y: 300))
            cgContext.addLine(to: CGPoint(x: 248 + xOffset, y: 165))
            cgContext.addLine(to: CGPoint(x: 318 + xOffset, y: 295))
            cgContext.addLine(to: CGPoint(x: 318 + xOffset, y: 160))

            cgContext.setStrokeColor(UIColor.black.cgColor)
            cgContext.setLineWidth(4)
            cgContext.drawPath(using: .stroke)
        }

        imageView.image = image
    }
    
}

