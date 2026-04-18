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

import bundleMonitor from '@ohos.bundle.bundleMonitor';
import { BusinessError } from '@ohos.base';
import nfcController from '@ohos.nfc.controller';
import cardEmulation from '@ohos.nfc.cardEmulation';
import bundleManager from '@ohos.bundle.bundleManager'
import emitter from '@ohos.events.emitter';
import { MemoryMgrUtils } from '@ohos/settings.common/src/main/ets/utils/MemoryMgrUtils';
import { NFCStateChangeListener, NFCUtil } from '@ohos/settings.moreconnection/src/main/ets/NFCUtil';
import { SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
import { DefaultPaymentController } from './DefaultPaymentController';

const DEFAULT_PAY_APP = 'nfc_payment_default_app';
const TAG: string = 'NFCDefaultPaymentAppController : ';

const DEFAULT_PAY_APP_SELECT: number = 300001;

export class NFCDefaultPaymentAppController extends DefaultPaymentController implements NFCStateChangeListener {
  // 应用卸载监听
  private removeCallBack: Callback<bundleMonitor.BundleChangedInfo> =
    (bundleChangeInfo: bundleMonitor.BundleChangedInfo) => {
      LogUtil.info(`${TAG} bundleStatusCallback remove : ${bundleChangeInfo?.bundleName}`);
      this.changState();
    };

  constructor(menu: SettingsBaseMenu) {
    super(menu);
  }

  static createNFCDefaultPaymentAppController(menu: SettingsBaseMenu): Controller {
    return new NFCDefaultPaymentAppController(menu);
  }

  getListenerName(): string {
    return this.menu.key ?? ' ';
  }

  aboutToAppear(): void {
    LogUtil.info(`${TAG} aboutToAppear`);
    super.aboutToAppear();
    NFCUtil.getInstance().start();
    emitter.on({
      eventId: DEFAULT_PAY_APP_SELECT,
    }, () => {
      this.changState()
    });
  }

  aboutToDisappear(): void {
    LogUtil.info(`${TAG} aboutToDisappear`);
    emitter.off(DEFAULT_PAY_APP_SELECT);
  }

  onPageShow() {
    LogUtil.info(`${TAG}  onPageShow`);
    this.changState();
  }

  onNFCStateChange(state: nfcController.NfcState): void {
    LogUtil.info(`${TAG} listener find nfc service isChanged: ${state}`);
    // 底层会返回多个状态值，仅当开、关状态时 进行响应
    if (state === nfcController.NfcState.STATE_OFF || state === nfcController.NfcState.STATE_ON) {
      this.checkNFCState();
      this.refreshUi();
    }
  }

  updateStatus(): void {
    super.updateStatus();
    this.checkNFCState();
    this.changState();
    this.refreshUi();
  }

  private checkNFCState(): void {
    try {
      let state: boolean = nfcController.isNfcOpen();
      LogUtil.info(`${TAG} update nfc service state, state: ${state}`);
      this.menu.enable = state;
      this.refreshUi();
    } catch (err) {
      LogUtil.error(`${TAG} check nfcStatus api failed`);
    }
  }

  private getDefaultNFCApp(curDefaultPayAPPValue: string) {
    try {
      let lastIndex: number = curDefaultPayAPPValue.indexOf('/');
      let bundleName: string = curDefaultPayAPPValue.substring(0, lastIndex);
      let nfcList: bundleManager.AbilityInfo[] = cardEmulation.getPaymentServices();
      let defaultPayAppItem: bundleManager.AbilityInfo | undefined =
        nfcList.find((nfcListItem) => nfcListItem?.bundleName === bundleName);
      if (!defaultPayAppItem) {
        LogUtil.error(`${this.tag} getDefaultNFCApp failed.`);
        this.menu.state = $r('app.string.not_set');
        return;
      }
      const resourceManager = ResourceManagerUtil.getBundleResourceManager(defaultPayAppItem?.bundleName);
      if (!resourceManager) {
        LogUtil.info(`${this.tag} resourceManager is null`);
        return;
      }
      resourceManager.getStringValue(defaultPayAppItem?.labelId).then((defaultNFCApp: string) => {
        LogUtil.info(`${this.tag} current defaultNFCApp is: ${defaultNFCApp}`);
        this.menu.state = defaultNFCApp;
        this.refreshUi();
      }).catch((error: BusinessError) => {
        this.menu.state = $r('app.string.not_set');
        LogUtil.error(`${this.tag} getStringValue error ${error?.message}`);
      })
      MemoryMgrUtils.removeNapiWrap(resourceManager, false);
    } catch (error) {
      LogUtil.error(`${this.tag} getDefaultNFCApp catch error, message:${error?.message}`);
    }
  }

  //操作后的函数
  private changState(): void {
    LogUtil.info(`${this.tag} changState.`);
    let curDefaultPayAPPValue: string = SettingsDataUtils.getSettingsData(DEFAULT_PAY_APP, '');
    this.getDefaultNFCApp(curDefaultPayAPPValue);
    this.refreshUi();
  }

  protected registerDataChange(): void {
    LogUtil.info(`${TAG} registerDataChange`);
    NFCUtil.getInstance().registerStateChangeListener(this);
    try {
      bundleMonitor.on('remove', this.removeCallBack);
    } catch (error) {
      LogUtil.error(`${TAG} bundleMonitor listen remove failed: ${error?.message}`);
    }
  }

  protected unRegisterDataChange(): void {
    LogUtil.info(`${TAG} unRegisterDataChange`);
    NFCUtil.getInstance().unRegisterStateChangeListener(this);
    try {
      bundleMonitor.off('remove', this.removeCallBack);
    } catch (error) {
      LogUtil.error(`${TAG} bundleMonitor listen remove failed: ${error?.message}`);
    }
  }
}
