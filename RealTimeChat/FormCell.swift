//
//  FormCell.swift
//  RealTimeChat
//
//  Created by Solji Kim on 12/05/2019.
//  Copyright © 2019 Doyeong Kim. All rights reserved.
//

import UIKit

class FormCell: UICollectionViewCell {
    
    @IBOutlet weak var usernameContainer: UIView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var slideButton: UIButton!
    
    @IBAction func didEndOnExit(_ sender: UITextField) {
        
    }
}


