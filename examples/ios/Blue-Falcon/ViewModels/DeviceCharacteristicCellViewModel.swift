//
//  DeviceCharacteristicCellViewModel.swift
//  Blue-Falcon
//
//  Created by Andrew Reed on 24/08/2019.
//  Copyright © 2019 Andrew Reed. All rights reserved.
//

import Foundation
import CoreBluetooth
import library
import UIKit

class DeviceCharacteristicCellViewModel: Identifiable, ObservableObject {

    var id: CBUUID
    let name: String
    let characteristic: CBCharacteristic
    let device: CBPeripheral
    @Published var notify: Bool = false
    @Published var characterisicValue: String? = nil

    init(id: CBUUID, characteristic: CBCharacteristic, device: CBPeripheral) {
        self.id = id
        self.name = characteristic.uuid.description
        self.characteristic = characteristic
        self.device = device
    }

    func onAppear() {
        AppDelegate.instance.bluetoothService.characteristicDelegates.append((characteristic.uuid, self))
    }

    func onDisapear() {
        AppDelegate.instance.bluetoothService.removeCharacteristicDelegate(delegate: self)
    }

    //consider moving to the characteristic cell view model.
    func readCharacteristicTapped(_ characteristic: CBCharacteristic) {
        AppDelegate.instance.bluetoothService.readCharacteristic(
            bluetoothPeripheral: device,
            bluetoothCharacteristic: characteristic
        )
    }

    func notifyCharacteristicTapped(_ characteristic: CBCharacteristic) {
        notify = !notify
        AppDelegate.instance.bluetoothService.notifyCharacteristic(
            bluetoothPeripheral: device,
            bluetoothCharacteristic: characteristic,
            notify: notify
        )
    }

    func writeCharacteristicTapped(_ characteristic: CBCharacteristic) {
        let alert = UIAlertController(
            title: "Characteristic Write",
            message: "Please enter a value to write to the characteristic",
            preferredStyle: .alert
        )
        alert.addTextField { textfield in
            textfield.placeholder = "Enter value"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            guard let input = alert.textFields?.first?.text else { return }
            AppDelegate.instance.bluetoothService.writeCharacteristic(
                bluetoothPeripheral: self.device,
                bluetoothCharacteristic: characteristic,
                value: input
            )
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        SceneDelegate.instance.window?.rootViewController?.present(alert, animated: true)
    }
}

extension DeviceCharacteristicCellViewModel: BluetoothServiceCharacteristicDelegate {

    func characteristcValueChanged() {
        guard let characteristicData = characteristic.value else { return }
        characterisicValue = String(decoding: characteristicData, as: UTF8.self)
    }

}

