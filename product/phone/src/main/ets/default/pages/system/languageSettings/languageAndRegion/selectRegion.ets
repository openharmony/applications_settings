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
import router from '@system.router';
import LogUtil from '../../../../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil.ets';
import ConfigData from '../../../../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData.ets';
import HeadComponent from '../../../../../../../../../../common/component/src/main/ets/default/headComponent.ets';
import BasicDataSource from '../../../../../../../../../../common/utils/src/main/ets/default/model/BasicDataSource.ets';
import LanguageAndRegionModel from '../../../../../default/model/systemImpl/languageSettings/LanguageAndRegionModel.ets'


/**
 * Home Page of  Select Region
 */
@Entry
@Component
struct SelectRegion {
  @State touchedItemName:string = '';
  private regionList: RegionDataSource = new RegionDataSource(LanguageAndRegionModel.getSystemCountries());
  private TAG = `${ConfigData.TAG} SelectRegion`;

  build(){
    Column(){
      HeadComponent({ headName: $r('app.string.selectRegion'), isActive: true })
      List(){
        LazyForEach(this.regionList, (item) => {
          ListItem(){
            Text(LanguageAndRegionModel.getDisplayRegion(item))
              .fontSize($r("app.float.font_28"))
              .height($r("app.float.wh_value_56"))
              .width(ConfigData.WH_100_100)
              .fontColor(LanguageAndRegionModel.isSystemRegion(item) ? $r("app.color.font_color_007DFF") : $r("app.color.font_color_182431"))
              .textAlign(TextAlign.Start);
          }
          .padding({left:$r("app.float.distance_16"),right:$r("app.float.distance_16")})
          .borderRadius($r("app.float.radius_24"))
          .backgroundColor(item === this.touchedItemName ? $r("app.color.color_D8D8D8_grey"):$r("app.color.white_bg_color"))
          .width(ConfigData.WH_100_100)
          .onClick(() => {
            LanguageAndRegionModel.setSystemRegion(item);
            router.back();
          })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.touchedItemName = item;
            }
            if (event.type === TouchType.Up) {
              this.touchedItemName = '';
            }
          })
        }, item => item);
      }
      .divider({strokeWidth: 1, color: $r("app.color.color_E3E3E3_grey"), startMargin:$r("app.float.distance_16"), endMargin:$r("app.float.distance_16")});
    }
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100)
    .backgroundColor($r("app.color.color_E3E3E3_grey"));
  }

  aboutToAppear(){
    LogUtil.info(`${this.TAG} aboutToAppear in`);
    LogUtil.info(`${this.TAG} aboutToAppear out`);
  }

  aboutToDisappear(){
    LogUtil.info(`${this.TAG} aboutToDisappear in`);
    LogUtil.info(`${this.TAG} aboutToDisappear out`);
  }
}


/**
 * RegionDataSource For Lazy Loading
 */
class RegionDataSource extends BasicDataSource {
  private regionArray: string[] = [];

  constructor(regionArray:string[]){
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
