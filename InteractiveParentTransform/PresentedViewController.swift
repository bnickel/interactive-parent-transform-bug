//
//  PresentedViewController.swift
//  InteractiveParentTransform
//
//  Created by Brian Nickel on 4/20/16.
//  Copyright © 2016 Stack Exchange. All rights reserved.
//

import UIKit

class PresentedViewController: UIViewController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        transitioningDelegate = self
        modalPresentationStyle = .Custom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension PresentedViewController : UIViewControllerTransitioningDelegate {
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}

class CustomPresentationController : UIPresentationController {
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        let frame = super.frameOfPresentedViewInContainerView()
        let insets = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        return UIEdgeInsetsInsetRect(frame, insets)
    }
    
    override func presentationTransitionWillBegin() {
        
        let fromMeasurement = presentingViewController.view.bounds.width
        let fromScale = (fromMeasurement - 30) / fromMeasurement
        presentingViewController.transitionCoordinator()?.animateAlongsideTransition({ context in
            self.presentingViewController.view.transform = CGAffineTransformMakeScale(fromScale, fromScale)
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator()?.animateAlongsideTransition({ context in
            self.presentingViewController.view.transform = CGAffineTransformIdentity
        }, completion: nil)
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard let bounds = containerView?.bounds else { return }
        presentingViewController.view.bounds = bounds
    }
}