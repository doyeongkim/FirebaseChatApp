//
//  ViewController.swift
//  RealTimeChat
//
//  Created by Solji Kim on 10/05/2019.
//  Copyright © 2019 Doyeong Kim. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

// MARK - UICollectionViewDelegate, UICollectionViewDataSource

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "formCell", for: indexPath) as! FormCell
        
        if indexPath.row == 0 { // Sign In cell
            cell.usernameContainer.isHidden = true
            cell.actionButton.setTitle("Login", for: .normal)
            cell.slideButton.setTitle("Sign Up", for: .normal)
            cell.slideButton.addTarget(self, action: #selector(slideToSignUpCell(_:)), for: .touchUpInside)
            cell.actionButton.addTarget(self, action: #selector(didPressLogin(_:)), for: .touchUpInside)
            
        } else if indexPath.row == 1 { // Sign Up cell
            cell.usernameContainer.isHidden = false
            cell.actionButton.setTitle("Sign Up", for: .normal)
            cell.slideButton.setTitle("Sign In", for: .normal)
            cell.slideButton.addTarget(self, action: #selector(slideToLoginCell(_:)), for: .touchUpInside)
            cell.actionButton.addTarget(self, action: #selector(didPressSignUp(_:)), for: .touchUpInside)
        }
        return cell
    }
    
    @objc func didPressSignUp(_ sender: UIButton) {
        
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as! FormCell
        
        guard let emailAddress = cell.emailAddressTextField.text,
            let password = cell.passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: emailAddress, password: password) { (result, error) in
            
            if error == nil {
//                print(result)
//                print(result?.user.uid)
                guard let userId = result?.user.uid, let userName = cell.userNameTextField.text
                    else { return }
                
                let reference = Database.database().reference()
                
                let user = reference.child("users").child(userId)
                let dataArray: [String: Any] = ["username": userName ]
                user.setValue(dataArray)
            }
        }
        displaySuccessMsg(successText: "회원가입을 축하합니다!")
    }
    
    @objc func didPressLogin(_ sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = collectionView.cellForItem(at: indexPath) as! FormCell
        
        guard let emailAddress = cell.emailAddressTextField.text, let password = cell.passwordTextField.text else { return }
        
        if emailAddress.isEmpty == true || password.isEmpty == true {
            displayErrorMsg(errorText: "Please fill in the empty fields")
        } else {
            Auth.auth().signIn(withEmail: emailAddress, password: password) { (result, error) in
                if error == nil {
//                    print(result?.user)
                    self.dismiss(animated: true)
                } else {
                    self.displayErrorMsg(errorText: "Wrong username or password")
                }
            }
        }
    }
    
    func displayErrorMsg(errorText: String) {
        let alert = UIAlertController(title: "Error", message: errorText, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func displaySuccessMsg(successText: String) {
        let alert = UIAlertController(title: "Success!", message: successText, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = self.collectionView.cellForItem(at: IndexPath(row: 1, section: 0)) as! FormCell
        
            self.collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
            
            cell.userNameTextField.text = ""
            cell.emailAddressTextField.text = ""
            cell.passwordTextField.text = ""
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    @objc func slideToSignUpCell(_ sender: UIButton) {
        let indexPath = IndexPath(row: 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
    }
    
    @objc func slideToLoginCell(_ sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
    }
}

// MARK - UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

