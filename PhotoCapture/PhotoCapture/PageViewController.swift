import UIKit

class PageViewController: UIPageViewController {
    
    var orderedViewControllers: [PosterViewController] = []
    
    private static func newColoredViewController(color: UIColor) -> PosterViewController {
        let controller =  UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "PosterViewController") as! PosterViewController
        controller.view.backgroundColor = color
        
        return controller
    }
    
//    var dataProvider: SeminarPagerViewDataProvider? {
//        didSet {
//            orderedViewControllers.enumerated().forEach { (index, page) in
//                page.dataProvider = dataProvider?.pages[index]
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeViewController()
        dataSource = self
        
        changePage(at: 0)
//        disableScolling()
    }
    
    fileprivate func initializeViewController() {
        orderedViewControllers = [PageViewController.newColoredViewController(color: .red),
                                  PageViewController.newColoredViewController(color: .blue),
                                  PageViewController.newColoredViewController(color: .yellow)]
    }
    
    fileprivate func disableScolling() {
        view.subviews.filter({ $0 is UIScrollView }).forEach { v in
            (v as? UIScrollView)?.isScrollEnabled = false
        }
    }
    
    func changePage(at index: Int) {
        guard index >= 0 && index < orderedViewControllers.count else {
            return
        }
        
        let page = orderedViewControllers[index]
        setViewControllers([page], direction: .forward, animated: false) { _ in
//            page.scrollToTop()
        }
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController as! PosterViewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController as! PosterViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
}



