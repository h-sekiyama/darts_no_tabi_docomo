import UIKit

extension UIImageView {

    func animateGIF(data: Data,
                    animationRepeatCount: UInt = 1000000,
                    completion: (() -> Void)? = nil) {
        guard let animatedGIFImage = UIImage.animatedGIF(data: data) else {
            return
        }

        self.image = animatedGIFImage.images?.last
        self.animationImages = animatedGIFImage.images
        self.animationDuration = animatedGIFImage.duration
        self.animationRepeatCount = Int(animationRepeatCount)
        self.startAnimating()

        DispatchQueue.main.asyncAfter(deadline: .now() + animatedGIFImage.duration * Double(animationRepeatCount)) {
            completion?()
        }
    }
}
