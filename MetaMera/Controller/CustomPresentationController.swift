//
//  CustomPresentationController.swift
//  MetaMera
//
//  Created by Jim on 2022/12/01.
//

import Foundation
import UIKit

class CustomPresentationController: UIPresentationController {
    private let dimmingView: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = .black
        return overlay
    }()

    override func presentationTransitionWillBegin() {
        dimmingView.alpha = 0
        containerView?.insertSubview(dimmingView, at: 0)

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 0.5
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        // presentが完了していない場合
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        // dismissが完了した場合
        if completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        .init(width: parentSize.width / 2, height: parentSize.height / 2)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerViewBounds = containerView?.bounds else { return .zero }

        var frame = CGRect.zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerViewBounds.size)

        frame.origin.x = (containerViewBounds.size.width - frame.size.width) / 2
        frame.origin.y = (containerViewBounds.size.height - frame.size.height) / 2

        return frame
    }

    override func containerViewWillLayoutSubviews() {
        dimmingView.frame = containerView?.frame ?? .zero
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
}
