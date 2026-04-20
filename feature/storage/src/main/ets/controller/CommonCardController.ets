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

import { Context } from '@kit.AbilityKit';
import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import { JSON } from '@kit.ArkTS';
import { resourceManager } from '@kit.LocalizationKit';
import rdb from '@ohos.data.rdb';
import { PushParam } from '@ohos/settings.common/src/main/ets/core/controller/Controller';
import { PageRouter } from '@ohos/settings.common/src/main/ets/framework/common/PageRouter';
import { NavEntryKey, UIExtensionFinishType } from '@ohos/settings.common/src/main/ets/utils/Consts';
import { DynamicLoader } from '@ohos/settings.common/src/main/ets/utils/DynamicLoader';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { MemoryMgrUtils } from '@ohos/settings.common/src/main/ets/utils/MemoryMgrUtils';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { StringUtil } from '@ohos/settings.common/src/main/ets/utils/StringUtil';
import { ToastUtil } from '@ohos/settings.common/src/main/ets/utils/ToastUtil';
import { MAX_PROPORTION } from '../constant/StorageConstant';
import { ButtonInfo, CardInfo, ControllerInfo, SummaryParams } from '../model/CardInfo';
import { CardController } from './CardController';

@Sendable
export class CommonCardController extends CardController {
  private queryUri?: string;
  private dataChangeUri?: string;
  private bundleName?: string;
  private abilityName?: string;
  private MAX_ICON_SIZE: number = 512 * 512;

  constructor(controllerInfo: ControllerInfo, proportion: number) {
    super(controllerInfo, proportion);
    if (!controllerInfo) {
      LogUtil.warn(`CommonCardController controllerInfo invalid`);
      return;
    }
    this.queryUri = controllerInfo.queryUri;
    this.dataChangeUri = controllerInfo.dataChangeUri;
    this.bundleName = controllerInfo.bundleName;
    this.abilityName = controllerInfo.abilityName;
  }

  isNeedShow(context: Context): boolean {
    LogUtil.info(`${this.tag} isNeedShow`);
    return this.proportion >= MAX_PROPORTION;
  }

  async createDataShareHelper(context: Context): Promise<dataShare.DataShareHelper | undefined> {
    if (!this.isNeedShow(context)) {
      LogUtil.info(`${this.tag} no need show, not init datashare`);
      return undefined;
    }
    if (!this.queryUri) {
      LogUtil.info(`${this.tag} queryUri is invalid`);
      return undefined;
    }
    LogUtil.info(`${this.tag} queryUri is ${this.queryUri}`);
    try {
      return await dataShare.createDataShareHelper(context, this.queryUri);
    } catch (err) {
      LogUtil.info(`${this.tag} createDataShareHelper: error ${err?.code}  ${err?.message}`);
    }
    return undefined;
  }

  async queryCardInfo(context: Context): Promise<Array<CardInfo>> {
    try {
      let dataShareHelper = await this.createDataShareHelper(context);
      if (!dataShareHelper) {
        LogUtil.warn(`${this.tag} dataShareHelper invalid`);
        return [];
      }
      LogUtil.info(`${this.tag} queryCardInfo start`);
      let start = Date.now();
      let predicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo('needShow', 'true');
      let resultSet = await dataShareHelper.query(this.queryUri, predicates, ['*']);
      let end = Date.now();
      LogUtil.info(`${this.tag} storageData interface cost time ${end - start}`);
      if (resultSet) {
        return this.getListFromResultSet(context, resultSet, dataShareHelper);
      }
    } catch (err) {
      LogUtil.error(`${this.tag} queryCardInfo: error ${err?.code} ${err?.message}`);
    }
    return [];
  }

  private getListFromResultSet(context: Context,
    resultSet: rdb.ResultSet | DataShareResultSet | undefined, dataShareHelper: dataShare.DataShareHelper): CardInfo[] {
    let cardDataList: CardInfo[] = [];
    if (!resultSet) {
      return cardDataList;
    }
    LogUtil.info(`${this.tag} queryCard getListFromResultSet, row count:${resultSet.rowCount}`);
    resultSet.goToFirstRow();
    let resourceManager = ResourceManagerUtil.getResManagerWithContext(this.bundleName, context);
    if (!resourceManager) {
      LogUtil.warn(`${this.tag} resourceManager is null`);
      this.closeDataShareResource(resultSet, dataShareHelper);
      return cardDataList;
    }
    for (let i = 0; i < resultSet.rowCount; i++) {
      let cardInfoValue = resultSet.getString(resultSet.getColumnIndex('cardInfo'));
      let cardInfo: CardInfo;
      try {
        cardInfo = JSON.parse(cardInfoValue) as CardInfo;
      } catch (err) {
        LogUtil.error(`${this.tag} parse cardInfo invalid ${err?.message}`);
        resultSet.goToNextRow();
        continue;
      }
      if (cardInfo?.buttonList && cardInfo.buttonList.length > 2) {
        cardInfo.buttonList = cardInfo.buttonList.slice(0, 2);
      }
      cardInfo.cardName = resultSet.getString(resultSet.getColumnIndex('cardName'));
      if (!this.initCardInfo(cardInfo, resourceManager)) {
        LogUtil.warn(`${this.tag} card info is invalid ${cardInfo.cardName}`);
        resultSet.goToNextRow();
        continue;
      }
      LogUtil.info(`${this.tag} parse cardInfo finish ${cardInfo.cardName}`);
      if (!cardDataList.includes(cardInfo)) {
        cardDataList.push(cardInfo);
      }
      resultSet.goToNextRow();
    }
    MemoryMgrUtils.removeNapiWrap(resourceManager, false);
    this.closeDataShareResource(resultSet, dataShareHelper);
    return cardDataList;
  }

