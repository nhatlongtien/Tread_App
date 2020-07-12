//
//  LogCell.swift
//  Treads
//
//  Created by NGUYENLONGTIEN on 6/9/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {
    // MARK: - UI Elements
    
    @IBOutlet weak var durationLable: UILabel!
    @IBOutlet weak var paceLable: UILabel!
    @IBOutlet weak var distanceLable: UILabel!
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var unitDistanceLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configureCell(run:Run){
        var duration = run.duration.convertFromDurationTimeToTime()
        //
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        var pace = formatter.string(from: NSNumber(value: run.pace))
        if run.distance > 1000 {
            distanceLable.text = formatter.string(from: NSNumber(value: run.distance/1000))
            unitDistanceLable.text = "Km"
        }else{
            distanceLable.text = formatter.string(from: NSNumber(value: run.distance))
            unitDistanceLable.text = "m"
        }
        
        //
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/mm/yy"
        var date = dateFormatter.string(from: run.date)
        //
        durationLable.text = duration
        paceLable.text = pace
        dateLable.text = date
        //
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
