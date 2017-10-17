import UIKit

class PageViewController: UIPageViewController {
    
    fileprivate lazy var orderedViewControllers: [PosterViewController] = {
        return [self.newPosterVC(), self.newPosterVC(), self.newPosterVC()]
    }()
    
    private func newPosterVC() -> PosterViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "PosterViewController") as! PosterViewController
        controller.view.backgroundColor = .clear
        return controller
    }
    
    fileprivate(set) var activePageIndex: Int = 0 {
        didSet {
            print(activePageIndex)
        }
    }
    
    var activePoster: UIImage? {
        return dataProvider[activePageIndex]
    }
    
    var dataProvider: [UIImage] = [] {
        didSet {
            initialize()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        initialize()
        changePage(at: 0)
    }
    
    fileprivate func initialize() {
        orderedViewControllers.enumerated().forEach { (index, page) in
            page.posterImageView.image = dataProvider[index]
        }
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

extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            guard
                let viewController = pageViewController.viewControllers?.first as? PosterViewController,
                let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
                return
            }
            
            activePageIndex = viewControllerIndex
        }
    }
}





