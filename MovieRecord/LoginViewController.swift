//
//  LoginViewController.swift
//  MovieRecord
//
//  Created by 李佳駿 on 2019/11/13.
//  Copyright © 2019 李佳駿. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import GoogleMobileAds
import FBSDKLoginKit



class LoginViewController: UIViewController,UITextFieldDelegate,GIDSignInDelegate{
    
  
    
    @IBOutlet weak var gogleLoginView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var fbLoginBtn: UIButton!
    
    @IBOutlet weak var googleLoginBtn: UIButton!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var rect:CGRect?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fbLoginBtn.isHidden = true
        loginBtn.addTarget(self, action: #selector(loginBtnClick(_:)), for: .touchUpInside)
        loginBtn.layer.cornerRadius = 10
        googleLoginBtn.addTarget(self, action: #selector(googleLoginBtnClick(_:)), for: .touchUpInside)
        googleLoginBtn.layer.cornerRadius = 10
        forgotPasswordBtn.addTarget(self, action: #selector(forgotPasswordBtnClick(_:)), for: .touchUpInside)
        forgotPasswordBtn.layer.cornerRadius = 10
        signUpBtn.addTarget(self, action: #selector(signUpBtnClick(_:)), for: .touchUpInside)
        signUpBtn.layer.cornerRadius = 10
        //fbLoginBtn.addTarget(self, action: #selector(fbLoginBtnClick(_:)), for: .touchUpInside)
        gogleLoginView.layer.cornerRadius = 10
      
        
        //UITextfield setting
        //輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        emailTextField.clearButtonMode = .whileEditing
        //鍵盤樣式
        emailTextField.keyboardType = .emailAddress
        //鍵盤上Retrun鍵樣式
        emailTextField.returnKeyType = .done
        //輸入框的樣式 這邊選擇圓角樣式
        emailTextField.borderStyle = .roundedRect
        //輸入框的樣式 這邊選擇圓角樣式
        emailTextField.placeholder = "請輸入Email"
        //設定代理
        emailTextField.delegate = self
        
        //輸入框右邊顯示清除按鈕時機 這邊選擇當編輯時顯示
        passwordTextField.clearButtonMode = .whileEditing
        //鍵盤樣式
        passwordTextField.keyboardType = .asciiCapable
        //鍵盤上Retrun鍵樣式
        passwordTextField.returnKeyType = .done
        //輸入框的樣式 這邊選擇圓角樣式
        passwordTextField.borderStyle = .roundedRect
        //輸入框的樣式 這邊選擇圓角樣式
        passwordTextField.placeholder = "請輸入密碼"
        //設定代理
        passwordTextField.delegate = self
        //隱藏輸入字元
        passwordTextField.isSecureTextEntry = true
     
        //是否登入
        if (Auth.auth().currentUser != nil) {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "movieList") as! MovieListViewController
                self.present(vc, animated: true, completion: nil)
            }
           
        }else{
            //print("not login")
            GIDSignIn.sharedInstance()?.presentingViewController = self
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
            GIDSignIn.sharedInstance()?.delegate = self
        }
       
//        GIDSignIn.sharedInstance()?.presentingViewController = self
//        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
//        GIDSignIn.sharedInstance()?.delegate = self
       
        //執行廣告
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
       
    }
    
//    @objc func fbLoginBtnClick(_ sender:UIButton){
//
//        let fbLoginManager = LoginManager()
//
//        fbLoginManager.logIn(permissions: ["public_profile","email"], from: self) { (result, error) in
//            if let error = error {
//                        print("Failed to login: \(error.localizedDescription)")
//                        return
//            }
//
//            guard let accessToken = AccessToken.current else {
//                        print("Failed to get access token")
//                        return
//            }
//            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
//
//            Auth.auth().signIn(with: credential) { (dataResult, error) in
//                DispatchQueue.main.async {
//
//                    let storyborad = UIStoryboard(name: "Main", bundle: nil)
//                    let vc = storyborad.instantiateViewController(identifier: "movieList") as! MovieListViewController
//                    self.present(vc, animated: true, completion: nil)
//
//                }
//            }
//
//        }
//
//
//    }
    
    //點擊鍵盤return取消鍵盤
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    //點擊螢幕取消鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

//    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
//
//        if error != nil{
//            DispatchQueue.main.async {
//                let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: error!.localizedDescription, alertControllerStyle: .alert, alertActionStyle: .default)
//                self.present(alert, animated: true, completion: nil)
//            }
//        }
//
//        if let accessToken = AccessToken.current{
//            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
//
//            Auth.auth().signIn(with: credential) { (dataResult, error) in
//                if error != nil{
//                    DispatchQueue.main.async {
//                        let alert = self.createErrorAlert(alertControllerTitle: "登入失敗", alertActionTitle: "確定", message: error!.localizedDescription, alertControllerStyle: .alert, alertActionStyle: .default)
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                }else{
//                    DispatchQueue.main.async {
//
//                        let storyborad = UIStoryboard(name: "Main", bundle: nil)
//                        let vc = storyborad.instantiateViewController(identifier: "movieList") as! MovieListViewController
//                        self.present(vc, animated: true, completion: nil)
//
//                    }
//                }
//
//
//
//
//            }
//        }
//
//
//
//    }
    
//    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
//
//        DispatchQueue.main.async {
//            let alert = self.createErrorAlert(alertControllerTitle: "登出", alertActionTitle: "確定", message: "Facebook已登出", alertControllerStyle: .alert, alertActionStyle: .default)
//            self.present(alert, animated: true, completion: nil)
//        }
//
//    }
    
    //登入
    @objc func loginBtnClick(_ sender:UIButton){
        
        if emailTextField.text == "" && passwordTextField.text != ""{
            
            DispatchQueue.main.async {
                let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "請輸入Email", alertControllerStyle: .alert, alertActionStyle: .default)
                self.present(alert, animated: true, completion: nil)
            }
            
        }else if emailTextField.text != "" && passwordTextField.text == ""{
            
            DispatchQueue.main.async {
                let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "請輸入密碼", alertControllerStyle: .alert, alertActionStyle: .default)
                self.present(alert, animated: true, completion: nil)
            }
            
        }else if emailTextField.text == "" && passwordTextField.text == ""{
            
            DispatchQueue.main.async {
                let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "請輸入Email與密碼", alertControllerStyle: .alert, alertActionStyle: .default)
                self.present(alert, animated: true, completion: nil)
            }
            
        }else if passwordTextField.text != "" && passwordTextField.text!.count < 6{
            
            DispatchQueue.main.async {
                let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "密碼必須6字元以上", alertControllerStyle: .alert, alertActionStyle: .default)
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
        //輸入Email Password登入
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (dataResult, error) in
                
            if error != nil{
                DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertControllerTitle: "登入失敗", alertActionTitle: "確定", message: error!.localizedDescription, alertControllerStyle: .alert, alertActionStyle: .default)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            DispatchQueue.main.async {
                let controller = UIAlertController(title: "成功", message: "登入成功", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
                   
                    let storyborad = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyborad.instantiateViewController(identifier: "movieList") as! MovieListViewController
                    self.present(vc, animated: true, completion: nil)
                   
                }
                controller.addAction(okAction)
                self.present(controller, animated: true, completion: nil)
            }
            
            
            
        }
        
        
    }
    //Google登入
    @objc func googleLoginBtnClick(_ sender:UIButton){
        
       GIDSignIn.sharedInstance()?.signIn()
        
    }
    //忘記密碼
    @objc func forgotPasswordBtnClick(_ sender:UIButton){
        
       
        
        let controller = UIAlertController(title: "重設密碼", message: "請輸入Email", preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "請輸入Email"
            textField.keyboardType = .emailAddress
            
        }
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (_) in
            
           
        
            if controller.textFields![0].text == ""{
                DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "請輸入Email", alertControllerStyle: .alert, alertActionStyle: .default)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            //輸入Email寄送重設密碼至該Email
            Auth.auth().sendPasswordReset(withEmail: controller.textFields![0].text!) { (error) in
                
                if error != nil{
                    DispatchQueue.main.async {
                        let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: error!.localizedDescription, alertControllerStyle: .alert, alertActionStyle: .default)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertControllerTitle: "成功", alertActionTitle: "確定", message: "請至信箱重設密碼", alertControllerStyle: .alert, alertActionStyle: .default)
                    self.present(alert, animated: true, completion: nil)
                }
                    
                    
               
            }
            
            
            
        }
        controller.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(controller, animated: true, completion: nil)
        }
        
        
        
    }
    //註冊
    @objc func signUpBtnClick(_ sender:UIButton){
       
        if emailTextField.text == "" && passwordTextField.text != ""{
            
            DispatchQueue.main.async {
                let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "請輸入Email", alertControllerStyle: .alert, alertActionStyle: .default)
                self.present(alert, animated: true, completion: nil)
            }
            
        }else if emailTextField.text != "" && passwordTextField.text == ""{
            
            DispatchQueue.main.async {
                let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "請輸入密碼", alertControllerStyle: .alert, alertActionStyle: .default)
                self.present(alert, animated: true, completion: nil)
            }
            
        }else if emailTextField.text == "" && passwordTextField.text == ""{
            
            DispatchQueue.main.async {
                let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "請輸入Email與密碼", alertControllerStyle: .alert, alertActionStyle: .default)
                self.present(alert, animated: true, completion: nil)
            }
            
        }else if passwordTextField.text != "" && passwordTextField.text!.count < 6{
            
            DispatchQueue.main.async {
                let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "密碼必須6字元以上", alertControllerStyle: .alert, alertActionStyle: .default)
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        
        
            //輸入Email Password註冊
            Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (dataResult, error) in
                
                    if error != nil{
                        DispatchQueue.main.async {
                            let alert = self.createErrorAlert(alertControllerTitle: "註冊失敗", alertActionTitle: "確定", message: error!.localizedDescription, alertControllerStyle: .alert, alertActionStyle: .default)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    DispatchQueue.main.async {
                        let alert = self.createErrorAlert(alertControllerTitle: "成功", alertActionTitle: "確定", message: "完成註冊", alertControllerStyle: .alert, alertActionStyle: .default)
                        self.present(alert, animated: true, completion: nil)
                    }
             
            }
       
    }
    //Google登入
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
      
            if error != nil {
                
                DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "請重試", alertControllerStyle: .alert, alertActionStyle: .default)
                    self.present(alert, animated: true, completion: nil)
                }
                
                
            }
            
            guard let authentication = user.authentication else {
                
                DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertControllerTitle: "用戶身份認證失敗", alertActionTitle: "確定", message: "請重試", alertControllerStyle: .alert, alertActionStyle: .default)
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            //取得credential
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            //用credential進行認證
            Auth.auth().signIn(with: credential) { (authDataResult, error) in
                
                if let error = error {
    
                    print("Login error: \(error.localizedDescription)")
        
                    DispatchQueue.main.async {
                        let alert = self.createErrorAlert(alertControllerTitle: "Google登入失敗", alertActionTitle: "確定", message: "請重新登入或嘗試其他登入方式", alertControllerStyle: .alert, alertActionStyle: .default)
                        self.present(alert, animated: true, completion: nil)
                    }
                    
    
                }
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(identifier: "movieList") as! MovieListViewController
                    self.present(vc, animated: true, completion: nil)
                }
               
            }
            
            
        }
    //錯誤警告Alert
    func createErrorAlert(alertControllerTitle:String, alertActionTitle:String,message:String,alertControllerStyle:UIAlertController.Style, alertActionStyle:UIAlertAction.Style) -> UIAlertController{
        
        let alert = UIAlertController(title: alertControllerTitle, message: message, preferredStyle: alertControllerStyle)
        let action = UIAlertAction(title: alertActionTitle, style: alertActionStyle) { (action) in
            
        }
        
        alert.addAction(action)
        return alert
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
