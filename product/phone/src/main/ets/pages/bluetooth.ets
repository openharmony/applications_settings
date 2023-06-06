/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or
    {
      "name": "bluetoothTab", agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Router from '@system.router';
import deviceInfo from '@ohos.deviceInfo';
import BluetoothDevice from '../model/bluetoothImpl/BluetoothDevice';
import BluetoothDeviceController from '../controller/bluetooth/BluetoothDeviceController';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import EntryComponent from '../../../../../../common/component/src/main/ets/default/entryComponent';
import { DeviceType, ProfileConnectionState, BondState } from '../model/bluetoothImpl/BluetoothModel';
import BasicDataSource from '../../../../../../common/utils/src/main/ets/default/model/BasicDataSource';
import DeviceNameEntryComponent from '../../../../../../common/component/src/main/ets/default/deviceNameEntryComponent';
import ImageAnimatorComponent from '../../../../../../common/component/src/main/ets/default/imageAnimatorComponent';

const PAIRED_ITEM_NUMBER = 3;
const PAGE_URI_DEVICE_NAME = 'pages/deviceName';
const PAGE_URI_BLUETOOTH_PAIRED_DEVICE_INFO = 'pages/bluetoothPairedDeviceInfo';
const deviceTypeInfo = deviceInfo.deviceType;

@Entry
@Component
struct Bluetooth {
  private PAGE_TAG = ConfigData.TAG + 'Bluetooth page ';
  private deviceController: BluetoothDeviceController = new BluetoothDeviceController();
  @StorageLink('bluetoothIsOn') isOn: boolean = false;
  @StorageLink('bluetoothToggleEnabled') isEnabled: boolean = true;
  @StorageLink('bluetoothLocalName') localName: string = '';

  @Log
  aboutToAppear(): void {
    LogUtil.log(this.PAGE_TAG + 'aboutToAppear in : isOn = ' + this.isOn)
    this.deviceController
      .initData()
      .subscribe();
    LogUtil.log(this.PAGE_TAG + 'aboutToAppear out : isOn = ' + this.isOn)
  }

  @Log
  onPageShow(): void {
    LogUtil.log(this.PAGE_TAG + 'onPageShow in : localName = ' + this.localName)
    this.deviceController.getLocalName();
    LogUtil.log(this.PAGE_TAG + 'onPageShow out : localName = ' + this.localName)
  }

  @Log
  aboutToDisappear(): void {
    this.deviceController.unsubscribe();
  }

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.bluetoothTab'), isActive: true });

          Row() {
            Text($r("app.string.bluetoothTab"))
              .fontColor($r('sys.color.ohos_fa_text_primary'))
              .fontSize($r("app.float.font_16"))
              .fontWeight(FontWeight.Medium)

            Blank()

            Toggle({ type: ToggleType.Switch, isOn: this.isOn })
              .width('36vp')
              .height('20vp')
              .selectedColor('#007DFF')
              .margin({ left: $r('app.float.wh_value_6') })
              .onChange((isOn: boolean) => {
                LogUtil.log(this.PAGE_TAG + 'Toggle onClick: isOn = ' + isOn + ', enabled = ' + this.isEnabled)
                if (!this.isEnabled) return;
                this.deviceController.toggleValue(isOn);
              });
          }
          .margin({ top: $r("app.float.distance_8") })
          .width(ConfigData.WH_100_100)
          .height($r('app.float.wh_value_56'))
          .backgroundColor($r("app.color.white_bg_color"))
          .borderRadius($r('app.float.wh_value_28'))
          .padding({ left: $r('app.float.wh_value_12'), right: $r('app.float.wh_value_6') })
          .alignItems(VerticalAlign.Center)
          .borderRadius($r('app.float.distance_24'))

          Text($r('app.string.bluetooth_visible_to_nearby'))
            .width(ConfigData.WH_100_100)
            .fontSize($r('app.float.font_14'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .visibility(this.isOn ? Visibility.Visible : Visibility.None)
            .height($r("app.float.wh_value_52"))
            .lineHeight($r("app.float.wh_value_20"))
            .padding({
              left: $r('app.float.wh_value_12'),
              top: $r('app.float.distance_8'),
              bottom: $r('app.float.distance_24')
            })

          Scroll() {
            Column() {
              DeviceNameComponent({
                isEnabled: $isOn,
                localName: $localName
              })

              if (this.isOn) {
                PairedDeviceComponent({
                  controller: this.deviceController
                })

                AvailableDeviceComponent({
                  controller: this.deviceController,
                })
              }
            }
            .width(ConfigData.WH_100_100)
          }
          .scrollBarWidth(0)
          .width(ConfigData.WH_100_100)
          .align(Alignment.TopStart)
          .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
        }
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        });
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }
}

