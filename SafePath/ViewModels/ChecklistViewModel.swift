import Foundation
import Combine

/// Person 3: Manages checklist state and persistence.
@MainActor
final class ChecklistViewModel: ObservableObject {
    // TODO: Person 3 will implement checklist CRUD, check-off, progress calculation, and local persistence.
    
    @Published var checklists: [DisasterChecklist] = []
    @Published var activeChecklist: DisasterChecklist?
}
