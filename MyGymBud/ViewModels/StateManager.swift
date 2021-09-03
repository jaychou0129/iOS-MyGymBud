//
//  StateManager.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/25/21.
//

import Foundation

class StateManager: ObservableObject {
    @Published var selectedTab = 1 {
        willSet(newSelectedTab) {
            if newSelectedTab == selectedTab && selectedTab == 0 {
                exercisesGoToRoot()
            }
        }
    }
    @Published var presentingCategoryID: UUID? = nil
    @Published var editingCategory: Category? = nil
    @Published var creatingNewExercise = false
    @Published var presentingExerciseID: UUID? = nil
    @Published var editingExercise = false
    @Published var creatingNewLog = false
    @Published var presentingNewLogConfigSheet = false
    
    @Published var editExerciseChangesMade = false
    @Published var editExerciseNameEmpty = true
    
    func exercisesGoToRoot() {
        dismissExercise()
        creatingNewExercise = false
        editingCategory = nil
        presentingCategoryID = nil
    }
    
    func dismissExercise() {
        dismissExerciseEditing()
        self.presentingExerciseID = nil
    }
    
    func dismissNewExercise() {
        self.creatingNewExercise = false
    }
    
    func dismissExerciseEditing() {
        self.editingExercise = false
    }
    
    func dismissCategoryEditing() {
        self.editingCategory = nil
    }
    
    func dismissNewLog() {
        self.creatingNewLog = false
    }
    
    func dismissNewLogConfigSheet() {
        self.presentingNewLogConfigSheet = false
    }
}
