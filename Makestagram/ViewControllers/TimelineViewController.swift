//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Jason Katzer on 5/12/16.
//  Copyright © 2016 Make School. All rights reserved.
//


import UIKit
import Parse
import ConvenienceKit

class TimelineViewController: UIViewController,TimelineComponentTarget {
    
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!
    
    let defaultRange = 0...4
    let additionalRangeSize = 5
    
//    var posts: [Post] = []
    
    var photoTakingHelper: PhotoTakingHelper?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         timelineComponent = TimelineComponent(target: self)
        self.tabBarController?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        timelineComponent.loadInitialIfRequired()
        
//        ParseHelper.timelineRequestForCurrentUser {
//            (result: [PFObject]?, error: NSError?) -> Void in
//            self.posts = result as? [Post] ?? []
//            
//            self.tableView.reloadData()
//        }
    }
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        // 1
        ParseHelper.timelineRequestForCurrentUser(range) { (result: [PFObject]?, error: NSError?) -> Void in
            // 2
            let posts = result as? [Post] ?? []
            // 3
            completionBlock(posts)
        }
    }
    
    
    func takePhoto() {
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!, callback: { (image: UIImage?) in
            
            let post = Post()
            post.image.value = image!
            post.uploadPost()
            
//            if let image = image {
//                let imageData = UIImageJPEGRepresentation(image, 0.8)!
//                let imageFile = PFFile(name: "image.jpg", data: imageData)!
//                
//                let post = PFObject(className: "Post")
//                post["imageFile"] = imageFile
//                post.saveInBackground()
//            }
        })
    }
    
}

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 1
        return timelineComponent.content.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 2
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
//        cell.textLabel!.text = "Post"
//        cell.postImageView.image = posts[indexPath.row].image
        let post = timelineComponent.content[indexPath.row]
        // 1
        post.downloadImage()
        // 2
         post.fetchLikes()
        
        cell.post = post
        
        return cell
    }
}

extension TimelineViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    }
    
}


// MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            //            print("Take Photo")
            takePhoto()
            return false
        } else {
            return true
        }
    }
}