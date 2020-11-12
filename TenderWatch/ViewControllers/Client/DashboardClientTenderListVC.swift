//
//  ClientTenderListVC.swift
//  TenderWatch
//
//  Created by lcom on 28/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import SideMenu


class DashboardClientTenderListVC: BaseViewController,ServiceManagerDelegate,UISearchBarDelegate{
    
    //MARK:- outlet
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var tblViewTenderList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var constrainBottomTblViewTenderList: NSLayoutConstraint!
    @IBOutlet weak var btnAddTender: UIButton!
    
    //MARK:- variable
    let utils = Utils()
    let serviceManager = ServiceManager()
    let doGetTenderForClient = "do get tender for client"
    let doRemoveTender = "do Remove Tender for DashboardClientTenderListVC"
    let doSendDetailForRemoveTender = "do Send Detail For Remove Tender for DashboardClientTenderListVC"
    let doGetTenderDetails = "do get Tender Details"
    let doGetInterestedContractor = "do get Interested Contractor for DashboardClientTenderListVC"
    let doFetchCategoryInfo = "do Fetch Category Info For DashBoard"
    let doFetchCountryInfo = "do Fetch Country Info For DashBoard"
    let componentManager = UIComponantManager()
    var arrTenders = [[String:Any]]()
    var arrFilteredTenders = [[String:Any]]()
    let refreshControl = UIRefreshControl()
    var isPullToRefreshRunning  = false
    var strSelectedTenderId = ""
    var arrInterestedContractors = [[String:Any]]()
    var dicSelectedTenderData = [String:Any]()
    let doAddFavoriteTender =  "do Add Favorite Tender for DashboardClientTenderListVC"
    var arrAllCategory : [[String:Any]] = []
    var arrAllCountry : [[String:Any]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //show navigation bar
        self.navigationController?.navigationBar.isHidden = false
        self.setupNavigationBar()
        self.setupSidemenu()
        componentManager.registerTableViewCell(cellName: "TblTenderListCell", to: tblViewTenderList)
        
        serviceManager.delegate = self
        searchBar.delegate = self
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        self.callCategoryDataAPI()
        self.callCountryDataAPI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //call api for fetch data
        self.callGetTenderForClientApi()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    //MARK:- setupUI
    func setupUI(){
        btnAddTender.cornerRadius = btnAddTender.Getheight/2
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tblViewTenderList.refreshControl = refreshControl
        
        //set today's date
        lblDate.text = "Date:" + Date().formateDate(format: "EEEE MMM dd YYYY")
        
        //set observer to get height of keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        //add long press gesture to table
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(sender:)))
        tblViewTenderList.addGestureRecognizer(longPress)
        
