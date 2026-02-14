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

import { settings } from '@kit.BasicServicesKit';
import lazy { AlertDialog } from '@ohos.arkui.advanced.Dialog';
import {
  FOCUS_BOX_PADDING_METRICS,
  PADDING_0,
  PADDING_12,
  PADDING_16,
  PADDING_2,
  PADDING_4,
  PADDING_8
} from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { SettingBaseModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { CompStateEvent, SettingCompState } from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  DeviceNameUtil,
  CHECK_SUCCESS,
  CHECK_FAIL_REASON_NETWORK,
  CHECK_FAIL_REASON_LOG_IN,
  ABOUT_DEVICE_NAME_COMP_ID
} from '@ohos/settings.common/src/main/ets/utils/DeviceNameUtils';
import { FontScaleUtils } from '@ohos/settings.common/src/main/ets/utils/FontScaleUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PreferencesUtil } from '@ohos/settings.common/src/main/ets/utils/PreferencesUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { CommonDialog } from '@ohos/settings.uikit/src/main/ets/dialog/CommonDialog';
import { DialogButtonType } from '@ohos/settings.uikit/src/main/ets/dialog/types';
import { DeviceNameController, SHOW_DEVICE_NAME_SHEET } from '../controller/DeviceNameController';
import { NameUpdateSheetComponent } from './NameUpdateSheetComponent';
import common from '@ohos.bluetooth.common';

const OPACITY_PERCENT_FULL: number = 1;
const MAX_LENGTH: number = 30;
const SETTINGS_DATA_DISPLAY_DEVICE_NAME: string = 'settings.general.display_device_name';
const ALPHA_DISABLED: Resource = $r('sys.float.alpha_tertiary');
const DEVICE_NAME_SETTINGS: string = 'DeviceNameSettings';

@Component
export struct DeviceNameItemComponent {
  tag: string = 'DeviceNameItemComponent: ';
  item?: SettingItemModel;
  controller?: DeviceNameController;
  hint?: ResourceStr;
  maxLength: number = MAX_LENGTH;
  blueToothName: boolean = false;
  private logInDialogController: CustomDialogController | undefined = undefined;
  private compStateEvent?: CompStateEvent;
  @State textValue: ResourceStr = '';
  @State inputValue: ResourceStr = '';
  @State isShow: boolean = false;
  @State sheetHeight: number = 300;
  @State title: ResourceStr = '';
  @State isToggleEnable: boolean = true;
  @State isGrayed: boolean = PreferencesUtil.getSync(DEVICE_NAME_SETTINGS, false) as boolean;
  @State isEnable: boolean = true;
  @State isHover: boolean = false;

  private isExtraLargeFontMode() {
    return FontScaleUtils.isExtraLargeFontMode();
  }

