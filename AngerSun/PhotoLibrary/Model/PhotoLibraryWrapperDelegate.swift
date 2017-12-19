import Foundation

protocol PhotoLibraryWrapperDelegate: class {
    func closeVC()
    func closeWhenImageCropDidFinish()
    func goToPhotoLibraryViewController()
    func goToImageCropViewController()
}
