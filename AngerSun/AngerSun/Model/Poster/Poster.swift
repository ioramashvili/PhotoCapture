import UIKit

class Poster: PosterDataProvider {
    fileprivate(set) var _mainPoster: UIImage
    fileprivate(set) var _isTextAppandable: Bool
    fileprivate(set) var _appendableImage: UIImage?
    
    required init(mainPoster: UIImage, isTextAppandable: Bool, appendableImage: UIImage?) {
        _mainPoster = mainPoster
        _isTextAppandable = isTextAppandable
        _appendableImage = appendableImage
    }
    
    var mainPoster: UIImage {
        return _mainPoster
    }
    
    var isTextAppandable: Bool {
        return _isTextAppandable
    }
    
    var appendableImage: UIImage? {
        return _appendableImage
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
    
    static func getPosters() -> [PosterDataProvider] {
        let filterColor = UIColor(name: "ff1515FF")
        
        let posters: [PosterDataProvider] = [
            MonochromePoster(posterImage: #imageLiteral(resourceName: "why-fuck-style"), intensity: 0, color: filterColor, isTextAppandable: false),
            MonochromePoster(posterImage: #imageLiteral(resourceName: "stop-fuck-style"), intensity: 0, color: filterColor, isTextAppandable: false),
            MonochromePoster(posterImage: #imageLiteral(resourceName: "fuck-fuck-style"), intensity: 0, color: filterColor, isTextAppandable: false),
            MonochromePoster(posterImage: #imageLiteral(resourceName: "2.1"), intensity: 0.35, color: filterColor, isTextAppandable: true, appendableImage: #imageLiteral(resourceName: "2-bottom")),
            MonochromePoster(posterImage: #imageLiteral(resourceName: "2.2"), intensity: 0.35, color: filterColor, isTextAppandable: true, appendableImage: #imageLiteral(resourceName: "2-bottom")),
            MonochromePoster(posterImage: #imageLiteral(resourceName: "2.3"), intensity: 0.65, color: filterColor, isTextAppandable: true, appendableImage: #imageLiteral(resourceName: "2-bottom"))
        ]
        
        return posters
    }
}
