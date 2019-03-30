import Foundation

typealias State = [String: Any]

enum ReduxError: Error {
    case typeError
}

enum Action {
    case add(number: Int)
    case minus(number: Int)
}

protocol ReducerType {
    associatedtype StateType

    var stateName: String { get }
    var initialValue: StateType { get }
    var f: (StateType, Action) throws -> StateType { get }
}

struct Reducer: ReducerType {
    typealias StateType = Any

    let stateName: String
    let initialValue: Any
    let f: (Any, Action) throws -> Any
}

let currentValue = Reducer(stateName: "currentValue", initialValue: 0) { state, action in
    guard let state = state as? Int else {
        throw ReduxError.typeError
    }

    switch action {
    case .add(let number):
        return state + number
    default:
        return state
    }
}

func add(_ number: Int) -> Action {
    return .add(number: number)
}


class Store {
    private var state: State = State()
    private let reducers: [Reducer]

    init(reducers: [Reducer]) {
        self.reducers = reducers
    }

    func dispatch(action: Action) throws {
        try reducers.forEach { reducer in
            let reducerState = state[reducer.stateName] ?? reducer.initialValue
            state[reducer.stateName] = try reducer.f(reducerState, action)
        }
    }

    func getState() -> State {
        return state
    }
}

let store = Store(reducers: [currentValue])
print(store.getState())

do {
    try store.dispatch(action: add(1))
    print(store.getState())
} catch {
    print("Deu erro!")
}


