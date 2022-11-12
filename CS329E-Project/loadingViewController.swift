//
//  loadingViewController.swift
//  CS329E-Project
//
//  Created by Ray Zhang on 11/6/22.
//

import UIKit

class loadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Add the blurEffectView with the same
        // size as view
        loadingBlurEffect.frame = self.view.bounds
        view.insertSubview(loadingBlurEffect, at: 0)
        
        // Add the loadingActivityIndicator in the
        // center of view
        loadingActivityIndicator.center = CGPoint(
            x: view.bounds.midX,
            y: view.bounds.midY
        )
        view.addSubview(loadingActivityIndicator)
    }
    
    var loadingActivityIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView()
        
        loadingIndicator.color = .white
        loadingIndicator.style = .large

            
        // The indicator should be animating when
        // the view appears.
        loadingIndicator.startAnimating()
            
        // Setting the autoresizing mask to flexible for all
        // directions will keep the indicator in the center
        // of the view and properly handle rotation.
        loadingIndicator.autoresizingMask = [
            .flexibleLeftMargin, .flexibleRightMargin,
            .flexibleTopMargin, .flexibleBottomMargin
        ]
            
        return loadingIndicator
    }()
    var loadingBlurEffect: UIVisualEffectView = {
        let loadBlurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: loadBlurEffect)
        
        blurEffectView.alpha = 0.8
        
        // Setting the autoresizing mask to flexible for
        // width and height will ensure the blurEffectView
        // is the same size as its parent view.
        blurEffectView.autoresizingMask = [
            .flexibleWidth, .flexibleHeight
        ]
        
        return blurEffectView
    }()

}
