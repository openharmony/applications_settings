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

import Want from '@ohos.app.ability.Want';
import deviceInfo from '@ohos.deviceInfo';
import UIExtensionAbility from '@ohos.app.ability.UIExtensionAbility';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import uiExtensionHost from '@ohos.uiExtensionHost';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { DisplayConstant } from '@ohos/settings.common/src/main/ets/constant/DisplayConstant';
import { AbilityContextManager } from '@ohos/settings.common/src/main/ets/ability/AbilityContextManager';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { PageUrl } from '../pages/PageUrl';

/* instrument ignore file */
const TAG: string = 'OobeLocalUserAbility : ';

interface UIExtensionStorage {
  session: UIExtensionContentSession,
}

export default class OobeLocalUserAbility extends UIExtensionAbility {
  onCreate(): void {
    LogUtil.info(`${TAG} Ability onCreate`);
    AbilityContextManager.addContext(this.context);
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
  }

  onDestroy(): void {
    AbilityContextManager.removeContext(this.context);
    LogUtil.info(`${TAG} Ability onDestroy`);
  }

  onSessionCreate(want: Want, session: UIExtensionContentSession): void {
    try {
      session.setWindowPrivacyMode(true);
      let localStorage: LocalStorage = new LocalStorage({
        session: session,
      } as UIExtensionStorage);
      session.loadContent(PageUrl.OOBE_LOCAL_USER_PAGE_URL, localStorage);
    } catch (err) {
      LogUtil.error(`${TAG} UIExtensionAbility on session create error: ${err?.message}`);
    }
    session.setWindowBackgroundColor('#00000000');
    this.updateBtnWidth(session);
    // 系统底层字体缩放倍数
    let fontSizeScale: number | undefined = this.context?.config?.fontSizeScale;
    const fontSizeMultiplier: number = fontSizeScale ? fontSizeScale : DisplayConstant.TEXT_FONT_SIZE_NORMAL;
    const maxMultiplierFont: number = DisplayConstant.TEXT_FONT_SIZE_HUGE;
    const multiplier: number = fontSizeMultiplier > maxMultiplierFont ? maxMultiplierFont : fontSizeMultiplier;
    AppStorage.setOrCreate<number>('oobe_local_user_ability_font_multiplier', multiplier);
  }

  public updateBtnWidth(session: UIExtensionContentSession): void {
    let windowClass: uiExtensionHost.UIExtensionHostWindowProxy = session.getUIExtensionHostWindowProxy();
    let hostWindowWidth: number = windowClass.properties.uiExtensionHostWindowProxyRect.width;
    // 仅在宽度值有效的情况下计算
    if (hostWindowWidth && hostWindowWidth > 0) {
      // 底部按钮宽度用格栅计算
      const columnMargin: number = vp2px(24);
      const columnMarginNum: number = 2;
      const columnGutter: number = vp2px(24);
      const columnCount: number = 12;
      const buttonColumnCount: number = 2;
      const singleColumnWidth = (hostWindowWidth - columnMargin * columnMarginNum - (columnCount - 1) * columnGutter) /
        columnCount;
      const btnWidth: number = px2vp(buttonColumnCount * singleColumnWidth + columnGutter);
      AppStorage.setOrCreate<number>('oobe_local_user_ability_btn_width', btnWidth);
    }
  }

  onForeground(): void {
    LogUtil.info(`${TAG} Ability onForeground`);
  }

  onBackground(): void {
    LogUtil.info(`${TAG} Ability onBackground`);
  }
}