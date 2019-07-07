//
//  AppDelegate.swift
//  Sports Talk
//
//  Created by Joey Aberasturi on 5/12/19.
//  Copyright © 2019 Joey Aberasturi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

var progressFloat: Float = 0.0

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        progressFloat = 10.0
        FirebaseApp.configure()
        db = Firestore.firestore()
        print(Auth.auth().currentUser)
        
        progressFloat = 20.0
        
        if Auth.auth().currentUser != nil {
             progressFloat - 30.0
            self.getMyData(id: Auth.auth().currentUser!.uid) {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                var tabBarController:UITabBarController = UITabBarController()
                progressFloat = 100.0
                tabBarController = storyBoard.instantiateViewController(withIdentifier: "MainScreen") as! UITabBarController
                self.window?.rootViewController = tabBarController
                self.window!.makeKeyAndVisible()
                //    navigationController.setToolbarHidden(true, animated: false)
            }
        } else {
                progressFloat = 100.0
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                var viewController:UIViewController = UIViewController()
            viewController = storyBoard.instantiateViewController(withIdentifier: "LoginScreen")
                self.window?.rootViewController = viewController
                self.window!.makeKeyAndVisible()
                //    navigationController.setToolbarHidden(true, animated: false)
        
        }
        return true
        
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //functions
    func getMyData(id: String, completion: @escaping () -> ()){
        progressFloat = 40.0
        //get document
        db.collection("users").document(id).getDocument { (document, error) in
            progressFloat = 50.0
            //capture the document
            if let document = document, document.exists {
                progressFloat = 60.0
                //make the user object
                myUser = User(dictionary: document.data()!)
                print("user: \(myUser)")
                progressFloat = 90.0
                completion()
                
            } else {
                print("Document does not exist")
            }
        }
    }

}

