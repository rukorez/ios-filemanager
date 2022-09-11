//
//  NavigationController.swift
//  MyCustomFileManger
//
//  Created by Филипп Степанов on 10.09.2022.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "storageTypeChanged"), object: nil, queue: OperationQueue.main) { notification in
            self.popToRootViewController(animated: true)
            (self.viewControllers.last as? FileManagerTableViewController)?.model = Model()
            (self.viewControllers.last as? FileManagerTableViewController)?.tableView.reloadData()
        }
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
