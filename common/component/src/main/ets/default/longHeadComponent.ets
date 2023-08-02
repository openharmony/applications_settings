/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and limitations
 * under the License.
 */
import ComponentConfig from './ComponentConfig';
import Router from '@system.router';

/**
 * long head custom component
 */
@Component
export default struct LongHeadComponent {
  private isActive: boolean= true;
  private icBackIsVisibility: boolean= true;
  private longHeadName: string | Resource = '';

  build() {
    Row() {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.ic_back'))
          .height($r('app.float.wh_value_24'))
          .width($r('app.float.wh_value_24'))
          .fillColor($r('sys.color.ohos_id_color_primary'))
      }
      .margin({ right: $r('app.float.wh_value_12') })
      .backgroundColor($r('app.color.color_00000000_transparent'))
      .visibility(this.icBackIsVisibility ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        Router.back();
      })

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Text(this.longHeadName)
          .fontSize($r('app.float.head_font_24'))
          .fontColor($r('app.color.font_color_182431'))
          .lineHeight($r('app.float.wh_value_0'))
          .fontWeight(FontWeight.Bold)
          .maxLines(ComponentConfig.MAX_LINES_3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('90%')
          .textAlign(TextAlign.Start);
      }
      .width(ComponentConfig.WH_100_100)
      .height($r('app.float.wh_value_56'))
      .width('90%')
    }
    .width(ComponentConfig.WH_100_100)
    .padding({ left: $r('app.float.wh_value_30') })
    .height($r('app.float.wh_value_56'))
    .alignItems(VerticalAlign.Center)
    .align(Alignment.Center)
  }
}