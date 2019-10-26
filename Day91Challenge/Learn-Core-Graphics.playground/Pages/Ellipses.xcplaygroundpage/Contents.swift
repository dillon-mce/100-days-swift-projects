//: [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
//: # Four circles
//: Now that you've mastered rectangles, ellipses ought to be easy. Like rectangles, ellipses are drawn by activating a color then specifying a rectangle. If the rectangle has the same width and height you'll get a circle, otherwise you'll get an ellipse.
//:
//: - Experiment: The code below draws one red circle in the top-left corner, but your designer wants you to create three more: a yellow circle in the top-right corner, a blue circle in the bottom-left corner, and a green circle in the bottom-right corner.
import UIKit

let rect = CGRect(x: 0, y: 0, width: 1000, height: 1000)
let renderer = UIGraphicsImageRenderer(bounds: rect)

let rendered = renderer.image { ctx in
    let colors: [[UIColor]] = [[.red, .blue], [.yellow, .green]]
    zip([0,0,1,1], [0,1,0,1]).forEach { x, y in
        let origin = CGPoint(x: x*500, y: y*500)
        let size = CGSize(width: 500, height: 500)
        let color = colors[x][y]
        color.setFill()
        ctx.cgContext.fillEllipse(in: CGRect(origin: origin, size: size))
    }
}

showOutput(rendered)
//: [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