  private closeDataShareResource(resultSet: rdb.ResultSet | DataShareResultSet | undefined,
    dataShareHelper: dataShare.DataShareHelper) {
    resultSet?.close();
    dataShareHelper?.close();
  }

  private initCardInfo(cardInfo: CardInfo, resourceManager: resourceManager.ResourceManager): boolean {
    if (!cardInfo) {
      return false;
    }
    LogUtil.info(`${this.tag} initCardInfo`);
    cardInfo.serviceName = this.bundleName;
    cardInfo.abilityName = this.abilityName;
    if (!cardInfo.icon || !cardInfo.title) {
      LogUtil.warn(`${this.tag} card icon or title is invalid`);
      return false;
    }
    if (!this.initButtonInfo(cardInfo, resourceManager)) {
      LogUtil.warn(`${this.tag} card button is invalid`);
      return false;
    }
    if (!this.initSummary(cardInfo, resourceManager)) {
      LogUtil.warn(`${this.tag} card summary is invalid`);
      return false;
    }
    cardInfo.titleString = this.getString(cardInfo.title, resourceManager);
    if (!cardInfo.titleString) {
      LogUtil.warn(`${this.tag} card titleString is invalid`);
      return false;
    }
    cardInfo.iconImg = this.getIcon(cardInfo.icon, resourceManager);
    if (!cardInfo.iconImg || cardInfo.iconImg.byteLength > this.MAX_ICON_SIZE) {
      LogUtil.warn(`${this.tag} card iconImg is invalid ${cardInfo.iconImg?.byteLength}`);
      return false;
    }
    return true;
  }

  private initSummary(cardInfo: CardInfo, resourceManager: resourceManager.ResourceManager): boolean {
    if (!cardInfo.summary) {
      LogUtil.warn(`${this.tag} cardInfo.summary invalid`);
      return false;
    }
    let params: string[] = [];
    let formatString = this.getString(cardInfo.summary, resourceManager);
    if (!formatString) {
      LogUtil.warn(`${this.tag} get summary invalid`);
      return false;
    }
    let summaryParams = cardInfo.summaryParam;
    if (!summaryParams) {
      cardInfo.summaryString = formatString;
      LogUtil.info(`${this.tag} summaryParams is null, use summary: ${formatString}`);
      return true;
    }
    if (!this.initSummaryParams(summaryParams, params, resourceManager)) {
      LogUtil.warn(`${this.tag} get summaryParams invalid`);
      return false;
    }
    LogUtil.info(`${this.tag} summary is ${formatString}   ${params}`);
    cardInfo.summaryString = ResourceUtil.replaceAnyFormatString(formatString, params);
    return true;
  }

  private initSummaryParams(summaryParams: SummaryParams[], params: string[],
    resourceManager: resourceManager.ResourceManager): boolean {
    for (let index = 0; index < summaryParams.length; index++) {
      let param = summaryParams[index];
      if (param.type === 'string') {
        if (param.value == null) {
          LogUtil.warn(`${this.tag} param value is invalid}`);
          return false;
        }
        params.push(param.value);
        continue;
      }

      if (param.type === 'res') {
        if (!param.value) {
          return false;
        }
        let value = this.getString(param.value, resourceManager);
        if (!value) {
          return false;
        }
        params.push(value);
      }
    }
    return true;
  }

  private initButtonInfo(cardInfo: CardInfo, resourceManager: resourceManager.ResourceManager): boolean {
    if (!cardInfo.buttonList) {
      LogUtil.warn(`${this.tag} no buttonInfo, invalid`);
      return false;
    }
    let result = true;
    cardInfo.buttonList?.forEach(buttonInfo => {
      if (!buttonInfo.button) {
        result = false;
        return;
      }
      buttonInfo.buttonString = this.getString(buttonInfo.button, resourceManager);
      if (!buttonInfo.buttonString) {
        result = false;
      }
    });
    return result;
  }

  getString(id: string, resourceManager: resourceManager.ResourceManager): undefined | string {
    if (!resourceManager || !id) {
      return undefined;
    }
    try {
      let resId = parseInt(id);
      return resourceManager?.getStringSync(resId);
    } catch (err) {
      LogUtil.warn(`${this.tag} getString failed`);
    }
    return undefined;
  }

