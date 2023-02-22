//
//  CreatePostViewController.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/12/12.
//

import UIKit
import CoreLocation
import Photos
import PKHUD

class CreatePostViewController: UIViewController {

    @IBOutlet weak var createPostTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    private let mapCellId = "MapTableViewCell"
    private let photoCellId = "PhotoTableViewCell"
    
    private let tableViewContentInset : UIEdgeInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
    private let tableViewIndicatorInser : UIEdgeInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
    
    let locationManager = LocationManager()
    let createPostModel = CreatePostModel()
    let accessory = Accessory()
    
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
            cell.postButton.isEnabled = createPostModel.postCheck()
            
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
        accessory.openPhotoLibrary(view: self, imagePicker: imagePicker)
    }
    
    func postLocation(postLocation: CLLocationCoordinate2D, altitude: Double, genreId: String) {
        createPostModel.postLocation = postLocation
        createPostModel.altitude = altitude
        createPostModel.LocationIsSet = true
        createPostModel.genreId = genreId
        createPostTableView.reloadData()
    }
    
    func postPhoto(comment: String) {
        createPostModel.comment = comment
    }
    
    func pushPostButton() {
        createPostModel.postUpload(view: self)
    }
    
}

extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editImage = info[.editedImage] as? UIImage {
            selectedImage = editImage
            createPostModel.postImage = editImage
        }else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            createPostModel.postImage = originalImage
        }
        imageIsSelected = true
        createPostModel.PhotoSelected = true
        createPostTableView.reloadData()
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePicker closed")
        dismiss(animated: true)
    }
    
}
