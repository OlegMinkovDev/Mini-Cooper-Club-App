import UIKit

class MCSignInViewController: UIViewController, UITextFieldDelegate {
    
    let IPHONE_4_HEIGHT:CGFloat = 480.0
    let IPHONE_5_HEIGHT:CGFloat = 568.0
    let IPHONE_6_HEIGHT:CGFloat = 667.0
    let IPHONE_6PLUS_HEIGHT:CGFloat = 736.0
    
    let NUMBER_OFFSET_IPHONE_4:CGFloat = 120.0
    let NUMBER_OFFSET_IPHONE_5:CGFloat = 90.0
    let NUMBER_OFFSET_IPHONE_6:CGFloat = 70.0
    let NUMBER_OFFSET_IPHONE_6Plus:CGFloat = 60.0
    
    let PASSWORD_OFFSET_IPHONE_4:CGFloat = 167.0
    let PASSWORD_OFFSET_IPHONE_5:CGFloat = 170.0
    let PASSWORD_OFFSET_IPHONE_6:CGFloat = 190.0
    let PASSWORD_OFFSET_IPHONE_6Plus:CGFloat = 200.0
    
    @IBOutlet weak var loginTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var passL: UILabel!
    @IBOutlet weak var passTFBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    var appDelegate:AppDelegate = AppDelegate()
    var carNumber = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        passTF.delegate = self
        loginTF.layer.cornerRadius = 3.0
        
        self.setDelegateForNumberTextFields()
        self.setCorrectUIElementsPosition()
        
