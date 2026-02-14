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

/* instrument ignore file */
import settings from '@ohos.settings';
import { SettingsDataUtils } from '@ohos/settings.common/src/main/ets/utils/SettingsDataUtils';
import { SettingItemModel } from '@ohos/settings.common/src/main/ets/framework/model/SettingItemModel';
import {
  ContactPolicyRadioController,
  FOCUS_MODE_CALL_MESSAGE_POLICY
} from '../controller/ContactPolicyRadioController';
import { ContactPolicy, ContactPolicyKey } from '../model/IncomingCallParam';

@Styles
function pressedStateStyles() {
  .backgroundColor($r('sys.color.interactive_click'))
}

@Styles
function normalStateStyles() {
  .backgroundColor(Color.Transparent)
}

@Component
struct RadioComponent {
  compId: string = '';
  itemModel?: SettingItemModel | undefined;
  @State controller?: ContactPolicyRadioController = undefined;

  aboutToAppear(): void {
    this.controller?.init();
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Text(this.controller?.menuTitle)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .flexShrink(0)
            .flexGrow(1)
        }
          Radio({
            value: this.compId,
            group: 'dormancy_dialog_group'
          })
            .checked(this.controller?.isChecked ? true : false)
            .onChange((isChecked: boolean) => {
              if (this.controller) {
                this.controller.isChecked = isChecked;
              }
            })
            .radioStyle({
              checkedBackgroundColor: $r('sys.color.brand')
            })
            .margin({ right: $r('app.float.distance_8') })
            .width($r('app.float.wh_value_20'))
            .constraintSize({ minHeight: $r('app.float.wh_value_20') })
            .hitTestBehavior(HitTestMode.None)
            .id(`contacts_radiomenu_radio_${this.compId}`)
            .visibility(this.controller?.isChecked ? Visibility.Visible : Visibility.None);
        }
      .padding({
        left: $r('sys.float.padding_level4'),
        right: $r('sys.float.padding_level4')
      })
      .constraintSize({ minHeight: $r('app.float.wh_value_48') })
      .borderRadius($r('sys.float.corner_radius_level8'))
      .stateStyles({
        normal: normalStateStyles,
        pressed: pressedStateStyles,
      })
    }
    .onClick((event) => {
      this.controller?.onRadioChange(true);
    })
    .accessibilityGroup(true)
    .accessibilityText(this.controller?.menuTitle)
    .accessibilityDescription((this.controller?.isChecked ? true : false) ? $r('app.string.be_chosen') : $r('app.string.not_selected_click_tips'))
  }
}

@Component
export struct ContactsPolicyComponent {
  private itemModel?: SettingItemModel | undefined;
  private contactPolicy: string = SettingsDataUtils.getSettingsData(
    FOCUS_MODE_CALL_MESSAGE_POLICY, ContactPolicy.ALLOW_FAVORITE_CONTACTS, settings.domainName.USER_PROPERTY);

  @Builder
  itemDividerBuilder(): void {
    Divider()
      .height(px2vp(2))
      .strokeWidth(0.5)
      .color($r('sys.color.comp_divider'))
      .lineCap(LineCapStyle.Square)
      .padding({ left: $r('sys.float.padding_level6'), right: $r('sys.float.padding_level6') })
  }

  build() {
    Column() {
      RadioComponent({
        compId: ContactPolicyKey.FORBID_EVERYONE_KEY,
        itemModel: this.itemModel,
        controller: new ContactPolicyRadioController(ContactPolicyKey.FORBID_EVERYONE_KEY,
          ContactPolicy.FORBID_EVERYONE, this.contactPolicy === ContactPolicy.FORBID_EVERYONE),
      })
      this.itemDividerBuilder()

      RadioComponent({
        compId: ContactPolicyKey.ALLOW_EVERYONE_KEY,
        itemModel: this.itemModel,
        controller: new ContactPolicyRadioController(ContactPolicyKey.ALLOW_EVERYONE_KEY,
          ContactPolicy.ALLOW_EVERYONE, this.contactPolicy === ContactPolicy.ALLOW_EVERYONE),
      })
      this.itemDividerBuilder()

      RadioComponent({
        compId: ContactPolicyKey.ALLOW_EXISTING_CONTACTS_KEY,
        itemModel: this.itemModel,
        controller: new ContactPolicyRadioController(ContactPolicyKey.ALLOW_EXISTING_CONTACTS_KEY,
          ContactPolicy.ALLOW_EXISTING_CONTACTS, this.contactPolicy === ContactPolicy.ALLOW_EXISTING_CONTACTS),
      })
      this.itemDividerBuilder()

      RadioComponent({
        compId: ContactPolicyKey.ALLOW_FAVORITE_CONTACTS_KEY,
        itemModel: this.itemModel,
        controller: new ContactPolicyRadioController(ContactPolicyKey.ALLOW_FAVORITE_CONTACTS_KEY,
          ContactPolicy.ALLOW_FAVORITE_CONTACTS, this.contactPolicy === ContactPolicy.ALLOW_FAVORITE_CONTACTS),
      })
      this.itemDividerBuilder()

      RadioComponent({
        compId: ContactPolicyKey.ALLOW_SPECIFIED_CONTACTS_KEY,
        itemModel: this.itemModel,
        controller: new ContactPolicyRadioController(ContactPolicyKey.ALLOW_SPECIFIED_CONTACTS_KEY,
          ContactPolicy.ALLOW_SPECIFIED_CONTACTS, this.contactPolicy === ContactPolicy.ALLOW_SPECIFIED_CONTACTS),
      })
    }
    .padding({ top: $r('sys.float.padding_level2'),
      bottom: $r('sys.float.padding_level2'),
      left: $r('sys.float.padding_level2'),
      right: $r('sys.float.padding_level2')
    })
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius($r('sys.float.corner_radius_level10'))
  }
}