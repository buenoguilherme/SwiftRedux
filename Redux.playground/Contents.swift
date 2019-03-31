import Foundation

typealias State = [String: Any]

enum ReduxError: Error {
    case typeError
}

protocol Action {}

protocol AppState {
    var name: String { get }
}

struct Reducer<T> where T: Action {
    let state: AppState
    let initialValue: Any
    let f: (Any, T) throws -> Any
}

protocol StoreSubscriber {
    func new(_ state: Any)
}

protocol TypedStoreSubscriber {
    associatedtype StateType
    func new(typed state: StateType)
}

extension TypedStoreSubscriber where Self: StoreSubscriber {
    func new(_ state: Any) {
        if let state = state as? StateType {
            new(typed: state)
        }
    }
}

class Store<T> where T: Action {
    private var state: State = State()
    private var reducers: [Reducer<T>]
    private var subscribers: [String: [StoreSubscriber]] = [String: [StoreSubscriber]]()

    init(reducers: [Reducer<T>]) {
        self.reducers = reducers
    }

    func dispatch(action: T) throws {
        try reducers.forEach { reducer in
            let reducerState = state[reducer.state.name] ?? reducer.initialValue
            state[reducer.state.name] = try reducer.f(reducerState, action)
            notify(reducer.state)
        }
    }

    private func notify(_ appState: AppState) {
        if let state = state[appState.name] {
            subscribers[appState.name]?.forEach { $0.new(state) }
        }
    }

    func add(subscriber: StoreSubscriber, to state: AppState) {
        var values: [StoreSubscriber] = subscribers[state.name] ?? []
        values.append(subscriber)
        subscribers.updateValue(values, forKey: state.name)
    }
}

enum CalculatorAction: Action {
    case add(number: Int)
    case minus(number: Int)
}

enum CalculatorState: AppState {
    case currentValue

    var name: String {
        switch self {
        case .currentValue:
            return "currentValue"
        }
    }
}

let currentValue = Reducer<CalculatorAction>(state: CalculatorState.currentValue, initialValue: 0) { state, action in
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

struct StoreListener: StoreSubscriber, TypedStoreSubscriber {
    typealias StateType = Int

    func new(typed state: StateType) {
        print(state)
    }
}

let store = Store(reducers: [currentValue])
store.add(subscriber: StoreListener(), to: CalculatorState.currentValue)

try? store.dispatch(action: .add(number: 1))
try? store.dispatch(action: .add(number: 2))
try? store.dispatch(action: .minus(number: 10))

