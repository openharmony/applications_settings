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

import {
  HotspotSummaryStyle,
  CardMenuSection,
  SummaryTextStyle,
  HeaderPage,
  CardSectionSpecifyDividerStyle,
} from '@ohos/settings.uikit';
import { PageUrl } from '../../PageUrl';
import { TextStyle, ContainerStyle, MenuGroup } from '@ohos/settings.common';
import { DefaultPaymentController } from '../controller/DefaultPaymentController'

export class AboutHotspotSummaryContainerStyle extends ContainerStyle {
  public padding: Padding = {
    left: $r('sys.float.ohos_id_default_padding_start'),
    top: $r('app.float.distance_24'),
    bottom: $r('app.float.distance_24'),
  };
}

export class AboutHotspotSummaryTextStyle extends SummaryTextStyle {
  public fontColor: ResourceColor = $r('app.color.color_summary_black');
  public opacity = $r('app.float.opacity_0_6');
}

export class AboutHotspotSummaryStyle extends HotspotSummaryStyle {
  public rootContainer?: ContainerStyle = new AboutHotspotSummaryContainerStyle();
  public title?: TextStyle = new AboutHotspotSummaryTextStyle();
}

let homePageCardSectionSpecifyDividerStyle = new CardSectionSpecifyDividerStyle('62vp', '14vp');


/**
 * 默认NFC页面数据
 *
 * @since 2023-12-14
 */

export class DefaultPaymentApplicationPage extends HeaderPage {
  constructor() {
    super({
      pageUrl: PageUrl.DEFAULT_PAYMENT_APPLICATION_URL,
      title: $r('app.string.nfc_default_payment_text'),
      isNavigation: true,
      showHeader: false,
    });
    this.addMenus([
      new CardMenuSection(
        {
          key: 'default_payment_app',
          index: 300,
          controller: {
            createControllerConstructorInter: DefaultPaymentController.CreateDefaultPaymentController,
          },
          style: homePageCardSectionSpecifyDividerStyle,
        },
        []
      )
    ]);

  }
}



