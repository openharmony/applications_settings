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

import wifiManager from '@ohos.wifiManager';
import { Controller } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { SingleChoiceListController } from '@ohos/settings.common/src/main/ets/core/controller/MenuController';
import { extraType, SettingsBaseMenu } from '@ohos/settings.common/src/main/ets/core/model/menu/SettingsMenu';
import { AccessibilityUtils } from '@ohos/settings.common/src/main/ets/utils/AccessibilityUtils';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { SingleChoiceEntryMenu, SingleSelectMenuItem } from '@ohos/settings.uikit/src/main/ets/menus/Menu';
import {
  EAP_PHASE2_NAME_VALUE_MAP,
  EAP_TTLS_PHASE2_NAME_VALUE_MAP,
  WIFI_EAP_CA_CERTIFICATE,
  WIFI_EAP_METHOD,
  WIFI_EAP_SELECT_PHASE2,
  WIFI_EAP_USER_CERTIFICATE,
  WIFI_WAPI_CERT_AS_CERTIFICATE,
  WIFI_WAPI_CERT_USER_CERTIFICATE,
} from '@ohos/settings.wifi/src/main/ets/WifiMenuManager';
import { WifiUtils } from '@ohos/settings.wifi/src/main/ets/WifiUtils';

/* instrument ignore file */
const NONE_SELECT: number = -1;

export class SingleSelectController extends SingleChoiceListController {
  static CreateSingleSelectController(menu: SettingsBaseMenu): Controller {
    return new SingleSelectController(menu);
  }

  public tag: string = 'SingleSelectController :';
  public listenMenuKeyArray: Array<string>;
  public menuList: SingleSelectMenuItem[] = [];
  // 走接口的增量数据
  public incrementalList: SingleSelectMenuItem[] = [];
  public currentSelectedVal: number | string;
  // 初始显示 请选择
  public isNoneSelect: boolean = false;

  constructor(menu: SettingsBaseMenu) {
    super(menu);
    const extra = this.menu.extra as extraType;
    this.listenMenuKeyArray = extra?.listenMenuKeyArray ?? [];
    this.menuList = this.map2Array(extra?.selectMenuNameAndValMap as Map<ResourceStr, number>);
    this.currentSelectedVal = extra?.currentSelectedVal ?? this.menuList[0]?.key as number;
    // 如果没有默认值 置为-1
    this.isNoneSelect = extra?.isNoneSelect as boolean;
    if (this.isNoneSelect) {
      this.currentSelectedVal = NONE_SELECT
    }
  }

  public getObserverKey = (): string => {
    return this.menu?.key ?? '';
  }

  aboutToAppear(): void {
    super.aboutToAppear();
    if (this.getLogKey() === WIFI_EAP_CA_CERTIFICATE || this.getLogKey() === WIFI_WAPI_CERT_AS_CERTIFICATE) {
      this.updateCACertificate();
    }
    if (this.getLogKey() === WIFI_EAP_USER_CERTIFICATE || this.getLogKey() === WIFI_WAPI_CERT_USER_CERTIFICATE) {
      this.updateUserCertificate();
    }
  }

  aboutToDisappear(): void {
    super.aboutToDisappear();
  }

  /**
   * 获取用户安装得CA证书转成选项
   */
  private async updateCACertificate(): Promise<void> {
    const certList = await WifiUtils.getAllUserTrustedCertificates();
    LogUtil.info(`${this.tag} getAllUserTrustedCertificates length:${certList.length}`);
    this.incrementalList = certList.map(it => ({
      title: it.certAlias,
      isSelect: false,
      key: it.uri,
    } as SingleSelectMenuItem));
    this.updateStatus();
  }

  /**
   * 获取用户安装得用户凭据转成选项
   */
  private async updateUserCertificate(): Promise<void> {
    const credentialList = await WifiUtils.getAllSystemAppCertificates();
    LogUtil.info(`${this.tag} getAllSystemAppCertificates length:${credentialList.length}`);
    this.incrementalList = credentialList.map(it => ({
      title: it.alias,
      isSelect: false,
      key: it.keyUri,
    } as SingleSelectMenuItem));
    this.updateStatus();
  }

  /**
   * map枚举转数组
   */
  private map2Array = (map: Map<ResourceStr, number>): SingleSelectMenuItem[] => {
    return map ? Array.from(map).map(arr => ({
      title: arr[0],
      isSelect: false,
      key: arr[1],
    } as SingleSelectMenuItem)) : [];
  }

  registerDataChange(): void {
    LogUtil.info(`${this.tag} registerDataChange`);
    this.listenMenuKeyArray.forEach(key => {
      this.registerControllerDataChange(key);
    });
  }

  unRegisterDataChange(): void {
    LogUtil.info(`${this.tag} unRegisterDataChange`);
    this.listenMenuKeyArray.forEach(key => {
      this.unRegisterControllerDataChange(key);
    });
  }

  onRegisteredByObserver(observerKey: string): void {
    if (this.currentSelectedVal !== NONE_SELECT) {
      this.publishDataChange(this.currentSelectedVal);
    }
  }

  onDataChange(fromKey: string, data: number): void {
    LogUtil.info(`${this.tag} onDataChange, fromKey: ${fromKey}`);
    // 当eap切换的时候 更新选择列表 和初始值
    if (this.getLogKey() === WIFI_EAP_SELECT_PHASE2 && fromKey === WIFI_EAP_METHOD && typeof data === 'number') {
      if (data === wifiManager.EapMethod.EAP_TTLS) {
        this.menuList = this.map2Array(EAP_TTLS_PHASE2_NAME_VALUE_MAP);
        this.currentSelectedVal = this.menuList[0]?.key as number;
        this.updateStatus();
      }
      if (data === wifiManager.EapMethod.EAP_PEAP) {
        this.menuList = this.map2Array(EAP_PHASE2_NAME_VALUE_MAP);
        this.currentSelectedVal = this.menuList[0]?.key as number;
        this.updateStatus();
      }
    }
  }

  onSelectMenuChanged(key: number): void {
    LogUtil.info(`${this.tag} onSelectMenuChanged data = ${key}`);
    this.currentSelectedVal = key;
    this.updateStatus();
  }

  updateStatus(): void {
    if (CheckEmptyUtils.isEmptyArr(this.menuList)) {
      LogUtil.error(`${this.tag} menuList is null.`);
      return;
    }
    if (this.menu instanceof SingleChoiceEntryMenu) {
      this.menu.singleChoiceData = [...this.menuList, ...this.incrementalList];
      for (let item of this.menu.singleChoiceData) {
        item.isSelect = item?.key === this.currentSelectedVal;
      }
      this.menu.state = this.menu.singleChoiceData.find(it => it.key === this.currentSelectedVal)?.title ||
      $r('app.string.please_select');
    }
    this.refreshUi();
    if (this.currentSelectedVal !== NONE_SELECT) {
      this.publishDataChange(this.currentSelectedVal);
    }
  }
}