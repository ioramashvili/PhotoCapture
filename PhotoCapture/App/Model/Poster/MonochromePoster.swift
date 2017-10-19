import UIKit

class MonochromePoster: Poster {
    var intensity: NSNumber
    fileprivate(set) var color: UIColor
    
    init(posterImage: UIImage, intensity: NSNumber, color: UIColor) {
        self.intensity = intensity
        self.color = color
        super.init(mainPoster: posterImage)
    }
    
    required convenience init(mainPoster: UIImage) {
        self.init(posterImage: mainPoster, intensity: 1, color: .black)
    }
    
    override func filter(with context: CIContext, image: UIImage) -> UIImage? {
        return image.addCIColorMonochrome(with: context, intensity: intensity, color: color)
    }
    
    override var posterFilterType: PosterFilterType {
        return .monochrome
    }
}
