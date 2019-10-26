//: [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
//: # Picture perfect
//: If you have a `UIImage`, you can render it directly into a Core Graphics context at any size you want – it will automatically be scaled up or down as needed. To do this, just call `draw(in:)` on your image, passing in the `CGRect` where it should be drawn.
//:
//: - Experiment: Your designer wants you to create a picture frame effect for an image. He's placed the frame at the right size, but it's down to you to position it correctly then position and size the image inside it.
import UIKit

let rect = CGRect(x: 0, y: 0, width: 1000, height: 1000)
let renderer = UIGraphicsImageRenderer(bounds: rect)

let mascot = UIImage(named: "HackingWithSwiftMascot.jpg")

extension CGSize {
    func centerOffset(in rect: CGRect) -> CGPoint {
        let x = (rect.width - self.width) / 2 + rect.origin.x
        let y = (rect.height - self.height) / 2 + rect.origin.y
        return CGPoint(x: x, y: y)
    }
}

let rendered = renderer.image { ctx in
    UIColor.darkGray.setFill()
    ctx.cgContext.fill(rect)

    let frameEdge = 640
    let frameSize = CGSize(width: frameEdge, height: frameEdge)
    let frameOrigin = frameSize.centerOffset(in: rect)
    UIColor.black.setFill()
    let frameRect = CGRect(origin: frameOrigin, size: frameSize)
    ctx.cgContext.fill(frameRect)

    let frameWidth = 20
    let imageEdge = frameEdge - 2 * frameWidth
    let imageSize = CGSize(width: imageEdge, height: imageEdge)
    let imageOrigin = imageSize.centerOffset(in: frameRect)
    let imageRect = CGRect(origin: imageOrigin, size: imageSize)
    mascot?.draw(in: imageRect)
}



showOutput(rendered)
//: [< Previous](@previous)           [Home](Introduction)           [Next >](@next)
