//
//  ChangedEmailAddressViewController.swift
//  MetaMera
//
//  Created by y.nakazawa on 2022/12/05.
//

import UIKit

class ChangedEmailAddressViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func pushCloseButton(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
}
