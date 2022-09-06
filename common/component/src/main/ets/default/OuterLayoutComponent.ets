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

import ConfigData from '../../../../../utils/src/main/ets/default/baseUtil/ConfigData';

@Extend(Column) function outerColumnFancy() {
  .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
  .width(ConfigData.WH_100_100)
  .height(ConfigData.WH_100_100)
}

@Extend(GridContainer) function gridContainerFancy() {
  .width(ConfigData.WH_100_100)
  .height(ConfigData.WH_100_100)
}

@Extend(Column) function gridColumnFancy() {
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

@Component
export struct OuterLayoutComponentNoParam {
  @BuilderParam mContentComponentNoParam: () => void;

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          this.mContentComponentNoParam()
        }
        .gridColumnFancy()
      }
      .gridContainerFancy()
    }
    .outerColumnFancy()
  }
}

@Component
export struct OuterLayoutComponentWithParam {
  @BuilderParam mContentComponentWithParam: any;

  build() {
    Column() {
      GridContainer({ gutter: ConfigData.GRID_CONTAINER_GUTTER_24, margin: ConfigData.GRID_CONTAINER_MARGIN_24 }) {
        Column() {
          this.mContentComponentWithParam();
        }
        .gridColumnFancy()
      }
      .gridContainerFancy()
    }
    .outerColumnFancy()
  }
}