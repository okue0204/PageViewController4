//
//  UIStoryboard.swift
//  PageViewController4
//
//  Created by 奥江英隆 on 2024/05/27.
//

import Foundation
import UIKit

extension UIStoryboard {
    static let latestStoryboard = UIStoryboard(name: String(describing: LatestViewController.self), bundle: nil)
    
    static let programStoryboard = UIStoryboard(name: String(describing: ProgramViewController.self), bundle: nil)
    
    static let downloadCompleteStoryboard = UIStoryboard(name: String(describing: DownloadCompleteViewController.self), bundle: nil)
    
    static let playlistStoryboard = UIStoryboard(name: String(describing: PlayListViewController.self), bundle: nil)
}
