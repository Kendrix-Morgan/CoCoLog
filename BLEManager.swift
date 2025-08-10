import Foundation
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isConnected = false
    @Published var bpm: Int = 0
    @Published var hrv: Float = 0.0
    @Published var spo2: Int = 0
    @Published var isScanning = true
    
    private var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var notifyCharacteristic: CBCharacteristic?
    var dataBuffer: String = ""

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func resetValues() {
        bpm = 0
        hrv = 0.0
        spo2 = 0
    }

    // MARK: - Scanning
    func startScan() {
        if !isScanning {
            isScanning = true
        }
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        print("🔍 Scanning for BLE devices...")
    }

    func stopScan() {
        if isScanning {
            isScanning = false
        }
        centralManager.stopScan()
        disconnectPeripheral()
        print("🛑 Scan stopped and disconnected.")
    }
    func disconnectPeripheral() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil
            isConnected = false
            print("🔌 Disconnected from peripheral.")
        }
    }

    func sendStartSignal() {
        guard let peripheral = connectedPeripheral,
              let characteristic = notifyCharacteristic else { return }

        let message = "start"
        if let data = message.data(using: .utf8) {
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
            print("📤 Sent start signal to M5 device.")
        }
    }

    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("✅ BLE is powered on.")
            startScan()
        } else {
            print("⚠️ BLE not available.")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, name.contains("CocoLog") {
            print("💡 Found device: \(name)")
            centralManager.stopScan()
            connectedPeripheral = peripheral
            peripheral.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ Connected to peripheral: \(peripheral.name ?? "Unknown")")
        isConnected = true
        peripheral.discoverServices(nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for char in characteristics {
            if char.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: char)
                notifyCharacteristic = char
                print("🔔 Notification characteristic set.")
            }

            if char.properties.contains(.writeWithoutResponse) {
                notifyCharacteristic = char
                print("✏️ Write characteristic ready.")
                sendStartSignal()
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }

        let value = String(decoding: data, as: UTF8.self)
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        print("📩 Received: \(cleaned)")

        let components = cleaned.split(separator: ",")
        if components.count == 3 {
            if let bpmVal = Int(components[0]),
               let hrvVal = Float(components[1]),
               let spo2Val = Int(components[2]) {
                DispatchQueue.main.async {
                    self.bpm = bpmVal
                    self.hrv = hrvVal
                    self.spo2 = spo2Val
                    print("❤️ BPM: \(bpmVal), HRV: \(hrvVal), SpO2: \(spo2Val)")
                }
            }
        }
    }
}
