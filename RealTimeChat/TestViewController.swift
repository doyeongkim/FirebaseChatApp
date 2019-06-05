//
//  TestViewController.swift
//  RealTimeChat
//
//  Created by Solji Kim on 19/05/2019.
//  Copyright © 2019 Doyeong Kim. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
    let imageView = UIImageView()
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        imageView.frame.size = CGSize(width: 300, height: 300)
        imageView.center = view.center
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        view.addSubview(imageView)
        
    }
}
