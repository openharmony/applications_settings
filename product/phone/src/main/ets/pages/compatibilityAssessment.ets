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

import deviceAttest from '@ohos.deviceAttest'
import ConfigData from '../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../common/component/src/main/ets/default/headComponent';
import LogUtil from '../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import { BusinessError } from '@ohos.base';

const MODULE_TAG = ConfigData.TAG + '.compatibilityAssessment -> ';
/**
 * Compatibility Assessment
 */
@Entry
@Component
struct compatibilityAssessment {
  @State assessmentImage: string = "";
  @State assessmentResult: string = ""
  @State assessmentResultText: string = ""
  @State assessmentIntroduction: string = ""
  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          HeadComponent({ headName: $r("app.string.OpenHarmony_Compatibility_Assessment"), isActive: true });
          Column() {
            Image(this.assessmentImage)
              .height($r("app.float.wh_value_64"))
              .width($r("app.float.wh_value_64"))
              .margin({top: $r("app.float.wh_value_32")})
            Text(this.assessmentResult)
              .fontFamily('HarmonyHeiTi')
              .fontSize($r("app.float.font_20"))
              .fontColor($r("sys.color.ohos_id_color_primary"))
              .fontWeight(FontWeight.Medium)
              .margin({
                top: $r("app.float.wh_value_8"),
              })
            Text(this.assessmentResultText)
              .fontFamily('HarmonyHeiTi')
              .fontSize($r("app.float.font_14"))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontWeight(FontWeight.Medium)
              .margin({
                top: $r("app.float.wh_value_4")
              })
              .align(Alignment.Center)
            Column() {
              Text(this.assessmentIntroduction)
                .fontFamily('HarmonyHeiTi')
                .fontSize($r("app.float.font_14"))
                .fontWeight(FontWeight.Medium)
                .lineHeight("app.float.lineHeight_19")
                .padding({
                  top:$r('app.float.wh_value_12'),
                  left:$r('app.float.wh_value_12'),
                  right:$r('app.float.wh_value_12'),
                  bottom:$r('app.float.wh_value_18')
                })
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            }
            .align(Alignment.Start)
            .borderRadius($r('app.float.radius_16'))
            .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
            .margin({
              top: $r("app.float.wh_value_24"),
            })
          }
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

  aboutToAppear(): void{
    this.assessmentIntroduction = JSON.parse(JSON.stringify($r("app.string.assessmentIntroduction")))
    try {
      deviceAttest.getAttestStatus().then((attestResultInfo) => {
         let authResult = attestResultInfo.authResult
         let softwareResult = attestResultInfo.softwareResult
        if(authResult == 0&&softwareResult == 0){
          this.assessmentResult = JSON.parse(JSON.stringify($r("app.string.assessmentPassed")))
          this.assessmentImage = '/res/image/assessmentPassed-light.svg'
          this.assessmentResultText = JSON.parse(JSON.stringify($r("app.string.assessmentPassedText")))
        }else if(authResult == -2&&softwareResult == -2){
          this.assessmentResult =JSON.parse(JSON.stringify($r("app.string.assessmentQueryFailed")))
          this.assessmentImage = '/res/image/assessmentQueryFailed-light.svg'
          this.assessmentResultText = JSON.parse(JSON.stringify($r("app.string.assessmentQueryFailedText")))
        }else{
          this.assessmentResult =JSON.parse(JSON.stringify($r("app.string.assessmentPassFailed")))
          this.assessmentImage = '/res/image/assessmentPassFailed-light.svg'
          this.assessmentResultText = JSON.parse(JSON.stringify($r("app.string.assessmentPassFailedText")))
        }
        LogUtil.info(MODULE_TAG + "attestResultInfo success"+JSON.stringify(attestResultInfo));
      })
        .catch((error: BusinessError) => {
          this.assessmentResult =JSON.parse(JSON.stringify($r("app.string.assessmentQueryFailed")))
          this.assessmentImage = '/res/image/assessmentQueryFailed-light.svg'
          this.assessmentResultText = JSON.parse(JSON.stringify($r("app.string.assessmentQueryFailedText")))
          LogUtil.info(MODULE_TAG + "assessmentQueryFailed"+error);
        });
    }catch (error){
      this.assessmentResult =JSON.parse(JSON.stringify($r("app.string.assessmentQueryFailed")))
      this.assessmentImage = '/res/image/assessmentQueryFailed-light.svg'
      this.assessmentResultText = JSON.parse(JSON.stringify($r("app.string.assessmentQueryFailedText")))
      LogUtil.info(MODULE_TAG + "assessmentQueryFailed"+error);
    }
  }

}