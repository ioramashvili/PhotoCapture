import UIKit

protocol PosterDataProvider: class {
    init(mainPoster: UIImage, appendableImage: UIImage?, posterTextViewPosition: PosterTextViewPosition, font: UIFont?, textColor: UIColor, maxTextViewLine: Int)
    var mainPoster: UIImage { get }
    var appendableImage: UIImage? { get }
    var posterFilterType: PosterFilterType { get }
    var intensity: NSNumber { get set }
    
    var maxTextViewLine: Int { get }
    var textColor: UIColor { get }
    var font: UIFont? { get }
    var posterTextViewPosition: PosterTextViewPosition { get }
    
    func filter(with context: CIContext, image: UIImage) -> UIImage?
    func filter(with context: CIContext, ciImage: CIImage) -> UIImage?
}

extension PosterDataProvider {
    var isTextAppandable: Bool {
        return font != nil && posterTextViewPosition != .none
    }
    
    var hasOutsideComponent: Bool {
        switch posterTextViewPosition {
        case .bottom: return true
        case .insideTop, .none: return false
        }
    }
}

extension PosterDataProvider {
    var hasIntensity: Bool {
        return intensity.doubleValue > 0
    }
}

enum PosterTextViewPosition {
    case none, bottom, insideTop
}