        if utils.getUserType() == USER_CONTRACTOR
        {
            btnAddTender.isHidden = true
        }
        else
        {
            btnAddTender.isHidden = false
        }
        
        
    }
    
    @objc func pullToRefresh(refreshControl: UIRefreshControl) {
        
        if !isPullToRefreshRunning{
            //clear serach bar
            self.searchBar.text = ""
            
            //set flag
            isPullToRefreshRunning = true
            self.callGetTenderForClientApi()
        }
        
    }
    
    //MARK:- setup navigation bar
    func setupNavigationBar() {
        self.setNavigationBarHeaderTitle(strTitle: "TenderWatch")
        self.addLeftBarButton()
    }
    
    func setupSidemenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sideMenuVC = storyboard.instantiateViewController(withIdentifier: "SideMenuVC")
        let menuLeftNavigationController = SideMenuNavigationController(rootViewController: sideMenuVC)
        menuLeftNavigationController.leftSide = true
        menuLeftNavigationController.navigationBar.isHidden = true
        menuLeftNavigationController.statusBarEndAlpha = 0
        menuLeftNavigationController.menuWidth = 300
        SideMenuManager.default.leftMenuNavigationController = menuLeftNavigationController
        SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.view)
        
    }
    
    
    func setNavigationBarHeaderTitle(strTitle:String)
    {
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 21)]
        
        SetNavigationBarTitle(string: strTitle)
    }
    func addLeftBarButton() {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(UIImage(named: "menu"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 1, bottom: 5, right: 1)
        button.addTarget(self, action: #selector(slideMenuPressed), for: UIControl.Event.touchUpInside)
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        view.addSubview(button)
        let barButton = UIBarButtonItem(customView: view)
        self.navigationItem.leftBarButtonItem = barButton
    }
    //MARK:- keyboard event
    @objc func keyboardWillHide(_ notification: NSNotification) {
        
        DispatchQueue.main.async {
            self.constrainBottomTblViewTenderList.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardDidShow(_ notification: NSNotification) {
        
        if let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("keyboard height = \(keyboardRect.height)")
            
            let safeAreaBottomInset = self.view.safeAreaInsets.bottom
            
            DispatchQueue.main.async {
                self.constrainBottomTblViewTenderList.constant = -(keyboardRect.size.height - safeAreaBottomInset);
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    //MARK:- handle long press of table
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: tblViewTenderList)
            if let indexPath = tblViewTenderList.indexPathForRow(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                print(indexPath)
                
                //selected tender
                let dicTender = arrFilteredTenders[indexPath.row]
                dicSelectedTenderData = dicTender
                
                if utils.getUserType() == USER_CONTRACTOR
                {
                    self.showAlertForFavoriteOrDeleteTender()
                }
                else
                {
                    self.showAlertForEditOrDeleteTender()
                }
                
            }
        }
    }
    
    func showAlertForEditOrDeleteTender()
    {
        
        let alert = UIAlertController(title: "Tender Watch", message:"Are you sure to delete or edit record?", preferredStyle: .alert)
        let Edit = UIAlertAction(title: "EDIT", style: .default) { _ in
            //Navigare for Edit
            guard let clientTenderDetailVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "ClientTenderDetailVC") as? ClientTenderDetailVC else { return }
            clientTenderDetailVC.tenderDetailId  =  self.dicSelectedTenderData["_id"] as? String ?? ""
            self.pushViewController(clientTenderDetailVC)
        }
        let Delete = UIAlertAction(title: "DELETE", style: .default) { _ in
            
            //show alert for confirm delete tender
            let alert = UIAlertController(title: "Tender Watch", message:"Tender will be completely removed from TenderWatch, Are you sure want to remove Tender?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "REMOVE", style: .default) { _ in
                //call api for interested contractor lisi
                self.strSelectedTenderId  =  self.dicSelectedTenderData["_id"] as? String ?? ""
                self.callInterestedContractorListApi()
                
                
                
            }
            let cancle = UIAlertAction(title: "CANCEL", style: .cancel) { _ in }
            
            alert.addAction(cancle)
            alert.addAction(ok)
            self.present(alert, animated: true){}
        }
        let cancle = UIAlertAction(title: "CANCEL", style: .cancel) { _ in }
        
        alert.addAction(Edit)
        alert.addAction(Delete)
        alert.addAction(cancle)
        self.present(alert, animated: true){}
    }
    
    
    func showAlertForFavoriteOrDeleteTender()
    {
        
        var isAlreadyFav = false
        let arrFavorite =   dicSelectedTenderData["favorite"] as? [String]
        if arrFavorite?.count ?? 0 > 0
        {
            //if userID is in array that means user make tender favourite
            for id in arrFavorite!
            {
                if id == utils.getLoginUserId()
                {
                    isAlreadyFav = true
                    break
                }
            }
        }
        
        
        let alert = UIAlertController(title: "Tender Watch", message:"Are you sure to delete or add favorite tender?", preferredStyle: .alert)
        
        if !isAlreadyFav{   // if tender is already favorite then do not show fav button
            let favorite = UIAlertAction(title: "FAVORITE", style: .default) { _ in
                
                self.callAddFavoriteTenderApi()
                
            }
            
            alert.addAction(favorite)
        }
        
        let Delete = UIAlertAction(title: "DELETE", style: .default) { _ in
            
            //show alert for confirm delete tender
            let alert = UIAlertController(title: "Tender Watch", message:"Are you sure want to delete Tender?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "REMOVE", style: .default) { _ in
                //call api for delete Tender
                self.strSelectedTenderId  =  self.dicSelectedTenderData["_id"] as? String ?? ""
                
                self.callRemoveTenderApi()
                
                
            }
            let cancle = UIAlertAction(title: "CANCEL", style: .cancel) { _ in }
            
            alert.addAction(cancle)
            alert.addAction(ok)
            self.present(alert, animated: true){}
        }
        let cancle = UIAlertAction(title: "CANCEL", style: .cancel) { _ in }
        
        
        alert.addAction(Delete)
        alert.addAction(cancle)
        self.present(alert, animated: true){}
    }
    
    //MARK:- search bar delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // This method updates filteredData based on the text in the Search Box
        
        if searchText == ""
        {
            arrFilteredTenders = arrTenders
        }
        else
        {
            arrFilteredTenders = arrTenders.filter { ($0["tenderName"] as! String).lowercased().contains(searchText.lowercased()) }.map { $0 }
        }
        
        self.tblViewTenderList.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    
    //MARK:- calculate days
    func calculateDaysBetweenTwoDates(strStartDate:String,strEndDate:String) -> Int{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDate = dateFormatter.date(from: strStartDate)
        let endDate = dateFormatter.date(from: strEndDate)
        
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.day], from: startDate!
            , to: endDate!)
        
        //include end date
        return components.day! + 1
        
    }
    //MARK:- Service manager delegate
    
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        if tagname == doGetTenderForClient{
            self.parseGetTenderForClientApiData(response: response)
        }
        if tagname == doGetInterestedContractor{
            self.parseInterestedContractorListApiData(response: response)
        }
        
        if tagname == doRemoveTender{
            self.parseRemoveTenderApiData(response: response)
        }
        
        if tagname == doSendDetailForRemoveTender{
            self.parseSendDetailAboutRemoveTenderApiData(response: response)
        }
        if tagname == doAddFavoriteTender{
            self.parseAddFavoriteTenderApiData(response: response)
        }
        if tagname == doFetchCategoryInfo{
            self.parseCategoryApiData(response: response)
        }
        if tagname == doFetchCountryInfo{
            self.parseCountryApiData(response: response)
        }
        
    }
    
    func webServiceCallFailure(_ error: Error?, forTag tagname: String?) {
        
        //reset flag
        isPullToRefreshRunning = false
        
        //stop pull to refresh
        refreshControl.endRefreshing()
        
        //hide loader
        hideLoader()
        
        //show toast for failure in API calling
        showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
    }
    
    
    //MARK:- API Calling
    func callGetTenderForClientApi(){
        if utils.connected(){
            
            if !isPullToRefreshRunning {
                //show loader
                showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            }
            
            let webPath = "\(BASE_URL)\(GET_TENDERS)"
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            serviceManager.callWebServiceWithPOSTWithHeaders(webpath: webPath, withTag: doGetTenderForClient, params: [:], headers: headers)
            
        }
        else{
            //reset flag
            isPullToRefreshRunning = false
            
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    
    func parseGetTenderForClientApiData(response:Any?){
        //reset flag
        isPullToRefreshRunning = false
        
        //stop pull to refresh
        refreshControl.endRefreshing()
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let arrResponseData = response as? [[String:Any]] else {return}
            arrTenders = arrResponseData
            arrFilteredTenders = arrResponseData
            self.tblViewTenderList.reloadData()
        }
    }
    
    func callInterestedContractorListApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(TENDER_DETAIL_API)\(strSelectedTenderId)"
            serviceManager.callWebServiceWithPOSTWithHeaders(webpath: webPath, withTag: doGetInterestedContractor, params: [:], headers: headers)
            
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    
    func parseInterestedContractorListApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let arrResponseData = response as? [[String:Any]] else {return}
            
            arrInterestedContractors = arrResponseData
            
            if arrInterestedContractors.count > 0 {
                self.callSendDetailAboutRemoveTenderApi()
            }
            else
            {
                //call api for remove tender
                self.callRemoveTenderApi()
            }
            
        }
    }
    
    
    func callRemoveTenderApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            let webPath = "\(BASE_URL)\(REMOVE_TENDER_API)\(strSelectedTenderId)"
            serviceManager.callWebServiceWithDeleteWithHeader_withNoJsonFormate(webpath: webPath, withTag: doRemoveTender, params: [:], headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    func parseRemoveTenderApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let dicResponseData = response as? [String:Any] else {return}
            if dicResponseData["data"] as? Int == 1
            {
                let alert = UIAlertController(title: "Tender Watch", message:"Tender Removed!", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { _ in
                    
                    //call api for refresh data
                    self.callGetTenderForClientApi()
                    
                }
                alert.addAction(ok)
                self.present(alert, animated: true){}
            }
            
        }
    }
    
    
    func callSendDetailAboutRemoveTenderApi(){
        if utils.connected(){
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            ///Contractors
            //            var arrEmailsOfContractors = [String]()
            //            for dic in arrInterestedContractors
            //            {
            //                arrEmailsOfContractors.append(dic["email"] as? String ?? "")
            //            }
            
            
            ///Contractors
            var arrEmailsOfContractors = [[String:Any]]()
            for dic in arrInterestedContractors
            {
                var dicTemp = [String:Any]()
                dicTemp["_id"] = "\(dic["_id"] as? String ?? "")"
                dicTemp["email"] = "\(dic["email"] as? String ?? "")"
                
                arrEmailsOfContractors.append(dicTemp)
                
            }
            
            
            print(arrEmailsOfContractors)
            
            ///category
            let arrCategoryData = (dicSelectedTenderData["category"] as? [String]) ?? [String]()
            var arrCategory = [String]()
            for category in arrCategoryData
            {
                let arrTemp =   arrAllCategory.filter { ($0["_id"] as! String) == (category) }.map { $0 }
                
                if arrTemp.count > 0{
                    arrCategory.append(arrTemp[0]["categoryName"] as! String)
                }
            }
            
            /// Country
            let selectedCountryId = "\(dicSelectedTenderData["country"] ?? "")"
            var selectedCountryName = ""
            
            let arrTemp =   arrAllCountry.filter { ($0["_id"] as! String) == (selectedCountryId) }.map { $0 }
            
            if arrTemp.count > 0{
                
                selectedCountryName = arrTemp[0]["countryName"] as! String
                
            }
            
            
            ///Tender Uploader
            let dicTenderUploader = dicSelectedTenderData["tenderUploader"] as? [String:Any]
            let userName = "\(dicTenderUploader?["firstName"] ?? "") \(dicTenderUploader?["lastName"] ?? "")"
            
            let dicParameter = ["Email":arrEmailsOfContractors,
                                "Category":"\(arrCategory.joined(separator: " || "))",
                "TenderName":"\(dicSelectedTenderData["tenderName"] ?? "")",
                "CountryName":"\(selectedCountryName)",
                "UserName":userName,
                "Operation" : "Remove"
                
                ] as [String : Any]
            
            print(dicParameter)
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as! String
            }
            
            let headers = [
                "Content-Type": "application/json;charset=UTF-8",
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            print(headers)
            let webPath = "\(BASE_URL)\(SEND_DETAIL_ABOUT_REMOVE_TENDER_API)"
            serviceManager.callWebServiceWithPOSTWithHeaders_withNoJsonFormate(webpath: webPath, withTag: doSendDetailForRemoveTender, params: dicParameter, headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseSendDetailAboutRemoveTenderApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let dicResponseData = response as? [String:Any] else {return}
            if dicResponseData["data"] as? Int == 1
            {
                //call api to remove tender
                self.callRemoveTenderApi()
            }
        }
    }
    
    func callAddFavoriteTenderApi(){
        
        if utils.connected(){
            
            //show loader
            showLoaderwithMessage(message: "", type: .circleStrokeSpin, color: .gray)
            
            var autoraizationToken = ""
            let userData = utils.getLoginUserData()
            if userData != nil
            {
                autoraizationToken = userData!["token"] as? String ?? ""
            }
            
            let headers = [
                "Authorization": "Bearer \(autoraizationToken)"
            ]
            
            
            let webPath = "\(BASE_URL)\(ADD_OR_REMOVE_FAVORITE_TENDER_API)\(dicSelectedTenderData["_id"] as? String ?? "")"
            
            serviceManager.callWebServiceWithPutWithHeaders_withNoJsonFormate(webpath: webPath, withTag: doAddFavoriteTender, params: [:], headers: headers)
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseAddFavoriteTenderApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let dicResponseData = response as? [String:Any] else {return}
            
            print(dicResponseData)
            if dicResponseData["data"] as? Int == 1
            {
                self.showToast(title: "Tender added to Favorite", duration: 1.0, position: .top)
                
                //refresh list
                self.callGetTenderForClientApi()
                
            }
            else{
                showToast(title: SOMETHING_WENT_WRONGE , duration: 1.0, position: .top)
            }
        }
    }
    
    
    func callCategoryDataAPI()
    {
        if utils.connected(){
            let webPath = "\(BASE_URL)\(TENDERCATEGORY_API)"
            serviceManager.callWebServiceWithGET(webpath: webPath, withTag: doFetchCategoryInfo)
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseCategoryApiData(response:Any?){
        
        if response != nil
        {
            let dicResponseData = response as! [[String:Any]]
            
            arrAllCategory = dicResponseData
            
        }
        
    }
    
    
    func callCountryDataAPI()
    {
        if utils.connected(){
            let webPath = "\(BASE_URL)\(COUNTRY_API)"
            serviceManager.callWebServiceWithGET(webpath: webPath, withTag: doFetchCountryInfo)
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseCountryApiData(response:Any?){
        if response != nil
        {
            let arrResponseData = response as! [[String:Any]]
            arrAllCountry = arrResponseData
        }
    }
    
    //MARK:- btn click
    @objc func slideMenuPressed() {
        self.view.endEditing(true)
        
        //open side menu
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func btnAddTenderPressed(_ sender: Any) {
        guard let uploadTenderVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "UploadTenderVC") as? UploadTenderVC else { return }
        uploadTenderVC.isComingForEditTender = false
        pushViewController(uploadTenderVC)
    }
}


//MARK: - TableView Delegate & Datasource Methods
extension DashboardClientTenderListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFilteredTenders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TblTenderListCell = tableView.dequeueReusableCell(withIdentifier: "TblTenderListCell", for: indexPath) as? TblTenderListCell ?? TblTenderListCell()
        
        let dicTender = arrFilteredTenders[indexPath.row]
        print(dicTender)
        
        cell.imgInterested.isHidden = true
        
        if  utils.getUserType() == USER_CONTRACTOR
        {
            var isReadTender = false
            var  isReadAmendTender = false
            
            
            //hide show "New" tender
            let arrReadBy = dicTender["readby"] as? [String]
            
            cell.lblNew.isHidden = true
            cell.imgViewIcon.layer.borderColor = UIColor.red.cgColor
            
            if arrReadBy?.count ?? 0 > 0
            {
                for id in arrReadBy!
                {
                    if id == utils.getLoginUserId()
                    {
                        isReadTender = true
                        break
                    }
                }
            }
            
            
            //hide show "Amended" Tender
            let arrAmendRead = dicTender["amendRead"] as? [String]
            if arrAmendRead?.count ?? 0 > 0
            {
                for id in arrAmendRead!
                {
                    if id == utils.getLoginUserId()
                    {
                        isReadAmendTender = true
                        break
                    }
                }
            }
            else if arrAmendRead == nil
            {
                isReadAmendTender = true
            }
            
            if isReadTender && isReadAmendTender
            {
                cell.lblNew.isHidden = true
                cell.imgViewIcon.layer.borderWidth = 0
                cell.lblNew.text = ""
            }
            else if isReadTender && !isReadAmendTender
            {
                cell.lblNew.isHidden = false
                cell.imgViewIcon.layer.borderWidth = 1
                cell.lblNew.text = "AMENDED"
            }
            else if !isReadTender && isReadAmendTender
            {
                cell.lblNew.isHidden = false
                cell.imgViewIcon.layer.borderWidth = 1
                cell.lblNew.text = "NEW"
            }
            else if !isReadTender && !isReadAmendTender
            {
                cell.lblNew.isHidden = false
                cell.imgViewIcon.layer.borderWidth = 1
                cell.lblNew.text = "NEW AMENDED"
            }
            
            
            
            //Hide show interest
            let arrInterested =   dicTender["interested"] as? [String]
            if arrInterested?.count ?? 0 > 0
            {
                
                for id in arrInterested!
                {
                    if id == utils.getLoginUserId()
                    {
                        cell.imgInterested.isHidden = false
                        break
                    }
                }
                
            }
            else
            {
                cell.imgInterested.isHidden = true
            }
            
        }
        else
        {
            cell.lblNew.isHidden = true
            cell.imgInterested.isHidden = true
        }
        
        
        if (dicTender["tenderPhoto"] as? String != "no image" && dicTender["tenderPhoto"] as? String != ""){
            cell.imgViewIcon.setImageWithActivityIndicator(imageURL: (dicTender["tenderPhoto"] as? String) ?? "", indicatorStyle: .gray, placeHolderImage: UIImage(named: "ic_avtar")!)
        }
        else
        {
            cell.imgViewIcon.image = UIImage(named: "ic_avtar")
        }
        let dicTenderUploader = dicTender["tenderUploader"] as? [String:Any]
        
        cell.lblName.text = dicTenderUploader?["email"] as? String
        cell.lblTitle.text = dicTender["tenderName"] as? String
        
        //show expiry date including last date
        
        let expiryDate = dicTender["expiryDate"] as? String
        let strDate = expiryDate?.components(separatedBy: "T")[0]
        let strCurrentDate = Date().formateDate(format: "YYYY-MM-dd")
        cell.lblExpDays.text = "\(self.calculateDaysBetweenTwoDates(strStartDate: strCurrentDate, strEndDate: strDate!)) days"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let clientTenderDetailVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "ClientTenderDetailVC") as? ClientTenderDetailVC else { return }
        let dicTender = arrFilteredTenders[indexPath.row]
        
        clientTenderDetailVC.tenderDetailId  =  dicTender["_id"] as? String ?? ""
        pushViewController(clientTenderDetailVC)
        
    }
}
