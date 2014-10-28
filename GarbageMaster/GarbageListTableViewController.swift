//
//  GarbageListTableViewController.swift
//  GarbageMaster
//
//  Created by 門脇裕 on 2014/10/11.
//  Copyright (c) 2014年 yu_kadowaki. All rights reserved.
//

import UIKit

class GarbageListTableViewController: UITableViewController {
    
    var myData: Array<AnyObject> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myData = ["燃えるゴミ", "燃えないゴミ", "ビン・カン", "ペットボトル", "粗大ごみ"]

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return myData.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell {

        let CellId: String = "Cell"
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(CellId) as UITableViewCell
        
        if let index = indexPath {
            cell.textLabel?.text = myData[index.row] as String
        }
        
        return cell
    }


    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            if let tv = tableView {
                myData.removeAtIndex(indexPath!.row)
                tv.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            }
        } else if editingStyle == .Insert {
        
        }
    }

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

}
