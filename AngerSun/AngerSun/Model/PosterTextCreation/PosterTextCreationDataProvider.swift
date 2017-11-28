import UIKit

protocol PosterTextCreationDataProvider: class {
    var capturedImage: UIImage { get }
    var posterDataProvider: PosterDataProvider { get }
}