/**
 * Device name component
 */
@Component
struct DeviceNameComponent {
  @Link isEnabled: boolean;
  @Link localName: string;

  build() {
    Row() {
      DeviceNameEntryComponent({
        settingIcon: '',
        settingTitle: $r('app.string.bluetooth_device_name'),
        settingSummary: '',
        settingValue: $localName,
        settingArrow: $r("app.media.ic_settings_arrow"),
        settingArrowStyle: '',
        settingUri: '',
        isEnabled: this.isEnabled,
        heights: ($r('app.float.wh_value_48')),
        fontSize: ($r('app.float.font_16'))
      })
    }
    .padding($r("app.float.distance_4"))
    .margin({ top: this.isEnabled ? $r('app.float.wh_value_0') : $r('app.float.wh_value_12') })
    .width(ConfigData.WH_100_100)
    .height($r('app.float.wh_value_56'))
    .borderRadius($r("app.float.radius_24"))
    .backgroundColor($r("app.color.white_bg_color"))
    .onClick(() => {
      if (this.isEnabled) {
        Router.push({ uri: PAGE_URI_DEVICE_NAME });
      }
    });
  }
}

/**
 * Paired device component
 */
@Component
struct PairedDeviceComponent {
  private TAG_PAGE = ConfigData.TAG + 'PairedDeviceComponent ';
  private controller: BluetoothDeviceController;
  @StorageLink('bluetoothPairedDevices') pairedDevices: BluetoothDevice[] = [];
  @State isTouched: boolean = false;
  @State hide: boolean = true;

  @Log
  aboutToAppear(): void{
    if (this.controller) {
      // bind component and initialize
      this.controller.bindComponent(this)
        .bindProperties(["pairedDevices"])
        .initData();
    }
  }

