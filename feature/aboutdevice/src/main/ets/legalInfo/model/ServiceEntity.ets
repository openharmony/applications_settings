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

import Want from '@ohos.application.Want';
import { StringUtil } from '../util/StringUtil';
/* instrument ignore file */
import { ArrayUtil } from '../util/ArrayUtil';

/**
 * 服务申明模型
 * @since 2023-09-15
 */
export class ServiceEntity {
  /**
   * 服务类型
   */
  public serviceType: string = '';
  /**
   * 服务申明名称
   */
  public serviceName: string = '';
  /**
   * 包名
   */
  public packageName: string = '';
  /**
   * 模块名
   */
  public moduleName: string = '';
  /**
   * 显示检查规则
   */
  public validatorList: Array<string> = [];
  /**
   * 勾选状态规则
   */
  private checkboxList: Array<string> = [];
  /**
   * 数据存储规则
   */
  private saveDataList: Array<string> = [];
  /**
   * 标题
   */
  private title: string = '';
  /**
   * 内容
   */
  private content: string = '';
  /**
   * 版本
   */
  private version: number = 0.0;
  /**
   * 参数
   */
  private params: Map<string, string> = new Map<string, string>();
  /**
   * abilities
   */
  private abilities: Map<string, Want> = new Map<string, Want>();
  /**
   * 是否可见
   */
  private isVisible: boolean = false;
  /**
   * 是否选中
   */
  private isChecked: boolean = false;
  /**
   * 服务content是否超长展开（3行）
   */
  private isExpanded: boolean = false;

  /**
   * 获取名称
   */
  getServiceName(): string {
    return this.serviceName;
  }

  setServiceName(serviceName: string): void {
    this.serviceName = serviceName;
  }

  /**
   * 获取包名
   */
  getPackageName(): string {
    return this.packageName;
  }

  setPackageName(packageName: string): void {
    this.packageName = packageName;
  }

  /**
   * 获取模块名
   */
  getModuleName(): string {
    return this.moduleName;
  }

  setModuleName(moduleName: string): void {
    this.moduleName = moduleName;
  }

  /**
   * 获取显示检查规则
   */
  getValidatorList(): Array<string> {
    return this.validatorList;
  }

  setValidatorList(validatorList: Array<string>): void {
    this.validatorList = validatorList;
  }

  /**
   * 获取勾选状态规则
   */
  getCheckboxList(): Array<string> {
    return this.checkboxList;
  }

  setCheckboxList(checkboxList: Array<string>): void {
    this.checkboxList = checkboxList;
  }

  /**
   * 获取存储数据规则
   */
  getSaveDataListList(): Array<string> {
    return this.saveDataList;
  }

  setSaveDataListList(saveDataList: Array<string>): void {
    this.saveDataList = saveDataList;
  }

  /**
   * 获取标题
   */
  getTitle(): string {
    return this.getShowString(this.title);
  }

  /**
   * 设置标题
   * @param title 标题
   */
  setTitle(title: string): void {
    this.title = title;
  }

  /**
   * 获取内容
   */
  getContent(): string {
    return this.getShowString(this.content);
  }

  /**
   * 设置内容
   * @param content 内容
   */
  setContent(content: string): void {
    this.content = content;
  }

  /**
   * 获取版本号
   */
  getVersion(): number {
    return this.version;
  }

  /**
   * 设置版本号
   * @param version 版本号
   */
  setVersion(version: number): void {
    this.version = version;
  }

  /**
   * 增加参数
   * @param param 参数
   */
  addParamValue(paramKey: string, paramValue: string): void {
    if (this.params === null) {
      this.params = new Map<string, string>();
    }
    this.params.set(paramKey, paramValue);
  }

  /**
   * 增加跳转ability
   * @param key key值
   * @param want 跳转want对象
   */
  addAbility(key: string, want: Want): void {
    if (this.abilities === null) {
      this.abilities = new Map<string, Want>();
    }
    this.abilities.set(key, want);
  }

  /**
   * 获取指定ability跳转信息
   * @param key 指定ability的key值
   */
  getAbility(key: string | undefined): Want | undefined {
    if (StringUtil.isEmpty(key) || ArrayUtil.isMapEmpty(this.abilities)) {
      return undefined;
    }
    if (key) {
      return this.abilities.get(key);
    } else {
      return undefined;
    }
  }

  /**
   * 获取服务申明类型
   */
  getServiceType(): ServiceType {
    return this.serviceType === 'basic' ? ServiceType.BASIC : ServiceType.ENHANCE;
  }

  /**
   * 获取ability跳转信息
   */
  getAbilities(): Map<string, Want> {
    return this.abilities;
  }

  setServiceType(serviceType: string): void {
    this.serviceType = serviceType;
  }

  /**
   * 获取服务是否可见
   */
  isServiceVisible(): boolean {
    return this.isVisible;
  }

  /**
   * 设置服务的可见性
   * @param isVisible true：可见；false：不可见
   */
  setServiceVisible(isVisible: boolean): void {
    this.isVisible = isVisible;
  }

  /**
   * 获取服务是否勾选
   */
  isServiceChecked(): boolean {
    return this.isChecked;
  }

  /**
   * 设置服务的勾选状态
   * @param isChecked true：勾选；false：不勾选
   */
  setServiceChecked(isChecked: boolean): void {
    this.isChecked = isChecked;
  }

  /**
   * 获取服务content是否超长展开
   */
  isServiceExpanded(): boolean {
    return this.isExpanded;
  }

  /**
   * 设置服务content是否超长展开
   * @param isExpanded true：展开；false：收缩
   */
  setServiceExpanded(isExpanded: boolean): void {
    this.isExpanded = isExpanded;
  }

  private getShowString(str: string): string {
    if (this.isMapEmpty(this.params)) {
      return str;
    }
    this.params.forEach((paramValue, paramKey) => {
      let key = '${' + paramKey + '}';
      let index = str.indexOf(key);
      while (index >= 0) {
        str = str.replace(key, paramValue);
        index = str.indexOf(key);
      }
    });
    return str;
  }

  /**
   * 判断map是否为空
   * @param map map
   */
  private isMapEmpty<K, V>(map: Map<K, V> | undefined | null): boolean {
    return map === null || map === undefined || map.size === 0;
  }
}

/**
 * 服务申明类型
 */
export enum ServiceType {
  /**
   * 基础协议
   */
  BASIC = 1,

  /**
   * 增强协议
   */
  ENHANCE = 2,
}