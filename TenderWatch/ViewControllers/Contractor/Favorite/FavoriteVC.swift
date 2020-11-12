//
//  FavoriteVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 05/06/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit
import SideMenu
class FavoriteVC: BaseViewController,ServiceManagerDelegate {
    
    //MARK:- outlet
    @IBOutlet weak var tblFavoriteTenderList: UITableView!
    
    @IBOutlet weak var lblNoFavTender: UILabel!
    //MARK:- variable
    let utils = Utils()
    let serviceManager = ServiceManager()
    let doGetFavoriteTenderForClient = "do get Favorite tender for client"
    let doRemoveFavoriteTender =  "do Remove Favorite Tender for FavoriteVC"
    let componentManager = UIComponantManager()
    let refreshControl = UIRefreshControl()
    var isPullToRefreshRunning  = false
    var arrTenders = [[String:Any]]()
    var arrFilteredTenders = [[String:Any]]()
    var dicSelectedTenderData = [String:Any]()
    var strSelectedTenderId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        self.setupNavigationBar()
        self.setupSidemenu()
        componentManager.registerTableViewCell(cellName: "TblTenderListCell", to: tblFavoriteTenderList)
        tblFavoriteTenderList.tableFooterView = UIView()
        serviceManager.delegate = self
        
        DispatchQueue.main.async {
            self.setupUI()
        }
        
        self.callGetFavoriteTenderForClientApi()
        
    }
    
    //MARK:- setupUI
    func setupUI(){
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tblFavoriteTenderList.refreshControl = refreshControl
        
        //add long press gesture to table
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(sender:)))
        tblFavoriteTenderList.addGestureRecognizer(longPress)
    }
    
    
    @objc func pullToRefresh(refreshControl: UIRefreshControl) {
        
        if !isPullToRefreshRunning{
            //set flag
            isPullToRefreshRunning = true
            self.callGetFavoriteTenderForClientApi()
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
    
    //MARK:- handle long press of table
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: tblFavoriteTenderList)
            if let indexPath = tblFavoriteTenderList.indexPathForRow(at: touchPoint) {
                // your code here, get the row for the indexPath or do whatever you want
                print(indexPath)
                
                //selected tender
                let dicTender = arrFilteredTenders[indexPath.row]
                dicSelectedTenderData = dicTender
                
                
                self.showAlertForRemoveTenderFromFavorite()
            }
        }
    }
    
    //MARK:- show alert
    func showAlertForRemoveTenderFromFavorite()
    {
        let alert = UIAlertController(title: "Tender Watch", message:"Are you sure want to remove Tender from Favorite?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "REMOVE FROM FAVORITE", style: .default) { _ in
            //call api for delete Tender
            self.strSelectedTenderId  =  self.dicSelectedTenderData["_id"] as? String ?? ""
            
            //CAll api for remove tender from favorite
            self.callRemoveFavoriteTenderApi()
            
        }
        let cancle = UIAlertAction(title: "CANCEL", style: .cancel) { _ in }
        
        alert.addAction(cancle)
        alert.addAction(ok)
        self.present(alert, animated: true){}
        
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
    
    //MARK:- btn click
    @objc func slideMenuPressed() {
        
        //open side menu
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    
    //MARK:- Service manager delegate
    
    func webServiceCallSuccess(_ response: Any?, forTag tagname: String?) {
        if tagname == doGetFavoriteTenderForClient{
            self.parseGetFavoriteTenderForClientApiData(response: response)
        }
        if tagname == doRemoveFavoriteTender{
            self.parseRemoveFavoriteTenderApiData(response: response)
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
    func callGetFavoriteTenderForClientApi(){
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
            serviceManager.callWebServiceWithPOSTWithHeaders(webpath: webPath, withTag: doGetFavoriteTenderForClient, params: [:], headers: headers)
            
        }
        else{
            //reset flag
            isPullToRefreshRunning = false
            
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseGetFavoriteTenderForClientApiData(response:Any?){
        //reset flag
        isPullToRefreshRunning = false
        
        //stop pull to refresh
        refreshControl.endRefreshing()
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let arrResponseData = response as? [[String:Any]] else {return}
            
            arrTenders = [[String:Any]]()
            
            for dic in arrResponseData
            {
                
                var isFavorite = false
                
                let arrFavorite =   dic["favorite"] as? [String]
                if arrFavorite?.count ?? 0 > 0
                {
                    //if userID is in array that means user make tender favourite
                    for id in arrFavorite!
                    {
                        if id == utils.getLoginUserId()
                        {
                            isFavorite = true
                            break
                        }
                    }
                }
                
                //Add favoite tender in one array
                if isFavorite {
                    arrTenders.append(dic)
                }
            }
            arrFilteredTenders = arrTenders
            self.tblFavoriteTenderList.reloadData()
            
            
            if arrTenders.count > 0
            {
                self.tblFavoriteTenderList.isHidden = false
                self.lblNoFavTender.isHidden = true
            }
            else
            {
                self.tblFavoriteTenderList.isHidden = true
                self.lblNoFavTender.isHidden = false
            }
        }
            
        else
        {
            self.tblFavoriteTenderList.isHidden = true
            self.lblNoFavTender.isHidden = false
        }
    }
    
    func callRemoveFavoriteTenderApi(){
        
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
            
            let webPath = "\(BASE_URL)\(ADD_OR_REMOVE_FAVORITE_TENDER_API)\(dicSelectedTenderData["_id"] ?? "")"
            
            serviceManager.callWebServiceWithDeleteWithHeader_withNoJsonFormate(webpath: webPath, withTag: doRemoveFavoriteTender, params: [:], headers: headers)
            
            
        }
        else{
            showToast(title: CHECK_INTERNET_CONNECTION, duration: 1.0, position: .top)
        }
    }
    
    func parseRemoveFavoriteTenderApiData(response:Any?){
        
        //hide loader
        hideLoader()
        
        if response != nil
        {
            guard let dicResponseData = response as? [String:Any] else {return}
            
            //refresh list
            self.callGetFavoriteTenderForClientApi()
        }
    }
    
    
}
//MARK: - TableView Delegate & Datasource Methods
extension FavoriteVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFilteredTenders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TblTenderListCell = tableView.dequeueReusableCell(withIdentifier: "TblTenderListCell", for: indexPath) as? TblTenderListCell ?? TblTenderListCell()
        
        let dicTender = arrFilteredTenders[indexPath.row]
        
        
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
                cell.lblNew.text = "NEW"
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
        cell.lblName.text = dicTender["email"] as? String
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
