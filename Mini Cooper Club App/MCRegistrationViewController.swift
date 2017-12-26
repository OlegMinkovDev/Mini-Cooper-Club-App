import UIKit

class MCRegistrationViewController: UIViewController, UITextFieldDelegate {
    
    let IPHONE_4_HEIGHT:CGFloat = 480.0
    let IPHONE_5_HEIGHT:CGFloat = 568.0
    let IPHONE_6_HEIGHT:CGFloat = 667.0
    let IPHONE_6PLUS_HEIGHT:CGFloat = 736.0
    
    let IPHONE4_CONSTRAINT:CGFloat = 80.0
    let IPHONE4_CONSTRAINT_OFFSET:CGFloat = 180.0
    let IPHONE5_CONSTRAINT:CGFloat = 120.0
    let IPHONE6_CONSTRAINT:CGFloat = 170.0
    let IPHONE6PLUS_CONSTRAINT:CGFloat = 200.0
    
    @IBOutlet weak var nickNameTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var autoNumberTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var acceptPassTF: UITextField!
    
    @IBOutlet weak var autoNumberIV: UIImageView!
    @IBOutlet weak var nameIV: UIImageView!
    @IBOutlet weak var nickNameIV: UIImageView!
    @IBOutlet weak var passIV: UIImageView!
    
    @IBOutlet weak var autoLine: UIView!
    @IBOutlet weak var nameLine: UIView!
    @IBOutlet weak var nickNameLine: UIView!
    @IBOutlet weak var passLine: UIView!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var distanceBetweenButtonAndPassLine: NSLayoutConstraint!
    
    var appDelegate:AppDelegate = AppDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        self.setDelegateForTextFields()
        self.setPlaceholderTextsAndFonts()
        self.setCorrectOffset()
        
        nameTF.autocapitalizationType = UITextAutocapitalizationType.words
        autoNumberTF.layer.cornerRadius = 3.0
        
        autoNumberTF.returnKeyType = .next
        nameTF.returnKeyType = .next
        nickNameTF.returnKeyType = .next
        passTF.returnKeyType = .next
        acceptPassTF.returnKeyType = .done
    }
    
    @IBAction func Back(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if self.detectDeviceModel() == "iPhone 4" || self.detectDeviceModel() == "iPhone 5" {
            
            if textField == nickNameTF || textField == passTF || textField == nameTF || textField == acceptPassTF {
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.distanceBetweenButtonAndPassLine.constant = self.IPHONE4_CONSTRAINT_OFFSET
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if self.detectDeviceModel() == "iPhone 4" {
            
            if textField == nickNameTF || textField == passTF || textField == nameTF || textField == acceptPassTF {
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.distanceBetweenButtonAndPassLine.constant = self.IPHONE4_CONSTRAINT
                    self.view.layoutIfNeeded()
                })
            }
        
        } else if self.detectDeviceModel() == "iPhone 5" {
            
            if textField == nickNameTF || textField == passTF || textField == nameTF || textField == acceptPassTF {
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.distanceBetweenButtonAndPassLine.constant = self.IPHONE5_CONSTRAINT
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.autoNumberTF {
        
            let currentCharacterCount = textField.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.characters.count - range.length
            return newLength <= 9
        }
        
        return true
    }
    
    // hide keyboard to press "Return" key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == autoNumberTF {
            textField.resignFirstResponder()
            self.nameTF.becomeFirstResponder()
        } else if textField == nameTF {
            textField.resignFirstResponder()
            self.nickNameTF.becomeFirstResponder()
        } else if textField == nickNameTF {
            textField.resignFirstResponder()
            self.passTF.becomeFirstResponder()
        } else if textField == passTF {
            textField.resignFirstResponder()
            self.acceptPassTF.becomeFirstResponder()
        } else if textField == acceptPassTF {
            
            DispatchQueue.main.async(execute: {
                self.view.endEditing(true)
            });
            
            //self.Registration(self)
        }
        
        return false
    }
    
    // hide keyboard by tapping anywhere
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func Registration(_ sender: AnyObject) {
        
        self.indicatorView.startAnimating()
        
        if passTF.text == acceptPassTF.text {
            
            var postRequestForActionReg = "&name=" + self.nameTF.text! +  "&nickname=" + self.nickNameTF.text! + "&car_number=" + self.autoNumberTF.text! + "&pas=" + self.passTF.text!
            postRequestForActionReg += "&act=reg"
            
            self.appDelegate.sendPostRequest(postRequestForActionReg, completionHandler: { (responseFromActionReg) in
                
                let error = Error()
                if !error.exist(responseFromActionReg) {
                    
                    let alertController = UIAlertController(title: "Сообщение", message: "Вы успешно зарегистрированы", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "Продолжить", style: .default, handler: { (action) in
                        self.indicatorView.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                    alertController.addAction(defaultAction)
                    
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Ошибка", message: error.getDesc(), preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                        self.indicatorView.stopAnimating()
                    })
                    
                    alertController.addAction(defaultAction)
                    
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            })
        
        } else {
            
            let alertController = UIAlertController(title: "Ошибка", message: "Поле пароль и подтверждение пароля не совпадают", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
            self.indicatorView.stopAnimating()
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

    func setCorrectOffset() {
        
        switch self.detectDeviceModel() {
        case "iPhone 4":
            self.distanceBetweenButtonAndPassLine.constant = self.IPHONE4_CONSTRAINT
        case "iPhone 5":
            self.distanceBetweenButtonAndPassLine.constant = self.IPHONE5_CONSTRAINT
        case "iPhone 6":
            self.distanceBetweenButtonAndPassLine.constant = self.IPHONE6_CONSTRAINT
        case "iPhone 6+":
            self.distanceBetweenButtonAndPassLine.constant = self.IPHONE6PLUS_CONSTRAINT
        default:
            print("")
        }
    }
    
    func setDelegateForTextFields() {
        
        self.nameTF.delegate = self
        self.autoNumberTF.delegate = self
        self.passTF.delegate = self
        self.nickNameTF.delegate = self
        self.acceptPassTF.delegate = self
    }
    
    func setPlaceholderTextsAndFonts() {
        
        let color = UIColor.init(colorLiteralRed: 187, green: 187, blue: 187, alpha: 1)
        
        self.nameTF.attributedPlaceholder = NSAttributedString(string:"Имя",
                                                               attributes:[NSForegroundColorAttributeName: color])
        self.nickNameTF.attributedPlaceholder = NSAttributedString(string:"Никнейм",
                                                                   attributes:[NSForegroundColorAttributeName: color])
        self.passTF.attributedPlaceholder = NSAttributedString(string:"Пароль",
                                                               attributes:[NSForegroundColorAttributeName: color])
        self.acceptPassTF.attributedPlaceholder = NSAttributedString(string:"Подтверждение пароля",
                                                               attributes:[NSForegroundColorAttributeName: color])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
