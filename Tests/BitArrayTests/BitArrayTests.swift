import XCTest
@testable import BitArray

protocol IRandomisable {
    static func random() -> Self
}
extension UInt8 : IRandomisable {
    
    static func random() -> Self { numericCast(Int.random(in: 0...255)) }
    
}
extension Bool : IRandomisable {}

final class BitArrayTests: XCTestCase {
    
    private func nb(_ n : Int) -> Int { (n+7)/8 }
    
    private func random<T>(_ n : Int) -> [T] where T : IRandomisable {
        (0..<n).map { _ in T.random() }
    }
    
    
    
    
    
    func testByteLength() throws {
        [7,64,254,1025].forEach { n in
            XCTAssertEqual(BitArray(nBits: n).nBytes, nb(n), "Byte count wrong for nBits=\(n)")
        }
    }
    
    func testBitLength() throws {
        [7,64,254,1025].forEach { n in
            XCTAssertEqual(BitArray(nBytes: n).nBits,  8*n, "Bit count wrong for nBytes=\(n)")
        }
    }
    
    func testByteArrayLength() throws {
        [7,64,254,1025].forEach { n in
            let array = Array<Bool>(repeating: true,count: n)
            XCTAssertEqual(BitArray(bits: array).nBytes, nb(n),"Byte count wrong from \(n) bit array")
        }
    }
    
    func testBitArrayLength() throws {
        [7,64,254,1025].forEach { n in
            let array = Array<UInt8>(repeating: 1,count: n)
            XCTAssertEqual(BitArray(bytes: array).nBits, n*8,"Bit count wrong from \(n) byte array")
        }
    }
    
    func testBitArrayWithLength() throws {
        [7,64,254,1025].forEach { n in
            let array = Array<UInt8>(repeating: 1,count: n)
            let count = Swift.min(37,n*8)
            XCTAssertEqual(BitArray(bytes: array, nBits: 37).nBits, count,"Truncated bit count wrong from \(n) byte array")
        }
    }
    
    func testConversionBitByteBit() throws {
        [7,64,254,1025].forEach { n in
            let array : [Bool] = self.random(n)
            let b1 = BitArray(bits: array)
            let b2 = BitArray(bytes: b1.bytes, nBits: b1.nBits)
            XCTAssertEqual(array,b2.bits,"Failed bit->byte->bit conversion for nBits=\(n)")
        }
    }
    
    func testConversionByteBitByte() throws {
        [7,64,254,1025].forEach { n in
            let array : [UInt8] = self.random(n)
            let b1 = BitArray(bytes: array)
            let b2 = BitArray(bits: b1.bits)
            XCTAssertEqual(array,b2.bytes,"Failed byte->bit->byte conversion for nBits=\(n)")
        }
    }
    
    func testConversionBitBinaryBit() throws {
        [7,64,254,1025].forEach { n in
            let array : [Bool] = self.random(n)
            let b1 = BitArray(bits: array)
            let b2 = BitArray(binary: b1.binary, nBits: b1.nBits)
            XCTAssertEqual(array,b2.bits,"Failed bit->binary->bit conversion for nBits=\(n)")
        }
    }
    
    func testConversionBinaryBitBinary() throws {
        [7,64,254,1025].forEach { n in
            let array : [UInt8] = self.random(n)
            let data = Data(array)
            let b1 = BitArray(binary: data)
            let b2 = BitArray(bits: b1.bits)
            XCTAssertEqual(data,b2.binary,"Failed byte->bit->byte conversion for nBytes=\(n)")
        }
    }
    
    
    
    
}

