import UIKit

class MonochromePoster: Poster {
    fileprivate var _intensity: NSNumber
    fileprivate(set) var color: UIColor
    
    init(posterImage: UIImage, intensity: NSNumber, color: UIColor, isTextAppandable: Bool, appendableImage: UIImage? = nil) {
        self._intensity = intensity
        self.color = color
        super.init(mainPoster: posterImage, isTextAppandable: isTextAppandable, appendableImage: appendableImage)
    }
    
    required convenience init(mainPoster: UIImage, isTextAppandable: Bool, appendableImage: UIImage?) {
       self.init(
        posterImage: mainPoster,
        intensity: 1, color:
        .black,
        isTextAppandable: isTextAppandable,
        appendableImage: appendableImage)
    }
    
    override var intensity: NSNumber {
        get { return _intensity }
        set { _intensity = newValue }
    }
    
    override func filter(with context: CIContext, image: UIImage) -> UIImage? {
        if !hasIntensity { return image }
        return image.addCIColorMonochrome(with: context, intensity: intensity, color: color)
    }
    
    override func filter(with context: CIContext, ciImage: CIImage) -> UIImage? {
        return ciImage.addCIColorMonochrome(with: context, intensity: intensity, color: color)
    }
    
    override var posterFilterType: PosterFilterType {
        return .monochrome
    }
}