  build() {
    Column() {
      if (this.pairedDevices && this.pairedDevices.length > 0) {
        // paired devices title
        Row() {
          Text($r('app.string.bluetooth_paired_devices'))
            .width(ConfigData.WH_100_100)
            .fontSize($r('app.float.font_14'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        }
        .width(ConfigData.WH_100_100)
        .padding({
          left: $r('app.float.wh_value_12'),
          top: $r('app.float.distance_19_5'),
          bottom: $r('app.float.distance_9_5')
        })

        List() {
          // paired devices list
          ForEach(this.pairedDevices, (item: BluetoothDevice, index: number) => {

            if (index < PAIRED_ITEM_NUMBER || !this.hide) {
              ListItem() {
                Row() {
                  EntryComponent({
                    settingIcon: getDeviceIconPath(item.deviceType),
                    settingTitle: item.deviceName,
                    settingSummary: this.getConnectionStateText(item),
                    settingValue: '',
                    settingArrow: $r("app.media.ic_public_settings"),
                    settingArrowStyle: 'bluetooth',
                    settingUri: '',
                    titleFontColor: this.isHeadPhoneConnected(item) ? $r("app.color.bluetooth_text_color_highlight") : $r("sys.color.ohos_id_color_text_primary"),
                    image_wh: $r('app.float.wh_value_24'),
                    heights: this.getConnectionStateText(item) == '' ? $r('app.float.wh_value_48') : ($r('app.float.wh_value_56')),
                    fontSize: ($r('app.float.font_16')),
                    onArrowClick: () => {
                      LogUtil.info(this.TAG_PAGE + 'item go detail');
                      this.gotoPairedDeviceInfo(item);
                    }
                  });
                }
                .width(ConfigData.WH_100_100)
                .borderRadius($r("app.float.radius_24"))
                .backgroundColor($r("app.color.white_bg_color"))
                .onClick(() => {
                  this.itemClicked(item);
                })
              }
            }

            if ((this.hide && index === PAIRED_ITEM_NUMBER) || //more
            (!this.hide && index >= PAIRED_ITEM_NUMBER && index == this.pairedDevices.length - 1)) { //put_away
              ListItem() {
                Stack({ alignContent: Alignment.Center }) {
                  Stack({ alignContent: Alignment.Center }) {
                    Text(this.hide ? $r('app.string.more') : $r('app.string.put_away'))
                      .fontColor($r('app.color.color_D8D8D8_grey'))
                      .fontSize($r('app.float.font_14'))
                  }
                  .width(ConfigData.WH_100_100)
                  .height($r("app.float.wh_value_48"))
                  .borderRadius($r("app.float.radius_20"))
                  .backgroundColor(this.isTouched ? $r("app.color.color_D8D8D8_grey") : $r("sys.color.ohos_id_color_foreground_contrary"))
                  .onTouch((event: TouchEvent) => {
                    if (event.type === TouchType.Down) {
                      this.isTouched = true;
                    }
                    if (event.type === TouchType.Up) {
                      this.isTouched = false;
                    }
                  })
                  .onClick(() => {
                    this.hide = !this.hide;
                  })
                }
                .height($r("app.float.wh_value_48"))
                .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
              }
            }
          }, item => JSON.stringify(item));
        }
        .padding($r("app.float.distance_4"))
        .divider({
          strokeWidth: $r('app.float.divider_wh'),
          color: $r('app.color.color_E3E3E3_grey'),
          startMargin: $r('app.float.wh_48'),
          endMargin: $r('app.float.wh_value_12')
        })
        .backgroundColor($r("app.color.white_bg_color"))
        .borderRadius($r("app.float.radius_24"))
      }
    }
  }

  /**
   * Get connection state text
   * @param device
   */
  getConnectionStateText(device: BluetoothDevice): string | Resource {
    let stateText: string | Resource = '';
    switch (device.connectionState) {
      case ProfileConnectionState.STATE_DISCONNECTED:
        stateText = '';
        break;

      case ProfileConnectionState.STATE_CONNECTING:
        stateText = $r('app.string.bluetooth_state_connecting');
        break;

      case ProfileConnectionState.STATE_CONNECTED:
        if (device.deviceType === DeviceType.HEADPHONE) {
          stateText = $r('app.string.bluetooth_state_connected');
        } else {
          stateText = '';
        }
        break;

      case ProfileConnectionState.STATE_DISCONNECTING:
        stateText = $r('app.string.bluetooth_state_disconnecting');
        break;

    }
    return stateText;
  }

  /**
   * Whether headphone connected.
   * @param item device
   * @return headphone connected or not
   */
  private isHeadPhoneConnected(item: BluetoothDevice): boolean {
    return item.deviceType === DeviceType.HEADPHONE && item.connectionState === ProfileConnectionState.STATE_CONNECTED
  }

  /**
   * Goto paired device Info
   * @param item device
   */
  private gotoPairedDeviceInfo(item: BluetoothDevice) {
    if (item.connectionState != ProfileConnectionState.STATE_CONNECTING
    && item.connectionState != ProfileConnectionState.STATE_DISCONNECTING) {
      LogUtil.info(this.TAG_PAGE + 'item right icon on click.');
      let param = { 'bluetoothDevice': JSON.stringify(item) }
      Router.push({
        uri: PAGE_URI_BLUETOOTH_PAIRED_DEVICE_INFO,
        params: param
      });
    }
  }

  /**
   * Item clicked
   * @param item device
   */
  private itemClicked(item: BluetoothDevice) {
    switch (item.connectionState) {
      case ProfileConnectionState.STATE_CONNECTED:
        this.showDisconnectDialog(item.deviceName, () => {
          this.controller.disconnect(item.deviceId)
        });
        break;

      case ProfileConnectionState.STATE_DISCONNECTED:
        if (!this.controller.connect(item.deviceId)) {
          this.showConnectFailedDialog(item.deviceName);
        }
        break;
    }
  }

  /**
   * Connect Failed Dialog
   */
  private showConnectFailedDialog(deviceName: string) {
    showDialog(
    $r("app.string.bluetooth_connect_failed"),
    $r("app.string.bluetooth_connect_failed_msg", deviceName),
    $r("app.string.bluetooth_know_button")
    );
  }

  /**
   * Disconnect Dialog
   */
  showDisconnectDialog(deviceName, callback) {
    AlertDialog.show({
      title: $r('app.string.bluetooth_disconnect'),
      message: $r("app.string.bluetooth_disconnect_device", deviceName),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          LogUtil.info(ConfigData.TAG + 'Closed callbacks');
        }
      },
      secondaryButton: {
        value: $r('app.string.confirm'),
        action: () => {
          LogUtil.info(ConfigData.TAG + `AlertDialog success:`);
          callback();
        }
      },
      alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
      offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 })
    })
  }
}

