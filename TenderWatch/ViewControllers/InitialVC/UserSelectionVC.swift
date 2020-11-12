//
//  UserSelectionVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 27/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit


class UserSelectionVC: BaseViewController {
    //MARK:- outlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClient: UIButton!
    @IBOutlet weak var btnContractor: UIButton!
    
    //MARK:- variable
    
    //MARK:- ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //hide navigation bar
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK:- setupUI
    func setupUI(){
        
        btnClient.cornerRadius = btnClient.Getheight/2
        btnContractor.cornerRadius = btnClient.Getheight/2
        
        //lblTitle.animate(newText: "Let's get Started! First,tell us what you are looking for.", characterDelay: 0.2)
        self.animation(lbl: lblTitle, typing: "Let's get Started! First,tell us what you are looking for.", duration: 0.15)
        
    }
    
    func animation(lbl:UILabel,typing value:String,duration: Double){
        let characters = value.map { $0 }
        var index = 0
        Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { [weak self] timer in
            if index < value.count {
                let char = characters[index]
                lbl.text! += "\(char)"
                index += 1
            } else {
                timer.invalidate()
            }
        })
        
    }
    
    //MARK:- btn click
    @IBAction func btnClientClicked(_ sender: Any) {
        
        //set user type = client
        utils.setUserType(userType: USER_CLIENT)
        
        guard let signInVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "SignInVC") as? SignInVC else { return }
        pushViewController(signInVC)
        
    }
    
    @IBAction func btnContractorClicked(_ sender: Any) {
        //set user type = contractor
        utils.setUserType(userType: USER_CONTRACTOR)
        
        guard let signInVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "SignInVC") as? SignInVC else { return }
        pushViewController(signInVC)
    }
    
    @IBAction func btnAboutTenderWatchClicked(_ sender: Any) {
        
        guard let aboutTenderWatchVC = MAIN_STORYBOARD.instantiateViewController(withIdentifier: "AboutTenderWatchVC") as? AboutTenderWatchVC else { return }
        self.pushViewController(aboutTenderWatchVC)

    }
}

