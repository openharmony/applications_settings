/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

class ComponentConfig {
  public defaultBatteryPower: string = '0';
  public spChargingSupportKey: string = 'hw.keyboard.charge.support'; //是否支持充电0,1
  public spKeyboardChargingStateKey: string = 'hw.keyboard.charging.state'; //充电状态
  public spKeyboardName: string = 'hw.keyboard.name'; //型号
  public spBatteryKey: string = 'hw.keyboard.battery'; // 电量
  public spStateKey: string = 'hw.keyboard.connection.state'; //连接状态on,off
  public spTranSport: string = 'hw.keyboard.transport'; //1表示sle，0表示ble
  public spShowBatteryKey: string = 'hw.keyboard.showBattery'; //是否支持显示电量0,1
  public batteryLevelList: number[] = [5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 100];
  public KEYBOARD_BATTERY: ResourceStr[] = [
    $r('app.media.battery_white5'),
    $r('app.media.battery_white10'),
    $r('app.media.battery_white20'),
    $r('app.media.battery_white30'),
    $r('app.media.battery_white40'),
    $r('app.media.battery_white50'),
    $r('app.media.battery_white60'),
    $r('app.media.battery_white70'),
    $r('app.media.battery_white80'),
    $r('app.media.battery_white90'),
    $r('app.media.battery_white95'),
    $r('app.media.battery_white100'),
  ];
  public KEYBOARD_BATTERY_CAHRGE: ResourceStr[] = [
    $r('app.media.battery_white5_charge'),
    $r('app.media.battery_white10_charge'),
    $r('app.media.battery_white20_charge'),
    $r('app.media.battery_white30_charge'),
    $r('app.media.battery_white40_charge'),
    $r('app.media.battery_white50_charge'),
    $r('app.media.battery_white60_charge'),
    $r('app.media.battery_white70_charge'),
    $r('app.media.battery_white80_charge'),
    $r('app.media.battery_white90_charge'),
    $r('app.media.battery_white95_charge'),
    $r('app.media.battery_white100_charge'),
  ];
  public KEYBOARD_BATTERY_DARK: ResourceStr[] = [
    $r('app.media.battery_white5_dark'),
    $r('app.media.battery_white10_dark'),
    $r('app.media.battery_white20_dark'),
    $r('app.media.battery_white30_dark'),
    $r('app.media.battery_white40_dark'),
    $r('app.media.battery_white50_dark'),
    $r('app.media.battery_white60_dark'),
    $r('app.media.battery_white70_dark'),
    $r('app.media.battery_white80_dark'),
    $r('app.media.battery_white90_dark'),
    $r('app.media.battery_white95_dark'),
    $r('app.media.battery_white100_dark'),
  ];
  public KEYBOARD_BATTERY_CAHRGE_DARK: ResourceStr[] = [
    $r('app.media.battery_white5_charge_dark'),
    $r('app.media.battery_white10_charge_dark'),
    $r('app.media.battery_white20_charge_dark'),
    $r('app.media.battery_white30_charge_dark'),
    $r('app.media.battery_white40_charge_dark'),
    $r('app.media.battery_white50_charge_dark'),
    $r('app.media.battery_white60_charge_dark'),
    $r('app.media.battery_white70_charge_dark'),
    $r('app.media.battery_white80_charge_dark'),
    $r('app.media.battery_white90_charge_dark'),
    $r('app.media.battery_white95_charge_dark'),
    $r('app.media.battery_white100_charge_dark'),
  ];
  public loopingChargeTimes: number = 600;
  public getBatteryDuration: number = 1000;
  public shortcutHelperEvent: string = 'usual.event.settings.shortcutpanel.show';
  public dividend: number = 10;
  public batteryLeverZero: number = 0;
  public batteryLeverFive: number = 5;
  public batteryLeverNinetyFive: number = 95;
  public batteryLeverOneHundred: number = 100;
  public keyboardImageRatio = '80%';
  public delayTime = 100;
  public rowSpaceTwo = 2;
}

const componentConfig: ComponentConfig = new ComponentConfig();

export default componentConfig;