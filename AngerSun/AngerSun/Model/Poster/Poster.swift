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
    
    func filter(with context: CIContext, ciImage: CIImage) -> UIImage? {
        return nil
    }
    
    static func staticPosters() -> [PosterDataProvider] {
        let posters: [PosterDataProvider] = [
            MonochromePoster(posterImage: #imageLiteral(resourceName: "04"), intensity: 0.35, color: UIColor(name: "ff1515FF")),
            MonochromePoster(posterImage: #imageLiteral(resourceName: "f1"), intensity: 0.35, color: UIColor(name: "ff1515FF")),
            MonochromePoster(posterImage: #imageLiteral(resourceName: "f2"), intensity: 0.35, color: UIColor(name: "ff1515FF")),
            MonochromePoster(posterImage: #imageLiteral(resourceName: "f3"), intensity: 0.35, color: UIColor(name: "ff1515FF"))
        ]
        
        return posters
    }
}
