import UIKit

class PageViewController: UIPageViewController {
    
    weak var pageControl: UIPageControl?
    
    fileprivate lazy var orderedViewControllers: [PosterViewController] = {
        return (0..<self.dataProvider.count).map { _ in self.newPosterVC() }
    }()
    
    private func newPosterVC() -> PosterViewController {
        let controller = AppStoryboard.main.instantiate(controller: PosterViewController.self)!
        controller.view.backgroundColor = .clear
        return controller
    }
    
    fileprivate(set) var activePageIndex: Int = 0 {
        didSet {
            pageControl?.currentPage = activePageIndex
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
        changePage(at: activePageIndex)
    }
    
    fileprivate func initialize() {
        orderedViewControllers.enumerated().forEach { (index, page) in
            page.posterImageView.image = dataProvider[index]
        }
        
        pageControl?.numberOfPages = dataProvider.count
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
        
        if nextIndex == orderedViewControllers.count {
            return orderedViewControllers.first
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController as! PosterViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        if previousIndex < 0 {
            return orderedViewControllers.last
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





