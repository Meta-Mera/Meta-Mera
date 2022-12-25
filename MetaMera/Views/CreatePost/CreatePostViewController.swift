//
//  CreatePostViewController.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/12/12.
//

import UIKit
import CoreLocation
import Photos

class CreatePostViewController: UIViewController {

    @IBOutlet weak var createPostTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    private let mapCellId = "MapTableViewCell"
    private let photoCellId = "PhotoTableViewCell"
    
    private let tableViewContentInset : UIEdgeInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
    private let tableViewIndicatorInser : UIEdgeInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
    
    let locationManager = LocationManager()
    
    //MARK: 投稿情報
    var postLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var altitude: Double = 0
    var comment: String = ""
    
    // image
    private var imagePicker = UIImagePickerController()
    private var selectedImage = UIImage()
    private var imageIsSelected = false
    
    var delegate : photoUploadDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configView()
        setUpTableView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.startLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        locationManager.stopLocation()
    }
    
    
    
    func configView() {
        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
    }
    

    
    
    func setUpTableView(){
        createPostTableView.delegate = self
        createPostTableView.dataSource = self
        createPostTableView.register(UINib(nibName: "MapTableViewCell", bundle: nil) , forCellReuseIdentifier: mapCellId)
        createPostTableView.register(UINib(nibName: "PhotoTableViewCell", bundle: nil) , forCellReuseIdentifier: photoCellId)
        createPostTableView.rowHeight = UITableView.automaticDimension
        
        createPostTableView.contentInset = tableViewContentInset
        createPostTableView.scrollIndicatorInsets = tableViewIndicatorInser
        createPostTableView.keyboardDismissMode = .interactive
        createPostTableView.backgroundColor = .clear
        createPostTableView.allowsSelection = false
    }
    
    @IBAction func pushBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    


}

extension CreatePostViewController: UITableViewDelegate, UITableViewDataSource{
//
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            createPostTableView.estimatedRowHeight = 400
            return UITableView.automaticDimension
        }else{
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("indexPath.section: ",indexPath.section)
        if indexPath.section == 0 {
            let cell = createPostTableView.dequeueReusableCell(withIdentifier: photoCellId, for: indexPath) as! PhotoTableViewCell
            cell.backgroundColor = .clear
            cell.delegate = self
            cell.configView()
            if imageIsSelected {
//                cell.photoButton.setImage(selectedImage, for: UIControl.State.normal)
                cell.selectImageView.setImage(image: selectedImage, name: "")
            }
            
            return cell
        }else {
            let cell = createPostTableView.dequeueReusableCell(withIdentifier: mapCellId, for: indexPath) as! MapTableViewCell
            cell.backgroundColor = .clear
            cell.setUpCircle()
            cell.delegate = self
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView()
            headerView.backgroundColor = .gray
            
            //            let titleLabel = UILabel()
            //            titleLabel.text = "header"
            //            titleLabel.frame = headerView.frame
            //            titleLabel.textColor = .white
            //
            //            headerView.addSubview(titleLabel)
            
            return headerView
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped table view")

    }
}

extension CreatePostViewController: CreatePostDelegate {
    func pushPhotoButton() {
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .authorized:
                    print("許可ずみ")
                    break
                case .limited:
                    print("制限あり")
                    break
                case .denied:
                    print("拒否ずみ")
                    break
                default:
                    break
                }
            }
        }else  {
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        print("許可ずみ")
                    } else if status == .denied {
                        print("拒否ずみ")
                    }
                }
            } else {
                
            }
        }
        
        
        // 権限
        let authPhotoLibraryStatus = PHPhotoLibrary.authorizationStatus()
        // authPhotoLibraryStatus = .authorized : 許可
        //                        = .limited    : 選択した画像のみ
        //                        = .denied     : 拒否
        
        if authPhotoLibraryStatus == .limited {
            
            //アラートの設定
            let alert = UIAlertController(title: "Failed to save image", message: "Allow this app to access Photos.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Enable photos access", style: .default) { (action) in
                //設定を開く
                if let settingURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.canOpenURL(settingURL)
                    UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
                }
            }
            let cancel = UIAlertAction(title: "cancel", style: .cancel) { (acrion) in
                self.dismiss(animated: true, completion: nil)
            }
            
            //アラートの下にあるボタンを追加
            alert.addAction(cancel)
            alert.addAction(ok)
            //アラートの表示
            present(alert, animated: true, completion: nil)
            
            
        }
        if authPhotoLibraryStatus == .denied {
            
            //アラートの設定
            let alert = UIAlertController(title: "Failed to save image", message: "Allow this app to access Photos.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Enable photos access", style: .default) { (action) in
                //設定を開く
                if let settingURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.canOpenURL(settingURL)
                    UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
                }
            }
            let cancel = UIAlertAction(title: "cancel", style: .cancel) { (acrion) in
                self.dismiss(animated: true, completion: nil)
            }
            
            //アラートの下にあるボタンを追加
            alert.addAction(cancel)
            alert.addAction(ok)
            //アラートの表示
            present(alert, animated: true, completion: nil)
        }
        // fix/update_prof_image_#33 >>>
        if authPhotoLibraryStatus == .authorized {
            // <<<
            present(imagePicker, animated: true)    // カメラロール起動
        }
        print("slect image")
    }
    
    
    func postLocation(postLocation: CLLocationCoordinate2D, altitude: Double) {
        self.postLocation = postLocation
        self.altitude = altitude
    }
    
    func postPhoto(comment: String) {
        self.comment = comment
    }
    
}

extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("呼ばれた")
        
        if let editImage = info[.editedImage] as? UIImage {
            selectedImage = editImage
        }else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        imageIsSelected = true
        createPostTableView.reloadData()
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePicker closed")
        dismiss(animated: true)
        
    }
    
}
