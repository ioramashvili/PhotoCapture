import Foundation

protocol PosterPageDelegate: class {
    func pageChanged(to poster: PosterDataProvider, at index: Int)
}
