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

import wifiManager from '@ohos.wifiManager';
import { BusinessError } from '@ohos.base';
import { prompt } from '@kit.ArkUI';
import CommonEventManager from '@ohos.commonEventManager';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { DeviceNameUtil } from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { CommonEventHelper } from '@ohos/settings.common/src/main/ets/utils/CommonEventHelper';
import { Controller, UiRefresher } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Style } from '@ohos/settings.common/src/main/ets/core/model/menu/ComponetStyle';
import { EntryMenuStyle } from '@ohos/settings.common/src/main/ets/core/model/menu/BaseMenu';
import { SheetMenu } from '../../menus/Menu';
import { EntryComponent } from '../BaseComponent';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
/* instrument ignore file */
const OPACITY_PERCENT_FULL: number = 1;

const OPACITY_PERCENT_SIXTY: number = 0.6;

const ALPHA_DISABLED: Resource = $r('sys.float.ohos_id_alpha_disabled');

const SHEET_TOP_MARGIN = 181;

const SHEET_MOVE_RATE = 999;

const MAX_INPUT_LENGTH_DEFAULT = 30;

const MAX_INPUT_LENGTH_BYTES = 64;

const MAX_REFRESH_ID = 1000;

const TOAST_DURATION = 2000;

const HOT_SPOT_KEY = 'hot_spot_device_name';

const DEVICE_NAME_KEY = 'device_name';

const WIFI_ACTIVE = 1;

const TAG: string = 'NameUpdateDialogComponent: ';

@CustomDialog
export struct NameUpdateDialogComponent {
  title: ResourceStr = '';
  primaryButton: ResourceStr = '';
  secondaryButton: ResourceStr = '';
  controller?: CustomDialogController;
  confirm?: Function;
  closeDialog?: Function;
  ssid: string = '';
  @Link inputValue: string;
  @Link textValue: string;
  @State isWarning: boolean = false;
  @State uiRefresherId: number = 1;

