//
//  ViewController.swift
//  MMVPDemo
//
//  Created by hp ios on 2/24/18.
//  Copyright © 2018 andiosdev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


extension String {
    var hexColor: UIColor {
        let hex = trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var txtFieldNewItems: UITextField!
    @IBOutlet weak var tableViewItems: UITableView!
    
    var disposeBag = DisposeBag()
    var viewModel:ToDoModel?
    
    @IBAction func AddItemsOnClick(_ sender: Any)
    {
        guard let newTFValue = txtFieldNewItems.text,!newTFValue.isEmpty else {return}
        viewModel?.newValue = newTFValue
        DispatchQueue.global(qos: .background).async {
            self.viewModel?.onAddItem()
        }
       
    }
    let todoItemIdentifier = "ToDoItemViewCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      let nibname = UINib(nibName: "ToDoItemViewCell", bundle: nil)
      tableViewItems.register(nibname, forCellReuseIdentifier: todoItemIdentifier)
      
      viewModel = ToDoModel()
      
     
        viewModel?.items.asObservable().bind(to:
            tableViewItems.rx.items(cellIdentifier: todoItemIdentifier,
                                    cellType: ToDoItemViewCell.self))
            {
                (index,item,cell) in
            
                cell.configure(withModelView: item)
         
            }.disposed(by:disposeBag)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var AddItem: UIButton!
    
}

extension ViewController:UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //_ itemViewModel = viewModel?.items[indexPath.row]
        
       
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var menuActions:[UIContextualAction]=[]
        
        let itemViewModel = viewModel?.items.value[indexPath.row]
       _ = itemViewModel?.menuItems?.map({
        
            menu in
            let menuAction = UIContextualAction(style: .normal, title: menu.title) {
                (action, sourceView, Suceess:(Bool)->Void) in
                
                if let delegate = menu as? ToDoMenuItemViewDelegate
                {
                    DispatchQueue.global(qos: .background).async
                    {
                        delegate.onMenuItemSelected()
                        
                    }
                    
                }
               Suceess(true)
                
            }
            menuAction.backgroundColor = menu.backColor?.hexColor
            menuActions.append(menuAction)
        })
      
        return UISwipeActionsConfiguration(actions: menuActions)
    }
}


