//
//  SelectCountryVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 06/05/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit

protocol SelectCountyDelegate {
    
    func getSelectedCountryData(dicCountryData:[String:Any])
}

class SelectCountryVC: BaseViewController,ServiceManagerDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    //MARK:- outlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblCountryList: UITableView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var constrainBottomBtnDone: NSLayoutConstraint!
    
    //MARK:- variable
    let utils = Utils()
    let serviceManager = ServiceManager()
    let doFetchCountryList = "do fetch country list for select country VC"
    let componentManager = UIComponantManager()
    var delegate : SelectCountyDelegate?
    var arrCountry = [[String:Any]]()
    var arrSectionTitle = [String]()
    var dicCountryList = [String:Any]()
    var dicFilterCountryList = [String:Any]()
    var dicSelectedCountry = [String:Any]()
    
    //MARK:- ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //show navigation bar
        self.navigationController?.navigationBar.isHidden = false
        self.setupNavigationBar()
        
        componentManager.registerTableViewCell(cellName: "CustomCountryTableViewCell", to: tblCountryList)
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        serviceManager.delegate = self
        searchBar.delegate = self
        
        //call api to get country data
        self.callCountryDataAPI()
        
    }
    
    //MARK:- setupUI
    func setupUI(){
        btnDone.cornerRadius = btnDone.Getheight/2
        
        //set observer to get height of keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    //MARK:- setup Navigation Bar
    func setupNavigationBar()
    {
        self.addLeftBarButton()
         self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    func addLeftBarButton() {
        
        self.navigationItem.setHidesBackButton(true, animated:false)
        
        //your custom view for back image with custom size
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 20, height: 20))
        if let imgBackArrow = UIImage(named: "ic_back") {
            imageView.image = imgBackArrow
        }
        view.addSubview(imageView)
        
        let backTitle = UILabel(frame: CGRect(x: 25, y: 5, width: 80, height: 30))
        backTitle.text = "Back"
        view.addSubview(backTitle)
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backBtnPressed))
        view.addGestureRecognizer(backTap)
        
        let leftBarButtonItem = UIBarButtonItem(customView: view )
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    
    //MARK:- keyboard event
    @objc func keyboardWillHide(_ notification: NSNotification) {
        
        DispatchQueue.main.async {
            self.constrainBottomBtnDone.constant = 20
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("keyboard height = \(keyboardRect.height)")
            
            let safeAreaBottomInset = self.view.safeAreaInsets.bottom
            
            DispatchQueue.main.async {
                self.constrainBottomBtnDone.constant = (keyboardRect.size.height - safeAreaBottomInset + 20);
                self.view.layoutIfNeeded()
            }
        }
    }
    
    //MARK:- search bar delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // This method updates filteredData based on the text in the Search Box
        
        if searchText == ""
        {
            dicFilterCountryList = dicCountryList
        }
        else
        {
            //empty previously loaded value
            dicFilterCountryList = [String:Any]()
            
            //load all Names for perticular Character ...for ex. if first character is "A" then load all country which names start from "A"
            let firstCharacter = String(searchText.prefix(1))
            let arrTemp = dicCountryList[firstCharacter] as? [[String:Any]]
            dicFilterCountryList[firstCharacter] = arrTemp
            
            //then search more from array value
            var arrTemp1 = dicFilterCountryList[firstCharacter] as? [[String:Any]]
            arrTemp1 = arrTemp1?.filter { ($0["countryName"] as! String).lowercased().contains(searchText.lowercased()) }.map { $0 }
            
            dicFilterCountryList[firstCharacter] = arrTemp1
            
        }
        
        //make section title list
        arrSectionTitle = dicFilterCountryList.map({ $0.key}).sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
        
        self.tblCountryList.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    
    //MARK:- Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return dicFilterCountryList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionTitle = arrSectionTitle[section]
        let arrSection = dicFilterCountryList [sectionTitle] as? [[String:Any]]
        
        return arrSection?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCountryTableViewCell", for: indexPath ) as! CustomCountryTableViewCell
        
        let sectionTitle = arrSectionTitle[indexPath.section]
        let arrSection = dicFilterCountryList[sectionTitle] as? [[String:Any]]
        
        cell.countryImg.image = (arrSection?[indexPath.row]["imageString"] as! String).base64ToImage()
        cell.contentMode = .scaleToFill
        cell.countryNameTxt.text = (arrSection?[indexPath.row]["countryName"] as! String)
        
        //hide show selection image
        if (arrSection?[indexPath.row]["countryName"] as? String) == (dicSelectedCountry["countryName"] as? String)
        {
            cell.imgSelected.isHidden = false
        }
        else
        {
            cell.imgSelected.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return arrSectionTitle[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return arrSectionTitle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sectionTitle = arrSectionTitle[indexPath.section]
        let arrSection = dicFilterCountryList[sectionTitle] as? [[String:Any]]
        dicSelectedCountry = arrSection?[indexPath.row] ?? [String:Any]()
        self.tblCountryList.reloadData()
    }
    
    
    //MARK:- Service manager delegate
    
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        if tagname == doFetchCountryList{
            self.parseCountryApiData(response: response)
        }
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    //MARK:- Calling API
    
    func callCountryDataAPI()
    {
        if utils.connected(){
            let webPath = "\(BASE_URL)\(COUNTRY_API)"
            serviceManager.callWebServiceWithGET(webpath: webPath, withTag: doFetchCountryList)
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseCountryApiData(response:Any?){
        if response != nil
        {
            let arrResponseData = response as! [[String:Any]]
            arrCountry = arrResponseData
            
            for dicCountryData in arrCountry{
                let countryName = dicCountryData["countryName"] as! String
                var firstCharacter = String(countryName.prefix(1))
                
                if firstCharacter == "Ã"
                {
                    firstCharacter = "A"
                }
                
                if dicCountryList[firstCharacter] != nil {
                    // now val is not nil and the Optional has been unwrapped, so use it
                    var arrTemp = dicCountryList[firstCharacter]  as? [[String:Any]]
                    arrTemp?.append(dicCountryData)
                    
                    //sort array according to "countryName"
                    arrTemp = (arrTemp! as NSArray).sortedArray(using: [NSSortDescriptor(key: "countryName", ascending: true)]) as? [[String:Any]]
                    
                    dicCountryList[firstCharacter] = arrTemp
                }
                else
                {
                    var arrTemp = [[String:Any]]()
                    arrTemp.append(dicCountryData)
                    dicCountryList[firstCharacter] = arrTemp
                }
            }
            
            dicFilterCountryList = dicCountryList
            //make section title list
            arrSectionTitle = dicCountryList.map({ $0.key}).sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            tblCountryList.reloadData()
            
        }
    }
    
    //MARK:- btn click
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneClicked(_ sender: Any) {
        if delegate != nil{
            delegate?.getSelectedCountryData(dicCountryData: dicSelectedCountry)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
