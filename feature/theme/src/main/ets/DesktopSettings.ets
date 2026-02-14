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
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { PageStartModeManager } from '@ohos/settings.common/src/main/ets/window/PageStartModeManager';
import { PushParam, Params } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { EVENT_ID_ICON_SETTING_PAGE_BACKGROUND } from '@ohos/settings.common/src/main/ets/event/types';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import { enterIconSettingPage } from './IconSettingPage';
import { emitter } from '@kit.BasicServicesKit';

const TAG: string = 'DesktopSettings : ';
const UI_EXTENSION_SOURCE: string = 'settingSearch';
const UI_EXTENSION_NAV: string = 'desktopSettingPage';

@Builder
export function DesktopSettingsLoader($$: Params): void {
  if (LogUtil.printBuilderLog(`${TAG} desktop settings loader`)) {
    DesktopSettings({ params: $$ as Object as PushParam });
  }
}

@Component
export struct DesktopSettings {
  uiExtensionProxy?: UIExtensionProxy;
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State params: PushParam | null = null;
  @StorageProp('navigationMode')
  @Watch('onNavigationModeChange') navigationMode: NavigationMode = NavigationMode.Stack;
  @State firstNavigationMode: NavigationMode = NavigationMode.Stack;
  private context = getContext(this) as common.UIAbilityContext;
  isFromExternal: boolean = false;
  want: Want = {
    bundleName: 'com.ohos.sceneboard',
    abilityName: 'HomeThemeComponentExtAbility',
    parameters: {
      'ability.want.params.uiExtensionType': 'sys/commonUI',
      'nav': UI_EXTENSION_NAV,
      'isFull': true,
      'source': UI_EXTENSION_SOURCE,
    }
  }

  build() {
    NavDestination() {
      UIExtensionComponent(this.want)
        .onRemoteReady((proxy) => {
          LogUtil.info(`${TAG} onRemoteReady navigationMode: ${this.navigationMode}`);
          this.uiExtensionProxy = proxy;
          this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
          this.uiExtensionProxy?.on('syncReceiverRegister', () => {
            this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
          });
        })
        .defaultFocus(true)
        .onError((error) => {
          LogUtil.info(`${TAG} UIExtensionComponent onError ${error?.message}`);
        })
        .onReceive((data) => {
          LogUtil.info(`${TAG} UIExtensionComponent onReceive`);
          if (data) {
            if (data['action'] === 'pop') {
              this.pathInfos.pop();
              LogUtil.info(`${TAG} pop`);
            }
          }
          if (data['iconEditPageWant'] !== undefined) {
            LogUtil.info(`${TAG} SCB UIExtension onReceive: IconEditPageWant`);
            enterIconSettingPage(data['iconEditPageWant']);
          }
        })
        .size({ width: '100%', height: '100%' })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .onShown(() => {
      LogUtil.info(`${TAG} NavDestination onShown`);
    })
    .onHidden(() => {
      LogUtil.info(`${TAG} NavDestination onHidden`);
    })
    .onBackPressed(() => {
      if (this.isFromExternal) {
        LogUtil.info(`${TAG} onBackPressed`);
        this.termiteAbility();
        return true;
      }
      return false;
    })
  }

  onNavigationModeChange(): void {
    LogUtil.info(`${TAG} onNavigationModeChange navigationMode: ${this.navigationMode}`);
    this.uiExtensionProxy?.send({ 'navigationMode': this.navigationMode });
  }

  aboutToAppear(): void {
    let nav = this.getTargetSubRouter(this.params);
    if (this.params?.config || this.params?.subUri) {
      this.want.parameters = {
        'ability.want.params.uiExtensionType': 'sys/commonUI',
        'pushParams': (this.params.config || this.params.subUri) as string,
        'startReason': this.params?.startReason ?? PageStartModeManager.getInstance().getStartReason(),
        'nav': nav,
        'isFull': true,
        'source': UI_EXTENSION_SOURCE,
      }
    }
    LogUtil.info(`${TAG} aboutToAppear nav: ${nav}`);
    emitter.on({
      eventId: EVENT_ID_ICON_SETTING_PAGE_BACKGROUND
    }, () => {
      this.pathInfos?.pop();
    })
    this.firstNavigationMode = this.navigationMode;
  }

  /**
   * 获取跳转地址
   *
   * @param pushParams 参数
   * @returns 跳转地址
   */
  private getTargetSubRouter(pushParams: PushParam | null | undefined): string {
    if (pushParams === null || pushParams === undefined) {
      return UI_EXTENSION_NAV;
    }
    let config: string | undefined = undefined;
    if (!CheckEmptyUtils.isEmpty(pushParams?.config) && typeof pushParams?.config === 'string') {
      // 设置搜索会在config后面拼接,isShowBack:false
      LogUtil.info(`${TAG} config`);
      config = pushParams.config.toString();
    }
    let targetSubRouter: string = config ?? (pushParams.subUri ?? '');
    LogUtil.info(`${TAG} targetSubRouter:${targetSubRouter}`);
    targetSubRouter = targetSubRouter?.split(',')[0];
    if (!targetSubRouter) {
      return UI_EXTENSION_NAV;
    }
    return targetSubRouter;
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    emitter.off(EVENT_ID_ICON_SETTING_PAGE_BACKGROUND);
    // 外部页面拉起一步返回
    if (this.isFromExternal) {
      LogUtil.info(`${TAG} from external, teminate ability`);
      this.termiteAbility();
    }
  }

  private termiteAbility(): void {
    this.context.terminateSelf();
  }
}