//
//  SelectTableViewController.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/10/25.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

protocol SelectTableViewDelegate {
    func selectTableViewDidChanged(SelectTableViewController)
}

class SelectTableViewController: UITableViewController {
    
    var selectTableViewDelegate: SelectTableViewDelegate? = nil
    
    // AddViewControllerで選択された配列(garbageArrayやtimeArrayなど)
    var selectedArray: Array<AnyObject> = []
    
    var arrayId = Int()
    var selectFlag = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Item Select"
        self.view.backgroundColor = UIColor.whiteColor()
        self.tableView.dataSource = self
        self.tableView.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return selectedArray.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell {
        let cellId: String = "Cell"
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellId)
        
        cell.textLabel!.text = selectedArray[indexPath.row] as String

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectFlag = 1
        arrayId = indexPath.row + 1
        self.navigationController?.popViewControllerAnimated(true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewDidDisappear(animated: Bool) {
        if selectFlag == 1 {
            selectTableViewDelegate!.selectTableViewDidChanged(self)
        }
    }

}
