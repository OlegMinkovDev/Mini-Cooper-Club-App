import UIKit
//import GoogleMaps

/*protocol RouteProtocol {
    func setTextToTextField(_ text: String, isA: Bool)
}*/

class MCRouteViewController: UIViewController/*, UISearchBarDelegate, LocateOnTheMap*/ {

    /*var searchResultController: MCSearchResultsController!
    var resultsArray = [String]()
    var delegate: RouteProtocol? = nil
    var text = String()
    
    var isA = false*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*searchResultController = MCSearchResultsController()
        searchResultController.delegate = self
        
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)*/
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //super.viewDidDisappear(animated)
    
        //self.delegate?.setTextToTextField(self.text, isA: self.isA)
    }
    
    /*func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let placeClient = GMSPlacesClient()
        placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error: NSError?) -> Void in
            
            self.resultsArray.removeAll()
            if results == nil {
                return
            }
            
            for result in results! {
                if let res = result as GMSAutocompletePrediction? {
                    self.resultsArray.append(res.attributedFullText.string)
                }
            }
            
            self.searchResultController.reloadDataWithArray(self.resultsArray)
        }
    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        DispatchQueue.main.async { () -> Void in
            
            self.text = title
            self.navigationController?.popViewController(animated: true)
        }
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