        MCStartViewController.sendFirstRequest()
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "Nav") as! MCNavigationController
        let mcTabBarContrller = controller.topViewController as? MCTabBarController
        mcTabBarContrller?.tabBar.backgroundColor = UIColor.red
        mcTabBarContrller?.tabBar.barTintColor = UIColor.green
        
        loginTF.returnKeyType = UIReturnKeyType.next
        passTF.returnKeyType = UIReturnKeyType.done
        
        let login =  UserDefaults.standard.string(forKey: "Login")
        let password = UserDefaults.standard.string(forKey: "Password")
        
        if login != nil {
            loginTF.text = login
            passTF.text = password
        }
        
        let callStatusBarHeight = UIApplication.shared.statusBarFrame.height
        if callStatusBarHeight == 40 {
            self.loginTF.frame = CGRect(x: self.loginTF.frame.origin.x, y: self.loginTF.frame.origin.y - 12, width: self.loginTF.frame.size.width, height: self.loginTF.frame.size.height)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(MCSignInViewController.receivedData), name: NSNotification.Name(rawValue: "trigger"), object: nil)
    }
    
    
    func receivedData(notification: Notification) {
        
        let data = notification.userInfo
        let callStatusBarHeight = (data?["trigger"] as! CGRect).height
        
        if callStatusBarHeight == 40 {
            self.loginTF.frame = CGRect(x: self.loginTF.frame.origin.x, y: self.loginTF.frame.origin.y - 12, width: self.loginTF.frame.size.width, height: self.loginTF.frame.size.height)
        } else if callStatusBarHeight == 20 {
            self.loginTF.frame = CGRect(x: self.loginTF.frame.origin.x, y: self.loginTF.frame.origin.y + 12, width: self.loginTF.frame.size.width, height: self.loginTF.frame.size.height)
        }
    }
    
    // hide keyboard to press "Return" key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == loginTF {
            
            textField.resignFirstResponder()
            self.passTF.becomeFirstResponder()
            //self.passTF.isHidden = false
            //self.passL.isHidden = false
        
        } else if textField == passTF {
            textField.resignFirstResponder()
            //self.SignIn(self)
        }
        
        return false
    }
    
    // hide keyboard by tapping anywhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.loginTF {
        
            let currentCharacterCount = textField.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.characters.count - range.length
            return newLength <= 9
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.loginTF {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                switch self.detectDeviceModel() {
                case "iPhone 4":
                    self.moveUpNumberUI(self.NUMBER_OFFSET_IPHONE_4)
                case "iPhone 5":
                    self.moveUpNumberUI(self.NUMBER_OFFSET_IPHONE_5)
                case "iPhone 6":
                    self.moveUpNumberUI(self.NUMBER_OFFSET_IPHONE_6)
                case "iPhone 6+":
                    self.moveUpNumberUI(self.NUMBER_OFFSET_IPHONE_6Plus)
                default:
                    print("Doing nothing")
                }
            })
        
        } else if textField == self.passTF {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                switch self.detectDeviceModel() {
                case "iPhone 4":
                    self.passTFBottomConstraint.constant = self.passTFBottomConstraint.constant + self.PASSWORD_OFFSET_IPHONE_4
                case "iPhone 5":
                    self.passTFBottomConstraint.constant = self.passTFBottomConstraint.constant + self.PASSWORD_OFFSET_IPHONE_5
                case "iPhone 6":
                    self.passTFBottomConstraint.constant = self.passTFBottomConstraint.constant + self.PASSWORD_OFFSET_IPHONE_6
                case "iPhone 6+":
                    self.passTFBottomConstraint.constant = self.passTFBottomConstraint.constant + self.PASSWORD_OFFSET_IPHONE_6Plus
                default:
                    print("Doing nothing")
                }
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField != self.passTF {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                switch self.detectDeviceModel() {
                case "iPhone 4":
                    self.moveDownNumberUI(self.NUMBER_OFFSET_IPHONE_4)
                case "iPhone 5":
                    self.moveDownNumberUI(self.NUMBER_OFFSET_IPHONE_5)
                case "iPhone 6":
                    self.moveDownNumberUI(self.NUMBER_OFFSET_IPHONE_6)
                case "iPhone 6+":
                    self.moveDownNumberUI(self.NUMBER_OFFSET_IPHONE_6Plus)
                default:
                    print("Doing nothing")
                }
            })
        
        } else {
            
            UIView.animate(withDuration: 0.5, animations: {
            
                switch self.detectDeviceModel() {
                case "iPhone 4":
                    self.passTFBottomConstraint.constant = self.passTFBottomConstraint.constant - self.PASSWORD_OFFSET_IPHONE_4
                case "iPhone 5":
                    self.passTFBottomConstraint.constant = self.passTFBottomConstraint.constant - self.PASSWORD_OFFSET_IPHONE_5
                case "iPhone 6":
                    self.passTFBottomConstraint.constant = self.passTFBottomConstraint.constant - self.PASSWORD_OFFSET_IPHONE_6
                case "iPhone 6+":
                    self.passTFBottomConstraint.constant = self.passTFBottomConstraint.constant - self.PASSWORD_OFFSET_IPHONE_6Plus
                default:
                    print("Doing nothing")

                }
            })
            
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func SignIn(_ sender: AnyObject) {
        
        self.indicatorView.startAnimating()
        self.appDelegate.car_namber = self.loginTF.text!.lowercased()
        
        let postRequestForActionAuth = "&car_number=" + self.appDelegate.car_namber + "&pas=" + self.passTF.text! + "&act=auth"
        
        self.appDelegate.sendPostRequest(postRequestForActionAuth, completionHandler: { (responseFromActionAuth) in
            
            let error = Error()
            if !error.exist(responseFromActionAuth) {
                
                UserDefaults.standard.set(self.loginTF.text?.lowercased(), forKey: "Login")
                UserDefaults.standard.set(self.passTF.text, forKey: "Password")
                    
                DispatchQueue.main.async(execute: {
                    self.indicatorView.stopAnimating()
                    self.performSegue(withIdentifier: "toTabBarController", sender: self)
                })
                
            } else {
                
                let alertController = UIAlertController(title: "Ошибка", message: error.getDesc(), preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                    self.indicatorView.stopAnimating()
                })
                
                alertController.addAction(defaultAction)
                
                DispatchQueue.main.async(execute: {
                    self.present(alertController, animated: true, completion: nil)
                })
            }
        })
    }
    
    func setCorrectUIElementsPosition() {
        
        self.allowChangeConstraints()
        
        switch self.detectDeviceModel() {
        case "iPhone 4":
            self.setUIElementsForIPhone4()
        case "iPhone 5":
            self.setUIElementsForIPhone5()
        case "iPhone 6":
            self.setUIElementsForIPhone6()
        case "iPhone 6+":
            self.setUIElementsForIPhone6Plus()
        default:
            self.setUIElementsForIPhone5()
        }
    }
    
    func detectDeviceModel() -> String {
        
        let screenHeight = UIScreen.main.bounds.height
        
        if screenHeight == IPHONE_4_HEIGHT {
            return "iPhone 4"
        } else if screenHeight == IPHONE_5_HEIGHT {
            return "iPhone 5"
        } else if screenHeight == IPHONE_6_HEIGHT {
            return "iPhone 6"
        } else { return "iPhone 6+" }
    }
    
    func setUIElementsForIPhone4() {
        
        self.loginTF.frame = CGRect(x: 58, y: 302, width: 199, height: 35)
        self.passTFBottomConstraint.constant = 30
    }
    
    func setUIElementsForIPhone5() {
        
        self.loginTF.frame = CGRect(x: 58, y: 358, width: 199, height: 41)
        self.passTFBottomConstraint.constant = 40
    }
    
    func setUIElementsForIPhone6() {
        
        self.loginTF.frame = CGRect(x: 67, y: 420, width: 234, height: 49)
        self.passTFBottomConstraint.constant = 80
    }
    
    func setUIElementsForIPhone6Plus() {
        
        self.loginTF.frame = CGRect(x: 74, y: 463, width: 258, height: 55)
        self.passTFBottomConstraint.constant = 100
    }
    
    func allowChangeConstraints() {
        self.loginTF.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func setDelegateForNumberTextFields() {
        self.loginTF.delegate = self
    }
    
    func moveUpNumberUI(_ offset: CGFloat) {
        
        self.loginTF.frame = CGRect(x: self.loginTF.frame.origin.x, y: self.loginTF.frame.origin.y - offset, width: self.loginTF.frame.width, height: self.loginTF.frame.height)
    }
    
    func moveDownNumberUI(_ offset: CGFloat) {
    
        self.loginTF.frame = CGRect(x: self.loginTF.frame.origin.x, y: self.loginTF.frame.origin.y + offset, width: self.loginTF.frame.width, height: self.loginTF.frame.height)
    }
    
    func moveUpPassTF(_ offset: CGFloat) {
    
        self.passTF.frame = CGRect(x: self.passTF.frame.origin.x, y: self.passTF.frame.origin.y - offset, width: self.passTF.frame.width, height: self.passTF.frame.height)
    }
    
    func moveDownPassTF(_ offset: CGFloat) {
        
        self.passTF.frame = CGRect(x: self.passTF.frame.origin.x, y: self.passTF.frame.origin.y + offset, width: self.passTF.frame.width, height: self.passTF.frame.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
