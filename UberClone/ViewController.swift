//
//  ViewController.swift
//  UberClone
//
//  Created by apple on 03/02/18.
//  Copyright © 2018 Sonkar. All rights reserved.
//

import UIKit
import FirebaseAuth


class ViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var topbutton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    
    var signUpMode = true
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func topButtonPressed(_ sender: Any) {
        
        if email.text == "" || password.text == ""{
            displayAlert(title: "Error!", message: "Fields can't be empty.")
        }else{
            if let emailtext = email.text{
                if let passwordtext = password.text{
                    if signUpMode{
                        //signup
                        
                        Auth.auth().createUser(withEmail: emailtext, password: passwordtext, completion: { (user, error) in
                            
                            if error != nil{
                                
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                                
                            }else{
                                if self.riderDriverSwitch.isOn {
                                    //driver
                                    
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Driver"
                                    req?.commitChanges(completion: nil)
                                    
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                }else{
                                //rider
                                    
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Rider"
                                    req?.commitChanges(completion: nil)
                                    
                                self.performSegue(withIdentifier: "RiderSegue", sender: nil)
                                }}
                        })
                        
                    }else{
                        //login
                        Auth.auth().signIn(withEmail: emailtext, password: passwordtext, completion: { (user, error) in
                            
                            if error != nil{
                                
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                                
                            }else{
                                if user?.displayName == "Driver"{
                                    //driver
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    print("Driver")
                                }else{
                                    //rider
                                self.performSegue(withIdentifier: "RiderSegue", sender: nil)
                                    print("rider")
                                }}
                            
                            
                        })
                    }
                }
            }
        }
    }
    
    
    func displayAlert(title: String, message: String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func bottomButtonPressed(_ sender: UIButton) {
        
        if signUpMode{
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
            topbutton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Don't have an Account? Create now.", for: .normal)
            signUpMode = false
        }else{
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
            topbutton.setTitle("Sign Up", for: .normal)
            bottomButton.setTitle("Already have an account? Log In", for: .normal)
            signUpMode = true
        }
    }
    
    
}