  private getIcon(id: string, resourceManager: resourceManager.ResourceManager): Uint8Array | undefined {
    if (!resourceManager || !id) {
      return undefined;
    }
    try {
      let resId = parseInt(id);
      return resourceManager.getMediaContentSync(resId);
    } catch (err) {
      LogUtil.warn(`${this.tag} getString failed`);
    }
    return undefined;
  }

  async registerDataChange(dataShareHelper: dataShare.DataShareHelper,
    callback: (cardInfos?: CardInfo[], cardController?: CardController) => void, context: Context): Promise<void> {
    LogUtil.info(`${this.tag} registerOnDataChange ${this.dataChangeUri}`);
    if (!dataShareHelper) {
      return;
    }
    if (StringUtil.isEmpty(this.dataChangeUri)) {
      return;
    }
    dataShareHelper.on('dataChange', this.dataChangeUri, () => {
      LogUtil.info(`${this.tag} onDataChange`);
      callback();
    });
  }

  async unRegisterDataChange(dataShareHelper: dataShare.DataShareHelper): Promise<void> {
    LogUtil.info(`${this.tag} unRegisterDataChange ${this.dataChangeUri}`);
    if (!dataShareHelper) {
      return;
    }
    if (StringUtil.isEmpty(this.dataChangeUri)) {
      return;
    }
    dataShareHelper.off('dataChange', this.dataChangeUri);
  }

  async clickButton(context: Context, buttonInfo: ButtonInfo, cardInfo: CardInfo, pathInfos: NavPathStack,
    navigationMode: boolean, callback: ((isShow: boolean, cardInfo?: CardInfo) => void)): Promise<void> {
    LogUtil.info(`${this.tag} clickButton ${buttonInfo.action}`);
    if (!context || !buttonInfo || !buttonInfo.action) {
      LogUtil.warn(`${this.tag} clickButton param invalid`);
      return;
    }
    if (buttonInfo.action === 'call') {
      this.clickButtonByCallUri(context, buttonInfo, cardInfo, callback);
    } else if (buttonInfo.action === 'router') {
      this.clickButtonByRouterUri(buttonInfo, cardInfo, pathInfos, navigationMode);
    } else {
      LogUtil.info(`${this.tag} action invalid`);
    }
  }

  private clickButtonByRouterUri(buttonInfo: ButtonInfo, cardInfo: CardInfo, pathInfos: NavPathStack,
    navigationMode: boolean): void {
    LogUtil.info(`${this.tag} clickButtonByRouterUri ${buttonInfo.routerUri}`);
    if (!buttonInfo.routerUri) {
      return;
    }
    let pushParam = new PushParam(buttonInfo.actionParams);
    pushParam.finishType = UIExtensionFinishType.IGNORE_SPLIT_SEND_POP;
    if (buttonInfo.routerUri === 'common_page') {
      if (!cardInfo.serviceName || !cardInfo.abilityName) {
        return;
      }
      pushParam.bundleName = cardInfo.serviceName;
      pushParam.abilityName = cardInfo.abilityName;
      this.clickButtonToCommonPage(pushParam);
      return;
    }

    // 云空间使用旧框架跳转
    DynamicLoader.getInstance().fire(buttonInfo.routerUri).then(() => {
      pathInfos?.pushPathByName(buttonInfo.routerUri, pushParam, navigationMode);
    });
  }

  private clickButtonToCommonPage(pushParam: PushParam): void {
    PageRouter.push(NavEntryKey.COMMON_PAGE, pushParam);
  }

  private async clickButtonByCallUri(context: Context, buttonInfo: ButtonInfo, cardInfo: CardInfo,
    callback: ((isShow: boolean, cardInfo?: CardInfo) => void)): Promise<void> {
    LogUtil.info(`${this.tag} clickButtonByCallUri`);
    if (!buttonInfo.callUri) {
      LogUtil.warn(`${this.tag} button uri is invalid`);
      return;
    }
    let dataShareHelper = await dataShare.createDataShareHelper(context, buttonInfo.callUri);
    LogUtil.info(`${this.tag} getdatashare succeed`);
    let resultSet =
      await dataShareHelper.query(buttonInfo.callUri, new dataSharePredicates.DataSharePredicates(), ['*']);
    LogUtil.info(`${this.tag} getdresultSet  succeed`);
    if (!resultSet) {
      LogUtil.warn(`${this.tag} resultSet invalid`);
      this.closeDataShareResource(resultSet, dataShareHelper);
      return;
    }
    if (!resultSet.goToFirstRow()) {
      LogUtil.info(`${this.tag} resultSet data is empty`);
      this.closeDataShareResource(resultSet, dataShareHelper);
      return;
    }
    let res = resultSet.getString(resultSet.getColumnIndex('toast'));
    LogUtil.info(`${this.tag} showToast ${res}`);
    if (res) {
      ToastUtil.showToast(res, ToastUtil.SHORT_DURATION);
    }
    let needShow = resultSet.getString(resultSet.getColumnIndex('needShow'));
    if (needShow === 'false') {
      callback(false);
    }
    this.closeDataShareResource(resultSet, dataShareHelper);
  }
}