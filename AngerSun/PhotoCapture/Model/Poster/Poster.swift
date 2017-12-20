import UIKit

class Poster: PosterDataProvider {
    fileprivate(set) var _mainPoster: UIImage
    fileprivate(set) var _appendableImage: UIImage?
    fileprivate(set) var _posterTextViewPosition: PosterTextViewPosition
    fileprivate(set) var _font: UIFont?
    fileprivate(set) var _textColor: UIColor
    fileprivate(set) var _maxTextViewLine: Int
    
    required init(mainPoster: UIImage, appendableImage: UIImage?, posterTextViewPosition: PosterTextViewPosition, font: UIFont?, textColor: UIColor, maxTextViewLine: Int) {
        _mainPoster = mainPoster
        _appendableImage = appendableImage
        _posterTextViewPosition = posterTextViewPosition
        _font = font
        _textColor = textColor
        _maxTextViewLine = maxTextViewLine
    }
    
    var mainPoster: UIImage {
        return _mainPoster
    }
    
    var appendableImage: UIImage? {
        return _appendableImage
    }
    
    var posterFilterType: PosterFilterType {
        return .none
    }
    
    var posterTextViewPosition: PosterTextViewPosition {
        return _posterTextViewPosition
    }
    
    var font: UIFont? {
        return _font
    }
    
    var textColor: UIColor {
        return _textColor
    }
    
    var maxTextViewLine: Int {
        return _maxTextViewLine
    }
    
    var intensity: NSNumber {
        get { return 0 }
        set { }
    }
    
    func filter(with context: CIContext, image: UIImage) -> UIImage? {
        return nil
    }
    
    func filter(with context: CIContext, ciImage: CIImage) -> UIImage? {
        return nil
    }
    
    static func getPosters() -> [PosterDataProvider] {
        let multiplier: CGFloat = UIScreen.main.bounds.width / 414
        
        let filterColor = UIColor(name: "ff1515FF")
        let secondPosterFont = UIFont(name: "Verdana-Bold", size: 24 * multiplier)
        let thirdPosterFont = UIFont(name: "Verdana-Bold", size: 50 * multiplier)
        
        
        let posters: [PosterDataProvider] = [
            MonochromePoster(
                posterImage: #imageLiteral(resourceName: "why-fuck-style"),
                intensity: 0,
                color: filterColor,
                appendableImage: nil,
                posterTextViewPosition: .none,
                font: nil,
                textColor: .clear,
                maxTextViewLine: 0),
            MonochromePoster(
                posterImage: #imageLiteral(resourceName: "stop-fuck-style"),
                intensity: 0,
                color: filterColor,
                appendableImage: nil,
                posterTextViewPosition: .none,
                font: nil,
                textColor: .clear,
                maxTextViewLine: 0),
            MonochromePoster(
                posterImage: #imageLiteral(resourceName: "fuck-fuck-style"),
                intensity: 0,
                color: filterColor,
                appendableImage: nil,
                posterTextViewPosition: .none,
                font: nil,
                textColor: .clear,
                maxTextViewLine: 0),
            
            MonochromePoster(
                posterImage: #imageLiteral(resourceName: "2.1"),
                intensity: 0.35,
                color: filterColor,
                appendableImage: #imageLiteral(resourceName: "2-bottom"),
                posterTextViewPosition: .bottom,
                font: secondPosterFont,
                textColor: .white,
                maxTextViewLine: 2),
            MonochromePoster(
                posterImage: #imageLiteral(resourceName: "2.2"),
                intensity: 0.35,
                color: filterColor,
                appendableImage: #imageLiteral(resourceName: "2-bottom"),
                posterTextViewPosition: .bottom,
                font: secondPosterFont,
                textColor: .white,
                maxTextViewLine: 2),
            MonochromePoster(
                posterImage: #imageLiteral(resourceName: "2.3"),
                intensity: 0.65,
                color: filterColor,
                appendableImage: #imageLiteral(resourceName: "2-bottom"),
                posterTextViewPosition: .bottom,
                font: secondPosterFont,
                textColor: .white,
                maxTextViewLine: 2),
            
            MonochromePoster(
                posterImage: #imageLiteral(resourceName: "flag"),
                intensity: 0,
                color: filterColor,
                appendableImage: nil,
                posterTextViewPosition: .insideTop,
                font: thirdPosterFont,
                textColor: .red,
                maxTextViewLine: 1)
        ]
        
        return posters
    }
}
