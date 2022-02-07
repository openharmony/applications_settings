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
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator.ets';
import ResultComponent from '../../../../../../../common/search/src/main/ets/default/page/resultComponent.ets';
import SearchHeader from '../../../../../../../common/search/src/main/ets/default/page/searchHeader.ets';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import SearchModel from '../../../../../../../common/search/src/main/ets/default/model/SearchModel.ets';
import SearchUtil from '../../../../../../../common/search/src/main/ets/default/common/SearchUtil.ets';
import SearchData from '../../../../../../../common/search/src/main/ets/default/model/SearchData';
import SEARCH_DATA_CONFIG from '../model/search/SearchDataConfig.ets';
import Router from '@system.router'

let SEARCH_INPUT_MAX_LENGTH = 100;

/**
 * search page
 */
@Entry
@Component
struct SearchPage {
  @State @Watch('setSearchKeyword') inputKeyword: string = ''
  @State @Watch('doSearch') searchKeyword: string = ''
  @State searchResultList: SearchData[] = []

  private searchModel: SearchModel;

  build() {
    Column() {
      SearchHeader({ inputKeyword: $inputKeyword })

      if (this.searchKeyword) {

        // search result exist
        if (this.searchResultList && this.searchResultList.length > 0) {

          // search result list
          List() {

            // item
            ForEach(this.searchResultList.map((item1, index1) => {
              return { index: index1, data: item1 }
            }), item => {

              ListItem() {
                Column() {
                  Navigator({ target: item.data.uri }) {
                    ResultComponent({
                      highlightKeyword: $searchKeyword,
                      icon: item.index == 0 ? item.data.icon : '',
                      data: item.data
                    });
                  }

                  if (item.index != (this.searchResultList.length - 1)) {
                    Divider()
                      .strokeWidth(1)
                      .color($r("app.color.color_E3E3E3_grey"))
                      .margin({ left: $r('app.float.wh_value_65') })
                  }
                }
              }
            })
          }
          .width(ConfigData.WH_100_100)
          .layoutWeight(1)
          .alignSelf(ItemAlign.Start)

        } else {

          // search no match
          Text($r('app.string.searchNoResult'))
            .height($r("app.float.search_no_result_height"))
            .fontSize($r('app.float.font_24'))
            .fontColor($r("app.color.color_E3E3E3_grey"))
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Center);
        }
      }
    }
  }

  @Log
  aboutToAppear(): void {

    // init search data
    this.searchModel = new SearchModel(SEARCH_DATA_CONFIG);
    this.searchModel.initSearchData()
      .then(() => {
        LogUtil.debug(ConfigData.TAG + 'searchPage aboutToAppear initSearchData complete');
        this.doSearch()
      })
  }

  @Log
  onBackPress() {
    Router.back();
  }

  /**
   * set search keyword
   */
  @Log
  setSearchKeyword() {
    this.searchKeyword = SearchUtil.stripKeyword(this.inputKeyword).trim()
  }

  /**
   * search
   */
  @Log
  doSearch() {
    this.searchModel.search(this.searchKeyword)
      .then((result: SearchData[]) => {
        LogUtil.debug(ConfigData.TAG + 'searchPage doSearch : search : searchKeyword = ' +
          this.searchKeyword + '; => then data = ' + JSON.stringify(result));
        this.searchResultList = undefined
        this.searchResultList = result
      })
  }
}
