extension LinkedList: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: T...) {
        self.init()
        for ele in elements {
            append(ele)
        }
        
    }
}

extension LinkedList: Collection, MutableCollection, RangeReplaceableCollection, BidirectionalCollection {
    var startIndex: Index {
        if let head = head {
            return Index(node: head)
        } else {
            return endIndex
        }
    }
    var endIndex: Index {
        return Index(node: end)
    }
    func index(after i: Index) -> Index {
        guard let next = i.node.next else { return endIndex }
        let i = Index(node: next)
        return i
    }
    subscript(position: Index) -> T {
        get {
            return position.node.data
        }
        set {
            position.node.data = newValue
        }
    }
    
    func index(before i: Index) -> Index {
        guard let previous = i.node.previous else { fatalError("Index out of range: no previous index") }
        let i = Index(node: previous)
        return i
    }
    
    mutating func replaceSubrange<C>(_ subrange: Range<LinkedList<T>.Index>, with newElements: C) where C : Collection, C.Iterator.Element == T {
        
        
        let newNodes = newElements.map { Node(data: $0) }
        if !newNodes.isEmpty {
            let droppedFirst = newNodes.dropFirst()
            
            for (first,second) in zip(newNodes,droppedFirst) {
                first.next = second
            }
        }
        
        if let _ /*head*/ = head, let tail = tail {
            
            if subrange.isEmpty {
                if let firstNew = newNodes.first, let newTail = newNodes.last {
                    tail.next = firstNew
                    self.tail = newTail
                    newTail.next = end
                } else {
                    //
                }
            } else {
                replaceSubrange(subrange.lowerBound...Index(node: subrange.upperBound.node.previous!), with: newElements)
            }
        } else {
            head = newNodes.first
            tail = newNodes.last
            tail?.next = end
        }
    }
    
    mutating func replaceSubrange<C>(_ subrange: ClosedRange<LinkedList<T>.Index>, with newElements: C) where C : Collection, C.Iterator.Element == T {
        
        guard indices.contains(subrange.lowerBound) && indices.contains(subrange.upperBound) else { fatalError("Index out of range") }
        
        let newNodes = newElements.map { Node(data: $0) }
        if !newNodes.isEmpty {
            
            let droppedFirst = newNodes.dropFirst()
            
            for (first,second) in zip(newNodes, droppedFirst) {
                first.next = second
            }
        }
        
        if let head = head, let tail = tail { // head and tail exist
            
            let firstNodeOld = subrange.lowerBound.node
            let lastNodeOld = subrange.upperBound.node
            
            let firstNodeOldHead = firstNodeOld === head
            let lastNodeOldHead = lastNodeOld === head
            
            let firstNodeOldTail = firstNodeOld === tail
            let lastNodeOldTail = lastNodeOld === tail
            
            
            if firstNodeOldHead && lastNodeOldHead { // head - head
                
                if let newHead = newNodes.first, let lastNew = newNodes.last {
                    defer { lastNew.next = head.next }
                    self.head = newHead
                } else {
                    self.head = head.next
                }
                
            } else if firstNodeOldHead && lastNodeOldTail { // head - tail
                
                if let newHead = newNodes.first, let newTail = newNodes.last {
                    self.head = newHead
                    self.tail = newTail
                    newTail.next = end
                } else {
                    self.head = nil
                    self.tail = nil
                }
                
            } else if firstNodeOldTail && lastNodeOldTail { // tail - tail
                
                if let firstNew = newNodes.first, let newTail = newNodes.last {
                    tail.previous!.next = firstNew
                    self.tail = newTail
                    newTail.next = end
                } else {
                    tail.previous!.next = end
                    self.tail = tail.previous
                }
                
            } else if firstNodeOldHead { // head - mid
                
                if let newhead = newNodes.first, let lastNew = newNodes.last {
                    self.head = newhead
                    lastNew.next = lastNodeOld.next
                } else {
                    self.head = lastNodeOld.next
                }
                
            } else if lastNodeOldTail { // mid - tail
                
                if let firstNew = newNodes.first, let newTail = newNodes.last {
                    firstNodeOld.previous!.next = firstNew
                    self.tail = newTail
                    newTail.next = end
                } else {
                    self.tail = firstNodeOld.previous
                    firstNodeOld.previous!.next = end
                }
                
            } else { // mid1 - mid1
                
                if let firstNew = newNodes.first, let lastNew = newNodes.last {
                    firstNodeOld.previous!.next = firstNew
                    lastNew.next = lastNodeOld.next
                } else {
                    firstNodeOld.previous!.next = lastNodeOld.next
                }
            }
        } else { // head and tail are blank
            if let newHead = newNodes.first, let newTail = newNodes.last {
                self.head = newHead
                self.tail = newTail
                newTail.next = end
            } else {
                //
            }
        }
        
    }
    
    struct Index: Comparable {
        fileprivate var node: Node<T>
        fileprivate init(node: Node<T>) {
            self.node = node
        }
        static func ==(lhs: Index, rhs: Index) -> Bool {
            return lhs.node === rhs.node
        }
        static func <(lhs: Index, rhs: Index) -> Bool {
            
            if lhs.node === rhs.node {
                return false
            }
            
            var current = lhs.node
            while let next = current.next {
                if next === rhs.node {
                    return true
                } else {
                    current = next
                }
            }
            current = rhs.node
            while let next = current.next {
                if next === lhs.node {
                    return false
                } else {
                    current = next
                }
            }
            
            fatalError("Nodes are not related.")
        }
    }
}

struct LinkedList<T> {
    
    fileprivate class Node<T> {
        var next: Node<T>? {
            didSet {
                self.next?.previous = self
            }
        }
        weak var previous: Node<T>?
        private var wrappedData: T? {
            willSet {
                if wrappedData == nil {
                    fatalError("Index out of range")
                }
            }
        }
        var data: T {
            get {
                guard let data = wrappedData else { fatalError("Index out of range") }
                return data
            }
            set {
                guard wrappedData != nil else { fatalError("Index out of range") }
                wrappedData = newValue
            }
        }
        
        
        init(data: T? = nil) {
            self.wrappedData = data
        }
    }
    
    fileprivate var head: Node<T>?
    fileprivate var tail: Node<T>?
    fileprivate let end = Node<T>()
    
    init() {
        
    }
}

extension LinkedList: CustomStringConvertible {
    var description: String {
        return map { String(describing: $0) }.joined(separator: " -> ")
    }
}

func ==<T>(lhs: LinkedList<T>, rhs: LinkedList<T>) -> Bool where T: Equatable {
    return lhs.count == rhs.count && zip(lhs, rhs).map { (l,r) in l == r }.reduce(true) { $0 && $1 }
}
