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
import MediaQuery from '@ohos.mediaquery';
import { settings } from '@kit.BasicServicesKit';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { NavEntryKey } from '@ohos/settings.common/src/main/ets/utils/Consts';
import {
  ElderCareManager,
  ElderCareUtils,
  OpenElderCare
} from '@ohos/settings.accessibility/src/main/ets/ElderCareUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DeviceUtil } from '@ohos/settings.common/src/main/ets/utils/BaseUtils';
import { DisplayUtils } from '@ohos/settings.common/src/main/ets/utils/DisplayUtils';
import { SWITCH_ON } from '../../constant/Constants'

let isPad: boolean = DeviceUtil.isDevicePad();
let isLargeFold: boolean = DeviceUtil.isLargeInFoldProduct();

@Component
export struct ElderCareGuidePageButtonComponent {
  @StorageLink('isPortraitOrientation') isPortraitOrientation: boolean = false;
  private TAG: string = 'ElderCareGuidePageButtonComponent: ';
  private orientationListener: MediaQuery.MediaQueryListener | undefined = undefined;

  build() {
    Column() {
      Button() {
        Text($r('app.string.accessibility_enable'))
          .fontFamily('HarmonyHeiTi')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
      }
      .type(ButtonType.Normal)
      .borderRadius($r('sys.float.ohos_id_corner_radius_button'))
      .fontColor('app.float.water_mark_text_color')
      .constraintSize({
        maxWidth: 448,
        minHeight: 40,
      })
      .width(!this.isPortraitOrientation && isPad ? 448 : '100%')
      .onClick(() => {
        this.onEntryClick();
      })
    }
    .width('100%')
    .padding({
      left: !this.isPortraitOrientation && (isPad || isLargeFold) ? 0 : 16,
      right: !this.isPortraitOrientation && (isPad || isLargeFold) ? 0 : 16,
      top: 8,
      bottom: 16,
    })
  }

  aboutToAppear(): void {
    LogUtil.info(`${this.TAG} aboutToAppear`);
    // 添加平板页面横竖屏的监听器
    if (isPad || isLargeFold) {
      this.isPortraitOrientation = DisplayUtils.isScreenPortraitOrientation();
      this.addOrientationListener();
    }
    this.registerDataChange();
  }

  aboutToDisappear(): void {
    LogUtil.info(`${this.TAG} aboutToDisappear`);
    // 销毁平板页面横竖屏监听器
    if (isPad || isLargeFold) {
      this.orientationListener?.off('change');
    }
    this.unRegisterDataChange();
  }

  private onEntryClick(): void {
    SettingsDataUtils.setSecureValue(ElderCareUtils.ELDER_CARE_HAS_ENABLED, 'true');
    SettingsDataUtils.setSecureValue(ElderCareUtils.ACCESSIBILITY_ELDER_CARE_SWITCH_ENABLED, SWITCH_ON);
    ElderCareUtils.updateElderCareSearchItemStatus(true);
    let elderCareManager = new ElderCareManager(new OpenElderCare(true));
    elderCareManager.doSetting();
    PageRouter.replace(NavEntryKey.ACCESSIBILITY_ELDER_CARE_ENTRY);
  }

  private registerDataChange(): void {
    SettingsDataUtils.registerKeyObserverWithDomain(ElderCareUtils.ELDER_CARE_HAS_ENABLED,
      settings.domainName.USER_SECURITY, (err, value) => {
        let isFirstOpenElderCare: boolean = SettingsDataUtils.getSecureValue(ElderCareUtils.ELDER_CARE_HAS_ENABLED,
          'false') === 'true';
        LogUtil.info(`${this.TAG} is first time open elder care: ${isFirstOpenElderCare}`);
        if (isFirstOpenElderCare) {
          PageRouter.replace(NavEntryKey.ACCESSIBILITY_ELDER_CARE_ENTRY);
        }
      })
  }

  private unRegisterDataChange(): void {
    SettingsDataUtils.unregisterKeyObserverWithDomain(ElderCareUtils.ELDER_CARE_HAS_ENABLED,
      settings.domainName.USER_SECURITY);
  }

  async addOrientationListener(): Promise<void> {
    this.orientationListener = MediaQuery.matchMediaSync('(orientation: landscape)');
    this.orientationListener.on('change', () => {
      AppStorage.setOrCreate('isPortraitOrientation', DisplayUtils.isScreenPortraitOrientation());
      LogUtil.info(`${this.TAG} isPortraitOrientation: ${this.isPortraitOrientation}`)
    })
  }
}