/**
 * Discovering animator component
 */
@Component
struct DiscoveringAnimatorComponent {
  build() {
    Column() {
      ImageAnimatorComponent({
        imageWidth: $r('app.float.wh_value_24'),
        imageHeight: $r('app.float.wh_value_24') })
    }
  }
}

/**
 * Available device component
 */
@Component
struct AvailableDeviceComponent {
  private TAG_PAGE = ConfigData.TAG + 'AvailableDeviceComponent ';
  private controller: BluetoothDeviceController;
  @State isDeviceDiscovering: boolean = false;
  @StorageLink('bluetoothAvailableDevices') @Watch("availableDevicesChange") availableDevices: BluetoothDevice[] = [];
  @State availableDevicesList: AvailableDevicesDataSource = new AvailableDevicesDataSource(this.availableDevices);
  @State pairPinCode: string = '';
  private pairingDevice: BluetoothDevice = undefined;
  @StorageLink("controlPairing") controlPairing: boolean = true ;
  @StorageLink("pairData") pairData: BluetoothDevice = null ;
  @StorageLink("pinRequiredParam") @Watch("pinRequiredParamChange") pinRequiredParam:  {deviceId: string; pinCode: string} = {deviceId: '',pinCode: ''} ;
  pairDialog: CustomDialogController = new CustomDialogController({
    builder: PairDialog({
      deviceName: (this.pairingDevice && this.pairingDevice.hasOwnProperty('deviceName'))?this.pairingDevice.deviceName:undefined,
      pinCode: this.pairPinCode,
      action: (accept: boolean) => {
        this.confirmPairing(accept);
      }
    }),
    alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
    offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 }),
    autoCancel: true,
  });

  availableDevicesChange() {
    this.availableDevicesList.setData(this.availableDevices)
    this.availableDevicesList.notifyDataReload()
  }

  @Log
  aboutToAppear(): void{
    if (this.controller) {
      // bind component and initialize
      this.controller.bindComponent(this)
        .bindProperties(["isDeviceDiscovering", "availableDevices", "pairPinCode"])
        .initData();

      this.controller.startBluetoothDiscovery();
    }
  }

  build() {
    Column() {
      Row() {
        Row() {
          // available devices title
          Text($r('app.string.bluetooth_available_devices'))
            .fontSize($r('app.float.font_14'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .height($r('app.float.distance_19'))
            .fontWeight(FontWeight.Medium)
        }
        .padding({
          left: $r('sys.float.ohos_id_card_margin_start'),
          right: $r('sys.float.ohos_id_card_margin_end'),
          top: $r('app.float.distance_19_5'),
          bottom: $r('app.float.distance_9_5')
        })

        Blank()

        // bluetooth discovering
        if (this.isDeviceDiscovering) {
          DiscoveringAnimatorComponent()
        }
      }
      .height($r("app.float.wh_value_48"))
      .width(ConfigData.WH_100_100)

      if (this.availableDevices && this.availableDevices.length >= 1) {
        List() {
          // paired devices list
          ForEach(this.availableDevices, (item: BluetoothDevice) => {
            ListItem() {
              Row() {
                EntryComponent({
                  settingIcon: getDeviceIconPath(item.deviceType),
                  settingTitle: item.deviceName ? item.deviceName : item.deviceId,
                  settingSummary: this.getPairStateText(item),
                  settingValue: '',
                  settingArrow: '',
                  settingArrowStyle: '',
                  settingUri: '',
                  image_wh: $r('app.float.wh_value_24'),
                  heights: this.getPairStateText(item) == '' ? $r('app.float.wh_value_56') : ($r('app.float.wh_value_64')),
                  fontSize: ($r('app.float.font_16')),
                });
              }
              .width(ConfigData.WH_100_100)
              .borderRadius($r("app.float.radius_24"))
              .backgroundColor($r("app.color.white_bg_color"))
              .onClick(() => {
                LogUtil.info(this.TAG_PAGE + 'item on click');
                if ( this.controlPairing ) {
                  this.pairDevice(item);
                } else {
                  return;
                }
              })
            }
          }, item => JSON.stringify(item));
        }
        .padding($r("app.float.distance_4"))
        .backgroundColor($r("app.color.white_bg_color"))
        .borderRadius($r("app.float.radius_24"))
        .divider({
          strokeWidth: $r('app.float.divider_wh'),
          color: $r('app.color.color_E3E3E3_grey'),
          startMargin: $r('app.float.wh_48'),
          endMargin: $r('app.float.wh_value_12')
        })
      } else {
        // Scanning...
        Text($r('app.string.scanning'))
          .fontSize($r('sys.float.ohos_id_text_size_body2'))
          .textCase(TextCase.UpperCase)
          .fontWeight(FontWeight.Medium)
          .fontColor($r("sys.color.ohos_id_color_primary"))
          .height($r('app.float.wh_value_48'))
      }
    }
  }

  /**
   * Get pair state text
   * @param device
   */
  getPairStateText(device: BluetoothDevice): string | Resource {
    return device.connectionState == BondState.BOND_STATE_BONDING ? $r('app.string.bluetooth_state_pairing') : '';
  }
  pinRequiredParamChange(){
    this.pairPinCode = this.pinRequiredParam.pinCode;
        this.pairingDevice = this.pairData;
        if (this.pairDialog) {
          this.pairDialog.open();
        }() => {
        this.showPairFailedDialog();
      }
  }
  /**
   * Pair device
   * @param device
   */
  pairDevice(device: BluetoothDevice) {
    this.controller.pair(device.deviceId, (pinCode: string) => {
      LogUtil.info(this.TAG_PAGE + 'pairDevice success callback : pinCode = ' + pinCode);
      // show pair pin dialog
      this.pairPinCode = pinCode;
      this.pairingDevice = device;
      if (this.pairDialog) {
        this.pairDialog.open();
      }
    }, () => {
      LogUtil.info(this.TAG_PAGE + 'pairDevice error callback');
      this.showPairFailedDialog();
    })
  }

  /**
   * Confirm pairing
   */
  @Log
  confirmPairing(accept: boolean) {
    LogUtil.info(this.TAG_PAGE + 'confirmPairing pairingDevice');
    try{
      if(this.pairingDevice && this.pairingDevice.deviceId!=null ){
        this.controller.confirmPairing(this.pairingDevice.deviceId, accept);
      }
    }catch(err){
      LogUtil.info(this.TAG_PAGE + `confirmPairing pairingDevice error ${err}`);
    }
  }

  /**
   * Show pair failed dialog
   */
  @Log
  showPairFailedDialog() {
    this.showPairingFailedDialog();
  }

  /**
   * Show device illegal prompt dialog
   */
  @Log
  private showDeviceIllegalPromptDialog(action) {
    AlertDialog.show({
      message: $r("app.string.bluetooth_address_error_msg"),
      primaryButton: {
        value: $r('app.string.cancel'),
        action: () => {
          LogUtil.info(this.TAG_PAGE + 'Closed callbacks');
        }
      },
      secondaryButton: {
        value: $r('app.string.bluetooth_pair_button'),
        action: () => {
          action();
          LogUtil.info(this.TAG_PAGE + `AlertDialog success:`);
        }
      },
      alignment: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? DialogAlignment.Bottom : DialogAlignment.Center,
      offset: ({ dx: 0, dy: deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? '-24dp' : 0 })
    })
  }

  /**
   * Show connect Failed Dialog
   */
  private showConnectFailedDialog(deviceName: string) {
    showDialog(
    $r("app.string.bluetooth_connect_failed"),
    $r("app.string.bluetooth_connect_failed_msg", deviceName),
    $r("app.string.bluetooth_know_button")
    );
  }

  /**
   * Show pairing failed title Dialog
   */
  @Log
  private showPairingFailedDialog() {
    showDialog(
    $r("app.string.pairing_failed_title"),
    $r("app.string.pairing_failed_message"),
    $r("app.string.bluetooth_know_button")
    );
  }
}

/**
 * AvailableDevicesDataSource For Lazy Loading
 */
class AvailableDevicesDataSource extends BasicDataSource {
  private availableDevicesArray: BluetoothDevice[] = null;

  constructor(availableDevicesArray:BluetoothDevice[]){
    super();
    this.availableDevicesArray = availableDevicesArray;
  }

  public setData(data: BluetoothDevice[]) {
    this.availableDevicesArray = data;
  }

  public totalCount(): number {
    if(this.availableDevicesArray) {
      return this.availableDevicesArray.length;
    }
    return 0;
  }

  public getData(index: number): BluetoothDevice {
    if(!this.availableDevicesArray) {
      LogUtil.log(ConfigData.TAG + 'array is null.');
      return null;
    }
    if(index < 0 || index >= this.totalCount()) {
      LogUtil.log(ConfigData.TAG + 'index out of range.');
      return null;
    }
    return this.availableDevicesArray[index];
  }

  public delData (device:BluetoothDevice):void{
    let index  = this.availableDevicesArray.indexOf(device);
    this.availableDevicesArray.splice(index,1)
    this.notifyDataDelete(index)
  }
}

/**
 * Pair dialog
 */
@CustomDialog
struct PairDialog {
  dialogController: CustomDialogController;
  action: (accept: boolean) => void;
  private deviceName: string = undefined;
  private pinCode: string;

  @Log
  aboutToAppear(): void {
    LogUtil.log(ConfigData.TAG + `bluetooth PairDialog aboutToAppear.`)
  }

  build() {
    Column() {
      Text($r('app.string.bluetooth_pairing_request'))
        .fontSize($r('app.float.font_20'))
        .height($r('app.float.wh_value_56'))
        .fontColor($r("sys.color.ohos_id_color_primary"))
        .width(ConfigData.WH_100_100)
        .fontWeight(500)
        .padding({
          left: $r('app.float.distance_24'),
          top: $r('app.float.distance_14'),
          bottom: $r('app.float.distance_14')
        })

      Column() {
        if (this.pinCode) {
          Text($r('app.string.bluetooth_pairing_intelligent_device_hit', this.deviceName, this.deviceName))
            .fontSize($r('sys.float.ohos_id_text_size_body1'))
            .fontColor($r("sys.color.ohos_id_color_primary"))
            .width(ConfigData.WH_100_100)
            .fontWeight(FontWeight.Regular)
            .margin({ bottom: $r('app.float.distance_16') })

          Text(`${this.pinCode}`)
            .fontSize($r('app.float.pinCode_font_size'))
            .fontWeight(500)
            .fontColor($r("sys.color.ohos_id_color_primary"))
            .width(ConfigData.WH_100_100)
            .textAlign(TextAlign.Center)
            .margin({
              top: $r('app.float.distance_6'),
              bottom: $r('app.float.distance_10')
            })
        } else {
          Text($r('app.string.bluetooth_pairing_media_device_hit'))
            .fontSize($r('app.float.font_16'))
            .fontColor($r("sys.color.ohos_id_color_primary"))
            .width(ConfigData.WH_100_100)
            .margin({ bottom: $r('app.float.switch_summary_margin') })

          Text(this.deviceName)
            .fontSize($r('app.float.font_16'))
            .width(ConfigData.WH_100_100)
            .fontWeight(FontWeight.Bold)
        }

        // button
        Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
          Button() {
            Text($r('app.string.cancel'))
              .fontSize($r('app.float.font_16'))
              .fontColor('#007DFF')
              .fontWeight(500)
          }
          .backgroundColor($r("app.color.white_bg_color"))
          .width($r("app.float.wh_value_160"))
          .height($r("app.float.wh_value_40"))
          .flexGrow(1)
          .onClick(() => {
            this.dialogController.close();
            this.action(false);
          })

          Divider()
            .height($r("app.float.wh_value_24"))
            .strokeWidth(0.5)
            .vertical(true)
            .color($r("sys.color.ohos_id_color_list_separator"))

          Button() {
            Text($r('app.string.bluetooth_pair_button'))
              .fontSize($r('app.float.font_16'))
              .fontColor('#007DFF')
              .fontWeight(500)
          }
          .backgroundColor($r("app.color.white_bg_color"))
          .width($r("app.float.wh_value_160"))
          .height($r("app.float.wh_value_40"))
          .flexGrow(1)
          .onClick(() => {
            this.dialogController.close();
            this.action(true);
          })
        }
        .width(ConfigData.WH_100_100)
        .height($r('app.float.wh_value_56'))
        .margin({ top: $r('app.float.wh_value_10') })
        .padding({ bottom: $r('app.float.wh_value_16') })
      }
      .width(ConfigData.WH_100_100)
      .padding({
        left: $r('app.float.distance_24'),
        right: $r('app.float.distance_24')
      })
    }
    .width(deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? ConfigData.WH_100_100 : $r("app.float.wh_value_410"))
    .padding(deviceTypeInfo === 'phone' || deviceTypeInfo === 'default' ? { left: $r("app.float.wh_value_12"), right: $r("app.float.wh_value_12")} : {})
  }
}

