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

import { CardInfo, SuggestionConfig } from '../model/SuggestionConfig';

/**
 * 外部建议 Provider 接入项，与 DataShare ExtensionAbility 声明保持一致。
 */
export class SuggestionAccessorItem {
  public bundleName: string = '';
  public queryUri: string = '';
  public isProxy?: boolean;

  constructor(bundleName: string, queryUri: string, isProxy?: boolean) {
    this.bundleName = bundleName;
    this.queryUri = queryUri;
    this.isProxy = isProxy;
  }
}

/**
 * SettingsSuggestionDemo 及后续 Provider 的对接配置。
 */
export class SuggestionAccessorConfig {
  public static readonly DEMO_BUNDLE_NAME: string = 'com.example.settingsSuggestion';
  // 消费侧 createDataShareHelper/query 的 URI 必须为三斜杠形式（datashare:///），
  // 第三个斜杠是 deviceId 占位符；两斜杠会被系统 QueryExtensionAbilityInfoByUri 判为 invalid uri。
  // scheme 大小写需与 Demo module.json5 注册的 extension uri 保持一致（dataShare）。
  public static readonly DEMO_QUERY_URI: string =
    'dataShare:///com.example.settingsSuggestion.dataprovider.SuggestionDataShare';
  public static readonly DEMO_CARD_NAME: string = 'demo';

  public static getAccessorList(): SuggestionAccessorItem[] {
    let accessorList: SuggestionAccessorItem[] = [];
    accessorList.push(new SuggestionAccessorItem(
      SuggestionAccessorConfig.DEMO_BUNDLE_NAME,
      SuggestionAccessorConfig.DEMO_QUERY_URI
    ));
    return accessorList;
  }

  /**
   * 设备未部署 etc/settings/setting_homepage_suggestion.json 时的兜底 CCM 配置。
   */
  public static getDefaultCcmConfig(): SuggestionConfig {
    let config: SuggestionConfig = new SuggestionConfig();
    config.silentTime = 86400000;
    config.longestShowTime = 259200000;
    let cardInfo: CardInfo = new CardInfo();
    cardInfo.cardName = SuggestionAccessorConfig.DEMO_CARD_NAME;
    cardInfo.bundleName = SuggestionAccessorConfig.DEMO_BUNDLE_NAME;
    cardInfo.priority = 1;
    let cardInfoList: CardInfo[] = [];
    cardInfoList.push(cardInfo);
    config.cardInfoList = cardInfoList;
    return config;
  }

  public static getDefaultCcmConfigStr(): string {
    return JSON.stringify(SuggestionAccessorConfig.getDefaultCcmConfig());
  }
}