  build() {
    Column() {
      Text(this.title)
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Bold)
        .fontSize($r('sys.float.ohos_id_text_size_headline8'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .constraintSize({
          minHeight: '27vp',
        })
        .padding({
          left: 16,
          right: 16,
          top: 15,
          bottom: 15,
        })

      TextInput({ placeholder: '', text: this.uiRefresherId ? this.textValue : '' })
        .height(48)
        .showUnderline(false)
        .maxLength(this.ssid ? MAX_INPUT_LENGTH_DEFAULT : MAX_INPUT_LENGTH_BYTES)
        .defaultFocus(true)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontSize('16vp')
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .backgroundColor(Color.Transparent)
        .padding(0)
        .margin({
          left: 16,
        })
        .cancelButton({
          style: CancelButtonStyle.CONSTANT,
          icon: {
            size: '24vp',
            color: $r('sys.color.ohos_id_color_primary'),
          },
        })
        .onChange((value: string) => {
          LogUtil.info(`TextInput onchange, value: ${value}`);
          if (this.ssid && value === this.ssid) {
            this.isWarning = true;
          } else {
            this.isWarning = false;
          }
          this.inputChange(value);
        })

      Divider()
        .vertical(false)
        .color($r('sys.color.ohos_id_color_primary'))
        .height('1vp')
        .margin({
          left: 16,
          right: 16,
        })

      Text(this.isWarning ? $r('app.string.repeat_name_warning') : $r('app.string.device_name_modify_tips'))
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .constraintSize({
          minHeight: '19vp',
        })
        .width('100%')
        .fontColor(this.isWarning ? $r('sys.color.ohos_id_color_warning') : $r('sys.color.ohos_id_color_text_hint'))
        .fontFamily('HarmonyHeiTi')
        .textAlign(TextAlign.Start)
        .fontWeight(FontWeight.Regular)
        .padding({
          left: '16vp',
          right: '16vp',
          top: '8vp',
        })

      Row() {
        Button() {
          Text(this.primaryButton)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_button1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .constraintSize({
              minHeight: '21vp',
            })
            .margin({
              top: 9.5,
              bottom: 10,
            })
        }
        .layoutWeight(1)
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .margin({
          right: 8,
        })
        .onClick(() => {
          this.closeDialog?.();
        })

        Button() {
          Text(this.secondaryButton)
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Medium)
            .fontSize($r('sys.float.ohos_id_text_size_button1'))
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .constraintSize({
              minHeight: '21vp',
            })
            .margin({
              top: 9.5,
              bottom: 10,
            })
        }
        .layoutWeight(1)
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .margin({
          left: 8,
        })
        .opacity(this.inputValue.trim().length > 0 ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_SIXTY)
        .enabled(this.inputValue.trim().length > 0)
        .onClick(() => {
          this.confirm?.();
          this.closeDialog?.();
        })
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .margin({
        left: 16,
        right: 16,
        top: 96,
        bottom: 24,
      })
    }
    .backgroundColor('#e6ffffff')
    .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
    .saturate(0.9)
    .alignItems(HorizontalAlign.Start)
    .borderRadius(24)
    .constraintSize({
      maxWidth: 480,
    })
    .padding({
      top: 8,
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  private inputChange(value: string): void {
    LogUtil.info(`${TAG} TextInput onchange, value: ${value}`);
    let maxLength = this.ssid ? MAX_INPUT_LENGTH_DEFAULT : MAX_INPUT_LENGTH_BYTES;
    if (value?.length >= maxLength) {
      ResourceUtil.getString($r('app.string.input_max_length_message')).then(value => {
        try {
          prompt.showToast({
            message: value,
            duration: TOAST_DURATION,
          });
        } catch (error) {
          LogUtil.info(`${TAG} showToast failed: ${error?.message}`);
        };
      });
    }
    if (!this.ssid) {
      this.inputValue = value;
      return;
    }
    let textArray = StringUtil.stringToUint8Array(value);
    if (textArray.length > MAX_INPUT_LENGTH_BYTES) {
      let tempString = value;
      let endIndex = 1;
      while (StringUtil.stringToUint8Array(tempString.substring(0, tempString.length - endIndex)).length >
        MAX_INPUT_LENGTH_BYTES) {
        endIndex++;
      }
      this.inputValue = tempString.substring(0, tempString.length - endIndex);
      this.textValue = this.inputValue;
      this.uiRefresherId = this.uiRefresherId > MAX_REFRESH_ID ? 1 : this.uiRefresherId + 1;
    } else {
      this.inputValue = value;
    }
  }
}

@Component
export struct SheetMenuComponent {
  public tag: string = 'SheetMenuComponent : ';
  private isPad: boolean = DeviceUtil.isDevicePad();
  private isPc: boolean = DeviceUtil.isDevicePc();
  private sheetDescription: string | Resource = '';
  private inputMaxLength: number = MAX_INPUT_LENGTH_DEFAULT;
  private ssid: string = '';
  private isShowNameRepeatWarning: boolean = false;
  private isGrayed: boolean = PreferencesUtil.getSync('DeviceNameSettings', false) as boolean;
  @State menu?: SettingsBaseMenu = undefined;
  @State style?: Style = undefined;
  @State controller?: Controller = undefined;
  @State uiRefresher: UiRefresher = new UiRefresher();
  @State isSecondSelected: boolean = false;
  @State isShowSheet: boolean = false;
  @State deviceName: string = '';
  @State uiRefresherId: number = 1;
  @State isWarning: boolean = false;

  private subscribeInfo: CommonEventManager.CommonEventSubscribeInfo = {
    events: [
      CommonEventManager.Support.COMMON_EVENT_WIFI_HOTSPOT_STATE,
    ]
  };

  private onWifiConnectionChange = (state: number): void => {
    LogUtil.info(`${TAG} wifi state change : ${state}`);
    if (state === WIFI_ACTIVE) {
      wifiManager.getLinkedInfo().then(data => {
        this.ssid = data?.ssid ?? '';
      }).catch((err: Error) => {
        LogUtil.error(`${TAG} getLinkedInfo fail, errMessage: ${err?.message}`);
        this.ssid = '';
      });
    } else {
      this.ssid = '';
    }
  };

  private apConnected: CommonEventHelper = new CommonEventHelper(this.subscribeInfo, (err, data) => {
    this.onHotSpotStateChange();
  });

  updateNameDialogController: CustomDialogController | null = new CustomDialogController({
    builder: NameUpdateDialogComponent({
      title: ResourceUtil.getStringSync($r('app.string.bluetooth_edit_device_name')),
      textValue: $deviceName,
      inputValue: $deviceName,
      primaryButton: ResourceUtil.getStringSync($r('app.string.cancel')),
      secondaryButton: ResourceUtil.getStringSync($r('app.string.ok')),
      ssid: this.ssid,
      confirm: () => {
        this.showConfirmDialog();
      },
      closeDialog: () => {
        this.updateNameDialogController?.close();
      },
    }),
    cancel: () => {
    },
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center,
  });

  @Styles
  normalStyles() {
    .borderRadius((this.style as EntryMenuStyle)?.rootContainer?.borderRadius ??
      $r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Styles
  pressedStyles() {
    .borderRadius((this.style as EntryMenuStyle)?.rootContainer?.borderRadius ??
      $r('sys.float.ohos_id_corner_radius_clicked'))
  }

  @Builder defaultSheetBuilder() {
    Column() {
      Text($r('app.string.bluetooth_edit_device_name'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .maxFontSize('32vp')
        .minFontSize('14vp')
        .width('100%')
        .constraintSize({
          minHeight: '56vp',
        })
        .padding({
          left: '16vp',
          right: '16vp',
        })
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)

      TextInput({ text: this.uiRefresherId ? this.deviceName : ''})
        .height('48vp')
        .constraintSize({ minHeight: '48vp' })
        .showUnderline(false)
        .maxLength(this.inputMaxLength)
        .defaultFocus(true)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontSize('16fp')
        .fontWeight(FontWeight.Regular)
        .fontFamily('HarmonyHeiTi')
        .backgroundColor(Color.Transparent)
        .cancelButton({
          style: CancelButtonStyle.CONSTANT,
          icon: {
            size: '24vp',
          },
        })
        .margin({
          left: '0vp',
          top: '8vp',
        })
        .padding({
          left: '16vp',
          right: '0vp',
        })
        .onChange((value: string) => {
          this.inputChange(value);
        })

      Divider()
        .vertical(false)
        .color($r('sys.color.ohos_id_color_primary'))
        .height('1vp')
        .padding({
          left: '16vp',
          right: '16vp',
        })

      Scroll() {
        Column() {
          Text(this.sheetDescription)
            .fontSize($r('sys.float.ohos_id_text_size_body2'))
            .width('100%')
            .fontColor(this.isWarning ? $r('sys.color.ohos_id_color_warning') : $r('sys.color.ohos_id_color_text_hint'))
            .fontFamily('HarmonyHeiTi')
            .textAlign(TextAlign.Start)
            .fontWeight(FontWeight.Regular)
            .padding({
              left: '16vp',
              right: '16vp',
              top: '8vp',
            })
          Row() {
            Button($r('app.string.dialog_cancel'),
              {
                type: ButtonType.Capsule,
                stateEffect: true,
              })
              .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
              .fontSize($r('sys.float.ohos_id_text_size_button1'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
              .width('100%')
              .onClick(() => {
                this.isShowSheet = false;
              })
              .layoutWeight(1)
              .margin({
                right: '8vp',
              })

            Button($r('app.string.dialog_sure'),
              {
                type: ButtonType.Capsule,
                stateEffect: true,
              })
              .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
              .fontSize($r('sys.float.ohos_id_text_size_button1'))
              .fontFamily('HarmonyHeiTi')
              .fontWeight(FontWeight.Medium)
              .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
              .width('100%')
              .opacity(this.deviceName.trim().length > 0 ? OPACITY_PERCENT_FULL : OPACITY_PERCENT_SIXTY)
              .enabled((this.deviceName.trim().length > 0 && !this.isWarning))
              .onClick(() => {
                this.isShowSheet = false;
                if (this.menu?.key === HOT_SPOT_KEY) {
                  this.showConfirmDialog();
                } else {
                  if (this.menu?.state !== undefined) {
                    this.menu.state = this.deviceName;
                    this.controller?.refreshUi();
                    this.controller?.onMenuClick();
                  }
                }
              })
              .margin({
                left: '8vp',
              })
              .layoutWeight(1)
          }
          .margin({
            left: '16vp',
            right: '16vp',
            top: '46vp',
          })
        }
      }.edgeEffect(EdgeEffect.Spring)
      .constraintSize({
        maxHeight:'70%'
      })
    }
    .width('100%')
    .height('100%')
  }

  build() {
    Column() {
      EntryComponent({
        menu: $menu,
        style: $style,
        controller: $controller,
        uiRefresher: $uiRefresher,
        isSecondSelected: this.isSecondSelected,
      })
    }
    .enabled(this.menu?.enable as boolean && !this.isGrayed)
    .opacity((this.menu?.enable as boolean && !this.isGrayed) ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .onClick(() => {
      this.dealClickEvent();
    })
    .bindSheet($$this.isShowSheet, this.defaultSheetBuilder(), {
      detents: [DisplayUtils.getScreenHeight() - SHEET_TOP_MARGIN,
        DisplayUtils.getScreenHeight() - SHEET_TOP_MARGIN, SHEET_MOVE_RATE],
      height: DisplayUtils.getScreenHeight() - SHEET_TOP_MARGIN,
      maskColor: $r('sys.color.mask_fourth'),
      backgroundColor: $r('sys.color.ohos_id_color_dialog_bg'),
      dragBar: true,
      showClose: false,
      onDisappear: () => {
        this.onSheetDisappear();
      }
    })
    .onHover((isHover?: boolean) => {
      this.controller?.handleHoverEvent(isHover ? true : false);
    })
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
    })
    .visibility(this.uiRefresher.isVisible() ? Visibility.Visible : Visibility.None);
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    if (!this.menu) {
      LogUtil.error(`${this.tag} aboutToAppear: menu is empty.`);
      return;
    }
    this.isWarning = false;
    this.style = this.menu.style;
    this.controller = this.menu.getControllerInstance(this.uiRefresher);
    this.sheetDescription = (this.menu as SheetMenu).sheetDescription;
    if (this.menu?.key === HOT_SPOT_KEY) {
      wifiManager.getLinkedInfo().then(data => {
        this.ssid = data?.ssid ?? '';
      }).catch((err: Error) => {
        LogUtil.error(`${TAG} getLinkedInfo fail, errMessage: ${err?.message}`);
        this.ssid = '';
      })
      this.registerListener();
    }
    if (this.menu?.key === DEVICE_NAME_KEY) {
      this.inputMaxLength = MAX_INPUT_LENGTH_BYTES;
    } else {
      this.inputMaxLength = MAX_INPUT_LENGTH_DEFAULT;
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.controller?.aboutToDisappear();
    if (this.menu?.key === HOT_SPOT_KEY) {
      this.unRegisterListener();
    }
  }

  private registerListener(): void {
    this.apConnected.registerCommonEvent();
    try {
      wifiManager.on('wifiConnectionChange', this.onWifiConnectionChange);
    } catch (error) {
      LogUtil.error(`${TAG}, registerListener failed. ${error?.message}`);
    }
  }

  private unRegisterListener(): void {
    this.apConnected.unRegisterCommonEvent();
    try {
      wifiManager.off('wifiConnectionChange', this.onWifiConnectionChange);
    } catch (error) {
      LogUtil.error(`${TAG}, unRegisterListener failed. ${error?.message}`);
    }
  }

  private inputChange(value: string): void {
    LogUtil.info(`${TAG} TextInput onchange, value: ${value}`);
    if (value?.length >= this.inputMaxLength) {
      ResourceUtil.getString($r('app.string.input_max_length_message')).then(value => {
        try {
          prompt.showToast({
            message: value,
            duration: TOAST_DURATION,
          });
        } catch (error) {
          LogUtil.info(`${TAG} showToast failed: ${error?.message}`);
        };
      });
    }
    if (this.menu?.key === HOT_SPOT_KEY) {
      if (this.ssid && value === this.ssid) {
        this.sheetDescription = $r('app.string.repeat_name_warning');
        this.isWarning = true;
      } else {
        this.sheetDescription = $r('app.string.device_name_modify_tips');
        this.isWarning = false;
      }
      this.deviceName = value;
    }
    if (this.menu?.key === DEVICE_NAME_KEY) {
      let textArray = StringUtil.stringToUint8Array(value);
      if (textArray.length > MAX_INPUT_LENGTH_BYTES) {
        let tempString = value;
        let endIndex = 1;
        while (StringUtil.stringToUint8Array(tempString.substring(0, tempString.length - endIndex)).length >
          MAX_INPUT_LENGTH_BYTES) {
          endIndex++;
        }
        this.deviceName = tempString.substring(0, tempString.length - endIndex);
        this.uiRefresherId = this.uiRefresherId > MAX_REFRESH_ID ? 1 : this.uiRefresherId + 1;
      } else {
        this.deviceName = value;
      }
    }
  }

  private dealClickEvent(): void {
    if (this.menu?.key === HOT_SPOT_KEY) {
      this.deviceName = DeviceNameUtil.getDisplayDeviceName();
      if (this.isPad || this.isPc) {
        this.updateNameDialogController?.open();
      } else {
        this.isShowSheet = true;
      }
      return;
    }
    if (this.menu?.key === DEVICE_NAME_KEY) {
      this.deviceName = this.menu?.state?.toString() ?? '';
      if (this.isPad || this.isPc) {
        this.updateNameDialogController?.open();
      } else {
        this.isShowSheet = true;
      }
      return;
    }
    this.isShowSheet = true;
  }

  private showConfirmDialog(): void {
    let currentDeviceName = DeviceNameUtil.getDisplayDeviceName();
    if (currentDeviceName === this.deviceName) {
      LogUtil.info(`${this.tag}, device name not change, no need to refresh`);
      return;
    }
    try {
      if ((!wifiManager.isHotspotActive() || wifiManager.getStations()?.length <= 0) &&
        this.menu?.state !== undefined) {
        this.menu.state = this.deviceName;
        this.controller?.refreshUi();
        this.controller?.onMenuClick();
        return;
      }
    } catch (error) {
      LogUtil.error(`${this.tag} getStations error： ${error?.message}`);
    }
    AlertDialog.show({
      title: ResourceUtil.getStringSync($r('app.string.attention')),
      message: ResourceUtil.getStringSync($r('app.string.confirm_change_name')),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: ResourceUtil.getStringSync($r('app.string.cancel')),
        fontColor: $r('sys.color.ohos_id_color_text_primary_activated'),
        action: () => {
        }
      },
      secondaryButton: {
        value: ResourceUtil.getStringSync($r('app.string.modify')),
        fontColor: $r('sys.color.ohos_id_color_text_primary_activated'),
        action: () => {
          if (this.menu?.state !== undefined) {
            this.menu.state = this.deviceName;
            this.controller?.refreshUi();
            this.controller?.onMenuClick();
          }
        }
      },
    });
  }

  private async onHotSpotStateChange(): Promise<void> {
    let ssid = await this.getLatestLinkedSsid();
    try {
      if (ssid !== this.menu?.state?.toString() ?? '') {
        LogUtil.info(`${TAG} ssid not equals state.`);
        return;
      }
      if (this.isShowNameRepeatWarning || !wifiManager.isHotspotActive()) {
        return;
      }
      this.isShowNameRepeatWarning = true;
      AlertDialog.show({
        message: ResourceUtil.getStringSync($r('app.string.name_repeat_warning')),
        autoCancel: false,
        alignment: DialogAlignment.Center,
        primaryButton: {
          value: ResourceUtil.getStringSync($r('app.string.cancel')),
          fontColor: $r('sys.color.ohos_id_color_text_primary_activated'),
          action: () => {
            this.closeHotspot();
            this.isShowNameRepeatWarning = false;
          }
        },
        secondaryButton: {
          value: ResourceUtil.getStringSync($r('app.string.modify')),
          fontColor: $r('sys.color.ohos_id_color_text_primary_activated'),
          action: () => {
            this.clickModify();
          }
        },
        cancel: () => {
          this.closeHotspot();
          this.isShowNameRepeatWarning = false;
        }
      });
    } catch (error) {
      LogUtil.error(`${TAG} onHotSpotStateChange occurs error: ${error?.message}`);
    }
  }

  private clickModify(): void {
    this.deviceName = this.menu?.state?.toString() ?? '';
    if (this.isPad || this.isPc) {
      this.updateNameDialogController?.open();
    } else {
      this.isShowSheet = true;
    }
    this.isShowNameRepeatWarning = false;
  }

  private closeHotspot(): void {
    let sharing: ESObject = loadNativeModule('@ohos.net.sharing');
    sharing.stopSharing(sharing.SharingIfaceType.SHARING_WIFI).then(() => {
      LogUtil.info(`${TAG} stopSharing success`);
    }).catch((error: BusinessError) => {
      LogUtil.error(`${TAG} stopSharing fail: ${error?.message}`);
    });
  }

  private async onSheetDisappear(): Promise<void> {
    if (this.menu?.key === HOT_SPOT_KEY) {
      let latestLinkedSsid = await this.getLatestLinkedSsid();
      if (this.menu?.state === latestLinkedSsid) {
        this.closeHotspot();
      }
    }
  }

  private async getLatestLinkedSsid(): Promise<string> {
    try {
      let linkInfo = await wifiManager.getLinkedInfo();
      return linkInfo.ssid;
    } catch (error) {
      LogUtil.error(`${TAG} getLinkedInfo failed: ${error?.message}`);
    }
    return '';
  }
}