/**
 * Get device icon resource
 * @param type
 * @return device icon path
 */
function getDeviceIconPath(deviceType: string): string {
  let path: string = "/res/image/ic_bluetooth_device.svg";
  switch (deviceType) {
    case DeviceType.HEADPHONE:
      path = "/res/image/ic_device_earphone_hero.svg";
      break;

    case DeviceType.PHONE:
      path = "/res/image/ic_public_devices_phone.svg";
      break;

    case DeviceType.WATCH:
      path = "/res/image/ic_device_watch.svg";
      break;

    case DeviceType.COMPUTER:
      path = "/res/image/ic_device_matebook.svg";
      break;
  }
  return path;
}

/**
 * Pair mode prompt
 * @param dialogTitle Dialog title
 * @param dialogMessage Dialog message
 * @param buttonValue Dialog buttonValue
 */
function showDialog(dialogTitle: string | Resource, dialogMessage: string | Resource, buttonValue: string | Resource) {
  LogUtil.info(ConfigData.TAG + 'Bluetooth page showDialog in.');

  AlertDialog.show({
    title: dialogTitle,
    message: dialogMessage,
    confirm: {
      value: buttonValue,
      action: () => {
        LogUtil.info(ConfigData.TAG + 'Bluetooth page showDialog : Button-clicking callback');
      }
    },
    cancel: () => {
      LogUtil.info(ConfigData.TAG + 'Bluetooth page showDialog : Closed callbacks');
    }
  })

  LogUtil.info(ConfigData.TAG + 'Bluetooth page showDialog out.');
}