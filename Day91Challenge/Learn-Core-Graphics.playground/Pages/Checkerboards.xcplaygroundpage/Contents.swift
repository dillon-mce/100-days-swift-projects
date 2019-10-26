//: [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
//: # Rectangles in a loop
//: Drawing rectangles inside two loops lets us create a checkerboard pattern. The image already has a white background color, so we need to draw black rectangles in an odd-even pattern to get the desired result.
//:
//: - Experiment: The code below makes a checkerboard, but it doesn't fill the image correctly. Try adjusting the grid size, number of rows, and number of columns so that you get a 10x10 checkerboard across the entire image.
import UIKit

let edge = 1000
let rect = CGRect(x: 0, y: 0, width: edge, height: edge)
let renderer = UIGraphicsImageRenderer(bounds: rect)

let rendered = renderer.image { ctx in
    UIColor.black.setFill()

    let numChecks = 10
    let size = edge / numChecks

    for row in 0 ..< numChecks {
        for col in 0 ..< numChecks {
            if (row + col) % 2 == 0 {
                let origin = CGPoint(x: col * size, y: row * size)
                let size = CGSize(width: size, height: size)
                ctx.cgContext.fill(CGRect(origin: origin, size: size))
            }
        }
    }
}

showOutput(rendered)
//: [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
