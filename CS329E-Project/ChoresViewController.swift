//
//  ChoresViewController.swift
//  CS329E-Project
//
//  Created by Dominic on 10/9/22.
//


import UIKit
import CalendarKit
import EventKit
import EventKitUI

final class ChoresViewController: DayViewController, EKEventEditViewDelegate {
    private var eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chores Calendar"
        // The app must have access to the user's calendar to show the events on the timeline
        calendarAccess()
        // Subscribe to notifications to reload the UI when
        subscribeToNotifications()
        //Adding unique font
        UILabel.appearance().substituteFontName = "American Typewriter";
        UITextView.appearance().substituteFontName = "American Typewriter";
        UITextField.appearance().substituteFontName = "American Typewriter";
        UIButton.appearance().substituteFontName = "American Typewriter";
    }
    
    @IBAction func addEventPress(_ sender: Any) {
        let event = EKEvent(eventStore: self.eventStore)
        event.title = "New Event"
        event.startDate = Date()
        presentEditingViewForEvent(event)
        
    }
    private func calendarAccess() {
        // Request access to the events
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            // Handle the response to the request.
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.initializeStore()
                self.subscribeToNotifications()
                self.reloadData()
    
            }
        }
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storeChanged(_:)),
                                               name: .EKEventStoreChanged,
                                               object: eventStore)
    }
    
    private func initializeStore() {
        eventStore = EKEventStore()
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    

    

    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        // The `date` always has it's Time components set to 00:00:00 of the day requested
        let startDay = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        // By adding one full `day` to the `startDate`, we're getting to the 00:00:00 of the *next* day
        let endDay = calendar.date(byAdding: oneDayComponents, to: startDay)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDay, // Start of the current day
                                                      end: endDay, // Start of the next day
                                                      calendars: nil) // Search in all calendars
        
        let eventKitEvents = eventStore.events(matching: predicate) // All events happening on a given day
        let calendarKitEvents = eventKitEvents.map(EKWrapper.init)
        
        return calendarKitEvents
    }
    
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let calendarKitEvent = eventView.descriptor as? EKWrapper else {
            return
        }
        presentEventDetailView(calendarKitEvent.ekEvent)
    }
    
    private func presentEventDetailView(_ ekEvent: EKEvent) {
        let eventController = EKEventViewController()
        eventController.event = ekEvent
        eventController.allowsCalendarPreview = true
        eventController.allowsEditing = true
        navigationController?.pushViewController(eventController,
                                                 animated: true)
    }
    

    
    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        // Cancel editing current event and start creating a new one
        endEventEditing()
        let newEKWrapper = makeNewEvent(at: date)
        create(event: newEKWrapper, animated: true)
    }
    
    private func makeNewEvent(at date: Date) -> EKWrapper {
        let newEKEvent = EKEvent(eventStore: eventStore)
        newEKEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        var components = DateComponents()
        components.hour = 1
        let endDate = calendar.date(byAdding: components, to: date)
        
        newEKEvent.startDate = date
        newEKEvent.endDate = endDate
        newEKEvent.title = "New event"
        
        let newEKWrapper = EKWrapper(eventKitEvent: newEKEvent)
        newEKWrapper.editedEvent = newEKWrapper
        return newEKWrapper
    }
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor as? EKWrapper else {
            return
        }
        endEventEditing()
        beginEditing(event: descriptor,
                     animated: true)
    }
    
    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        guard let editingEvent = event as? EKWrapper else { return }
        if let originalEvent = event.editedEvent {
            editingEvent.commitEditing()
            
            if originalEvent === editingEvent {
                // If editing event is the same as the original one, it has just been created.
                // Showing editing view controller
                presentEditingViewForEvent(editingEvent.ekEvent)
            } else {
                // If editing event is different from the original,
                // then it's pointing to the event already in the `eventStore`
                // Let's save changes to oriignal event to the `eventStore`
                try! eventStore.save(editingEvent.ekEvent,
                                     span: .thisEvent)
            }
        }

        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    
    private func presentEditingViewForEvent(_ ekEvent: EKEvent) {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.event = ekEvent
        eventEditViewController.eventStore = eventStore
        eventEditViewController.editViewDelegate = self
        present(eventEditViewController, animated: true, completion: nil)
    }
    
    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
    }
    
    override func dayViewDidBeginDragging(dayView: DayView) {
        endEventEditing()
    }
    
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        endEventEditing()
        
        DispatchQueue.main.async {
            self.reloadData()
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}

