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

import router from '@system.router';
import LogUtil from '../../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { SubHeader } from '../../../../../../../../../common/component/src/main/ets/default/textComponent';
import ConfigData from '../../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import LanguageAndRegionModel from '../../../../model/systemImpl/languageSettings/LanguageAndRegionModel';
import HeadComponent from '../../../../../../../../../common/component/src/main/ets/default/headComponent';
import BasicDataSource from '../../../../../../../../../common/utils/src/main/ets/default/model/BasicDataSource';

/**
 * Home Page of  Select Region
 */
@Entry
@Component
struct SelectRegion {
  @State touchedItemName:string = '';
  private regionList: RegionDataSource = new RegionDataSource(LanguageAndRegionModel.getSystemCountries());
  private TAG = `${ConfigData.TAG} SelectRegion `;

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r('app.string.selectRegion'), isActive: true })

          List(){
            ListItem(){
              SubHeader({ titleContent: $r('app.string.currentRegion') })
            }

            ListItem(){
              CurrentRegion();
            }

            ListItem(){
              SubHeader({ titleContent: $r('app.string.allRegion') })
            }

            ListItem(){
              List(){
                LazyForEach(this.regionList, (item) => {
                  ListItem(){
                    Text(LanguageAndRegionModel.getDisplayRegion(item))
                      .fontSize($r("app.float.font_16"))
                      .lineHeight($r("app.float.wh_value_22"))
                      .fontWeight(FontWeight.Medium)
                      .height($r('app.float.wh_value_48'))
                      .width(ConfigData.WH_100_100)
                      .fontColor(LanguageAndRegionModel.isSystemRegion(item) ? $r("app.color.font_color_007DFF") : $r("app.color.font_color_182431"))
                      .textAlign(TextAlign.Start);
                  }
                  .padding({left: $r("app.float.distance_8"),right: $r("app.float.distance_8")})
                  .borderRadius($r("app.float.radius_20"))
                  .width(ConfigData.WH_100_100)
                  .onClick(() => {
                    LanguageAndRegionModel.setSystemRegion(item);
                    router.back();
                  })
                }, item => item);
              }
              .padding($r('app.float.distance_4'))
              .width(ConfigData.WH_100_100)
              .borderRadius($r('app.float.radius_24'))
              .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
              .divider({
                strokeWidth: $r('app.float.divider_wh'),
                color: $r('sys.color.ohos_id_color_list_separator'),
                startMargin: $r("app.float.distance_8"),
                endMargin: $r("app.float.distance_8")});
            }
          }
          .flexShrink(1)
          .width(ConfigData.WH_100_100)
          .layoutWeight(ConfigData.LAYOUT_WEIGHT_1)
        }
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

  aboutToAppear(){
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }
}

/**
 * Text Component
 */
@Component
struct CurrentRegion {
  @StorageProp('currentRegion') currentRegion: string = LanguageAndRegionModel.getSysDisplayRegion();
  @State isTouched:boolean = false;

  build() {
    Column() {
      Text(this.currentRegion)
        .fontSize($r('app.float.font_16'))
        .lineHeight($r('app.float.wh_value_22'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r("app.color.font_color_007DFF"))
        .margin({ left: $r('app.float.distance_8') })
        .textAlign(TextAlign.Start)
        .height(ConfigData.WH_100_100)
        .width(ConfigData.WH_100_100)
        .borderRadius($r('app.float.radius_20'))
        .linearGradient(this.isTouched ? {
                                           angle: 90,
                                           direction: GradientDirection.Right,
                                           colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
                                         } : {
                                               angle: 90,
                                               direction: GradientDirection.Right,
                                               colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]
                                             })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.isTouched = true;
          }
          if (event.type === TouchType.Up) {
            this.isTouched = false;
          }
        });
    }
    .padding($r('app.float.distance_4'))
    .height($r('app.float.wh_value_56'))
    .borderRadius($r('app.float.radius_24'))
    .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"));
  }
}

/**
 * RegionDataSource For Lazy Loading
 */
class RegionDataSource extends BasicDataSource {
  private regionArray: string[] = [];

  constructor(regionArray: string[]){
    super();
    this.regionArray = regionArray;
  }

  public totalCount(): number {
    return this.regionArray.length;
  }

  public getData(index: number): any {
    return this.regionArray[index];
  }
}
