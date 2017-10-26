import Foundation

protocol PhotoLibraryWrapperDelegate: class {
    func closeVC()
    func goToPhotoLibraryViewController()
    func goToImageCropViewController()
}
