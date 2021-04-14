//
//  MovieRecordViewController.swift
//  MovieRecord
//
//  Created by CHIA CHUN LI on 2021/4/7.
//  Copyright © 2021 李佳駿. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class MovieRecordViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var selectImageView: UIImageView!
    @IBOutlet weak var photoAlbumBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var filmReviewsTextView: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectImageView.image = nil
        self.filmReviewsTextView.text = ""
        activityIndicator.isHidden = true
        coverView.isHidden = true
        filmReviewsTextView.keyboardType = .default
        filmReviewsTextView.returnKeyType = .default
      
        
        //print("select key=\(ImageEdit.selectDataKey)")
        
        dismissBtn.addTarget(self, action: #selector(dismissBtnClick(_:)), for: .touchUpInside)
        photoAlbumBtn.addTarget(self, action: #selector(photoAlbumBtnClick(_:)), for: .touchUpInside)
        cameraBtn.addTarget(self, action: #selector(cameraBtnClick(_:)), for: .touchUpInside)
        saveBtn.addTarget(self, action: #selector(saveBtnClick(_:)), for: .touchUpInside)
        
        //編輯狀態 取得collection view點選的資料
        if ImageEdit.imageData != nil && ImageEdit.textViewContent != nil{
            DispatchQueue.main.async {
                self.selectImageView.image = UIImage(data: ImageEdit.imageData)
                self.filmReviewsTextView.text = ImageEdit.textViewContent
            }
        }else{
            self.selectImageView.image = UIImage(named: "image.png")
        }
        
        
        
        //顯示廣告
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        
        // Do any additional setup after loading the view.
    }
    
   
    
    //點擊取消鍵盤
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //返回上一頁
    @objc func dismissBtnClick(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    //開啟相簿
    @objc func photoAlbumBtnClick(_ sender:UIButton){
       
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
       
        
    }
    //選完照片後
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        DispatchQueue.main.async {
            if let image = info[.originalImage] as? UIImage{
                self.selectImageView.image = image
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        
    }
    //開啟相機
    @objc func cameraBtnClick(_ sender:UIButton){
        
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    //儲存
    @objc func saveBtnClick(_ sender:UIButton){
        
        //編輯狀態 取得點擊collection view item對應資料
        if ImageEdit.selectDataKey != ""{
            
            let storageRef = Storage.storage().reference().child("fireUpload").child(ImageEdit.selectDataKey)
            if let uploadData = ImageEdit.instance.resizeAndCompressImageWith(image: selectImageView.image!  , maxWidth: 800.0, maxHeight: 1200.0, compressionQuality: 0.5) {

                storageRef.putData(uploadData, metadata: nil) { (data, error) in
                    
                    if error != nil{
                        DispatchQueue.main.async {
                            let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "照片儲存失敗", alertControllerStyle: .alert, alertActionStyle: .default)
                            self.present(alert, animated: true, completion: nil)
                        }
                        //print("error=\(String(describing: error?.localizedDescription))")
                    }
                    
                    storageRef.downloadURL { (url, error) in
                        
                        if error != nil{
                            DispatchQueue.main.async {
                                let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "照片加載失敗", alertControllerStyle: .alert, alertActionStyle: .default)
                                self.present(alert, animated: true, completion: nil)
                            }
                            //print("error=\(String(describing: error?.localizedDescription))")
                        }else{
                            
                            let dbRef = Database.database().reference().child("fireUpload").child(ImageEdit.selectDataKey)
                            dbRef.updateChildValues(["image":url!.absoluteString,"filmReviewsText":self.filmReviewsTextView.text!]) { (error, dbRef) in
                                
                                if error != nil{
                                    DispatchQueue.main.async {
                                        let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "編輯資料失敗", alertControllerStyle: .alert, alertActionStyle: .default)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    //print("error=\(String(describing: error?.localizedDescription))")
                                }
                                
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                                self.coverView.isHidden = true
                                
                                print("儲存成功")
                                ImageEdit.selectDataKey = ""
                                ImageEdit.imageData = nil
                                ImageEdit.textViewContent = nil
                                self.selectImageView.image = nil
                                self.filmReviewsTextView.text = ""
                                
                                DispatchQueue.main.async {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            
        }
         
        }else{
            
            if selectImageView.image == nil{
                
                DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "請選擇照片", alertControllerStyle: .alert, alertActionStyle: .default)
                    self.present(alert, animated: true, completion: nil)
                }
                
                
            }else if filmReviewsTextView.text == ""{
                
                DispatchQueue.main.async {
                    let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "請輸入影評心得", alertControllerStyle: .alert, alertActionStyle: .default)
                    self.present(alert, animated: true, completion: nil)
                }
               
            }else{
                coverView.isHidden = false
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                
                let uniqueString = UUID().uuidString
                //let imageData = selectImageView.image?.pngData()
                
                
                //儲存image至storage,取得storage image url,將image url以及其他資料儲存至firebase database
                let storageRef = Storage.storage().reference().child("fireUpload").child("\(uniqueString)")
                //image壓縮大小
                if let uploadData = ImageEdit.instance.resizeAndCompressImageWith(image: selectImageView.image!  , maxWidth: 800.0, maxHeight: 1200.0, compressionQuality: 0.5) {
                    //儲存image至storage
                    storageRef.putData(uploadData, metadata: nil) { (data, error) in
                        
                        if error != nil{
                            DispatchQueue.main.async {
                                let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "照片儲存失敗", alertControllerStyle: .alert, alertActionStyle: .default)
                                self.present(alert, animated: true, completion: nil)
                            }
                            //print("error=\(String(describing: error?.localizedDescription))")
                        }
                        //取得storage image url
                        storageRef.downloadURL { (url, error) in
                            
                            if error != nil{
                                DispatchQueue.main.async {
                                    let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "照片加載失敗", alertControllerStyle: .alert, alertActionStyle: .default)
                                    self.present(alert, animated: true, completion: nil)
                                }
                                //print("error=\(String(describing: error?.localizedDescription))")
                            }else{
                                
                                let dbRef = Database.database().reference().child("fireUpload").child(uniqueString)
                                //儲存firebase database
                                dbRef.setValue(["image":url?.absoluteString,"filmReviewsText":self.filmReviewsTextView.text!]) { (error, dbRef) in
                                    
                                    if error != nil{
                                        DispatchQueue.main.async {
                                            let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "資料儲存失敗", alertControllerStyle: .alert, alertActionStyle: .default)
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                        //print("error=\(String(describing: error?.localizedDescription))")
                                    }
                                    
                                    self.activityIndicator.stopAnimating()
                                    self.activityIndicator.isHidden = true
                                    self.coverView.isHidden = true
                                    
                                    print("儲存成功")
                                    DispatchQueue.main.async {
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                    
                    
                }
                
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
