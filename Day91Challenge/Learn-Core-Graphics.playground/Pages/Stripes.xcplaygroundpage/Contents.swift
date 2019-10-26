//: [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
//: # Fixing the fade
//: This time you'll see the image now contains five rectangles, each 200 pixels wide and the full height of the image. Your designer wanted to make them red, orange, yellow, green, and blue, but they didn't get some of the colors quite right – they look faded.
//:
//: - Experiment: Can you draw the five rectangles in their correct colors? The first one has been done for you.
import UIKit

let rect = CGRect(x: 0, y: 0, width: 1000, height: 1000)
let renderer = UIGraphicsImageRenderer(bounds: rect)

let rendered = renderer.image { ctx in
    let colors: [UIColor] = [.red, .orange, .yellow, .green, .blue]
    let width = Int(rect.width) / colors.count
    colors.enumerated().forEach {
        let origin = CGPoint(x: width * $0, y: 0)
        let size = CGSize(width: width, height: 1000)
        $1.setFill()
        ctx.cgContext.fill(CGRect(origin: origin, size: size))
    }
}

showOutput(rendered)
//: [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
