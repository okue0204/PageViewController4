//
//  ViewController.swift
//  PageViewController4
//
//  Created by 奥江英隆 on 2024/05/26.
//

import UIKit

class ViewController: UIViewController {
    
    private enum Tag: Int {
        case latest = 0
        case program
        case download
        case playlist
    }
    
    private enum Move {
        case scroll
        case tap
    }
    
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var pageContainerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let viewControllers: [UIViewController] = [
        UIStoryboard.latestStoryboard.instantiateInitialViewController()!,
        UIStoryboard.programStoryboard.instantiateInitialViewController()!,
        UIStoryboard.downloadCompleteStoryboard.instantiateInitialViewController()!,
        UIStoryboard.playlistStoryboard.instantiateInitialViewController()!
    ]
    
    private var oldTapButtonTag: Int = 0
    private var move: Move = .scroll
    private var currentPage: Int = 0 {
        didSet {
            pageControl.currentPage = currentPage
        }
    }
    
    // 次のページの移動量を取得
    private var afterAmountMovement: CGFloat {
        guard viewControllers.count > currentPage + 1 else {
            return 0
        }
        let afterButtonCenterX = buttons[currentPage + 1].center.x
        return afterButtonCenterX - firstButtonCenterX
    }
    
    // 現在地点の移動量を取得
    private var currentAmountMovement: CGFloat {
        let currentButtonCenterX = buttons[currentPage].center.x
        return currentButtonCenterX - firstButtonCenterX
    }
    
    // 前回の地点の移動量を取得
    private var previousAmountMovement: CGFloat {
        guard 0 < currentPage else {
            return 0
        }
        let previousButtonCenterX = buttons[currentPage - 1].center.x
        return previousButtonCenterX - firstButtonCenterX
    }
    
    private var screenWidth: CGFloat = {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return 0
        }
        return windowScene.screen.bounds.width
    }()
    
    private var buttons: [UIButton] {
        stackView.arrangedSubviews.compactMap {
            $0 as? UIButton
        }
    }
    
    private lazy var firstButtonCenterX: CGFloat = {
        guard let firstButton = stackView.arrangedSubviews.first as? UIButton else {
            fatalError("Invalid firstButton")
        }
        return firstButton.center.x
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
    }
    
    private func setupPageViewController() {
        pageViewController.view.subviews.forEach {
            if let scrollView = $0 as? UIScrollView {
                scrollView.delegate = self
            }
        }
        pageViewController.view.backgroundColor = .white
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageContainerView.addSubview(pageViewController.view)
        pageViewController.view.topAnchor.constraint(equalTo: pageContainerView.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: pageContainerView.bottomAnchor).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: pageContainerView.trailingAnchor).isActive = true
        pageViewController.view.leadingAnchor.constraint(equalTo: pageContainerView.leadingAnchor).isActive = true
        pageViewController.setViewControllers([viewControllers.first!], direction: .forward, animated: false)
    }
    
    private func updateLayout(at index: Int) {
        move = .tap
        if oldTapButtonTag == index {
            return
        }
        buttons.forEach {
            $0.isUserInteractionEnabled = false
        }
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self else {
                return
            }
            handleMoveAnimation(move: .tap, scrollView: nil, at: index)
            pageViewController.setViewControllers([viewControllers[index]],
                                                  direction: index > currentPage ? .forward : .reverse,
                                                  animated: true) { [weak self] isFinished in
                guard let self else {
                    return
                }
                if isFinished {
                    currentPage = index
                    buttons.forEach {
                        $0.isUserInteractionEnabled = true
                    }
                    move = .scroll
                }
            }
        }
        oldTapButtonTag = index
    }
    
    private func handleMoveAnimation(move: Move, scrollView: UIScrollView?, at index: Int? = nil) {
        switch move {
        case .scroll:
            guard let scrollView else {
                return
            }
            let contentOffsetX = scrollView.contentOffset.x - screenWidth
            guard let tag = Tag(rawValue: currentPage) else {
                return
            }
            if contentOffsetX > 0 {
                // forward
                let resultX: CGFloat = switch tag {
                case .latest:
                    afterAmountMovement * (contentOffsetX / screenWidth)
                case .program, .download, .playlist:
                    (afterAmountMovement - currentAmountMovement) * (contentOffsetX / screenWidth)
                }
                if resultX == 0 {
                    return
                }
                animationView.transform = CGAffineTransform(translationX: resultX + currentAmountMovement, y: 0)
            } else {
                // reverse
                let resultX = (currentAmountMovement - previousAmountMovement) * (contentOffsetX / screenWidth)
                animationView.transform = CGAffineTransform(translationX: resultX + currentAmountMovement, y: 0)
            }
        case .tap:
            guard let index else {
                return
            }
            let afterIndexX = buttons[index].center.x
            animationView.transform = CGAffineTransform(translationX: afterIndexX - firstButtonCenterX, y: 0)
        }
    }
    
    @IBAction func didTapLatestButton(_ button: UIButton) {
        updateLayout(at: button.tag)
    }
    
    @IBAction func didTapPragramButton(_ button: UIButton) {
        updateLayout(at: button.tag)
    }
    
    @IBAction func didTapDownloadButton(_ button: UIButton) {
        updateLayout(at: button.tag)
    }
    
    @IBAction func didTapPlaylistButton(_ button: UIButton) {
        updateLayout(at: button.tag)
    }
}

extension ViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if let viewController = pageViewController.viewControllers?.first,
           let afterIndex = viewControllers.firstIndex(of: viewController),
           completed {
            currentPage = afterIndex
        }
    }
}

extension ViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = viewControllers.firstIndex(of: viewController),
           viewControllers.count - 1 > index {
            return viewControllers[index + 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = viewControllers.firstIndex(of: viewController),
           0 < index {
            return viewControllers[index - 1]
        }
        return nil
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if move == .tap {
            return
        }
        handleMoveAnimation(move: .scroll, scrollView: scrollView)
    }
}

