import UIKit

protocol PosterDataProvider: class {
    init(mainPoster: UIImage, isTextAppandable: Bool, appendableImage: UIImage?)
    var mainPoster: UIImage { get }
    func filter(with context: CIContext, image: UIImage) -> UIImage?
    func filter(with context: CIContext, ciImage: CIImage) -> UIImage?
    var posterFilterType: PosterFilterType { get }
    var isTextAppandable: Bool { get }
    var appendableImage: UIImage? { get }
    var intensity: NSNumber { get set }
}

extension PosterDataProvider {
    var hasIntensity: Bool {
        return intensity.doubleValue > 0
    }
}
