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

// New top level function for login button
func tintBackgroundColor(layer layer: CALayer, toColor: UIColor){
    let tint = CABasicAnimation(keyPath: "backgroundColor")
    tint.fromValue = layer.backgroundColor
    tint.toValue = toColor.CGColor
    tint.duration = 1.0
    layer.addAnimation(tint, forKey: nil)
    layer.backgroundColor = toColor.CGColor
}

func roundCorners(layer layer: CALayer, toRadius: CGFloat){
    let round = CABasicAnimation(keyPath: "cornerRadius")
    round.fromValue = layer.cornerRadius
    round.toValue = toRadius
    round.duration = 0.33
    layer.addAnimation(round, forKey: nil)
    layer.cornerRadius = toRadius
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
    
    let info = UILabel()
    
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
        
        info.frame = CGRect(x: 0.0, y: loginButton.center.y + 55.0, width: view.frame.size.width, height: 30)
        info.backgroundColor = UIColor.clearColor()
        info.font = UIFont(name: "HelveticaNeue", size: 12.0)
        info.textAlignment = .Center
        info.textColor = UIColor.whiteColor()
        info.text = "Tap on a field and enter username and password"
        view.insertSubview(info, belowSubview: loginButton)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loginButton.center.y += 30.0
        loginButton.alpha = 0.0
        
        username.layer.position.x -= view.bounds.width
        password.layer.position.x -= view.bounds.width
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let flyRight = CABasicAnimation(keyPath: "position.x")
        
        flyRight.toValue = view.bounds.size.width/2
        flyRight.fromValue = -view.bounds.size.width/2
        flyRight.duration = 0.5
        flyRight.fillMode = kCAFillModeBoth
        flyRight.delegate = self
        flyRight.setValue("form", forKey: "name")
        flyRight.setValue(heading.layer, forKey: "layer")
        
        heading.layer.addAnimation(flyRight, forKey: nil)
        
        flyRight.beginTime = CACurrentMediaTime() + 0.3
        flyRight.setValue(username.layer, forKey: "layer")
        username.layer.addAnimation(flyRight, forKey: nil)
        username.layer.position.x = view.bounds.size.width/2
        
        flyRight.beginTime = CACurrentMediaTime() + 0.4
        flyRight.setValue(password.layer, forKey: "layer")
        password.layer.addAnimation(flyRight, forKey: nil)
        password.layer.position.x = view.bounds.size.width/2
        
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0.0
        fadeIn.toValue = 1.0
        fadeIn.duration = 0.5
        fadeIn.fillMode = kCAFillModeBackwards
        
        fadeIn.beginTime = CACurrentMediaTime() + 0.5
        cloud1.layer.addAnimation(fadeIn, forKey: nil)
        
        fadeIn.beginTime = CACurrentMediaTime() + 0.7
        cloud2.layer.addAnimation(fadeIn, forKey: nil)
        
        fadeIn.beginTime = CACurrentMediaTime() + 0.9
        cloud3.layer.addAnimation(fadeIn, forKey: nil)
        
        fadeIn.beginTime = CACurrentMediaTime() + 1.1
        cloud4.layer.addAnimation(fadeIn, forKey: nil)
        
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
        
        let flyLeft = CABasicAnimation(keyPath: "position.x")
        flyLeft.fromValue = info.layer.position.x + view.frame.size.width
        flyLeft.toValue = info.layer.position.x
        flyLeft.duration = 5.0
        info.layer.addAnimation(flyLeft, forKey: "infoappear")
        
        let fadeLabelIn = CABasicAnimation(keyPath: "opacity")
        fadeLabelIn.fromValue = 0.2
        fadeLabelIn.toValue = 1.0
        fadeLabelIn.duration = 4.5
        info.layer.addAnimation(fadeLabelIn, forKey: "fadein")
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
        
        //This has been removed and replaced with the code at the bottom of this method
        //3rd user interaction animation: animate button's background color tint
        //        self.loginButton.backgroundColor = UIColor(red: 0.85, green: 0.83, blue: 0.45, alpha: 1.0)
        
        //4th user interaction animation: activity indicator spinner appears
        self.spinner.center = CGPoint(x: 40.0,
            y: self.loginButton.frame.size.height/2)
        self.spinner.alpha = 1.0
        
        //3rd new code
        let tintColor = UIColor(red: 0.85, green: 0.83, blue: 0.45, alpha: 1.0)
        tintBackgroundColor(layer: loginButton.layer,
            toColor: tintColor)
        
        roundCorners(layer: loginButton.layer, toRadius: 25.0)
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
            
            //this line of code is being removed and replaced with the code in completion:
            //                self.loginButton.backgroundColor = UIColor(red: 0.63, green: 0.84, blue: 0.35, alpha: 1.0)
            
            }, completion: {_ in
                let tintColor = UIColor(red: 0.63, green: 0.84, blue: 0.35, alpha: 1.0)
                tintBackgroundColor(layer: self.loginButton.layer, toColor: tintColor)
                roundCorners(layer: self.loginButton.layer, toRadius: 10.0)
        })
        
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
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        print("animation did finish")
        
        if let name = anim.valueForKeyPath("name") as? String {
            if name == "form" {
                //form field found
                let layer = anim.valueForKeyPath("layer") as? CALayer
                anim.setValue(nil, forKey: "layer")
                
                let pulse = CABasicAnimation(keyPath: "transform.scale")
                pulse.fromValue = 1.25
                pulse.toValue = 1.0
                pulse.duration = 0.25
                layer?.addAnimation(pulse, forKey: nil)
            }
        }
    }
    
}