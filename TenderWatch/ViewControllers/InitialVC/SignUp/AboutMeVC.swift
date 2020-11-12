//
//  AboutMeVC.swift
//  TenderWatch
//
//  Created by mac2019_17 on 29/04/20.
//  Copyright © 2020 mac2019_17. All rights reserved.
//

import UIKit


protocol AboutMeTextDelegate {
    
    func getAboutMeText(strAboutMe:String)
}

class AboutMeVC: BaseViewController,UITextViewDelegate {
    //MARK:- outlet
    @IBOutlet weak var txtAboutMe: UITextView!
    
    //MARK:- variable
    var delegate : AboutMeTextDelegate?
    var strAbout : String?
    
    //MARK:- ViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        self.setupNavigationBar()
        DispatchQueue.main.async {
            self.setupUI()
        }
    }
    
    //MARK:- setupUI
    func setupUI(){
        
        //aasign old value to text view
        if strAbout != ""
        {
            txtAboutMe.text = strAbout
        }
        else{
            txtAboutMe.text = "Enter some information about yourself"
            txtAboutMe.textColor = UIColor.lightGray
        }
    }
    
    //MARK:- setup Navigation Bar
    func setupNavigationBar()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor.white   
        self.setNavigationBarHeaderTitle(strTitle: "0/1000")
        self.addLeftBarButton()
        self.addRightBarButton()
    }
    
    func setNavigationBarHeaderTitle(strTitle:String)
    {
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont.systemFont(ofSize: 21)]
        
        SetNavigationBarTitle(string: strTitle)
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
    
    func addRightBarButton() {
        
        //your custom view
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        
        let saveTitle = UILabel(frame: CGRect(x: 25, y: 5, width: 80, height: 30))
        saveTitle.text = "Save"
        view.addSubview(saveTitle)
        
        let saveTap = UITapGestureRecognizer(target: self, action: #selector(saveBtnPressed))
        view.addGestureRecognizer(saveTap)
        
        let rightBarButtonItem = UIBarButtonItem(customView: view )
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    //MARK:- touch event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //MARK:- text view delegate method
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            
            if textView.text == "Enter some information about yourself"
            {
                textView.text = nil
            }
            
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter some information about yourself"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView.text == "Enter some information about yourself"
        {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        let charCount = textView.text.length + (text.length - range.length)
        //limit characters
        if charCount <= 1000{
            //set charactor count in header title
            self.setNavigationBarHeaderTitle(strTitle: "\(charCount)/1000")
            
            return true
        }
        else
        {
            return false
        }
        
    }
    
    //MARK:- btn click
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveBtnPressed() {
        if delegate != nil{
            
            if txtAboutMe.text == "Enter some information about yourself"{
                delegate?.getAboutMeText(strAboutMe: "")
            }else
            {
                delegate?.getAboutMeText(strAboutMe: txtAboutMe.text.trim())
            }
            
            //navigate to previous VC
            self.navigationController?.popViewController(animated: true)
        }
    }
}
