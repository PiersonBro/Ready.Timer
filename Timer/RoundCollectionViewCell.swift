//
//  RoundCollectionViewCell.swift
//  Timer
//
//  Created by EandZ on 3/25/16.
//  Copyright © 2016 E&Z Pierson. All rights reserved.
//

import UIKit

class RoundCollectionViewCell: UICollectionViewCell {
    var gestureRecognizer: UIPanGestureRecognizer? = nil
    // Note this must be set
    var draggingHandler: CellDraggingHandler? = nil {
        didSet {
            if let draggingHandler = draggingHandler {
                gestureRecognizer = UIPanGestureRecognizer(target: draggingHandler, action: #selector(draggingHandler.cellWasDragged(_:)))
                gestureRecognizer?.delegate = draggingHandler
                addGestureRecognizer(gestureRecognizer!)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
