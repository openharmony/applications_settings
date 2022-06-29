/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
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
import ConfigData from '../../../../../../utils/src/main/ets/default/baseUtil/ConfigData';
import Log from '../../../../../../utils/src/main/ets/default/baseUtil/LogDecorator';
import { BaseData } from '../../../../../../utils/src/main/ets/default/bean/BaseData';
import LogUtil from '../../../../../../utils/src/main/ets/default/baseUtil/LogUtil';
import SearchConfig from '../common/SearchConfig';
import SearchData from '../model/SearchData';
import SearchDataProvider from '../provider/SearchDataProvider';
import BaseParseConfModel from '../../../../../../utils/src/main/ets/default/model/BaseParseConfModel';
import ohosDataRdb from '@ohos.data.rdb';
import featureAbility from '@ohos.ability.featureAbility';

/**
 * Search service class
 */
export default class SearchModel {
  private rdbStore;
  private searchDataConfig;

  constructor(configData: Array<Object>) {
    this.searchDataConfig = configData;
  }

  /**
   * Initialize rdb
   */
  @Log
  private async initRdb(): Promise<void> {
    LogUtil.log('settings initRdb.');

    if (!this.rdbStore) {
      LogUtil.log('settings RDB has not been initialized yet.');

      // database init
      const STORE_CONFIG = { name: SearchConfig.RDB_NAME};
      this.rdbStore = await ohosDataRdb.getRdbStore(globalThis.settingsAbilityContext, STORE_CONFIG, 1);
      LogUtil.log('settings SettingsSearch.db is ready.');

      // table SEARCH_DATA init
      await this.rdbStore.executeSql(SearchConfig.search.DDL_TABLE_CREATE, null);
      LogUtil.log('settings table SEARCH_DATA is ready.');
    }
  }

  /**
   * Initialize search data
   */
  @Log
  public async initSearchData(): Promise<void> {
    const searchData = await this.gatherSearchData();
    await this.initRdbSearchData(searchData);
  }

  /**
   * Search
   *
   * @param query - query content
   */
  @Log
  public async search(query: string): Promise<SearchData[]> {
    if (!query) {
      return []
    }
    query = this.sqlLikeCharReplace(query);
    await this.initRdb();

    // query search data
    let predicates = new ohosDataRdb.RdbPredicates(SearchConfig.search.TABLE_NAME);
    predicates.like(SearchConfig.search.FIELD_KEYWORD, `%${query}%`)
      .or().like(SearchConfig.search.FIELD_SUMMARY, `%${query}%`)
      .or().like(SearchConfig.search.FIELD_SYNONYM, `%${query}%`)
      .orderByAsc(SearchConfig.search.FIELD_URI);

    let resultSet = await this.rdbStore.query(predicates, [
        SearchConfig.search.FIELD_ICON,
        SearchConfig.search.FIELD_TITLE,
        SearchConfig.search.FIELD_KEYWORD,
        SearchConfig.search.FIELD_SUMMARY,
        SearchConfig.search.FIELD_URI
      ]);

    // build search data from resultSet
    let searchData: SearchData[] = [];
    while (resultSet.goToNextRow()) {
      const data = new SearchData();
      data.icon = resultSet.getString(0);
      data.title = resultSet.getString(1);
      data.keyword = resultSet.getString(2);
      data.summary = resultSet.getString(3);
      data.uri = resultSet.getString(4);
      searchData.push(data);
    }
    resultSet.close();
    resultSet = null;

    return searchData;
  }

  /**
   * Handle special characters for sql.like
   *
   * @param query - query content
   */
  @Log
  private sqlLikeCharReplace(query: string): string {
    query = query.replace("[", "/[");
    query = query.replace("]", "/]");
    query = query.replace("/", "//");
    query = query.replace("%", "/%");
    query = query.replace("&", "/&");
    query = query.replace("'", "''");
    query = query.replace("(", "/(");
    query = query.replace(")", "/)");
    query = query.replace("_", "/_");
    return query;
  }

  /**
   * Gather search data from providers
   *
   * @param searchData - search data to be grouped
   */
  @Log
  private async gatherSearchData(): Promise<SearchData[]> {
    // init uriConfigMapping
    const uriConfigMapping = new Map();
    this.searchDataConfig.forEach(config => {
      uriConfigMapping.set(config.settingUri, config);
    })

    // get searchData (note: settingList must be the first)
    let searchData: SearchData[] = await this.getSearchData(this.searchDataConfig[0].settingUri, '', uriConfigMapping);
    LogUtil.log('settings search searchData: ' + JSON.stringify(searchData));

    return searchData;
  }

  /**
   * Initialize rdb search data
   *
   * @param searchData - search data
   */
  @Log
  private async initRdbSearchData(searchData: SearchData[]): Promise<void> {
    LogUtil.log('settings search old data if exists.');
    await this.initRdb();

    // delete old data if exists
    await this.rdbStore.executeSql(SearchConfig.search.SQL_DELETE_ALL, null);
    LogUtil.log('settings search old data if exists.');

    // insert new data into table
    for (let data of searchData) {
      const valueBucket = {};
      valueBucket[SearchConfig.search.FIELD_URI] = data.uri;
      valueBucket[SearchConfig.search.FIELD_ICON] = data.icon;
      valueBucket[SearchConfig.search.FIELD_TITLE] = data.title;
      valueBucket[SearchConfig.search.FIELD_KEYWORD] = data.keyword;
      valueBucket[SearchConfig.search.FIELD_SUMMARY] = data.summary;
      valueBucket[SearchConfig.search.FIELD_SYNONYM] = data.synonym;
      let ret = await this.rdbStore.insert(SearchConfig.search.TABLE_NAME, valueBucket)
      LogUtil.log("settings: search insert data: " + ret)
    }
  }

  /**
   * Get search data
   *
   * @param settingUri - setting uri
   * @param settingIcon - setting icon
   * @param uriConfigMapping - uri config mapping
   */
  @Log
  private async getSearchData(settingUri: string, settingIcon: string, uriConfigMapping: Map<string, any>): Promise<SearchData[]> {
    if (!uriConfigMapping.get(settingUri)) {
      return [];
    }

    // get search data from provider
    const provider: SearchDataProvider = uriConfigMapping.get(settingUri).provider;
    let searchProviderData: SearchData[] = await provider.getSearchData();

    // set uri, icon
    searchProviderData.forEach(providerData => {
      if (!providerData.uri) {
        providerData.uri = settingUri;
      }
      providerData.icon = settingIcon;
    });

    // get setting list
    let settingConfig = ConfigData.FILE_URI.concat(uriConfigMapping.get(settingUri).settingRawJson)
    let settingList: BaseData[] = this.getSettingList(settingConfig);

    // get child page search
    for (const setting of settingList) {
      const icon = settingIcon ? settingIcon : setting.settingIcon;  // higher priority for parent icon
      const childData = await this.getSearchData(setting.settingUri, icon, uriConfigMapping);
      searchProviderData = searchProviderData.concat(childData);
    };

    return searchProviderData;
  }

  /**
   * Get setting list which includes settingUri in each setting
   *
   * @param settingConfig - setting config path
   */
  @Log
  private getSettingList(settingConfig: string): BaseData[] {
    let result = [];

    let settingList: any[] = BaseParseConfModel.getJsonData(settingConfig);
    settingList.forEach(setting => {
      if (setting.settingUri) {
        let baseData = new BaseData();
        baseData.settingIcon = setting.settingIcon;
        baseData.settingUri = setting.settingUri;
        result.push(baseData);
      }
    });

    return result;
  }

}
