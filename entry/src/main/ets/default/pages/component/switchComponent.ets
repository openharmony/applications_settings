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
import ConfigData from '../../common/baseUtil/ConfigData.ets';

/**
 * Toggle component
 */
@Component
export default
struct SwitchComponent {
  private isOn: boolean= false;
  private title: '';

  build() {
    Row() {
      Text(this.title)
        .fontSize($r('app.float.font_20'))
        .fontColor(Color.Black)
        .align(Alignment.Start)

      Toggle({ type: ToggleType.Switch, isOn: false })
        .align(Alignment.End)
        .width($r('app.float.wh_value_60'))
        .height($r('app.float.wh_value_40'))

    }
    .width(ConfigData.WH_100_100)
    .height($r('app.float.wh_value_70'))
    .alignItems(VerticalAlign.Center)
    .padding({ left: $r('app.float.wh_value_15'), right: $r('app.float.wh_value_15') })
  }
}