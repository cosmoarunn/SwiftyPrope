//
//  PropeViewController.swift
//  PropeEpafes
//
//  Created by ARUN PANNEERSELVAM on 18/12/2024.
//

import UIKit

class PropeViewController: UIViewController, Coordinatable, Tabbable {
    var tabCoordinator: ViewCoordinator?
    var coordinator: ViewCoordinator?
    
    init(coordinator: ViewCoordinator) {
        super.init(nibName: nil, bundle: nil)
        self.coordinator = coordinator
        self.tabCoordinator = coordinator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
