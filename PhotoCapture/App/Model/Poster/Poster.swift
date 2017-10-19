import UIKit

class Poster: PosterDataProvider {
    fileprivate(set) var _mainPoster: UIImage
    
    required init(mainPoster: UIImage) {
        _mainPoster = mainPoster
    }
    
    var mainPoster: UIImage {
        return _mainPoster
    }
    
    var posterFilterType: PosterFilterType {
        return .none
    }
    
    func filter(with context: CIContext, image: UIImage) -> UIImage? {
        return nil
    }
}
