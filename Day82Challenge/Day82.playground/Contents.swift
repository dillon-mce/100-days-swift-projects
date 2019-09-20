import UIKit

typealias EmptyClosure = () -> Void

extension UIView {
    func bounceOut(duration: TimeInterval, completion: ((Bool) -> Void)?) {
        let animations: EmptyClosure = {
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.0001, y: 0.0001)
        }
        UIView.animate(withDuration: duration,
                       delay: 0,
                       animations: animations,
                       completion: completion)
    }
}

extension Int {
    func times(closure: EmptyClosure) {
        (0..<self.magnitude).forEach { _ in
            closure()
        }
    }
}

let str = "Hello"
3.times { print(str) }

extension Array where Element: Equatable {
    @discardableResult
    mutating func remove(_ item: Element) -> Element? {
        guard let index = firstIndex(of: item) else {
            return nil
        }
        return self.remove(at: index)
    }
}

var arr = [1, 2, 3, 4 , 5, 1]
print(arr)
arr.remove(1)
print(arr)
