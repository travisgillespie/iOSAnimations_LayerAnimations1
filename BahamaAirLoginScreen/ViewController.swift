//
//  ViewController.swift
//  BahamaAirLoginScreen
//
//  Created by Travis Gillespie on 12/14/15.
//  Copyright © 2015 Travis Gillespie. All rights reserved.
//

import UIKit

// A delay function
func delay(seconds seconds: Double, completion:()->()){
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var cloud1: UIImageView!
    @IBOutlet weak var cloud2: UIImageView!
    @IBOutlet weak var cloud3: UIImageView!
    @IBOutlet weak var cloud4: UIImageView!
    
    // MARK: further UI
    
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    let status = UIImageView(image: UIImage(named: "banner"))
    let label = UILabel()
    let messages = ["Connecting ...", "Authorizing ...", "Sending credentials ...", "Failed"]
    
    var statusPosition = CGPoint.zero
    
    // MARK view controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up the UI
        loginButton.layer.cornerRadius = 8.0
        loginButton.layer.masksToBounds = true
        
        spinner.frame = CGRect(x: -20.0, y: 6.0, width: 20.0, height: 20.0)
        spinner.startAnimating()
        spinner.alpha = 0.0
        loginButton.addSubview(spinner)
        
        status.hidden = true
        status.center = loginButton.center
        view.addSubview(status)
        
        label.frame = CGRect(x: 0.0, y: 0.0, width: status.frame.size.width, height: status.frame.size.height)
        label.font = UIFont(name: "HelveticaNeue", size: 18.0)
        label.textColor = UIColor(red: 0.89, green: 0.38, blue: 0.0, alpha: 1.0)
        label.textAlignment = .Center
        status.addSubview(label)
        
        statusPosition = status.center
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cloud1.alpha = 0.0
        cloud2.alpha = 0.0
        cloud3.alpha = 0.0
        cloud4.alpha = 0.0
        
        loginButton.center.y += 30.0
        loginButton.alpha = 0.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //these 4 lines of code are going to help eliminate the animation calls below
        let flyRight = CABasicAnimation(keyPath: "position.x")
        flyRight.fromValue = -view.bounds.size.width/2
        flyRight.toValue = view.bounds.size.width/2
        flyRight.duration = 0.5
        flyRight.fillMode = kCAFillModeBoth
        heading.layer.addAnimation(flyRight, forKey: nil)
        
        flyRight.beginTime = CACurrentMediaTime() + 0.3
        username.layer.addAnimation(flyRight, forKey: nil)
        
        //Replace animation call w/ the two lines of code below it
        //        UIView.animateWithDuration(0.5, delay: 0.4,
        //            usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0,
        //            options: [], animations: {
        //                self.password.center.x += self.view.bounds.width
        //            }, completion: nil)
        
        flyRight.beginTime = CACurrentMediaTime() + 0.4
        password.layer.addAnimation(flyRight, forKey: nil)
        
        UIView.animateWithDuration(0.5, delay: 0.5, options: [], animations: {
            self.cloud1.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.7, options: [], animations: {
            self.cloud2.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 0.9, options: [], animations: {
            self.cloud3.alpha = 1.0
            }, completion: nil)
        UIView.animateWithDuration(0.5, delay: 1.1, options: [], animations: {
            self.cloud4.alpha = 1.0
            }, completion: nil)
        
        UIView.animateWithDuration(0.5, delay: 0.5,
            usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0,
            options: [],
            animations: {
                self.loginButton.center.y -= 30.0
                self.loginButton.alpha = 1.0
            }, completion: nil)
        
        animateCloud(cloud1)
        animateCloud(cloud2)
        animateCloud(cloud3)
        animateCloud(cloud4)
    }
    
    
    // MARK: further methods
    @IBAction func login(sender: UIButton) {
        view.endEditing(true)
        
        //1st user interaction animation: button grows & bounces
        UIView.animateWithDuration(1.5, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            self.loginButton.bounds.size.width += 80.0
            }, completion: {_ in
                self.showMessage(index: 1)
        })
        
        //2nd user interaction animation: button moves down 60 points
        UIView.animateWithDuration(0.33, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            self.loginButton.center.y += 60.0
            }, completion: nil)
        
        //3rd user interaction animation: animate button's background color tint
        self.loginButton.backgroundColor = UIColor(red: 0.85, green: 0.83, blue: 0.45, alpha: 1.0)
        
        //4th user interaction animation: activity indicator spinner appears
        self.spinner.center = CGPoint(x: 40.0,
            y: self.loginButton.frame.size.height/2)
        self.spinner.alpha = 1.0
        
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextField = (textField === username) ? password : username
        nextField.becomeFirstResponder()
        return true
    }
    
    func showMessage(index index: Int){
        label.text = messages[index]
        
        //changed transition to TransitionFlipFromBottom... this transition presents the banner smooth/clean
        UIView.transitionWithView(status, duration: 0.33, options: [.CurveEaseOut, .TransitionFlipFromBottom], animations: {
            self.status.hidden = false
            }, completion: {_ in
                //transition completion
                delay(seconds: 0.2) {
                    if index < self.messages.count-1{
                        self.removeMessage(index: index)
                    } else {
                        //reset form
                        self.resetForm()
                    }
                }
                
        })
    }
    
    func removeMessage(index index: Int){
        UIView.animateWithDuration(0.33, delay: 0.0, options: [], animations:
            {
                self.status.center.x += self.view.frame.size.width
            }, completion: {_ in
                self.status.hidden = true
                self.status.center = self.statusPosition
                
                self.showMessage(index: index+1)
        })
    }
    
    func resetForm(){
        UIView.transitionWithView(status, duration: 0.2, options: [.TransitionFlipFromTop], animations: {
            self.status.hidden = true
            self.status.center = self.statusPosition
            }, completion: nil)
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: [], animations: {
            self.spinner.center = CGPoint(x: -20.0, y: 16.0)
            self.spinner.alpha = 0.0
            self.loginButton.backgroundColor = UIColor(red: 0.63, green: 0.84, blue: 0.35, alpha: 1.0)
            
            //              can reverse login button animations here... but placing them in their own method to create a visual that catches the eye
            
            //                self.loginButton.bounds.size.width -= 80.0
            //                self.loginButton.center.y -= 60.0
            
            }, completion: nil)
        
        //reverse login button animation 1
        UIView.animateWithDuration(1.5, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            self.loginButton.bounds.size.width -= 80.0
            }, completion: nil)
        
        //reverse login button animation 2
        UIView.animateWithDuration(0.33, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            self.loginButton.center.y -= 60.0
            }, completion: nil)
        
    }
    
    func animateCloud(cloud: UIImageView){
        let cloudSpeed = 60.0 / view.frame.size.width
        let duration = (view.frame.size.width - cloud.frame.origin.x) * cloudSpeed
        
        UIView.animateWithDuration(NSTimeInterval(duration), delay: 0.0, options: .CurveLinear, animations: {
            cloud.frame.origin.x = self.view.frame.size.width
            }, completion: {_ in
                cloud.frame.origin.x = -cloud.frame.size.width
                self.animateCloud(cloud)
                //                self.animateCloud(cloud2)
                //                self.animateCloud(cloud3)
                //                self.animateCloud(cloud4)
                
                
        })
        
    }
    
}