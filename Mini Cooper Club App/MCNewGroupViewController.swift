import UIKit

class MCNewGroupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var groupSubjectTF: UITextField!
    
    var charArr:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.groupSubjectTF.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.groupSubjectTF.becomeFirstResponder()
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        
        self.groupSubjectTF.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func next(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toMCAddParticipantsViewController", sender: self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string != "" {
            self.charArr.append(string)
        } else { self.charArr.removeLast() }
        
        if self.charArr.count > 0 {
            self.nextB.isEnabled = true
        } else { self.nextB.isEnabled = false }
        
        
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let viewController = segue.destination as? MCAddParticipantsViewController {
            viewController.subjectGroup = self.groupSubjectTF.text!
        }
    }
    

}
