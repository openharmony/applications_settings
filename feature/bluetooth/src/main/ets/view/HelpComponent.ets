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

/* instrument ignore file */
import { EventBus } from '@ohos/settings.common/src/main/ets/framework/common/EventBus';
import { CommonUtils } from '@ohos/settings.common/src/main/ets/utils/CommonUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import bundleManager from '@ohos.bundle.bundleManager';
import util from '@ohos.util';
import { AbilityUtils } from '@ohos/settings.common/src/main/ets/utils/AbilityUtils';
import { CommonEventConstant } from '@ohos/settings.common/src/main/ets/constant/CommonEventConstant';
import { PADDING_16, PADDING_8 } from '@ohos/settings.common/src/main/ets/constant/StyleConstant';
import { BluetoothUtils } from '@ohos/settings.common/src/main/ets/utils/BluetoothUtils';
import { BluetoothAdapter } from '../BluetoothAdapter';

const TIPS_APP_BUNDLE_NAME = 'com.ohos.tips';
const TIPS_APP_ID = '';
const URI_FORMATTER = '';
const MODULE_NAME_APPGALLERY = '';
const URI_APPGALLERY = '';
const FUN_NUM_HOME = '';
const TYPE = 118;
const DISPLAY_DURATION = 5000;

@Component
export struct HelpComponent {
  private tag: string = 'HelpComponent: ';
  private showPopupTimerId: number | null = null;
  @State isShowPopup: boolean = false;

  private popupShowEventCallback = () => {
    LogUtil.info(`${this.tag} receive isShowPopup event`);
    if (!BluetoothUtils.isBluetoothStateOn(BluetoothAdapter.getInstance().currentState)) {
      LogUtil.warn(`${this.tag} receive isShowPopup event, but the bluetooth state is off`);
      return;
    }

    this.isShowPopup = true;
    this.showPopupTimerId = setTimeout(() => {
      this.isShowPopup = false;
      this.showPopupTimerId = null;
    }, DISPLAY_DURATION);
  };

  build() {
    Button({ type: ButtonType.Circle, buttonStyle: ButtonStyleMode.NORMAL }) {
      SymbolGlyph($r('sys.symbol.questionmark_circle'))
        .fontSize($r('app.float.wh_value_24'))
        .fontColor([$r('sys.color.icon_primary')])
        .renderingStrategy(SymbolRenderingStrategy.SINGLE)
        .draggable(false)
    }
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .width(40)
    .height(40)
    .margin({
      end: PADDING_16,
      top: PADDING_8,
      bottom: PADDING_8,
    })
    .accessibilityText($r('app.string.help'))
    .onClick(() => {
      LogUtil.info(`${this.tag} onclick, start to jump`);
      this.handleClickEvent();
    })
    .bindPopup(this.isShowPopup, {
      builder: this.popupBuilder,
      popupColor: $r('sys.color.ohos_id_color_dialog_bg'),
      radius: 18,
      placement:Placement.Bottom,
      onStateChange: (isVisible)=> {
        LogUtil.info(`${this.tag} onStateChange: ${isVisible}`);
      },
    })
  }

  @Builder popupBuilder() {
    Row() {
      Text($r('app.string.bluetooth_help_popup_content'))
        .fontFamily('HarmonyHeiTi')
        .fontWeight(FontWeight.Regular)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(19)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .padding({
      top: 13,
      bottom: 13,
      left: 12,
      right: 12,
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.tag} aboutToAppear`);
    EventBus.getInstance().on(CommonEventConstant.EVENT_BLUETOOTH_HELP_POPUP_CHANGE, this.popupShowEventCallback);
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.tag} aboutToDisappear`);
    EventBus.getInstance().detach(CommonEventConstant.EVENT_BLUETOOTH_HELP_POPUP_CHANGE, this.popupShowEventCallback);
    clearTimeout(this.showPopupTimerId);
  }

  private handleClickEvent(): void {
    let isTipsInstall: boolean =
      CommonUtils.isAppInstalled(TIPS_APP_BUNDLE_NAME, bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO,
        TIPS_APP_ID);
    if (isTipsInstall) {
      LogUtil.info(`${this.tag} try jump to tips app`);
      let uri = util.format(URI_FORMATTER, FUN_NUM_HOME, TYPE);
      let want: Want = {
        bundleName: TIPS_APP_BUNDLE_NAME,
        action: 'ohos.want.action.viewData',
        entities: ['entity.system.browsable'],
        uri: uri,
      };
      AbilityUtils.startAbility(want);
    } else {
      LogUtil.info(`${this.tag} try jump to appgallery`);
      const want: Want = {
        bundleName: MODULE_NAME_APPGALLERY,
        uri: URI_APPGALLERY,
      };
      AbilityUtils.startAbility(want);
    }
  }
}