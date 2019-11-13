//
//  PlayerMovingTransition.swift
//  PlayerHubSample
//
//  Created by 廖雷 on 2019/11/13.
//  Copyright © 2019 Danis. All rights reserved.
//

import UIKit

protocol PlayerMovingTransitionVideoContainer: UIViewController {
    var videoContainer: UIView? { get }
}

class PlayerMovingTransition: NSObject, UINavigationControllerDelegate {
    private let showAnimator = ShowAnimator()
    private let dismissAnimator = DismissAnimator()
 
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard fromVC is PlayerMovingTransitionVideoContainer && toVC is PlayerMovingTransitionVideoContainer else {
            return nil
        }
        switch operation {
        case .push:
            return showAnimator
        case .pop:
            return dismissAnimator
        default:
            return nil
        }
    }
}

extension PlayerMovingTransition {
    class ShowAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.3
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let containerView = transitionContext.containerView
            let fromVC = transitionContext.viewController(forKey: .from)! as! PlayerMovingTransitionVideoContainer
            let toVC = transitionContext.viewController(forKey: .to)! as! PlayerMovingTransitionVideoContainer
            
            containerView.addSubview(toVC.view)
            
            let finalToFrame = transitionContext.finalFrame(for: toVC)
            toVC.view.frame = finalToFrame
            toVC.view.setNeedsLayout()
            toVC.view.layoutIfNeeded()
            
            var tempEndFrame: CGRect?
            var tempVideoContainer: UIView?
            
            if let fromVideoContainer = fromVC.videoContainer,
                let toVideoContainer = toVC.videoContainer,
                let fromSuperView = fromVideoContainer.superview,
                let toSuperview = toVideoContainer.superview,
                PlayerHub.shared.isPlayer(in: fromVideoContainer)
            {
                let videoContainer = UIView()
                let startFrame = fromSuperView.convert(fromVideoContainer.frame, to: containerView)
                let endFrame = toSuperview.convert(toVideoContainer.frame, to: containerView)
                
                containerView.addSubview(videoContainer)
                videoContainer.frame = startFrame
                PlayerHub.shared.movePlayer(to: videoContainer)
                
                tempEndFrame = endFrame
                tempVideoContainer = videoContainer
            }
            
            toVC.view.frame = finalToFrame.offsetBy(dx: toVC.view.frame.width, dy: 0)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
                toVC.view.frame = finalToFrame
                
                if let tempEndFrame = tempEndFrame, let tempVideoContainer = tempVideoContainer {
                    tempVideoContainer.frame = tempEndFrame
                    tempVideoContainer.subviews.first?.frame = tempVideoContainer.bounds
                }
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                
                if let toVideoContainer = toVC.videoContainer {
                    PlayerHub.shared.movePlayer(to: toVideoContainer)
                }
                tempVideoContainer?.removeFromSuperview()
            }
            
        }
        
        
    }
    
    class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.3
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let containerView = transitionContext.containerView
            let fromVC = transitionContext.viewController(forKey: .from)! as! PlayerMovingTransitionVideoContainer
            let toVC = transitionContext.viewController(forKey: .to)! as! PlayerMovingTransitionVideoContainer
            
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            toVC.view.frame = transitionContext.finalFrame(for: toVC)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
                fromVC.view.frame = fromVC.view.frame.offsetBy(dx: fromVC.view.frame.width, dy: 0)
            }) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
        
        
    }
}
