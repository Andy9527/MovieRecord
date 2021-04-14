//
//  MovieListViewController.swift
//  MovieRecord
//
//  Created by CHIA CHUN LI on 2021/4/9.
//  Copyright © 2021 李佳駿. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds



class MovieListViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    var fileUploadDic:[String:AnyObject]?
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //coverView.isHidden = true
        //activityIndicator.isHidden = true
        
        
        signOutBtn.addTarget(self, action: #selector(signOutBtnClick(_:)), for: .touchUpInside)
        addBtn.addTarget(self, action: #selector(addBtnClick(_:)), for: .touchUpInside)
     
        // 取得螢幕的尺寸
        let fullScreenSize = UIScreen.main.bounds.size
        // 建立 UICollectionViewFlowLayout
        let layout = UICollectionViewFlowLayout()
        // 設置 section 的間距 四個數值分別代表 上、左、下、右 的間距
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        // 設置每一行的間距
        layout.minimumLineSpacing = 5
        // 設置每個 cell 的尺寸
        layout.itemSize = CGSize(
            width: CGFloat(fullScreenSize.width)/2 - 10.0,
            height: CGFloat(fullScreenSize.width)/2 - 10.0)
        //設定collectionView layout
        imageCollectionView.collectionViewLayout = layout
        
        self.coverView.isHidden = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        //讀取firebase database資料
        let dbRef = Database.database().reference().child("fireUpload")
        dbRef.observe(.value) { [self] (snapshot) in
            
            if let uploadDataDic = snapshot.value as? [String:AnyObject]{
                
                self.fileUploadDic = uploadDataDic
             
                    //collectionView 重整
                    //設定代理
                    self.imageCollectionView.dataSource = self
                    self.imageCollectionView.delegate = self
                    self.imageCollectionView.reloadData()
                
                if self.activityIndicator.isAnimating{
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.coverView.isHidden = true
                }
                    
            }
            
           
        }
        
       
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
            
        // Do any additional setup after loading the view.
    }
    
    //Item數量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataDic = fileUploadDic{
            return dataDic.count
        }
        return 0
    }
    //取得db資料顯示
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //建立Cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCVC", for: indexPath) as! ImageCollectionViewCell
        
        //將讀取的database資料顯示在collectionView Cell上
        if  let dataDic = fileUploadDic{
            let keyArr = Array(dataDic.keys)
            if let imageUrlDic = dataDic[keyArr[indexPath.row]] as? [String:AnyObject]{
                //取得圖片連結
                if let imageURL = URL(string: imageUrlDic["image"] as! String){
                    //下載圖片
                    URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                        //print("image url=\(imageURL)")
                        if error != nil{
                            
                            DispatchQueue.main.async {
                                let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "圖片載入失敗", alertControllerStyle: .alert, alertActionStyle: .default)
                                self.present(alert, animated: true, completion: nil)
                            }
                            //print("download image fail=\(String(describing: error?.localizedDescription))")
                            
                        }else if let imageData = data{
                            DispatchQueue.main.async {
                                //設定圖片
                                cell.image.image = UIImage(data: imageData)
                            }
                        }
                        
                    }.resume()
                }
                
            }
        }
        
       return cell
        
    }
    //點擊Item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //點擊Item 顯示alerController做編輯 刪除選擇
        let alertController = UIAlertController(title: "請選擇", message: "編輯或刪除", preferredStyle: .alert)
        
        let editAction = UIAlertAction(title: "編輯", style: .default) { (action) in
            
            self.coverView.isHidden = false
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            
            //取得點擊Item對應資料傳到MovieRecordController
            if  let dataDic = self.fileUploadDic{
                let keyArr = Array(dataDic.keys)
                //print("image url dic key=\(String(describing: keyArr[indexPath.row]))")
                if let imageUrlDic = dataDic[keyArr[indexPath.row]] as? [String:AnyObject]{
                    //取得圖片連結
                    if let imageURL = URL(string: imageUrlDic["image"] as! String){
                        //下載圖片
                        URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                            
                            //print("image url=\(imageURL)")
                            
                            if error != nil{
                                
                                DispatchQueue.main.async {
                                    let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "圖片載入失敗", alertControllerStyle: .alert, alertActionStyle: .default)
                                    self.present(alert, animated: true, completion: nil)
                                }
                                //print("download image fail=\(String(describing: error?.localizedDescription))")
                                
                            }else if let imageData = data{
                                DispatchQueue.main.async {
                                    //取得對應的值做傳遞
                                    ImageEdit.imageData = imageData
                                    ImageEdit.textViewContent = (imageUrlDic["filmReviewsText"] as! String)
                                    ImageEdit.selectDataKey = keyArr[indexPath.row]
                                    
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = storyboard.instantiateViewController(identifier: "movieRecord") as! MovieRecordViewController
                                    self.present(vc, animated: true, completion: nil)
                                }
                               
                              
                               
                            }
                            DispatchQueue.main.async {
                                if self.activityIndicator.isAnimating{
                                    self.activityIndicator.stopAnimating()
                                    self.activityIndicator.isHidden = true
                                    self.coverView.isHidden = true
                                }
                            }
                           
                            
                            
                        }.resume()
                    }
                    
                }
            }
        }
        let deleteAction = UIAlertAction(title: "刪除", style: .default) { (action) in
            
            self.coverView.isHidden = false
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            
            //刪除點擊對應的Item資料
            if  let dataDic = self.fileUploadDic{
                //
                let keyArr = Array(dataDic.keys)
                //print("image url dic key=\(String(describing: keyArr[indexPath.row]))")
                if (dataDic[keyArr[indexPath.row]] as? [String:AnyObject]) != nil{
                    //取得db資料
                    let dbRef = Database.database().reference().child("fireUpload").child(keyArr[indexPath.row])
                    //刪除db資料
                    dbRef.removeValue()
                    //刪除陣列資料
                    self.fileUploadDic?.removeValue(forKey: keyArr[indexPath.row])
                    //刷新畫面
                    collectionView.reloadData()
                    
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.coverView.isHidden = true
                   
                }
            }
            
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
       
    }
    
    //登出
    @objc func signOutBtnClick(_ sender:UIButton){
        
        self.coverView.isHidden = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        
        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "login") as! LoginViewController
                self.present(vc, animated: true, completion: nil)
            }
            
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.coverView.isHidden = true
           
        } catch {
            DispatchQueue.main.async {
                let alert = self.createErrorAlert(alertControllerTitle: "錯誤", alertActionTitle: "確定", message: "編輯資料失敗", alertControllerStyle: .alert, alertActionStyle: .default)
                self.present(alert, animated: true, completion: nil)
            }
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            self.coverView.isHidden = true
            
        }
        
    }
    //新增
    @objc func addBtnClick(_ sender:UIButton){
        
        ImageEdit.selectDataKey = ""
        ImageEdit.imageData = nil
        ImageEdit.textViewContent = nil
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "movieRecord") as! MovieRecordViewController
        self.present(vc, animated: true, completion: nil)
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
