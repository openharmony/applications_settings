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

import { HtmlParser } from './src/main/ets/legalInfo/parser/HtmlParser';
import { LinkTextParser } from './src/main/ets/legalInfo/parser/LinkTextParser';
import { BoldTextParser } from './src/main/ets/legalInfo/parser/BoldTextParser';
import { IParser } from './src/main/ets/legalInfo/parser/IParser';
import { BaseText, NormalText, BoldText, LinkText } from './src/main/ets/legalInfo/parser//TextModel';
import AppOpenSourceStatementController from './src/main/ets/legalInfo/controller/AppOpenSourceStatementController';

export { WebViewComponent } from './src/main/ets/legalInfo/component/WebViewComponent';

export { AppOpenSourceStatementController };

export { ScreenItemComponent } from './src/main/ets/view/ScreenItemComponent';

export { ConsumerBusinessPrivacyController,
} from './src/main/ets/controller/LegalInfoController';

export { AppInfo } from './src/main/ets/legalInfo/model/AppInfo';

export { AppInfoDataSource } from './src/main/ets/legalInfo/model/AppInfoDataSource';

export { ServiceEntity } from './src/main/ets/legalInfo/model/ServiceEntity';

export { AppLicenseParam } from './src/main/ets/legalInfo/model/type';

export { BaseText, NormalText, BoldText, LinkText };

export { HtmlParser, LinkTextParser, BoldTextParser, IParser };

export { OucAboutDeviceController } from './src/main/ets/controller/OucAboutDeviceController';


