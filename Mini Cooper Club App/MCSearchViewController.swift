import UIKit
import GoogleMaps

class MCSearchViewController: UIViewController/*, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, RouteProtocol*/ {
    
    /*@IBOutlet weak var tableView: UITableView!
    
    var flag = false
    var isA = false
    var cellFrom = RouteCell()
    var cellTo = RouteCell()
    var origin = String()
    var destination = String()*/

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.delegate = self
        //tableView.dataSource = self
        //tableView.isScrollEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.tabBarController?.navigationItem.title = "Поиск"
        //self.tabBarController?.navigationItem.rightBarButtonItem = nil
        //self.tabBarController?.navigationItem.leftBarButtonItem = nil
    }
    
    /*func setTextToTextField(_ text: String, isA: Bool) {
        
        let greebColor = UIColor.init(red: 60/255, green: 182/255, blue: 2/255, alpha: 1)
        let blueColor = UIColor.init(red: 46/255, green: 196/255, blue: 236/255, alpha: 1)
        
        cellFrom = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! RouteCell
        cellTo = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! RouteCell
        
        cellFrom.textTF.textColor = greebColor
        cellTo.textTF.textColor = blueColor
        
        if isA { cellFrom.textTF.text = text }
        else { cellTo.textTF.text = text }
    }

    @IBAction func Change(_ sender: AnyObject) {
        
        let greebColor = UIColor.init(red: 60/255, green: 182/255, blue: 2/255, alpha: 1)
        let blueColor = UIColor.init(red: 46/255, green: 196/255, blue: 236/255, alpha: 1)
        
        cellFrom = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! RouteCell
        cellTo = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! RouteCell
        
        if !flag {
            
            
            cellFrom.textTF.attributedPlaceholder = NSAttributedString(string:"От", attributes:[NSForegroundColorAttributeName: greebColor])
            cellTo.textTF.attributedPlaceholder = NSAttributedString(string:"Текущая позиция", attributes:[NSForegroundColorAttributeName: blueColor])
            
            let text = cellFrom.textTF.text
            cellFrom.textTF.text = cellTo.textTF.text
            cellTo.textTF.text = text
            
            flag = true
            
        } else {
            
            cellFrom.textTF.attributedPlaceholder = NSAttributedString(string:"Текущая позиция", attributes:[NSForegroundColorAttributeName: greebColor])
            cellTo.textTF.attributedPlaceholder = NSAttributedString(string:"Назначение", attributes:[NSForegroundColorAttributeName: blueColor])
            
            let text = cellTo.textTF.text
            cellTo.textTF.text = cellFrom.textTF.text
            cellFrom.textTF.text = text

            flag = false
        }
    }
    
    @IBAction func GetDirection(_ sender: AnyObject) {
        
        cellFrom = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! RouteCell
        cellTo = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! RouteCell
        
        if (cellFrom.textTF.placeholder == "От" && cellFrom.textTF.text != "") || cellTo.textTF.placeholder == "Назначение" && cellTo.textTF.text != "" {
            
            if cellFrom.textTF.text != "" {
                self.origin = cellFrom.textTF.text!
            } else { self.origin = "Current location" }
            
            if cellTo.textTF.text != "" {
                self.destination = cellTo.textTF.text!
            } else { self.destination = "Current location" }
            
            self.performSegue(withIdentifier: "toMCGetDirectionViewController", sender: self)
        }
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let greebColor = UIColor.init(red: 60/255, green: 182/255, blue: 2/255, alpha: 1)
        let blueColor = UIColor.init(red: 46/255, green: 196/255, blue: 236/255, alpha: 1)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RouteCell", for: indexPath) as! RouteCell
        
        if (indexPath as NSIndexPath).row == 0 {
            cell.textTF.attributedPlaceholder = NSAttributedString(string:"Текущая позиция", attributes:[NSForegroundColorAttributeName: greebColor])
            cell.iconIV.image = UIImage(named: "greenIcon.png")
            cell.imageIV.image = UIImage(named: "greenA.png")
            cell.textTF.delegate = self
            cell.textTF.isUserInteractionEnabled = false
        } else {
            cell.textTF.attributedPlaceholder = NSAttributedString(string:"Назначение", attributes:[NSForegroundColorAttributeName: blueColor])
            cell.iconIV.image = UIImage(named: "blueIcon.png")
            cell.imageIV.image = UIImage(named: "blueB.png")
            cell.textTF.delegate = self
            cell.textTF.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if (indexPath as NSIndexPath).row == 0 {
            isA = true
        } else { isA = false }
        
        self.performSegue(withIdentifier: "toMCRouteViewController", sender: self)
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewController = segue.destination as? MCRouteViewController {
            viewController.isA = isA
            viewController.delegate = self
        }
        
        if let viewController = segue.destination as? MCGetDirectionViewController {
            viewController.origin = self.origin
            viewController.destination = self.destination
        }
    }*/
    
}
