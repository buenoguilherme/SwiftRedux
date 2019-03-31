import Foundation

typealias State = [String: Any]

enum ReduxError: Error {
    case typeError
}

protocol Action {}

struct Reducer<T> where T: Action {
    let stateName: String
    let initialValue: Any
    let f: (Any, T) throws -> Any
}

class Store<T> where T: Action {
    private var state: State = State()
    private var reducers: [Reducer<T>]

    init(reducers: [Reducer<T>]) {
        self.reducers = reducers
    }

    func dispatch(action: T) throws {
        try reducers.forEach { reducer in
            let reducerState = state[reducer.stateName] ?? reducer.initialValue
            state[reducer.stateName] = try reducer.f(reducerState, action)
        }
    }

    func getState() -> State {
        return state
    }
}

enum CalculatorAction: Action {
    case add(number: Int)
    case minus(number: Int)
}


let currentValue = Reducer<CalculatorAction>(stateName: "currentValue", initialValue: 0) { state, action in
    guard let state = state as? Int else {
        throw ReduxError.typeError
    }

    switch action {
    case .add(let number):
        return state + number
    case .minus(let number):
        return state - number
    }
}


let store = Store(reducers: [currentValue])
print(store.getState())

try? store.dispatch(action: .add(number: 1))
print(store.getState())

try? store.dispatch(action: .add(number: 2))
print(store.getState())

try? store.dispatch(action: .minus(number: 10))
print(store.getState())
