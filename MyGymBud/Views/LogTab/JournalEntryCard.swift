//
//  JournalEntryCard.swift
//  MyGymBud
//
//  Created by Jay Chou on 7/31/21.
//

import SwiftUI

struct JournalEntryCard: View {
    @EnvironmentObject var data: MGBData
    let entry: JournalEntry
    let showDate: Bool
    
    private var contentDict: [(String, String)] = []
    
    init(entry: JournalEntry, showDate: Bool) {
        self.entry = entry
        self.showDate = showDate
        if let bodyWeight = entry.bodyWeight {
            contentDict.append(("Body Weight", bodyWeight.disp()))
        }
        if let bodyFatPercentage = entry.bodyFatPercentage {
            contentDict.append(("Body Fat %", bodyFatPercentage.removeTrailingZeros() + "%"))
        }
        if let bmr = entry.bmr {
            contentDict.append(("BMR", bmr.toString()))
        }
        if let bmi = entry.bmi {
            contentDict.append(("BMI", bmi.removeTrailingZeros()))
        }
        if let skeMuscleMass = entry.skeMuscleMass {
            contentDict.append(("Ske. Muscle Mass", skeMuscleMass.disp()))
        }
        if let totalCalories = entry.totalCalories {
            contentDict.append(("Total Calories", totalCalories.toString()))
        }
        if let carb = entry.carbohydrateGrams {
            contentDict.append(("Carbohydrates", carb.removeTrailingZeros() + " g"))
        }
        if let protein = entry.proteinGrams {
            contentDict.append(("Protein", protein.removeTrailingZeros() + " g"))
        }
        if let fat = entry.fatGrams {
            contentDict.append(("Fat", fat.removeTrailingZeros() + " g"))
        }
        if !entry.notes.isEmpty {
            contentDict.append(("Notes", entry.notes))
        }
        contentDict = Array(contentDict.prefix(3))

    }
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5){
                ForEach(contentDict, id: \.0) { label, value in
                    HStack {
                        Text("\(label): ").bold()
                        Text(value).lineLimit(1)
                    }.font(.footnote)
                }
            }
            Spacer()
            if showDate {
                Text(entry.date.disp(data.appConfig.dateDisplayMode)).font(.footnote)
            } else {
                Text(entry.date.dispTime()).font(.footnote)
            }
        }
    }
}

struct JournalEntryCard_Previews: PreviewProvider {
    static var previews: some View {
        JournalEntryCard(entry: JournalEntry(bodyWeight: Weight(70,.KG), bodyFatPercentage: 20.0, bmr: 1800, bmi: 18, skeMuscleMass: Weight(33, .KG), totalCalories: 2100), showDate: false)
            .environmentObject(MGBData())
    }
}
