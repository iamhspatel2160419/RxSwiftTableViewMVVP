//
//  ToDoModel.swift
//  MMVPDemo
//
//  Created by hp ios on 2/24/18.
//  Copyright © 2018 andiosdev. All rights reserved.
//

import Foundation
import RxSwift

protocol ToDoMenuItemViewPresentable {
    var title : String? {get set}
    var backColor : String? {get}
}
protocol ToDoMenuItemViewDelegate
{
    func onMenuItemSelected()->()
    
}
class ToDoMenuItemViewModel:ToDoMenuItemViewPresentable,ToDoMenuItemViewDelegate
{
    var title: String?
    var backColor: String?
    weak var parent : ToDoItemViewDelegate?
    
    init(parentViewModel: ToDoItemViewDelegate)
    {
        self.parent = parentViewModel
    }
    func onMenuItemSelected() {
        
    }
}
class RemoveMenuItemToDo: ToDoMenuItemViewModel {

    override func onMenuItemSelected()
    {
        parent?.onRemoveSelected()
        
    }
}
class DoneMenuItemToDo:ToDoMenuItemViewModel
{
    override func onMenuItemSelected()
    {
        parent?.onDoneSelected()
    }
  
}

protocol ToDoItemViewDelegate:class
{
    func goToDoItemAdded()->(Void)
    func onRemoveSelected()->(Void)
    func onDoneSelected()->(Void)
    
}
protocol ToDoViewDelegate:class
{
    func onAddItem() ->(Void)
    func onRemoveSelected(toDoItem:String)->(Void)
    func onDoneSelected(toDoItem:String)->(Void)
    
}

protocol ItemS
{
    var newValue:String?{get}
}
protocol ToDoItemPresentable
{
    var id:String? { get }
    var textValue:String? { get }
    var isDone:Bool?{get set}
    var menuItems:[ToDoMenuItemViewPresentable]?{ get }
    
}

class TodoItemViewModel:ToDoItemPresentable
{
    var menuItems: [ToDoMenuItemViewPresentable]?=[]
    var isDone: Bool? = false
    var id:String? = "0"
    var textValue:String?
    weak var parent:ToDoViewDelegate?
    
    init(id1:String?,textVal:String?,parentViewModel:ToDoViewDelegate)
    {
        self.id = id1
        self.textValue = textVal
        parent=parentViewModel
      
        let removeMenuItem = RemoveMenuItemToDo(parentViewModel: self as ToDoItemViewDelegate)
        removeMenuItem.title="Remove"
        removeMenuItem.backColor="ff0000"
        
        let DoneMenuItem = DoneMenuItemToDo(parentViewModel: self as ToDoItemViewDelegate)
        DoneMenuItem.title =  isDone! ? "UnDone" : "Done"
        DoneMenuItem.backColor="00ff00"
        
        menuItems?.append(contentsOf:[removeMenuItem,DoneMenuItem])
        
       
        
    }
}
extension TodoItemViewModel:ToDoItemViewDelegate
{
    /*
     * @Discussion onItem selected Received in view model from didSelectRowAt
     * @params id
     * @return Void
     */
    func goToDoItemAdded() {
        
    }
    
    func onRemoveSelected() {
        parent?.onRemoveSelected(toDoItem: id!)
    }
    
    func onDoneSelected() {
        parent?.onDoneSelected(toDoItem: id!)
    }
    
}

class ToDoModel:ItemS
    
{
   
  
    var newValue: String?
    
    
    var items : Variable<[ToDoItemPresentable]> = Variable([])
    
    init()
    {
      
        let item1 = TodoItemViewModel(id1: "1", textVal: "Mac PC",parentViewModel:self as ToDoViewDelegate)
        let item2 = TodoItemViewModel(id1: "2", textVal: "Laptop",parentViewModel:self as ToDoViewDelegate)
        let item3 = TodoItemViewModel(id1: "3", textVal: "iphone7",parentViewModel:self as ToDoViewDelegate)
        items.value.append(contentsOf:[item1,item2,item3])
    }
 }


extension ToDoModel:ToDoViewDelegate
{
    func onAddItem() {
        guard let newValueOfItem = newValue else  {return }
        let itemIndex = items.value.count + 1
        let newItem=TodoItemViewModel(id1: "\(itemIndex)", textVal:newValueOfItem,parentViewModel:self as ToDoViewDelegate)
        self.items.value.append(newItem)
        self.newValue=""
        
    }
    
    func onRemoveSelected(toDoItem: String) {
        guard let index = self.items.value.index(where: {$0.id! == toDoItem})
            else { return }
        
        self.items.value.remove(at: index)
       
    }
    
    func onDoneSelected(toDoItem: String) {
        guard let index = self.items.value.index(where: {$0.id! == toDoItem})
            else { return }
        
            var toDoItem = self.items.value[index]
        
           toDoItem.isDone = !(toDoItem.isDone)!
        
            if var doneMenuItem = toDoItem.menuItems?.filter({ (toDoMenuItem) -> Bool in
                 toDoMenuItem is DoneMenuItemToDo
             }).first
              {
                doneMenuItem.title = toDoItem.isDone! ? "UnDone" : "Done"
              }
           self.items.value.sort(by:
            {
                if !($0.isDone!) && !($1.isDone!)
                {
                    return $0.id! < $1.id!
                }
                if $0.isDone! && $1.isDone!
                {
                    return $0.id! < $1.id!
                }
            return !($0.isDone!) && $1.isDone!
            })
       
       
    }
    
  

}




