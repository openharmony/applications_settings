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
import { BusinessError } from '@ohos.base';
import commonEventManager from '@ohos.commonEventManager';
import {
  CompCtrlParam,
  ComponentControl,
} from '@ohos/settings.common/src/main/ets/framework/model/SettingBaseModel';
import { ItemResultType } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import {
  notifyCompStateChange,
  SettingResultState,
  SettingStateType
} from '@ohos/settings.common/src/main/ets/framework/model/SettingStateModel';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ProxyUtil } from '../util/ProxyUtil';

const TAG: string = 'ProxySettingController:';

/**
 * 网络页面控制器类
 */
export class ProxySettingController implements ComponentControl {
  private compId: string = '';
  private defaultXGateProxyHost: string = '';
  private useProxy: boolean = false;
  private subscriber: commonEventManager.CommonEventSubscriber | null = null;
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: [commonEventManager.Support.COMMON_EVENT_HTTP_PROXY_CHANGE]
  }

  init(compParam: CompCtrlParam): void {
    LogUtil.info(`${TAG} init`);
    if (!compParam || !compParam.compId) {
      LogUtil.error(`${TAG} init fail, compParam is invalid`);
      return;
    }
    LogUtil.info(`${TAG} init, compId: ${compParam.compId}`);
    this.compId = compParam.compId;
    // 初始化代理开关状态
    ProxyUtil.isHttpProxyEnabled((v: boolean) => {
      LogUtil.info(`${TAG} isHttpProxyEnabled received ${v}`);
      this.useProxy = v;
      this.refreshUi(this.checkState());
    });

    this.defaultXGateProxyHost = ResourceUtil.getStringByName('openharmony_proxy');
    this.subscribeProxyEvent();
  }

  onPageShow(): void {
    LogUtil.info(`${TAG} onPageShow`);
  }

  destroy(): void {
    LogUtil.info(`${TAG} destroy`);
  }

  private checkState(): ResourceStr {
    AppStorage.setOrCreate('useProxy', this.useProxy);
    LogUtil.info(`${TAG} checkState useProxy ${this.useProxy}`);
    return this.useProxy ? $r('app.string.projection_state_on') :
    $r('app.string.projection_state_off');
  }

  private refreshUi(content: ResourceStr): void {
    LogUtil.info(`${TAG} refreshUi ${this.useProxy}`);
    notifyCompStateChange(this.compId,
      new Map<SettingStateType, SettingResultState>([[SettingStateType.STATE_TYPE_ITEM_RESULT,
        { type: ItemResultType.RESULT_TYPE_TEXT, result: { content: content } } as SettingResultState]]));
  }

  private async subscribeProxyEvent(): Promise<void> {
    commonEventManager.createSubscriber(this.subscribeInfo, (err: BusinessError, commonEventSubscriber) => {
      if (err) {
        LogUtil.error(`${TAG} createSubscriber failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      LogUtil.info(`${TAG} createSubscriber success`);
      this.subscriber = commonEventSubscriber;
      commonEventManager.subscribe(this.subscriber, (err: BusinessError, data) => {
        if (err) {
          LogUtil.error(`${TAG} subscribe failed, code is ${err.code}, message is ${err.message}`);
          return;
        }
        LogUtil.info(`${TAG} subscribe success.`);
        if (data !== null) {
          if (data.parameters !== undefined) {
            let dataStr: string = JSON.stringify(data.parameters.HttpProxy);
            let proxyData: string[] = dataStr.substring(1, dataStr.length - 1).split('\\t');
            if (proxyData != null) {
              if (proxyData[0] === '') {
                this.useProxy = false;
                this.refreshUi(this.checkState());
              } else if (proxyData[0] === this.defaultXGateProxyHost) {
                this.useProxy = true;
              } else {
                LogUtil.info(`${TAG} proxyData change subscribed`);
              }
            }
          }
        }
      })
    })
  }
}
