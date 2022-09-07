/**
 * Copyright (c) 2021-2022 Huawei Device Co., Ltd.
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

import SEARCH_DATA_CONFIG from '../model/search/SearchDataConfig';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import SearchData from '../../../../../../common/search/src/main/ets/default/model/SearchData';
import SearchUtil from '../../../../../../common/search/src/main/ets/default/common/SearchUtil';
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import SearchModel from '../../../../../../common/search/src/main/ets/default/model/SearchModel';
import SearchHeader from '../../../../../../common/search/src/main/ets/default/page/searchHeader';
import ResourceUtil from '../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import ResultComponent from '../../../../../../common/search/src/main/ets/default/page/resultComponent';

/**
 * search page
 */
@Entry
@Component
struct SearchPage {
  @State @Watch('setSearchKeyword') inputKeyword: string = '';
  @State @Watch('doSearch') searchKeyword: string = '';
  @State searchResultList: SearchData[][] = [];
  @State data: SearchData = new SearchData();
  private searchModel: SearchModel;
  @State listSpace: string = '12vp';

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          SearchHeader({ inputKeyword: $inputKeyword })

          if (this.searchKeyword) {
            // search result exist
            if (this.searchResultList && this.searchResultList.length > 0) {
              List({ space: this.listSpace }) {
                // search result list
                ForEach(this.searchResultList, (eachBlock) => {
                  ListItem() {
                    List() {
                      // item
                      ForEach(eachBlock.map((item2, index2) => { return { index: index2, data: item2 }}), (item) => {
                        ListItem() {
                          Flex({ alignItems: ItemAlign.Center }) {
                            Navigator({ target: item.data.uri }) {
                              ResultComponent({
                                highlightKeyword: $searchKeyword,
                                icon: item.index == 0 ? item.data.icon : '',
                                data: item.data
                              });
                            }
                          }
                          .padding({
                            top: $r('app.float.wh_value_8'),
                            bottom: $r('app.float.wh_value_8')
                          })
                        }
                        .constraintSize({
                          minHeight: this.data.summary ? $r('app.float.wh_value_64') : $r('app.float.wh_value_56')
                        })
                      })
                    }
                    .padding({ top: $r('app.float.wh_value_4'), bottom: $r('app.float.wh_value_4') })
                    .width(ConfigData.WH_100_100)
                    .divider({
                      strokeWidth: $r('app.float.divider_wh'),
                      color: $r('app.color.color_E3E3E3_grey'),
                      startMargin: $r('app.float.wh_value_52'),
                      endMargin: $r('app.float.wh_value_20')
                    })
                    .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
                    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
                  }
                })
              }
              .width(ConfigData.WH_100_100)
            } else {
              // search no match
              Column() {
                Image($r("app.media.img_search_no_result"))
                  .width($r("app.float.search_no_result_image_size"))
                  .height($r("app.float.search_no_result_image_size"))

                  // search no match
                  Text($r("app.string.searchNoResult"))
                    .fontFamily('HarmonyHeiTi')
                    .fontSize($r("app.float.search_no_result_text_font_size"))
                    .fontColor($r("sys.color.ohos_id_color_tertiary"))
                    .fontWeight(FontWeight.Regular)
                    .lineHeight($r('app.float.wh_value_19'))
                    .alignSelf(ItemAlign.Center);
                }
                .alignItems(HorizontalAlign.Center)
                .margin({ top: $r("app.float.search_no_result_margin_top") })
              }
            }
          }
        .padding({
          left: $r('sys.float.ohos_id_card_margin_start'),
          right: $r('sys.float.ohos_id_card_margin_end')
        })
        .useSizeType({
          sm: { span: 4, offset: 0 },
          md: { span: 6, offset: 1 },
          lg: { span: 8, offset: 2 }
        })
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100)
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
  }

  @Log
  aboutToAppear(): void {
    ResourceUtil.getString($r('app.float.distance_12')).then(value => this.listSpace = value);

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
    LogUtil.info('settings SearchPage onBackPress');
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
        this.searchResultList = undefined;
        this.searchResultList = this.makeViewData(result);
        LogUtil.debug(ConfigData.TAG + 'searchPage doSearch : searchResultList = ' + JSON.stringify(this.searchResultList));
      })
  }

  /**
   * make data for view
   *
   * @param result Search result
   * @return Data for show to view
   */
  @Log
  makeViewData(result: SearchData[]): SearchData[][]  {
    let list: SearchData[][] = [];
    let group: SearchData[] = undefined;

    let lastUri = undefined;
    for (var i = 0; i < result.length; i++) {
      let data = result[i];

      if (data.uri !== lastUri) {
        if (group) {
          let g = group;
          list.push(g);
        }
        group = [];
        lastUri = data.uri;
      }
      group.push(data);

      if (i == result.length - 1) {
        list.push(group);
      }
    }
    return list;
  }
}
