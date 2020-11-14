import UIKit
import Dispatch

let numberOfPhilosophers = 5

print("Количество философов: \(numberOfPhilosophers)")

struct ForkPair {
    static let forksSemaphore: [DispatchSemaphore] = Array(repeating: DispatchSemaphore(value: 1), count: numberOfPhilosophers)
    
    let leftFork: DispatchSemaphore
    let rightFork: DispatchSemaphore
    
    init(leftIndex: Int, rightIndex: Int) {
        //Упорядочивание вилок по индексу, чтобы исключить deadlock
        if leftIndex > rightIndex {
            leftFork = ForkPair.forksSemaphore[leftIndex]
            rightFork = ForkPair.forksSemaphore[rightIndex]
        } else {
            leftFork = ForkPair.forksSemaphore[rightIndex]
            rightFork = ForkPair.forksSemaphore[leftIndex]
        }
    }
    
    func pickUp() {
        leftFork.wait() // ожидание левой вилки
        rightFork.wait() // ожидание правой вилки
    }
    
    func putDown() {
        leftFork.signal() // ожидание сигнала левой вилки
        rightFork.signal() // ожидание сигнала правой вилки
    }
}

struct Philosophers {
    let forkPair: ForkPair
    let philosopherIndex: Int
    
    var leftIndex = -1
    var rightIndex = -1
    
    init(philosopherIndex: Int) {
        leftIndex = philosopherIndex
        rightIndex = philosopherIndex - 1
        
        if rightIndex < 0 {
            rightIndex += numberOfPhilosophers
        }
        
        self.forkPair = ForkPair(leftIndex: leftIndex, rightIndex: rightIndex)
        self.philosopherIndex = philosopherIndex
        
        
    }
    
    func run() {
        while true {
            print("Подписывается на поток философ: \(philosopherIndex) ")
            forkPair.pickUp()
            print("Начинает есть философ: \(philosopherIndex)")
            sleep(1)
            print("Заканчивает есть философ: \(philosopherIndex)")
            forkPair.putDown()
        }
    }
}

let globalSem = DispatchSemaphore(value: 0)

for i in 0..<numberOfPhilosophers {
    DispatchQueue.global(qos: .background).async {
        let p = Philosophers(philosopherIndex: i)
        p.run()
    }
}

//Запустить поток, сигнализирующий семафор
for semaphore in ForkPair.forksSemaphore {
    sleep(3)
    semaphore.signal()
}

//Ждать бесконечно
globalSem.wait()
