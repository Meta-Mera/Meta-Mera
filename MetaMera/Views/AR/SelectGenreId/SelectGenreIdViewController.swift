//
//  SelectGenreIdViewController.swift
//  MetaMera
//
//  Created by Jim on 2023/02/22.
//

import UIKit

class SelectGenreIdViewController: UIViewController {
    
    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMenuButton()
        configView()
    }
    
    var selectedMenuType = GenreType.creator
    
    func configView(){
        selectButton.setTitle(NSLocalizedString(LocalizeKey.creator.localizedString(), comment: ""), for: .normal)
    }
    
    
    @IBAction func pushNext(_ sender: Any) {
        Profile.shared.genreId = selectedMenuType.rawValue
        self.navigationController?.popViewController(animated: true)
    }
    

    private func configureMenuButton(){
        var actions = [UIMenuElement]()
        //creator
        actions.append(UIAction(title: LocalizeKey.creator.localizedString(), image: nil, state: self.selectedMenuType == GenreType.creator ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .creator
            self?.selectButton.setTitle(LocalizeKey.creator.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //design
        actions.append(UIAction(title: LocalizeKey.design.localizedString(), image: nil, state: self.selectedMenuType == GenreType.design ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .design
            self?.selectButton.setTitle(LocalizeKey.design.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //music
        actions.append(UIAction(title: LocalizeKey.music.localizedString(), image: nil, state: self.selectedMenuType == GenreType.music ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .music
            self?.selectButton.setTitle(LocalizeKey.music.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //IT
        actions.append(UIAction(title: LocalizeKey.It.localizedString(), image: nil, state: self.selectedMenuType == GenreType.It ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .It
            self?.selectButton.setTitle(LocalizeKey.It.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //technology
        actions.append(UIAction(title: LocalizeKey.technology.localizedString(), image: nil, state: self.selectedMenuType == GenreType.technology ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .technology
            self?.selectButton.setTitle(LocalizeKey.technology.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        //sports
        actions.append(UIAction(title: LocalizeKey.sports.localizedString(), image: nil, state: self.selectedMenuType == GenreType.sports ? .on : .off,handler: {[weak self] (_) in
            self?.selectedMenuType = .sports
            self?.selectButton.setTitle(LocalizeKey.sports.localizedString(), for: .normal)
            self?.configureMenuButton()
        }))
        
        // UIButtonにUIMenuを設定
        selectButton.menu = UIMenu(title: "Please select the name of the college", options: .displayInline, children: actions)
        // こちらを書かないと表示できない場合があるので注意
        selectButton.showsMenuAsPrimaryAction = true
    }

}
