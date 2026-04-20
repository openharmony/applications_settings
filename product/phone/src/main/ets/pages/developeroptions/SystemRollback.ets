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

import { systemParameterEnhance } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import brightness from '@ohos.brightness';
import Settings from '@ohos.settings';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageLifecycleOwner } from '@ohos/settings.common/src/main/ets/core/lifecycle/Lifecycle';
import { PageRoot } from '@ohos/settings.common/src/main/ets/core/viewmodel/PageViewModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { Params, PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { WindowManager } from '@ohos/settings.common/src/main/ets/window/WindowManager';

/* instrument ignore file */
const TAG: string = 'SystemRollback : ';
const OUC_CODE_SCREEN_ON_TIME: number = 1000 * 60 * 90; // 息屏定时时间
const SCREEN_ON_TIME: number = 1000 * 25; // 降亮度间隔时间
const BACKUP_OPEN_KEEP_SCREEN_ON_CODE = 108; // 备份发送的屏幕常亮消息
const BACKUP_CLOSE_KEEP_SCREEN_OFF_CODE = 109; // 关闭屏幕常亮消息
const TIMER_RESET = -1; // 定时器重置

@Builder
export function SystemRollbackLoader($$: Params): void {
  SystemRollback({ params: $$ as Object as PushParam });
}

@Component
export struct SystemRollback {
  pageRoot: PageRoot = new PageRoot(new PageLifecycleOwner());
  @State params: PushParam | null = null;
  @Consume('pathInfos') pathInfos: NavPathStack;
  uiExtensionProxy?: UIExtensionProxy;
  title: string = ResourceUtil.getStringSync($r('app.string.system_rollback'));
  private timerId: number = -1;
  private timerScreen: number = -1;
  private initBrightness: number = -1;
  private isBackupIng: boolean = false;
  private isBackupEnd: boolean = false;

  build() {
    NavDestination() {
      UIExtensionComponent({
        bundleName:'com.ohos.ouc',
        abilityName:'com.ohos.ouc.RollbackAbility',
        parameters: {
          'ability.want.params.uiExtensionType': 'sys/commonUI',
          'externalInfo': (this.params?.config as Record<string, object>)?.externalInfo,
        },
      })
        .defaultFocus(true)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onRemoteReady((proxy) => {
          this.uiExtensionProxy = proxy;
        })
        .onReceive((data) => {
          if (data.code === BACKUP_OPEN_KEEP_SCREEN_ON_CODE) {
            this.isBackupIng = true;
            this.wakeUpAndKeepScreen();
          }
          if (data.code === BACKUP_CLOSE_KEEP_SCREEN_OFF_CODE) {
            this.isBackupIng = false;
            this.isBackupEnd = true;
            clearTimeout(this.timerScreen);
            this.timerScreen = TIMER_RESET;
            clearTimeout(this.timerId);
            this.timerId = TIMER_RESET;
            this.releaseKeepScreenOn();
          }
          LogUtil.info(`${TAG} UIExtensionComponent onReceive data:${JSON.stringify(data)}`);
        })
        .onRelease((data)=>{
          this.pathInfos.pop();
          LogUtil.info(`${TAG} UIExtensionComponent pop`);
        })
        .size({ width: '100%', height: '100%' });
    }
    .hideTitleBar(true)
    .title(this.title)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      this.onPageShow();
    })
    .onTouch(() => {
      if (this.isBackupIng === true) {
        this.setScreenBrightness(this.initBrightness);
        this.startScreenTimer();
      }
    })
    .onHidden(() => {
      this.onPageHide();
    });
  }

  private setScreenBrightness(value: number): void {
    try {
      brightness.setValue(value);
      LogUtil.info(`${TAG} brightness setValue ${value}`);
    } catch (err) {
      LogUtil.error(`${TAG} brightness setValue fail`);
    }
  }

  private startScreenTimer(): void {
    if (this.timerScreen !== TIMER_RESET) {
      clearTimeout(this.timerScreen);
      this.timerScreen = TIMER_RESET;
    }
    this.timerScreen = setTimeout(() => {
      this.setScreenBrightness(0);
    }, SCREEN_ON_TIME);
  }

  private wakeUpAndKeepScreen(): void {
    LogUtil.info(`${TAG} wakeUpAndKeepScreen`);
    WindowManager.setKeepScreenOn((AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage), true);

    this.initBrightness = this.getDeviceBrightness();
    LogUtil.info(`${TAG} initBrightness ${this.initBrightness}`);
    this.startScreenTimer();

    if (this.timerId !== TIMER_RESET) {
      clearTimeout(this.timerId);
      this.timerId = TIMER_RESET;
    }
    this.timerId = setTimeout(() => {
      LogUtil.info(`${TAG} timerId start`);
      this.releaseKeepScreenOn();
    }, OUC_CODE_SCREEN_ON_TIME);
  }

  private releaseKeepScreenOn(): void {
    LogUtil.info(`${TAG} releaseKeepScreenOn`);
    this.setScreenBrightness(this.initBrightness);
    WindowManager.setKeepScreenOn((AppStorage.get<window.WindowStage>('windowStage') as window.WindowStage), false);
  }

  private getDeviceBrightness(): number {
    if (this.initBrightness !== -1) {
      LogUtil.info(`${TAG} this.initBrightness `);
      return this.initBrightness;
    }
    try {
      const defValue: string = systemParameterEnhance.getSync('const.display.brightness.default');
      const name: string = Settings.display.SCREEN_BRIGHTNESS_STATUS;
      let brightness: string = Settings.getValueSync(getContext(), name, defValue);
      return Number(brightness);
    } catch (err) {
      LogUtil.error(`${TAG} getDeviceBrightness error: ${err?.code}, ${err?.message}`);
    }
    LogUtil.info(`${TAG} getDeviceBrightness`);
    return this.initBrightness;
  }

  aboutToAppear(): void {
    this.initBrightness = this.getDeviceBrightness();
    LogUtil.info(`${TAG} aboutToAppear`);
  }

  aboutToDisappear(): void {
    this.releaseKeepScreenOn();
    clearTimeout(this.timerId);
    clearTimeout(this.timerScreen);
    this.timerScreen = TIMER_RESET;
    this.timerId = TIMER_RESET;
    LogUtil.info(`${TAG} aboutToDisappear`);
  }

  onPageShow(): void {
    if (this.isBackupIng) {
      this.wakeUpAndKeepScreen();
      this.setScreenBrightness(this.initBrightness);
      this.startScreenTimer();
    }
    if (this.isBackupEnd) {
      this.setScreenBrightness(this.initBrightness);
    }
    LogUtil.info(`${TAG} onPageShow`);
  }

  onPageHide(): void {
    if (this.isBackupIng) {
      this.releaseKeepScreenOn();
      clearTimeout(this.timerScreen);
      this.timerScreen = TIMER_RESET;
    }
    LogUtil.info(`${TAG} onPageHide`);
  }
}