  build() {
    Flex({ wrap: this.isExtraLargeFontMode() ? FlexWrap.Wrap : FlexWrap.NoWrap,
      justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
      Row() {
        Text($r('app.string.device_name_settings_title'))
          .fontColor($r('sys.color.font_primary'))
          .fontSize($r('sys.float.Body_L'))
          .fontWeight(FontWeight.Medium)
          .align(Alignment.Center)
          .fontFamily('HarmonyHeiTi')
          .constraintSize({
            minHeight: 21,
          })
      }
      .flexGrow(0)
      .flexShrink(0)
      .align(Alignment.Start)

      Flex({ justifyContent: FlexAlign.End, alignItems: ItemAlign.Center }) {
        Column() {
          Text(this.title)
            .fontColor($r('sys.color.font_secondary'))
            .fontSize($r('sys.float.Body_M'))
            .fontFamily('HarmonyHeiTi')
            .fontWeight(FontWeight.Regular)
            .constraintSize({
              minHeight: 19,
            })
            .wordBreak(WordBreak.BREAK_WORD)
        }
        .margin({
          start: PADDING_2,
          end: PADDING_2,
        })
        .flexGrow(1)
        .alignItems(this.isExtraLargeFontMode() ? HorizontalAlign.Start : HorizontalAlign.End)
        .justifyContent(FlexAlign.Center)

        if (this.blueToothName === false) {
          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.icon_fourth')])
            .draggable(false)
            .fontSize('24vp')
            .margin({
              start: PADDING_4,
            })
        }
      }
      .padding({
        start: this.isExtraLargeFontMode() ? PADDING_0 : PADDING_16,
      })
    }
    .focusBox({ margin: FOCUS_BOX_PADDING_METRICS })
    .enabled(this.isEnable)
    .opacity(this.isEnable ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
    .width('100%')
    .padding({
      start: PADDING_8,
      end: PADDING_8,
      top: this.isExtraLargeFontMode() ? FontScaleUtils.getSafetyPadding() : PADDING_12,
      bottom: this.isExtraLargeFontMode() ? FontScaleUtils.getSafetyPadding() : PADDING_12,
    })
    .borderRadius($r('sys.float.corner_radius_level8'))
    .stateStyles({
      normal: this.normalStyles,
      pressed: this.pressedStyles,
    })
    .onClick(() => {
      if (this.blueToothName) {
        return
      }
      this.controller?.checkUpdateCondition().then((result) => {
        /* instrument ignore if*/
        // if (result !== CHECK_SUCCESS) {
        //   LogUtil.info(`update device name pre check fail, result: ${result}`);
        //   this.handlePreCheckFail(result);
        //   return;
        // }
        this.isShow = true;
        LogUtil.info(`onclick show sheet, isShow: ${this.isShow}`);
      });
    })
    .onHover((hover: boolean) => {
      this.isHover = hover;
    })
    .bindSheet(this.isShow, this.controller?.sheetBuilder ? this.customSheetBuilder() : this.updateNameSheetBuilder(), {
      detents: [DisplayUtils.getScreenHeight() * 0.75],
      height: 320,
      preferType: SheetType.CENTER,
      dragBar: true,
      title: { title: $r('app.string.change_device_name') },
      backgroundColor: $r('sys.color.ohos_id_color_dialog_bg'),
      maskColor: $r('sys.color.mask_fourth'),
      showClose: true,
      keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
      onDisappear: () => {
        this.controller?.onSheetDisappear();
      },
      onWillDisappear: () => {
        LogUtil.info(`${this.tag} onWillDisappear`);
        this.isShow = false;
      },
    })
  }

  @Builder
  customSheetBuilder() {
    this.controller?.sheetBuilder?.builder.builder(this.controller?.sheetBuilder?.param)
  }

  @Builder
  updateNameSheetBuilder() {
    Column() {
      NameUpdateSheetComponent({
        textValue: this.textValue,
        inputValue: this.inputValue,
        hint: this.hint,
        maxLength: this.maxLength,
        primaryButton: $r('app.string.dialog_sure'),
        needReConfirm: this.controller?.needReConfirm,
        confirm: () => {
          LogUtil.info(`${this.tag} confirm`);
          this.controller?.onPrimaryButtonClick(getContext(this), this.inputValue.toString());
        },
        reConfirm: () => {
          /* instrument ignore if*/
          if (this.controller?.needReConfirm) {
            let res: boolean = this.controller.updateConfirm(this.inputValue.toString());
            if (res) {
              let reConfirmDialogController = new CustomDialogController({
                builder: CommonDialog({
                  title: ResourceUtil.getStringSync($r('app.string.attention')),
                  actionType: DialogButtonType.TWO_BUTTON_HORIZONTAL,
                  cancelText: $r('app.string.cancel'),
                  cancelCallback: () => {
                    reConfirmDialogController.close();
                  },
                  confirmText: $r('app.string.modify'),
                  confirmCallback: () => {
                    EventBus.getInstance().emit('updateDeviceNameConfirm');
                    reConfirmDialogController.close();
                  },
                  content: () => {
                    this.buildReConfirmDialogContent();
                  },
                }),
              });
              reConfirmDialogController.open();
            }
          }
        },
        closeDialog: () => {
          LogUtil.info(`${this.tag} close sheet`);
          this.isShow = false;
        },
      })
    }
    .enabled(!this.isGrayed)
    .opacity(!this.isGrayed ? OPACITY_PERCENT_FULL : ALPHA_DISABLED)
  }

  @Styles
  normalStyles() {
    .backgroundColor(this.getNormalColor())
  }

  private getNormalColor(): ResourceColor {
    if (this.isHover) {
      return $r('sys.color.ohos_id_color_hover');
    }
    return Color.Transparent;
  }

  @Builder
  buildReConfirmDialogContent() {
    Column() {
      Text($r('app.string.confirm_change_name'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(21)
    }
  }

  @Styles
  pressedStyles() {
    .backgroundColor($r('sys.color.interactive_click'))
  }

  aboutToAppear(): void {
    this.registerDataChange();
    this.initParam();
    this.controller?.init();
    LogUtil.info(`${this.tag} aboutToAppear`+JSON.stringify(this.item));
    this.isEnable = (this.item as SettingBaseModel).enabled ?? true;
    this.compStateEvent = new CompStateEvent(ABOUT_DEVICE_NAME_COMP_ID, {
      enabled: (enabledState: SettingCompState): void => {
        /* instrument ignore if*/
        if (enabledState.state !== undefined && enabledState.state !== this.isEnable) {
          this.isEnable = enabledState.state;
          this.isGrayed = !enabledState.state;
        }
      }
    });
    this.compStateEvent.on();
    EventBus.getInstance().on(SHOW_DEVICE_NAME_SHEET, (isShow: boolean) => {
      this.isShow = isShow;
    });
    if (this.controller) {
      this.controller.reConfirmCallBack = (result: boolean) => {
        LogUtil.info(`${this.tag} reConfirmCallBack result: ${result}`);
        EventBus.getInstance().emit('deviceNameCheck');
        if (result) {
          this.refreshData();
          this.isShow = false;
        }
      };
    }
  }

  private registerDataChange(): void {
    SettingsDataUtils.registerKeyObserverWithDomain(SETTINGS_DATA_DISPLAY_DEVICE_NAME,
      settings.domainName.USER_SECURITY,
      () => {
        LogUtil.info(`${this.tag} displayDeviceName data change`);
        this.title = DeviceNameUtil.getDisplayDeviceName();
        this.textValue = this.title;
        this.inputValue = this.title;
      })
  }

  private unRegisterDataChange(): void {
    SettingsDataUtils.unregisterKeyObserverWithDomain(SETTINGS_DATA_DISPLAY_DEVICE_NAME,
      settings.domainName.USER_SECURITY);
  }

  private initParam(): void {
    this.controller = this.item?.compControl as DeviceNameController;
    this.refreshData();
  }
//设备名称
  private refreshData(): void {
    this.title = this.controller?.result ?? '';
    this.textValue = this.controller?.textValue ?? '';
    this.inputValue = this.controller?.textValue ?? '';
  }

  aboutToDisappear(): void {
    this.unRegisterDataChange();
    this.controller?.destroy();
    LogUtil.info(`${this.tag} aboutToDisappear`);
    EventBus.getInstance().off(SHOW_DEVICE_NAME_SHEET);
    this.compStateEvent?.detach();
  }

}