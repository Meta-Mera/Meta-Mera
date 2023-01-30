//
//  AppInfoViewController.swift
//  MetaMera
//
//  Created by Jim on 2023/01/27.
//

import UIKit
import CoreTelephony

class AppInfoViewController: UIViewController {

    @IBOutlet weak var appInfoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        // Do any additional setup after loading the view.
    }
    
    func configView(){
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            let iOS = UIDevice.current.systemVersion
            let career = CTTelephonyNetworkInfo().subscriberCellularProvider?.carrierName ?? "unknown"
            let iPhone = "iPhone " + String(Int.random(in: 4...14))
            let info : String = "Version: %version%\nOS: %ios%\niPhone: %iPhone%\ncareer: %career%\n\nlanguage: %language%\n管理情報\n%uid%\n%areaId%".replacingOccurrences(of: "%version%", with: version)
                .replacingOccurrences(of: "%ios%", with: UIDevice.current.systemName+" "+iOS)
                .replacingOccurrences(of: "%career%", with: career)
                .replacingOccurrences(of: "%iPhone%", with: iPhone+"?")
                .replacingOccurrences(of: "%language%", with: LocalizeKey.language.localizedString())
                .replacingOccurrences(of: "%uid%", with: Profile.shared.loginUser.uid)
                .replacingOccurrences(of: "%areaId%", with: Profile.shared.areaId)
            appInfoTextView.text = info
        }
    }


    
    @IBAction func pushBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
