//
//  SecondViewController.swift
//  TabBarDemo
//
//  Created by 강보현 on 3/19/25.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TabBarController viewDidLoad")
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .systemBackground
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        setupTabBar()
    }
    
    func setupTabBar() {
        let firstVC = FirstViewController()
        let secondVC = SecondViewController()
        
        let firstNavController = UINavigationController(rootViewController: firstVC)
        let secondNavController = UINavigationController(rootViewController: secondVC)
        
        self.viewControllers = [firstNavController, secondNavController]
        
        firstNavController.tabBarItem = UITabBarItem(title: "첫번쩨", image: UIImage(systemName: "1.circle"), tag: 0)
        secondNavController.tabBarItem = UITabBarItem(title: "두번째", image: UIImage(systemName: "2.circle"), tag: 1)
    }
    
}

#Preview {
    UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
    
}
