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
    
    private var interactiveTransitioning:UIPercentDrivenInteractiveTransition? = nil
    
    @IBAction private func panned(sender : UIPanGestureRecognizer) {
        
        switch sender.state {
        case .Began:
            interactiveTransitioning = UIPercentDrivenInteractiveTransition()
            performSegueWithIdentifier("unwind", sender: self)
        case .Changed:
            interactiveTransitioning?.updateInteractiveTransition(sender.translationInView(view.superview).y / view.bounds.height)
        case .Cancelled:
            interactiveTransitioning?.cancelInteractiveTransition()
            interactiveTransitioning = nil
        case .Ended:
            if sender.velocityInView(view.superview).y > 0 {
                interactiveTransitioning?.finishInteractiveTransition()
            } else {
                interactiveTransitioning?.cancelInteractiveTransition()
            }
            interactiveTransitioning = nil
        default:
            break
        }
    }
}

extension PresentedViewController : UIViewControllerTransitioningDelegate {
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomDismissAnimatedTransitioning()
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitioning
    }
}

class CustomPresentationController : UIPresentationController {
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        let frame = super.frameOfPresentedViewInContainerView()
        let insets = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        return UIEdgeInsetsInsetRect(frame, insets)
    }
    
    private func setScale(expanded expanded: Bool) {
        
        if expanded {
            let fromMeasurement = presentingViewController.view.bounds.width
            let fromScale = (fromMeasurement - 30) / fromMeasurement
            presentingViewController.view.transform = CGAffineTransformMakeScale(fromScale, fromScale)
        } else {
            presentingViewController.view.transform = CGAffineTransformIdentity
        }
        
    }
    
    override func presentationTransitionWillBegin() {
        
        presentingViewController.transitionCoordinator()?.animateAlongsideTransition({ context in
            self.setScale(expanded: true)
        }, completion: { context in
            self.setScale(expanded: !context.isCancelled())
        })
    }
    
    override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator()?.animateAlongsideTransition({ context in
            self.setScale(expanded: false)
        }, completion: { context in
            self.setScale(expanded: context.isCancelled())
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        guard let bounds = containerView?.bounds else { return }
        presentingViewController.view.bounds = bounds
    }
}

class CustomDismissAnimatedTransitioning : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let duration = transitionDuration(transitionContext)
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        let initialFrame = transitionContext.initialFrameForViewController(fromViewController)
        var finalFrame = initialFrame
        
        finalFrame.origin.y = initialFrame.maxY
        
        fromViewController.view.frame = initialFrame
        transitionContext.containerView()?.addSubview(fromViewController.view)
        
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseInOut, animations: {
            fromViewController.view.frame = finalFrame
        }, completion: { _ in
            if transitionContext.transitionWasCancelled() {
                transitionContext.completeTransition(false)
            } else {
                fromViewController.view.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        })
    }
}
