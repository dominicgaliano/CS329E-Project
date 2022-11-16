//
//  ChoresViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//

import UIKit
var choreList: [Chore] = []

class ChoresViewController: UIViewController, UICalendarSelectionSingleDateDelegate, sendChore{
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        print(choreList)
        return 
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createCalendar()
    }
    func createCalendar(){
        //create calendar
        let calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        //calendar settings
        calendarView.calendar = .current
        calendarView.locale = .current
        calendarView.fontDesign = .rounded
        calendarView.delegate = self
        
        //make the selection single selection
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        
        view.addSubview(calendarView)

    }
    func addChore(newChore: Chore) {
        choreList.append(newChore)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "choreSchedSegue" {
            let secondVC: ChoresSchedulerViewController = segue.destination as! ChoresSchedulerViewController
            secondVC.delegate = self
        }
    }


}

extension ChoresViewController: UICalendarViewDelegate{
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let font = UIFont.systemFont(ofSize: 10)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let image = UIImage(systemName: "circle.fill", withConfiguration: configuration)?.withRenderingMode(.alwaysOriginal)
        return .image(image)
    }
}
