//
//  ReminderView.swift
//  Reminders_Pencil
//
//  Created by Patryk Ostrowski on 01/04/2025.
//



//rozkminka przeciaganie

//dodaj funkcje usuwania.

import SwiftUI
import SwiftData
import PencilKit

struct ReminderView: View {
    //dostep do kontekstu, operacje na nim
    @Environment(\.modelContext) var modelContext
    //pobiera dane z bazy, automatycznie aktualizuje widok. Jest nie mutowalna, wiec nie mozemy zamieniac kolejnosci elementow w kolekcji, nie mozna na niej uzywac move
    // swiftData -> @Query reminders -> updateReminders() -> orderedReminders -> UI
    @Query(sort: \Reminder.order) var reminders: [Reminder]
    
    //modyfikujemy wlasicowsci obiektow, zapisujemy poprzez modelContext.save() a w funkcji updateReimnders pobieramy dane z Query do orderedReminders
    //modyfikacje w UI -> orderedReminders -> modyfikacja wlasciowsci obiektow -> modelContext.save() -> baza danych -> @Query reminders
    //kiedy cos tutaj zmieniamy, pamietaj o modelContext.save(),
    @State private var orderedReminders: [Reminder] = []
    
    //do masowego usuwania, empty by defult, no selections
    @State private var selectedProspects = Set<Reminder>()
    
    
    var body: some View {
        //selection umozliwia wybor wielu elementow
        List(selection: $selectedProspects) {
            ForEach(orderedReminders) { reminder in
                NavigationLink(destination: EditReminderView(reminder: reminder)) {
                    HStack {
                        DrawingView(reminder: reminder)
                            .frame(height: 100)
                        
                        Spacer()
                        
                        Image(systemName: "info")
                    }
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        modelContext.delete(reminder)
                        //zapisz zmiany w bazie danych
                        try? modelContext.save()
                        updateReminders()
                        reindexReminders()
                    }
                }
                .tag(reminder)
            }
            //umozliwa przeciaganie i upuszczanie elementow z listy, wywoluje funkjce po zmianie kolejnosci
            .onMove(perform: moveReminder)
            .listRowBackground(Color.gray)
        }
        .navigationTitle("Reminders")
        .scrollContentBackground(.hidden)
        .background(Color.gray)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sample Reminder", systemImage: "plus") {
                    let newOrder = orderedReminders.count
                    let newReminder = Reminder(title: "New reminder \(newOrder)", order: newOrder)
                    modelContext.insert(newReminder)
                    orderedReminders.append(newReminder)
                    print(orderedReminders)
                }
            }
            
            
            if selectedProspects.isEmpty == false {
                ToolbarItem(placement: .bottomBar) {
                    Button("Delete Selected", action: delete)
                }
            }
        }
        .onAppear(perform: updateReminders)
        .onAppear {
            selectedProspects = []
        }
        //wazne gdy sie zmieni cos w query zeby zaktualizowac
        .onChange(of: reminders) {
            updateReminders()
        }

        
        
    }
    

//Movig funcs
    private func moveReminder(from source: IndexSet, to destination: Int) {
        
        //przesuwa elementy w orderReminders metoda move
        orderedReminders.move(fromOffsets: source, toOffset: destination)
        
        // aktualizuje wartosc order kazdego elementu zgdonie z jego nowa pozycja
        for (index, reminder) in orderedReminders.enumerated() {
            reminder.order = index
        }
        
        
        //zapis baza dancyh
        try? modelContext.save()
        print("Moved")
    }
    
    //wazna bardzo akutlanie, kopiuje elementy z reimnders (query) do kolekcji orderedReminders
    func updateReminders() {
        orderedReminders = reminders
    }
    
    func delete() {
        //usun wszystko zaznaczone
        for reminder in selectedProspects {
            modelContext.delete(reminder)
        }
        //zapisz zmiany
        try? modelContext.save()
        updateReminders()
        reindexReminders()
        selectedProspects = []
    }
    
    func reindexReminders() {
        //przechodzi przez wszystkie przypomnienia i ustawia ich wlasciowsci (order) na ich biezacy indeks, wazne jesli usuniemy element
        for (index, reminder) in orderedReminders.enumerated() {
            reminder.order = index
        }
        try? modelContext.save()
    }
    
}


#Preview {
    ReminderView()
        .modelContainer(for: Reminder.self)
}


