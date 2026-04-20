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
import router from '@ohos.router';
import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import emitter from '@ohos.events.emitter';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { EVENT_ID_ON_PAGE_BACKGROUND, EVENT_ID_ICON_SETTING_PAGE_BACKGROUND } from '@ohos/settings.common/src/main/ets/event/types';
import { MainConstants } from '@ohos/settings.common/src/main/ets/constant/MainConstants';
import { ComponentContent } from '@ohos.arkui.node';

const TAG: string = 'IconSettingPage : ';
const PAGE_NAME: string = 'IconSettingPage';

class Params {
}

@Builder
function loadingBuilder(params: Params) {
  Column({ space: 16 }) {
    LoadingProgress()
      .width(72)
      .height(72)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
}

@Entry({ routeName: PAGE_NAME })
@Component
struct IconSettingPage {
  @State want: Want = {};
  private lastOrientation?: window.Orientation;
  // 如果已经接到了返回的消息，不重复做退出操作，防止连续退回到桌面
  private onReceiveBack: boolean = false;
  private loadingProgress = new ComponentContent(this.getUIContext(), wrapBuilder(loadingBuilder), new Params);

  /**
   * 是否启用系统栏(状态栏、导航栏、导航条)，启用会显示系统栏，不启用会隐藏系统栏
   *
   * @param enable 是否启用
   */
  private async setSystemBarEnabled(enable: boolean): Promise<void> {
    try {
      const lastWindow: window.Window = await window.getLastWindow(getContext(this));
      await lastWindow.setSpecificSystemBarEnabled('status', enable);
    } catch (error) {
      const e = error as BusinessError;
      LogUtil.error(`${TAG}Failed to set system bar enabled. Error = ${e?.name}, ${e?.code}, ${e?.message}`);
    }
  }

  /**
   * 锁定屏幕方向，禁止旋转
   */
  private lockOrientation(): void {
    let orientation = window.Orientation.LOCKED;
    const winStage: window.WindowStage | undefined =
      AppStorage.get<window.WindowStage>(MainConstants.MAIN_WINDOW_STAGE);
    winStage?.getMainWindow().then((window) => {
      const lastOrientation: window.Orientation = window.getPreferredOrientation();
      if (orientation === lastOrientation) {
        LogUtil.info(`${TAG} lockOrientation faild, orientation equals lastOrientation`);
        return;
      }
      this.lastOrientation = this.lastOrientation ?? lastOrientation;
      window.setPreferredOrientation(orientation);
    }).catch((error: Error) => {
      LogUtil.error(`${TAG} lockOrientation, setPreferredOrientation error: ${error?.message}`);
    });
  }

  /**
   * 解除锁定屏幕方向
   */
  private unlockOrientation(): void {
    if (!this.lastOrientation) {
      LogUtil.info(`${TAG} unlockOrientation faild, orientation is undefined`);
      return;
    }
    LogUtil.info(`${TAG} unlockOrientation, lastOrientation is ${this.lastOrientation}`);
    const winStage: window.WindowStage | undefined =
      AppStorage.get<window.WindowStage>(MainConstants.MAIN_WINDOW_STAGE);
    winStage?.getMainWindow().then((window) => {
      window.setPreferredOrientation(this.lastOrientation);
      this.lastOrientation = undefined;
    }).catch((error: Error) => {
      LogUtil.error(`${TAG} unlockOrientation, setPreferredOrientation error: ${error?.message}`);
    });
  }

  private onReceiveData: (data: object) => void = (data: object) => {
    LogUtil.info(`${TAG} onReceiveData`);
    if (data === undefined) {
      LogUtil.error(`${TAG} onReceiveData is undefined`);
      return;
    }
    if (data['back'] !== undefined) {
      this.doPageBack();
    }
    if (data['apply'] === true) {
      this.doPageBack();
    }
  };

  private doPageBack(): void {
    if (this.onReceiveBack) {
      return;
    }
    this.setSystemBarEnabled(true);
    router.back();
    this.onReceiveBack = true;
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    this.want = router.getParams() as Want;
    this.lockOrientation();
    emitter.on({
      eventId: EVENT_ID_ON_PAGE_BACKGROUND
    }, () => {
      LogUtil.showInfo(TAG, 'on background pop');
      this.doPageBack();
      emitter.emit({
        eventId: EVENT_ID_ICON_SETTING_PAGE_BACKGROUND,
      }, {});
    })
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    this.unlockOrientation();
    emitter.off(EVENT_ID_ON_PAGE_BACKGROUND);
  }

  onPageHide(): void {
    LogUtil.info(`${TAG} onPageHide`);
    this.setSystemBarEnabled(true);
  }

  build() {
    Stack() {
      UIExtensionComponent(this.want,
        {
          placeholder: this.loadingProgress
        })
        .defaultFocus(true)
        .width('100%')
        .height('100%')
        .onError((error) => {
          LogUtil.error(`${TAG} UIExtensionComponent onError ${error?.message}`);
          this.doPageBack();
        })
        .onRelease((releaseCode: number) => {
          LogUtil.error(`${TAG} UIExtensionComponent onRelease, code: ${releaseCode}`);
          this.doPageBack();
        })
        .onTerminated(() => {
          LogUtil.error(`${TAG} UIExtensionComponent onTerminated`);
          this.doPageBack();
        })
        .onDrawReady(() => {
          this.setSystemBarEnabled(false);
        })
        .id('iconSettingPage_extension')
        .onReceive(this.onReceiveData)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }

    .width('100%')
    .height('100%')
  }
}

/**
 * 进入图标调节页面，此页面不分栏全屏显示
 * @param want 需要加载的外部UIExtensionComponent的want参数
 */
export function enterIconSettingPage(want: Want): void {
  router.pushNamedRoute({ name: PAGE_NAME, params: want }, router.RouterMode.Standard, (err) => {
    if (err) {
      LogUtil.error(`${TAG} enterFullPage error:${err.message}`);
      return;
    }
  });
}
