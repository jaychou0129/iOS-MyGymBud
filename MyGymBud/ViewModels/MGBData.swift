//
//  MGBData.swift
//  MyGymBud
//
//  Created by Jay Chou on 6/16/21.
//

import SwiftUI
import Combine

class MGBData: ObservableObject {
    private static var documentsFolder: URL {
        do {
            return try FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: false)
        } catch {
            fatalError("Can't find documents directory.")
        }
    }
    
    private static var categoriesFileURL: URL {
        return documentsFolder.appendingPathComponent("categories.data")
    }
    private static var logsFileURL: URL {
        return documentsFolder.appendingPathComponent("logs.data")
    }
    private static var journalFileURL: URL {
        return documentsFolder.appendingPathComponent("journal.data")
    }
    private static var appConfigFileURL: URL {
        return documentsFolder.appendingPathComponent("config.data")
    }
    
    @Published var categories: [Category] = [] {
        didSet { saveCategories() }
    }
    @Published var logs: [Log] = [] {
        didSet { saveLogs() }
    }
    @Published var journal: [JournalEntry] = [] {
        didSet { saveJournal() }
    }
    @Published var appConfig: AppConfiguration = AppConfiguration() {
        didSet { saveAppConfig() }
    }
    
    var listOfCategoryNames: [String] {
        var list: [String] = []
        for element in self.categories {
            list.append(element.name)
        }
        return list
    }
    
    init() {
        self.load()
    }
    
    func resetAllSettings() {
        self.appConfig.resetAll()
    }
    
    func updateCategory(id: UUID, from detailData: Category.Data) {
        if let index = self.categories.firstIndex(where: {$0.id == id}) {
            self.categories[index].update(from: detailData)
        } else {
            // new category
            self.categories.append(Category(name: detailData.name, color: detailData.color))
        }
    }
    
    func deleteCategory(id: UUID) {
        guard let index = self.categories.firstIndex(where: {$0.id == id}) else {
            return
        }
        
        for exercise in self.categories[index].exercises {
            // delete all logs of this exercise
            self.logs.removeAll(where: {$0.eID == exercise.id})
        }
        self.categories.remove(at: index)
    }
    
    func moveCategory(from source: IndexSet, to destination: Int) {
        self.categories.move(fromOffsets: source, toOffset: destination)
    }
    
    func findCategory(id: UUID) -> Category? {
        return self.categories.first(where: {$0.id == id})
    }
    
    func findCategory(name: String) -> Category? {
        return self.categories.first(where: {$0.name == name})
    }
    
    func findCategoryIndex(category: Category) -> Int? {
        return self.categories.firstIndex(where: { $0.id == category.id })
    }
    
    func deleteExercise(categoryID: UUID, id: UUID) {
        guard let cIndex = self.categories.firstIndex(where: {$0.id == categoryID}) else {
            return
        }
        
        self.categories[cIndex].exercises.removeAll(where: { $0.id == id })
    }
    
    func addExercise(categoryID: UUID, from data: Exercise.Data) {
        guard let cIndex = self.categories.firstIndex(where: {$0.id == categoryID}) else {
            return
        }
        
        self.categories[cIndex].exercises.append(Exercise(from: data))
    }
    
    func addExercise(categoryID: UUID, exercise data: Exercise) {
        guard let cIndex = self.categories.firstIndex(where: {$0.id == categoryID}) else {
            return
        }
        
        self.categories[cIndex].exercises.append(data)
    }
    
    func findExercise(id: UUID) -> Exercise? {
        for category in self.categories {
            if let ex = category.exercises.first(where: {$0.id == id}) {
                return ex
            }
        }
        return nil
    }
    
    func findExercise(categoryID: UUID, id: UUID) -> Exercise? {
        if let category = self.categories.first(where: {$0.id == categoryID}) {
            return category.exercises.first(where: {$0.id == id})
        }
        return nil
    }
    
    func findExercise(category: Category, id: UUID) -> Exercise? {
        return category.exercises.first(where: {$0.id == id})
    }
    
    func findExerciseIndices(category: Category? = nil, exercise: Exercise) -> (categoryIndex: Int, exerciseIndex: Int)? {
        guard let categoryIndex = self.categories.firstIndex(where: {$0.exercises.contains(exercise)}),
              let exerciseIndex = self.categories[categoryIndex].exercises.firstIndex(where: {$0.id == exercise.id}) else {
            return nil
        }
            
        return (categoryIndex, exerciseIndex)
    }
    
    func findColor(exerciseID: UUID) -> Color {
        guard let exercise = self.findExercise(id: exerciseID) else {
            return .random
        }
        
        for category in self.categories {
            if category.exercises.contains(exercise) {
                return category.color
            }
        }
        return .random
    }
    
    func moveExercise(fromCategoryID: UUID, id: UUID, toCategoryName: String) {
        if let toCategoryID = self.findCategory(name: toCategoryName)?.id,
           let exercise = self.findExercise(categoryID: fromCategoryID, id: id) {
            // add to destination
            self.addExercise(categoryID: toCategoryID, exercise: exercise)
            
            // delete from source
            self.deleteExercise(categoryID: fromCategoryID, id: id)
        }
    }
    
    func newLog(date: Date, data: Log.Data) {
        var tempData = data
        tempData.date = .createDate(onDay: date, atTime: Date()) // add time component to date
        self.logs.append(Log.build(from: tempData))
        
        if let exercise = self.findExercise(id: data.eID) {
            self.updateMaxRecord(exercise: exercise, newLog: data)
        }
    }
    
    func updateLog(log: Log, data: Log.Data) {
        if let logIndex = self.logs.firstIndex(where: {$0.id == log.id}) {
            self.logs[logIndex].update(from: data)
        }
    }
    
    func findLogs(for exercise: Exercise) -> [Log] {
        return self.logs.filter({$0.eID == exercise.id}).sorted()
    }
    
    func deleteLog(offsets: IndexSet) {
        for index in offsets {
            if let exercise = self.findExercise(id: self.logs[index].eID) {
                self.logs.remove(at: index)
                self.updateMaxRecord(exercise: exercise)
            }
        }
    }
    
    func deleteLog(ids: [UUID]) {
        for id in ids {
            if let index = self.logs.firstIndex(where: {$0.id == id}),
               let exercise = self.findExercise(id: self.logs[index].eID) {
                self.logs.remove(at: index)
                self.updateMaxRecord(exercise: exercise)
            }
        }
    }
    
    func clearLogs(exerciseID: UUID) {
        self.logs.removeAll(where: {$0.eID == exerciseID})
        resetMaxRecords(exerciseID: exerciseID)
    }
    
    func deleteLogsWithUndefinedExerciseID() {
        guard self.logs.count > 0 else {
            return
        }
        
        for index in self.logs.indices {
            if self.findExercise(id: self.logs[index].eID) == nil {
                self.logs.remove(at: index)
            }
        }
    }
    
    func resetMaxRecords(exerciseID: UUID) {
        for categoryIndex in self.categories.indices {
            if let exerciseIndex = self.categories[categoryIndex].exercises.firstIndex(where: {$0.id == exerciseID}) {
                self.categories[categoryIndex].exercises[exerciseIndex].maxDate = nil
                self.categories[categoryIndex].exercises[exerciseIndex].maxTimedLog = nil
                self.categories[categoryIndex].exercises[exerciseIndex].maxWeightLog = nil
            }
        }
    }
    
    func setMaxRecord(exercise: Exercise, maxDate: Date, maxWeightLog: WeightLog? = nil, maxTimedLog: TimedLog? = nil) {
        if let indices = self.findExerciseIndices(exercise: exercise) {
            self.categories[indices.categoryIndex].exercises[indices.exerciseIndex].maxDate = maxDate
            self.categories[indices.categoryIndex].exercises[indices.exerciseIndex].maxWeightLog = maxWeightLog
            self.categories[indices.categoryIndex].exercises[indices.exerciseIndex].maxTimedLog = maxTimedLog
        }
    }
    
    func updateMaxRecord(exercise: Exercise, newLog: Log.Data? = nil) {
        if let newLog = newLog { // only compare current max and newLog
            switch exercise.mode {
            case .Weight:
                var temp = newLog.weightLogs.sorted().last!
                temp.reps = [temp.reps.sorted().last!]
                
                if exercise.maxWeightLog == nil || temp > exercise.maxWeightLog! || (temp == exercise.maxWeightLog! && newLog.date > exercise.maxDate!) {
                    setMaxRecord(exercise: exercise, maxDate: newLog.date, maxWeightLog: temp)
                }
            case .Timed:
                let temp = newLog.timedLogs.sorted().last!
                
                if exercise.maxTimedLog == nil || temp > exercise.maxTimedLog! || (temp == exercise.maxTimedLog! && newLog.date > exercise.maxDate!) {
                    setMaxRecord(exercise: exercise, maxDate: newLog.date, maxTimedLog: temp)
                }
            default:
                return
            }
        } else { // resets max records and thoroughly check every log to find new Max
            self.resetMaxRecords(exerciseID: exercise.id)
            
            switch exercise.mode {
            case .Weight:
                var temp = self.logs.filter{ $0.eID == exercise.id }.map { (date: $0.date, weightLog: $0.weightLogs.sorted().last!) } // keep date and "greatest" weightLog
                
                if temp.isEmpty {
                    return
                }
                temp.sort { lhs, rhs in
                    lhs.weightLog == rhs.weightLog ? (lhs.date > rhs.date) : (lhs.weightLog > rhs.weightLog)
                }
                if var tempLog = temp.first {
                    tempLog.weightLog.reps = [tempLog.weightLog.reps.sorted().last!] // keep the greatest rep only
                    self.setMaxRecord(exercise: exercise, maxDate: tempLog.date, maxWeightLog: tempLog.weightLog)
                }
                
            case .Timed:
                var temp = self.logs.filter{ $0.eID == exercise.id }.map { (date: $0.date, timedLog: $0.timedLogs.sorted().last!) } // keep date and "greatest" timedLog
                
                if temp.isEmpty {
                    resetMaxRecords(exerciseID: exercise.id)
                    return
                }
                temp.sort { lhs, rhs in
                    return (lhs.timedLog == rhs.timedLog) ? (lhs.date > rhs.date) : (lhs.timedLog > rhs.timedLog)
                }
                if let tempLog = temp.first {
                    self.setMaxRecord(exercise: exercise, maxDate: tempLog.date, maxTimedLog: tempLog.timedLog)
                }
            default:
                return
            }
        }
    }
    
    func newJournalEntry(data: JournalEntry.Data) {
        var tempData = data
        tempData.date = .createDate(onDay: data.date, atTime: Date()) // add time component to date
        self.journal.append(JournalEntry.build(from: tempData))
    }
    
    func deleteJournalEntry(ids: [UUID]) {
        for id in ids {
            if let index = self.journal.firstIndex(where: {$0.id == id}) {
                self.journal.remove(at: index)
            }
        }
    }
    
    func updateJournalEntry(entry: JournalEntry, from data: JournalEntry.Data) {
        if let index = self.journal.firstIndex(where: {$0.id == entry.id}) {
            self.journal[index].update(from: data)
        }
    }
    
    func load() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            // read Categories data
            if let data = try? Data(contentsOf: Self.categoriesFileURL),
               let decodedData = try? JSONDecoder().decode([Category].self, from: data) {
                DispatchQueue.main.async {
                    self?.categories = decodedData
                }
                print("CATEGORIES: FROM SAVED")
            } else {
                // file does not exist or file format/organization changed
                // populate with sample data
                DispatchQueue.main.async {
                    self?.categories = Category.sampleData
                }
                print("CATEGORIES: FROM SAMPLE")
            }
            
            // read Logs data
            if let data = try? Data(contentsOf: Self.logsFileURL),
               let decodedData = try? JSONDecoder().decode([Log].self, from: data) {
                DispatchQueue.main.async {
                    self?.logs = decodedData
                }
                print("LOGS: FROM SAVED")
            } else {
                // file does not exist or file format/organization changed
                // leave logs empty
                print("LOGS: EMPTY")
            }
            
            // read AppConfig data
            if let data = try? Data(contentsOf: Self.journalFileURL),
               let decodedData = try? JSONDecoder().decode([JournalEntry].self, from: data) {
                DispatchQueue.main.async {
                    self?.journal = decodedData
                }
                print("JOURNAL: FROM SAVED")
            } else {
                // file does not exist or file format/organization changed
                // leave appConfig as default
                print("JOURNAL: EMPTY")
            }
            
            // read AppConfig data
            if let data = try? Data(contentsOf: Self.appConfigFileURL),
               let decodedData = try? JSONDecoder().decode(AppConfiguration.self, from: data) {
                DispatchQueue.main.async {
                    self?.appConfig = decodedData
                }
                print("APPCONFIG: FROM SAVED")
            } else {
                // file does not exist or file format/organization changed
                // leave appConfig as default
                print("APPCONFIG: EMPTY")
            }
        }
    }
    
    func save() {
        saveCategories()
        saveLogs()
        saveJournal()
        saveAppConfig()
    }
    
    func saveCategories() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            // save Categories data
            if let categories = self?.categories,
               let encodedData = try? JSONEncoder().encode(categories) {
                do {
                    try encodedData.write(to: Self.categoriesFileURL)
                } catch { print("Can't write categories to file"); }
            }
        }
        print("SAVED CATEGORIES")
    }
    
    func saveLogs() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            // save Logs data
            if let logs = self?.logs,
               let encodedData = try? JSONEncoder().encode(logs) {
                do {
                    try encodedData.write(to: Self.logsFileURL)
                } catch { print("Can't write logs to file"); }
            }
        }
        print("SAVED LOGS")
    }
    
    func saveJournal() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            // save Journal data
            if let journal = self?.journal,
               let encodedData = try? JSONEncoder().encode(journal) {
                do {
                    try encodedData.write(to: Self.journalFileURL)
                } catch { print("Can't write journal to file"); }
            }
        }
        print("SAVED JOURNAL")
    }
    
    func saveAppConfig() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            // save AppConfig data
            if let appConfig = self?.appConfig,
               let encodedData = try? JSONEncoder().encode(appConfig) {
                do {
                    try encodedData.write(to: Self.appConfigFileURL)
                } catch { print("Can't write appConfig to file"); }
            }
        }
        print("SAVED APPCONFIGS")
    }
}
