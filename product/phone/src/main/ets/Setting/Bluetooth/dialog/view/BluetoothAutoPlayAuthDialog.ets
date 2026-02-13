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

import a2dp from '@ohos.bluetooth.a2dp';
import UIExtensionContentSession from '@ohos.app.ability.UIExtensionContentSession';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { AutoPlayAuthDialog } from '@ohos/settings.bluetooth/src/main/ets/component/AutoPlayAuthDialog';

/* instrument ignore file */
const TAG: string = 'BluetoothAutoPlayAuthDialog : ';

// 自动播报的弹窗出现后，15s不操作会自动关闭
const AUTO_CLOSE_TIME: number = 15000;

// 拦截时间默认值
const AUTO_PLAY_INTERCEPT_DEFAULT_VALUE: number = 3000;

@Component
@Entry
export struct BluetoothAutoPlayAuthDialog {
  private a2dpProfile: a2dp.A2dpSourceProfile | undefined = undefined;
  private autoCloseId: number | null = null;
  private autoPlayDialogController = new CustomDialogController({
    builder: AutoPlayAuthDialog({
      handleConfirmClick: () => {
        LogUtil.info(`${TAG} handleConfirmClick`);
        this.onConfirmClick();
      },
      handleForbiddenClick: () => {
        LogUtil.info(`${TAG} handleForbiddenClick`);
        this.onForbiddenClick();
      },
    }),
    autoCancel: true,
    customStyle: true,
    backgroundColor: $r('sys.color.ohos_id_color_background'),
    cancel: () => {
      LogUtil.info(`${TAG} on cancel is called.`);
      this.onConfirmClick();
    },
    alignment: DialogAlignment.Center,
  });

  build() {
    Column()
      .width('100%')
      .height('100%')
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.autoPlayDialogController.open();
    if (!this.autoCloseId) {
      this.autoCloseId = setTimeout(() => {
        LogUtil.info(`${TAG} automatically close when time is up`);
        this.autoCloseId = null;
        this.onConfirmClick();
      }, AUTO_CLOSE_TIME);
    }
    try {
      this.a2dpProfile = a2dp.createA2dpSrcProfile();
    } catch (error) {
      LogUtil.error(`${TAG} createA2dpSrcProfile error: ${error?.message}`);
    }
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    if (!this.autoCloseId) {
      clearTimeout(this.autoCloseId);
      this.autoCloseId = null;
    }
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
  }

  async onConfirmClick(): Promise<void> {
    AppStorage.get<UIExtensionContentSession>('dialogSession')?.terminateSelf();
    try {
      let deviceId = AppStorage.get<string>('bt_autoPlay_deviceId');
      await this.a2dpProfile?.enableAutoPlay(deviceId);
      LogUtil.info(`${TAG} enableAutoPlay finished.`);
    } catch (error) {
      LogUtil.error(`${TAG} deal auto play error: ${error?.message}`);
    }
  }

  async onForbiddenClick(): Promise<void> {
    AppStorage.get<UIExtensionContentSession>('dialogSession')?.terminateSelf();
    try {
      let deviceId = AppStorage.get<string>('bt_autoPlay_deviceId');
      let duration = await this.a2dpProfile?.getAutoPlayDisabledDuration(deviceId);
      // allow devices automatic play music when connected.
      if (duration === -1) {
        duration = AUTO_PLAY_INTERCEPT_DEFAULT_VALUE;
      }
      await this.a2dpProfile?.disableAutoPlay(deviceId, duration);
      LogUtil.info(`${TAG} disableAutoPlay finished.`);
    } catch (error) {
      LogUtil.error(`${TAG} deal auto play error: ${error?.message}`);
    }
  }
}