import Foundation

fileprivate extension BinaryInteger {
    
    subscript(_ idx : Int) -> Bool {
        get { (self >> idx) & 1 == 1 }
        set(b) {
            self = b ? self | (1<<idx) : self & ~(1<<idx)
        }
    }
}

public class BitArray : Codable {
    public struct Index {
        let byte : Int
        let bit : Int
        
        init(_ index : Int) {
            self.byte=index/8
            self.bit=index%8
        }
        
        init(byte : Int, bit : Int) {
            self.byte=byte
            self.bit=bit
        }
    }
    public private(set) var nBits : Int
    public private(set) var nBytes : Int
    
    private var data : [UInt8]

    public init(nBits : Int) {
        self.nBits = nBits
        self.nBytes = (nBits+7)>>3
        self.data = Array<UInt8>(repeating: 0, count: self.nBytes)
    }
    
    public init() {
        self.nBits=0
        self.nBytes=0
        self.data = []
    }
    
    public init(nBytes : Int) {
        self.nBits = 8*nBytes
        self.nBytes = nBytes
        self.data = Array<UInt8>(repeating: 0, count: self.nBytes)
    }
    
    public convenience init(bits: [Bool]) {
        self.init(nBits : bits.count)
        
        (0..<self.nBits).forEach { nb in
            let word = nb/8
            let offset = nb%8
            self.data[word][offset]=bits[nb]
        }
    }
    public init(bytes : [UInt8], nBits : Int) {
        self.nBits=Swift.min(nBits,bytes.count*8)
        self.nBytes=(self.nBits+7)>>3
        self.data=Array(bytes.prefix(upTo: self.nBytes))
    }
    public convenience init(bytes : [UInt8]) {
        self.init(bytes: bytes, nBits: 8*bytes.count)
    }
    
    public convenience init(_ other : BitArray) {
        self.init(bytes: other.bytes, nBits: other.nBits)
    }
    
    public subscript(_ index : Index) -> Bool {
        get { self.data[index.byte][index.bit] }
        set(b) { self.data[index.byte][index.bit]=b }
    }
    
    public subscript(_ index : Int) -> Bool {
        get { self[Index(index)] }
        set(b) { self[Index(index)]=b }
    }
    
    public var bits : [Bool] { (0..<self.nBits).map { self[$0] } }
    public var bytes : [UInt8] { self.data }
    
    
    // Handle codability
    
    enum CodingKeys : String, CodingKey {
        case nBits
        case data
    }
    
    public required init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.nBits = try c.decode(Int.self,forKey: .nBits)
        self.nBytes=(self.nBits+7)>>3
        self.data = try c.decode([UInt8].self,forKey: .data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var c=encoder.container(keyedBy: CodingKeys.self)
        try c.encode(self.nBits,forKey : .nBits)
        try c.encode(self.data,forKey : .data)
    }
}

public extension BitArray {
    convenience init(binary: Data, nBits : Int) {
        var bytes = Array<UInt8>(repeating: 0, count: binary.count)
        bytes.withUnsafeMutableBufferPointer { ptr in
            guard let base = ptr.baseAddress else { return }
            binary.copyBytes(to: base, count: binary.count)
        }
        self.init(bytes: bytes, nBits: nBits)
    }
    convenience init(binary: Data) {
        self.init(binary: binary, nBits: 8*binary.count)
    }
    
    var binary : Data { Data(data) }
}






