import UIKit

protocol PosterDataProvider: class {
    init(mainPoster: UIImage)
    var mainPoster: UIImage { get }
    func filter(with context: CIContext, image: UIImage) -> UIImage?
    func filter(with context: CIContext, ciImage: CIImage) -> UIImage?
    var posterFilterType: PosterFilterType { get }
}
