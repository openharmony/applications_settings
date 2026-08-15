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

import { dataShare, dataSharePredicates, DataShareResultSet } from '@kit.ArkData';
import rdb from '@ohos.data.rdb';
import abilityAccessCtrl from '@ohos.abilityAccessCtrl';
import bundleManager from '@ohos.bundle.bundleManager';
import { resourceManager } from '@kit.LocalizationKit';
import { JSON } from '@kit.ArkTS';
import { MemoryMgrUtils } from '@ohos/settings.common/src/main/ets/utils/MemoryMgrUtils';
import { LogUtil } from '@ohos/settings.common/src/main/ets/utils/LogUtil';
import { ResourceUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceUtil';
import { ResourceManagerUtil } from '@ohos/settings.common/src/main/ets/utils/ResourceManagerUtil';
import { CheckEmptyUtils } from '@ohos/settings.common/src/main/ets/utils/CheckEmptyUtils';
import { SuggestionInfo } from '../model/SuggestionInfo';
import SuggestionUtil from '../util/SuggestionUtil';
import { SuggestionController } from './SuggestionController';

class JumpValue {
  public bundleName?: string;
  public abilityName?: string;
  public routerUri?: string;
  public callUri?: string;
  public actionParams?: string;
}

class StringParams {
  // string和res字段，string直接取值，res根据value作为资源name跨进程获取
  public type?: string;
  public value?: string;
}

class Suggestion {
  public id?: string;
  public cardName?: string;
  public icon?: string;
  public title?: string;
  public titleParam?: Array<StringParams>;
  public titleParams?: Array<StringParams>;
  public summary?: string;
  public summaryParam?: Array<StringParams>;
  public summaryParams?: Array<StringParams>;
  public jumpType?: string;
  public jumpValue?: JumpValue;
  public isHomePageNoNeedShowDesc?: boolean;
}

@Sendable
export class SuggestionDataShareBaseController extends SuggestionController {
  public bundleName: string = '';
  public tag: string = 'SuggestionDataShareBaseController';
  public queryUri: string = '';
  public isProxy: boolean = false;
  private keyNeedShow: string = 'needShow';

  constructor(bundleName: string, queryUri: string, isDataShareProxy?: boolean) {
    super();
    this.bundleName = bundleName;
    this.queryUri = queryUri;
    this.isProxy = isDataShareProxy ? true : false;
  }

  /**
   * 所有在设置显示的提示卡片，如果通过dataShare进行数据存储交互，必须都具有ohos.permission.ACCESS_SYSTEM_SETTINGS权限
   * @returns boolean 返回权限校验结果，是否拥有相应权限
   */
  public checkSuggestionBundlePermission(): boolean {
    const ACCESS_SYSTEM_SETTINGS = 'ohos.permission.ACCESS_SYSTEM_SETTINGS';
    let atManager = abilityAccessCtrl.createAtManager();
    let info = bundleManager.getApplicationInfoSync(this.bundleName,
      bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO);
    let callerTokenId: number = info?.accessTokenId;
    try {
      let grantStatus = atManager?.verifyAccessTokenSync(callerTokenId, ACCESS_SYSTEM_SETTINGS);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        LogUtil.info(`${this.tag} check success, bundle has permission`);
        return true;
      }
    } catch (err) {
      LogUtil.showError(this.tag, `errInfo: ${err?.message}`);
      return false;
    }
    LogUtil.info(`${this.tag} not has permission`);
    return false;
  }

  async getSuggestionListAsync(context: Context): Promise<SuggestionInfo[]> {
    LogUtil.info(`${this.tag} getSuggestionList`);
    if (!this.checkSuggestionBundlePermission()) {
      return [];
    }
    if (CheckEmptyUtils.isEmpty(this.queryUri)) {
      return [];
    }
    let dataShareHelper: dataShare.DataShareHelper | undefined = await this.createDataShareHelperWithRetry(context);
    if (!dataShareHelper) {
      LogUtil.warn(`${this.tag} dataShareHelper invalid`);
      return [];
    }
    try {
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      predicates.equalTo(this.keyNeedShow, 'true');
      let resultSet = await dataShareHelper.query(this.queryUri, predicates, ['*']);
      if (resultSet) {
        return this.getListFromResultSet(context, resultSet, dataShareHelper);
      }
    } catch (err) {
      LogUtil.info(`${this.tag} getSuggestionList: error ${err?.code}  ${err?.message}`);
    }
    return [];
  }

  /**
   * DataShare 首次连接为异步建立，首次查询可能因连接尚未就绪而失败（15700010）。
   * 这里在创建失败时做有限次重试，规避首次连接竞态。
   *
   * @param context 上下文
   * @returns DataShareHelper 实例，失败返回 undefined
   */
  private async createDataShareHelperWithRetry(context: Context): Promise<dataShare.DataShareHelper | undefined> {
    const maxRetry: number = 3;
    const retryInterval: number = 120;
    for (let i = 0; i < maxRetry; i++) {
      try {
        let dataShareHelper: dataShare.DataShareHelper = await dataShare.createDataShareHelper(context, this.queryUri, {
          isProxy: this.isProxy
        } as dataShare.DataShareHelperOptions);
        if (dataShareHelper) {
          return dataShareHelper;
        }
      } catch (err) {
        LogUtil.warn(`${this.tag} createDataShareHelper failed, retry: ${i}, error ${err?.code}  ${err?.message}`);
      }
      await this.delay(retryInterval);
    }
    return undefined;
  }

  private delay(ms: number): Promise<void> {
    return new Promise((resolve: () => void) => {
      setTimeout(() => {
        resolve();
      }, ms);
    });
  }

  private getListFromResultSet(context: Context, resultSet: rdb.ResultSet | DataShareResultSet | undefined,
    dataShareHelper: dataShare.DataShareHelper): SuggestionInfo[] {
    let suggestionList: SuggestionInfo[] = [];
    if (!resultSet) {
      return suggestionList;
    }
    LogUtil.info(`${this.tag} queryCard getListFromResultSet, row count:${resultSet.rowCount}`);
    resultSet.goToFirstRow();
    let resourceManager: resourceManager.ResourceManager | null =
      ResourceManagerUtil.getResManagerWithContext(this.bundleName, context);
    if (!resourceManager) {
      LogUtil.warn(`${this.tag} resourceManager is null`);
      return suggestionList;
    }
    for (let i = 0; i < resultSet.rowCount; i++) {
      let isNeedShow = resultSet.getString(resultSet.getColumnIndex(this.keyNeedShow));
      if (isNeedShow !== 'true') {
        continue;
      }
      let suggestionValue = resultSet.getString(resultSet.getColumnIndex('suggestionInfo'));
      let cardInfo: Suggestion;
      try {
        cardInfo = JSON.parse(suggestionValue) as Suggestion;
      } catch (err) {
        LogUtil.error(`${this.tag} parse cardInfo invalid ${err?.message}`);
        resultSet.goToNextRow();
        continue;
      }
      cardInfo.cardName = resultSet.getString(resultSet.getColumnIndex('cardName'));
      let suggestionInfo: SuggestionInfo | undefined = this.initCardInfo(cardInfo, resourceManager);
      if (!suggestionInfo) {
        resultSet.goToNextRow();
        continue;
      }
      if (!suggestionList.includes(suggestionInfo)) {
        suggestionList.push(suggestionInfo);
      }
      resultSet.goToNextRow();
    }
    MemoryMgrUtils.removeNapiWrap(resourceManager, false);
    resultSet.close();
    dataShareHelper.close()
    LogUtil.info(`${this.tag} parse cardInfo finish ${suggestionList.length}`);
    return suggestionList;
  }

  initCardInfo(cardInfo: Suggestion, resourceManager: resourceManager.ResourceManager): SuggestionInfo | undefined {
    if (!cardInfo.title || !cardInfo.icon) {
      return undefined;
    }
    let titleParams: Array<StringParams> | undefined = cardInfo.titleParam ?? cardInfo.titleParams;
    let summaryParams: Array<StringParams> | undefined = cardInfo.summaryParam ?? cardInfo.summaryParams;
    let suggestionInfo: SuggestionInfo = new SuggestionInfo();
    suggestionInfo.bundleName = this.bundleName;
    suggestionInfo.id = cardInfo.id;
    suggestionInfo.name = cardInfo.cardName;
    suggestionInfo.title = this.getStringWithParams(cardInfo.title, titleParams, resourceManager);
    if (cardInfo.summary) {
      suggestionInfo.desc = this.getStringWithParams(cardInfo.summary, summaryParams, resourceManager);
    }
    suggestionInfo.iconImg = SuggestionUtil.getIconByName(cardInfo.icon, resourceManager);
    suggestionInfo.actionParams = cardInfo.jumpValue?.actionParams;
    suggestionInfo.jumpBundleName = cardInfo.jumpValue?.bundleName;
    suggestionInfo.abilityName = cardInfo.jumpValue?.abilityName;
    suggestionInfo.routerUri = cardInfo.jumpValue?.routerUri;
    suggestionInfo.isHomePageNoNeedShowDesc = cardInfo.isHomePageNoNeedShowDesc ?? !cardInfo.summary;
    return suggestionInfo;
  }

  private getStringWithParams(stringFormatName: string, summaryParams: StringParams[] | undefined,
    resourceManager: resourceManager.ResourceManager): string | undefined {
    if (!stringFormatName) {
      return undefined;
    }
    let stringFormat = SuggestionUtil.getStringByResourceManager(stringFormatName, resourceManager);
    if (stringFormat && summaryParams) {
      let params: string[] = this.getParsedParams(summaryParams, resourceManager);
      return ResourceUtil.replaceAnyFormatString(stringFormat, params);
    }
    return stringFormat;
  }

  private getParsedParams(summaryParams: StringParams[],
    resourceManager: resourceManager.ResourceManager): string[] {
    let params: string[] = [];
    for (let index = 0; index < summaryParams.length; index++) {
      let param = summaryParams[index];
      if (param.type === 'string') {
        if (param.value == null) {
          LogUtil.warn(`${this.tag} param value is invalid}`);
          return [];
        }
        params.push(param.value);
        continue;
      }

      if (param.type === 'res') {
        if (!param.value) {
          return [];
        }
        let value = SuggestionUtil.getStringByResourceManager(param.value, resourceManager);
        if (!value) {
          return [];
        }
        params.push(value);
      }
    }
    return params;
  }
}