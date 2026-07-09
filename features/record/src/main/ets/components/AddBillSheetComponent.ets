/**
 * Copyright (C), 2026-05-18
 * @author ZestBox
 * @date 2026/05/18
 * @version 1.0
 * @description: 新增账单半模态组件
 */

import {
  AccountBean,
  AppThemeState,
  BillBean,
  BillTypeEnum,
  CategoryBean,
  SystemOptions
} from 'base';
import { AccountManager, BillManager, CategoryManager } from 'data_core';
import { curves } from '@kit.ArkUI';
import { CapsuleSegmentButtonV2, SegmentButtonV2Items } from '@ohos.arkui.advanced.SegmentButtonV2';
import { ColorMetrics, LengthMetrics } from '@ohos.arkui.node';

const KEYBOARD_CORNER_RADIUS: number = 22;
const CATEGORY_CARD_SIZE: number = 40;
const KEYBOARD_KEYS_PER_ROW: number = 4;
const ACCOUNT_VIEWPORT_EXPANDED_WIDTH: number = 196;
const ACCOUNT_PILL_HEIGHT: number = 34;
const ACCOUNT_PILL_GAP: number = 12;
const ACCOUNT_COLLAPSE_DELAY: number = 350;
const ACCOUNT_ANIMATION_DURATION: number = 600;
const REMARK_INPUT_ID: string = 'add_bill_sheet_remark_input';
const RECORD_MODE_EXPENSE: string = 'expense';
const RECORD_MODE_INCOME: string = 'income';
const RECORD_MODE_TRANSFER: string = 'transfer';

class CategoryOption {
  id: number = 0;
  label: string = '';
  icon: Resource = $r('sys.symbol.creditcard');
  isSystem: boolean = false;

  constructor(id: number, label: string, icon: Resource, isSystem: boolean = false) {
    this.id = id;
    this.label = label;
    this.icon = icon;
    this.isSystem = isSystem;
  }
}

class KeypadKey {
  label: string = '';
  action: string = '';
  isPrimary: boolean = false;
  isAccent: boolean = false;

  constructor(label: string, action: string, isPrimary: boolean = false, isAccent: boolean = false) {
    this.label = label;
    this.action = action;
    this.isPrimary = isPrimary;
    this.isAccent = isAccent;
  }
}

@ComponentV2
export struct AddBillSheetComponent {
  @Require @Param themeState: AppThemeState;
  @Require @Param optionSystem: SystemOptions;
  @Param editingBillId: number = 0;
  @Event onClose: () => void = () => {
  };
  @Event onSaved: () => void = () => {
  };
  @Event onManageCategory: () => void = () => {
  };

  @Local amountText: string = '0';
  @Local activeMode: string = RECORD_MODE_EXPENSE;
  @Local selectedType: string = BillTypeEnum.EXPENSE;
  @Local selectedCategory: string = '餐饮';
  @Local selectedAccount: string = '';
  @Local targetAccount: string = '';
  @Local remarkText: string = '';
  @Local isSaving: boolean = false;
  @Local selectedDate: number = Date.now();
  @Local isRemarkExpanded: boolean = false;
  @Local isAccountSelectorVisible: boolean = false;
  @Local isAccountSelectorExpanded: boolean = false;
  @Local isAccountSelectorClosing: boolean = false;
  @Local accountOptions: string[] = [];
  @Local isDateSheetVisible: boolean = false;
  @Local dateDraft: number = Date.now();
  @Local expenseCategories: CategoryOption[] = [];
  @Local incomeCategories: CategoryOption[] = [];

  private scroller: Scroller = new Scroller();
  private accountScroller: ListScroller = new ListScroller();
  private readonly modeSegmentItems: SegmentButtonV2Items = new SegmentButtonV2Items([
    { text: '支出' },
    { text: '收入' },
    { text: '转账' }
  ]);
  private readonly keypadKeys: KeypadKey[] = [
    new KeypadKey('1', 'digit_1'),
    new KeypadKey('2', 'digit_2'),
    new KeypadKey('3', 'digit_3'),
    new KeypadKey('⌫', 'delete'),
    new KeypadKey('4', 'digit_4'),
    new KeypadKey('5', 'digit_5'),
    new KeypadKey('6', 'digit_6'),
    new KeypadKey('-', 'minus', false, true),
    new KeypadKey('7', 'digit_7'),
    new KeypadKey('8', 'digit_8'),
    new KeypadKey('9', 'digit_9'),
    new KeypadKey('+', 'plus', false, true),
    new KeypadKey('再记', 'save_continue'),
    new KeypadKey('0', 'digit_0'),
    new KeypadKey('.', 'decimal'),
    new KeypadKey('保存', 'save_close', true)
  ];

  /**
   * 半模态出现时从数据库加载分类，确保新用户和老用户都走同一套数据源。
   */
  aboutToAppear(): void {
    this.initializeForm();
  }

  /**
   * 当前是否处于编辑账单模式。
   */
  private isEditingMode(): boolean {
    return this.editingBillId > 0;
  }

  /**
   * 初始化录入表单；编辑模式会回填原账单数据。
   */
  private async initializeForm(): Promise<void> {
    await Promise.all([this.loadAccounts(), this.loadCategories()]);
    if (this.isEditingMode()) {
      await this.fillFormByBillId();
      return;
    }
    this.resetForm();
  }

  /**
   * 构建半模态主体布局，顶部直接展示模式切换与关闭操作。
   */
  build() {
    Column() {
      this.TopActionSection()

      Stack({ alignContent: Alignment.Top }) {
        Scroll(this.scroller) {
          Column({ space: 12 }) {
            this.CategoryGridSection()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 6, bottom: 20 })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .fadingEdge(true)
        .clip(false)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      }
      .width('100%')
      .layoutWeight(1)

      Column({ space: 10 }) {
        this.AmountEditorSection()
        this.CustomKeyboardSection()
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 18 })
      .backgroundColor(this.themeState.backgroundPrimary)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.backgroundPrimary)
    .bindSheet($$this.isDateSheetVisible, this.DatePickerSheet(), {
      height: 380,
      preferType: SheetType.BOTTOM,
      title: {
        title: '选择日期'
      }
    })
  }

  /**
   * 返回当前账单类型对应的分类选项。
   */
  private getCurrentCategoryOptions(): CategoryOption[] {
    if (this.activeMode === RECORD_MODE_TRANSFER) {
      return [new CategoryOption(0, '转账', $r('sys.symbol.arrow_left_arrow_right'), true)];
    }
    if (this.selectedType === BillTypeEnum.EXPENSE) {
      return this.expenseCategories;
    }
    return this.incomeCategories;
  }

  /**
   * 切换账单类型后修正默认分类，避免出现无效选项。
   */
  private updateCategoryForCurrentType(): void {
    const categories: CategoryOption[] = this.getCurrentCategoryOptions();
    let hasMatchedCategory: boolean = false;
    categories.forEach((item: CategoryOption) => {
      if (item.label === this.selectedCategory) {
        hasMatchedCategory = true;
      }
    });
    if (!hasMatchedCategory && categories.length > 0) {
      this.selectedCategory = categories[0].label;
    }
  }

  /**
   * 将账单类型映射为金额显示色。
   */
  private getAmountToneColor(): ResourceColor {
    if (this.activeMode === RECORD_MODE_TRANSFER) {
      return this.themeState.fontPrimary as ResourceColor;
    }
    if (this.selectedType === BillTypeEnum.INCOME) {
      return this.themeState.brand as ResourceColor;
    }
    return '#E55454';
  }

  /**
   * 返回格式化后的日期文案。
   */
  private getSelectedDateText(): string {
    const date: Date = new Date(this.selectedDate);
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  /**
   * 根据索引计算每行应展示的数字键盘按键。
   */
  private getKeyboardRow(rowIndex: number): KeypadKey[] {
    const startIndex: number = rowIndex * KEYBOARD_KEYS_PER_ROW;
    return this.keypadKeys.slice(startIndex, startIndex + KEYBOARD_KEYS_PER_ROW);
  }

  /**
   * 返回顶部模式切换对应的选中索引。
   */
  private getModeSelectedIndex(): number {
    if (this.activeMode === RECORD_MODE_INCOME) {
      return 1;
    }
    if (this.activeMode === RECORD_MODE_TRANSFER) {
      return 2;
    }
    return 0;
  }

  /**
   * 根据分段索引切换当前录入模式。
   */
  private updateModeByIndex(selectedIndex: number): void {
    if (selectedIndex === 1) {
      this.activeMode = RECORD_MODE_INCOME;
      this.selectedType = BillTypeEnum.INCOME;
    } else if (selectedIndex === 2) {
      this.activeMode = RECORD_MODE_TRANSFER;
      this.selectedType = BillTypeEnum.TRANSFER;
      this.selectedCategory = '转账';
      this.updateTransferTargetAccount();
    } else {
      this.activeMode = RECORD_MODE_EXPENSE;
      this.selectedType = BillTypeEnum.EXPENSE;
    }
    this.updateCategoryForCurrentType();
  }

  /**
   * 将数据库分类实体转换为当前页面直接渲染的分类选项。
   */
  private buildCategoryOption(category: CategoryBean): CategoryOption {
    return new CategoryOption(category.id, category.name, category.getIconResource(), category.isSystem);
  }

  /**
   * 从数据库加载支出和收入分类，并回填当前选中分类。
   */
  private async loadCategories(): Promise<void> {
    try {
      const expenseCategories: CategoryBean[] = await CategoryManager.getCategoriesByType(BillTypeEnum.EXPENSE);
      const incomeCategories: CategoryBean[] = await CategoryManager.getCategoriesByType(BillTypeEnum.INCOME);
      this.expenseCategories = expenseCategories.map((item: CategoryBean) => this.buildCategoryOption(item));
      this.incomeCategories = incomeCategories.map((item: CategoryBean) => this.buildCategoryOption(item));
      this.updateCategoryForCurrentType();
    } catch {
      this.showToast('分类加载失败');
    }
  }

  /**
   * 根据账单详情回填编辑表单，保证首页和账单页共用同一套录入体验。
   */
  private async fillFormByBillId(): Promise<void> {
    try {
      const bill: BillBean | null = await BillManager.getBillById(this.editingBillId);
      if (bill === null) {
        this.showToast('账单不存在或已删除');
        return;
      }
      this.selectedType = bill.type;
      if (bill.type === BillTypeEnum.INCOME) {
        this.activeMode = RECORD_MODE_INCOME;
      } else if (bill.type === BillTypeEnum.TRANSFER) {
        this.activeMode = RECORD_MODE_TRANSFER;
      } else {
        this.activeMode = RECORD_MODE_EXPENSE;
      }
      this.selectedCategory = bill.category;
      this.amountText = bill.amount.toFixed(2);
      this.selectedAccount = bill.account;
      this.targetAccount = bill.targetAccount;
      this.selectedDate = bill.date;
      this.dateDraft = bill.date;
      this.remarkText = bill.remark;
      this.updateCategoryForCurrentType();
      this.updateSelectedAccount();
    } catch {
      this.showToast('账单加载失败');
    }
  }

  /**
   * 返回当前选中的支付账户名称。
   */
  private getSelectedAccountLabel(): string {
    if (this.selectedAccount.trim().length > 0) {
      return this.selectedAccount;
    }
    return '暂无账户';
  }

  /**
   * 返回当前选中的转入账户名称。
   */
  private getTargetAccountLabel(): string {
    if (this.targetAccount.trim().length > 0) {
      return this.targetAccount;
    }
    return '选择转入账户';
  }

  /**
   * 返回可选的转入账户列表，避免与转出账户重复。
   */
  private getTransferTargetOptions(): string[] {
    return this.accountOptions.filter((item: string) => item !== this.selectedAccount);
  }

  /**
   * 返回当前选中支付方式在原始数组中的索引，用于展开时恢复可视区域位置。
   */
  private getSelectedAccountIndex(): number {
    const selectedIndex: number = this.accountOptions.indexOf(this.selectedAccount);
    if (selectedIndex >= 0) {
      return selectedIndex;
    }
    return 0;
  }

  /**
   * 判断给定支付方式是否为当前激活项。
   */
  private isActiveAccount(account: string): boolean {
    return account === this.selectedAccount;
  }

  /**
   * 根据转出账户修正当前转入账户，保证转账目标始终有效。
   */
  private updateTransferTargetAccount(): void {
    const targetOptions: string[] = this.getTransferTargetOptions();
    if (targetOptions.length === 0) {
      this.targetAccount = '';
      return;
    }
    if (targetOptions.indexOf(this.targetAccount) >= 0) {
      return;
    }
    this.targetAccount = targetOptions[0];
  }

  /**
   * 从数据库加载账户列表，并修正当前选中的账户。
   */
  private async loadAccounts(): Promise<void> {
    try {
      const accounts: AccountBean[] = await AccountManager.getAccounts();
      this.accountOptions = accounts.map((item: AccountBean) => item.name);
      this.updateSelectedAccount();
    } catch {
      this.showToast('账户加载失败');
    }
  }

  /**
   * 当账户列表变化时，确保当前选中项仍然有效。
   */
  private updateSelectedAccount(): void {
    let hasMatchedAccount: boolean = false;
    this.accountOptions.forEach((item: string) => {
      if (item === this.selectedAccount) {
        hasMatchedAccount = true;
      }
    });
    if (!hasMatchedAccount) {
      this.selectedAccount = this.getDefaultAccountName();
    }
    this.updateTransferTargetAccount();
  }

  /**
   * 返回默认账户名称，用于首次加载和重置表单。
   */
  private getDefaultAccountName(): string {
    if (this.accountOptions.length > 0) {
      return this.accountOptions[0];
    }
    return '';
  }

  /**
   * 根据文本长度返回支付方式按钮在展开态下的完整宽度。
   */
  private getAccountExpandedWidth(account: string): number {
    const normalizedLength: number = account.length > 0 ? account.length : 4;
    const calculatedWidth: number = 50 + normalizedLength * 16;
    return calculatedWidth > 82 ? calculatedWidth : 82;
  }

  /**
   * 返回支付方式按钮在当前状态下的宽度。
   */
  private getAccountPillWidth(account: string): number {
    if (this.isAccountSelectorExpanded) {
      return this.getAccountExpandedWidth(account);
    }
    return this.isActiveAccount(account) ? this.getAccountExpandedWidth(account) : 0;
  }

  /**
   * 返回支付方式按钮在当前状态下的透明度。
   */
  private getAccountPillOpacity(account: string): number {
    if (this.isAccountSelectorClosing && this.isActiveAccount(account)) {
      return 0;
    }
    if (this.isAccountSelectorExpanded) {
      return 1;
    }
    return this.isActiveAccount(account) ? 1 : 0;
  }

  /**
   * 返回支付方式按钮在当前状态下的右间距。
   */
  private getAccountPillMarginRight(index: number, totalCount: number): number {
    if (this.isAccountSelectorExpanded) {
      return index === totalCount - 1 ? 0 : ACCOUNT_PILL_GAP;
    }
    return 0;
  }

  /**
   * 返回支付方式按钮在当前状态下的缩放。
   */
  private getAccountPillScale(account: string): number {
    if (this.isAccountSelectorClosing && this.isActiveAccount(account)) {
      return 0.92;
    }
    if (this.isAccountSelectorExpanded) {
      return 1;
    }
    return this.isActiveAccount(account) ? 1 : 0.6;
  }

  /**
   * 返回账户选择视窗宽度，展开后限制宽度并交给横向 List 渐隐处理。
   */
  private getAccountViewportWidth(): number {
    if (this.isAccountSelectorExpanded) {
      return ACCOUNT_VIEWPORT_EXPANDED_WIDTH;
    }
    return this.getAccountExpandedWidth(this.getSelectedAccountLabel());
  }

  /**
   * 展开账户列表后，将当前选中项平滑滚动到视窗中央，避免末尾项再次展开时不可见。
   */
  private scrollSelectedAccountIntoView(): void {
    const selectedIndex: number = this.getSelectedAccountIndex();
    setTimeout(() => {
      try {
        this.accountScroller.scrollToIndex(selectedIndex, true, ScrollAlign.CENTER);
      } catch {
      }
    }, 48);
  }

  /**
   * 展开支付方式列表，复现向右弹开的胶囊动画。
   */
  private expandAccountSelector(): void {
    if (this.isAccountSelectorVisible) {
      return;
    }
    if (this.accountOptions.length === 0) {
      this.showToast('请先添加资产账户');
      return;
    }
    if (this.isRemarkExpanded) {
      this.updateRemarkPanel(false);
    }
    this.isAccountSelectorVisible = true;
    this.isAccountSelectorClosing = false;
    this.getUIContext().animateTo({
      duration: ACCOUNT_ANIMATION_DURATION,
      curve: curves.cubicBezierCurve(0.34, 1.56, 0.64, 1)
    }, () => {
      this.isAccountSelectorExpanded = true;
      this.scrollSelectedAccountIntoView();
    });
  }

  /**
   * 收起支付方式列表，只保留当前激活项。
   */
  private collapseAccountSelector(): void {
    if (!this.isAccountSelectorVisible) {
      return;
    }
    this.isAccountSelectorClosing = true;
    this.getUIContext().animateTo({
      duration: ACCOUNT_ANIMATION_DURATION,
      curve: curves.cubicBezierCurve(0.34, 1.56, 0.64, 1)
    }, () => {
      this.isAccountSelectorExpanded = false;
    });
    setTimeout(() => {
      this.isAccountSelectorVisible = false;
      this.isAccountSelectorClosing = false;
    }, ACCOUNT_ANIMATION_DURATION);
  }

  /**
   * 处理支付方式胶囊点击，展开态下先切换再延迟收起。
   */
  private handleAccountPillClick(account: string, index: number): void {
    if (this.isAccountSelectorClosing) {
      return;
    }
    if (!this.isAccountSelectorExpanded) {
      if (this.isActiveAccount(account)) {
        this.expandAccountSelector();
      }
      return;
    }
    this.selectedAccount = account;
    this.updateTransferTargetAccount();
    setTimeout(() => {
      this.collapseAccountSelector();
    }, ACCOUNT_COLLAPSE_DELAY);
  }

  /**
   * 切换到下一个可用的转入账户，避免依赖动态菜单数组。
   */
  private cycleTargetAccount(): void {
    const targetOptions: string[] = this.getTransferTargetOptions();
    if (targetOptions.length === 0) {
      this.showToast('请至少准备两个账户再进行转账');
      return;
    }
    const currentIndex: number = targetOptions.indexOf(this.targetAccount);
    if (currentIndex < 0 || currentIndex === targetOptions.length - 1) {
      this.targetAccount = targetOptions[0];
      return;
    }
    this.targetAccount = targetOptions[currentIndex + 1];
  }

  /**
   * 打开分类管理面板，按当前收支类型展示可拖拽排序的分类。
   */
  private showCategoryManageMenu(): void {
    if (this.activeMode === RECORD_MODE_TRANSFER) {
      this.showToast('转账使用系统分类，无需编辑');
      return;
    }
    this.onManageCategory();
  }

  /**
   * 将数字追加到金额字符串，最多保留两位小数。
   */
  private appendDigit(digit: string): void {
    if (this.amountText.includes('.')) {
      const decimalPart: string = this.amountText.split('.')[1];
      if (decimalPart.length >= 2) {
        return;
      }
    }

    if (this.amountText === '0') {
      this.amountText = digit;
      return;
    }
    if (this.amountText === '-0') {
      this.amountText = `-${digit}`;
      return;
    }
    this.amountText = `${this.amountText}${digit}`;
  }

  /**
   * 为金额补充小数点，避免重复输入。
   */
  private appendDecimalPoint(): void {
    if (this.amountText.includes('.')) {
      return;
    }
    this.amountText = `${this.amountText}.`;
  }

  /**
   * 删除金额末尾字符，并保持最小可显示格式。
   */
  private removeLastCharacter(): void {
    if (this.amountText.length <= 1) {
      this.amountText = '0';
      return;
    }
    this.amountText = this.amountText.slice(0, this.amountText.length - 1);
    if (this.amountText === '-' || this.amountText === '-0') {
      this.amountText = '0';
    }
  }

  /**
   * 切换金额正负号，便于快速修正录入方向。
   */
  private toggleAmountSign(): void {
    if (this.amountText === '0' || this.amountText === '0.') {
      return;
    }
    if (this.amountText.startsWith('-')) {
      this.amountText = this.amountText.slice(1);
      return;
    }
    this.amountText = `-${this.amountText}`;
  }

  /**
   * 根据按键动作更新金额或触发保存。
   */
  private handleKeyboardAction(action: string): void {
    if (action.startsWith('digit_')) {
      this.appendDigit(action.substring(6));
      return;
    }
    if (action === 'decimal') {
      this.appendDecimalPoint();
      return;
    }
    if (action === 'delete') {
      this.removeLastCharacter();
      return;
    }
    if (action === 'minus' || action === 'plus') {
      this.toggleAmountSign();
      return;
    }
    if (action === 'save_continue') {
      this.submitBill(false);
      return;
    }
    if (action === 'save_close') {
      this.submitBill(true);
    }
  }

  /**
   * 校验输入内容并返回可提交的金额。
   */
  private validateAmount(): number {
    const amountValue: number = Number(this.amountText);
    if (!Number.isFinite(amountValue) || amountValue === 0) {
      this.showToast('请输入正确的金额');
      return 0;
    }
    return Math.abs(amountValue);
  }

  /**
   * 校验当前是否存在可用账户，避免把空账户写入账单记录。
   */
  private validateAccount(): boolean {
    if (this.selectedAccount.trim().length > 0) {
      if (this.activeMode !== RECORD_MODE_TRANSFER) {
        return true;
      }
      if (this.targetAccount.trim().length === 0) {
        this.showToast('请选择转入账户');
        return false;
      }
      if (this.targetAccount === this.selectedAccount) {
        this.showToast('转入和转出账户不能相同');
        return false;
      }
      return true;
    }
    this.showToast('请先添加资产账户');
    return false;
  }

  /**
   * 构建待保存的账单对象。
   */
  private buildBill(amountValue: number): BillBean {
    const bill: BillBean = new BillBean();
    bill.type = this.selectedType;
    bill.category = this.selectedCategory;
    bill.amount = amountValue;
    bill.account = this.selectedAccount;
    bill.targetAccount = this.activeMode === RECORD_MODE_TRANSFER ? this.targetAccount : '';
    bill.date = this.selectedDate;
    bill.remark = this.remarkText.trim();
    return bill;
  }

  /**
   * 提交新增账单，支持保存后关闭或继续记账两种模式。
   */
  private async submitBill(closeAfterSave: boolean): Promise<void> {
    if (this.isSaving) {
      return;
    }
    const amountValue: number = this.validateAmount();
    if (amountValue <= 0) {
      return;
    }
    if (!this.validateAccount()) {
      return;
    }

    this.isSaving = true;
    try {
      if (this.isEditingMode()) {
        const bill: BillBean = this.buildBill(amountValue);
        await BillManager.updateBill(this.editingBillId, bill);
        this.showToast('已更新账单');
      } else {
        await BillManager.addBill(this.buildBill(amountValue));
        this.showToast('已保存账单');
      }
      this.onSaved();
      this.resetForm();
      if (closeAfterSave) {
        this.handleClose();
      }
    } catch (err) {
      this.showToast('保存失败，请稍后重试');
    } finally {
      this.isSaving = false;
    }
  }

  /**
   * 关闭半模态，并保持当前退出动效平滑。
   */
  private handleClose(): void {
    this.getUIContext().animateTo({
      duration: 220,
      curve: curves.springMotion(0.6, 0.9)
    }, () => {
      this.onClose();
    });
  }

  /**
   * 将表单状态恢复为默认值，便于下一笔继续录入。
   */
  private resetForm(): void {
    this.amountText = '0';
    this.activeMode = RECORD_MODE_EXPENSE;
    this.selectedType = BillTypeEnum.EXPENSE;
    this.selectedCategory = '餐饮';
    this.selectedAccount = this.getDefaultAccountName();
    this.targetAccount = '';
    this.remarkText = '';
    this.selectedDate = Date.now();
    this.updateTransferTargetAccount();
    this.updateRemarkPanel(false);
  }

  /**
   * 切换备注胶囊的输入态，让它在原位展开或收起。
   */
  private updateRemarkPanel(expanded: boolean): void {
    this.getUIContext().animateTo({
      duration: 220,
      curve: curves.springMotion(0.6, 0.9)
    }, () => {
      this.isRemarkExpanded = expanded;
    });
  }

  /**
   * 展开备注输入态后主动请求焦点，确保单击即可拉起键盘。
   */
  private focusRemarkInput(): void {
    setTimeout(() => {
      try {
        this.getUIContext().getFocusController().requestFocus(REMARK_INPUT_ID);
      } catch {
      }
    }, 40);
  }

  /**
   * 打开底部日期选择面板，并在确认后回写当前账单日期。
   */
  private showDatePickerDialog(): void {
    if (this.isRemarkExpanded) {
      this.updateRemarkPanel(false);
    }
    if (this.isAccountSelectorVisible) {
      this.collapseAccountSelector();
    }
    this.dateDraft = this.selectedDate;
    this.isDateSheetVisible = true;
  }

  /**
   * 统一弹出操作结果提示。
   */
  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: 1800
      });
    } catch {
    }
  }

  /**
   * 构建顶部操作区，左侧是分段切换，右侧是关闭按钮。
   */
  @Builder
  private TopActionSection() {
    Row() {
      Text(this.isEditingMode() ? '编辑账单' : '记一笔')
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.fontPrimary)
        .layoutWeight(1)

      CapsuleSegmentButtonV2({
        items: this.modeSegmentItems,
        selectedIndex: this.getModeSelectedIndex(),
        itemFontSize: LengthMetrics.vp(14),
        itemSelectedFontSize: LengthMetrics.vp(14),
        itemFontWeight: FontWeight.Medium,
        itemSelectedFontWeight: FontWeight.Bold,
        itemFontColor: ColorMetrics.resourceColor(this.themeState.fontPrimary as ResourceColor),
        itemSelectedFontColor: ColorMetrics.resourceColor(this.themeState.fontOnPrimary as ResourceColor),
        itemSelectedBackgroundColor: ColorMetrics.resourceColor(this.themeState.brand as ResourceColor),
        buttonBackgroundColor: ColorMetrics.resourceColor(this.themeState.compBackgroundPrimary as ResourceColor),
        buttonBorderRadius: LengthMetrics.vp(24),
        itemBorderRadius: LengthMetrics.vp(20),
        buttonPadding: LengthMetrics.vp(4),
        buttonMinHeight: LengthMetrics.vp(44),
        itemMinHeight: LengthMetrics.vp(36),
        $selectedIndex: (selectedIndex: number) => {
          this.updateModeByIndex(selectedIndex);
        }
      })
      .layoutWeight(2)

      Button() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(18)
          .fontColor([this.themeState.fontPrimary as ResourceColor])
      }
      .width(40)
      .height(40)
      .padding(0)
      .backgroundColor(this.themeState.compBackgroundPrimary)
      .borderRadius(20)
      .border({ width: 1, color: this.themeState.compDivider })
      .onClick(() => {
        this.handleClose();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 10 })
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 构建参考 MoneyTrack1 的日期选择 Sheet，避免使用系统弹窗打断录入流。
   */
  @Builder
  private DatePickerSheet() {
    Column() {
      DatePicker({
        start: new Date('2000-01-01'),
        end: new Date('2100-12-31'),
        selected: new Date(this.dateDraft)
      })
        .disappearTextStyle({
          font: { size: 14, weight: FontWeight.Regular }
        })
        .textStyle({
          color: this.themeState.fontPrimary,
          font: { size: 16, weight: FontWeight.Regular }
        })
        .selectedTextStyle({
          color: this.themeState.fontPrimary,
          font: { size: 20, weight: FontWeight.Medium }
        })
        .onDateChange((value: Date) => {
          this.dateDraft = value.getTime();
        })
        .width('78%')

      Row({ space: 12 }) {
        Button('取消')
          .layoutWeight(1)
          .height(46)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
          .backgroundColor(this.themeState.compBackgroundPrimary)
          .borderRadius(16)
          .border({ width: 1, color: this.themeState.compDivider })
          .onClick(() => {
            this.isDateSheetVisible = false;
          })

        Button('确定')
          .layoutWeight(1)
          .height(46)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.fontOnPrimary)
          .backgroundColor(this.themeState.brand as ResourceColor)
          .borderRadius(16)
          .onClick(() => {
            this.selectedDate = this.dateDraft;
            this.isDateSheetVisible = false;
          })
      }
      .width('100%')
      .margin({ top: 24 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
    .backgroundColor(this.themeState.backgroundPrimary)
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 构建列表顶部渐隐遮罩，视觉上弱化滚动起点。
   */
  @Builder
  private TopFadeMask() {
    Column()
      .width('100%')
      .height(20)
      .linearGradient({
        angle: 180,
        colors: [[this.themeState.backgroundPrimary as ResourceColor, 0], ['#00FFFFFF', 1]]
      })
      .hitTestBehavior(HitTestMode.None)
  }

  /**
   * 构建列表底部渐隐遮罩，让分类区过渡到固定录入面板更自然。
   */
  @Builder
  private BottomFadeMask() {
    Column() {
      Blank()
      Column()
        .width('100%')
        .height(28)
        .linearGradient({
          angle: 0,
          colors: [[this.themeState.backgroundPrimary as ResourceColor, 0], ['#00FFFFFF', 1]]
        })
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.None)
  }

  /**
   * 构建参考图风格的分类宫格区域。
   */
  @Builder
  private CategoryGridSection() {
    Column({ space: 14 }) {
      this.CategoryHeaderSection();

      Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row }) {
        ForEach(this.getCurrentCategoryOptions(), (item: CategoryOption) => {
          this.CategoryCard(item);
        }, (item: CategoryOption) => item.label);
      }
      .width('100%')
    }
    .width('100%')
    .padding({ top: 4 })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 构建分类标题与管理入口。
   */
  @Builder
  private CategoryHeaderSection() {
    Row() {
      Text('分类')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.fontSecondary);
      Button('管理分类')
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeState.brand)
        .backgroundColor(this.themeState.backgroundPrimary)
        .borderRadius(16)
        .border({ width: 1, color: this.themeState.compDivider })
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(() => {
          this.showCategoryManageMenu();
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 构建固定在键盘上方的金额展示面板。
   */
  @Builder
  private AmountEditorSection() {
    Column({ space: 10 }) {
      this.EntryMetaRow()

      Row() {
        Text(`¥ ${this.amountText}`)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getAmountToneColor())
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
        Blank();
        Text(this.selectedCategory)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontSecondary);
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      if (this.activeMode === RECORD_MODE_TRANSFER) {
        this.TransferTargetSection();
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeState.compBackgroundPrimary)
    .borderRadius(22)
    .border({ width: 1, color: this.themeState.compDivider })
    .alignItems(HorizontalAlign.Start)
  }

  /**
   * 构建底部自定义数字键盘。
   */
  @Builder
  private CustomKeyboardSection() {
    Column({ space: 10 }) {
      ForEach([0, 1, 2, 3], (rowIndex: number) => {
        Row({ space: 10 }) {
          ForEach(this.getKeyboardRow(rowIndex), (keyItem: KeypadKey) => {
            this.KeyboardKey(keyItem);
          }, (keyItem: KeypadKey) => keyItem.action);
        }
        .width('100%');
      }, (rowIndex: number) => `${rowIndex}`);
    }
    .width('100%')
    .padding({ top: 4 })
  }

  /**
   * 构建分类宫格里的单个分类卡片。
   */
  @Builder
  private CategoryCard(item: CategoryOption) {
    Button() {
      Column({ space: 8 }) {
        Row() {
          SymbolGlyph(item.icon)
            .fontSize(25)
            .fontWeight(this.optionSystem.iconThickness)
            .fontColor([this.selectedCategory === item.label ? this.themeState.fontOnPrimary as ResourceColor :
              this.themeState.brand as ResourceColor]);
        }
        .width(CATEGORY_CARD_SIZE)
        .height(CATEGORY_CARD_SIZE)
        .justifyContent(FlexAlign.Center)
        .borderRadius(20)
        .backgroundColor(this.selectedCategory === item.label ? this.themeState.brand as ResourceColor :
          this.themeState.compBackgroundPrimary)
        .border({
          width: 1,
          color: this.selectedCategory === item.label ? this.themeState.brand as ResourceColor :
            this.themeState.compDivider
        });

        Text(item.label)
          .fontSize(14)
          .fontWeight(this.selectedCategory === item.label ? FontWeight.Bold : FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary);
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('20%')
    .padding(0)
    .backgroundColor('#00000000')
    .stateEffect(false)
    .margin({ bottom: 14 })
    .onClick(() => {
      this.selectedCategory = item.label;
    })
  }

  /**
   * 构建金额上方的紧凑信息条。
   */
  @Builder
  private EntryMetaRow() {
    Row({ space: 8 }) {
      this.AccountSelectorSection();
      if (!this.isRemarkExpanded) {
        this.MetaPill(this.getSelectedDateText(), $r('sys.symbol.calendar'), () => {
          this.showDatePickerDialog();
        });
      }
      this.RemarkTriggerPill();
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 构建转账模式下的转入账户入口。
   */
  @Builder
  private TransferTargetSection() {
    Button() {
      Row({ space: 8 }) {
        SymbolGlyph($r('sys.symbol.arrow_left_arrow_right'))
          .fontSize(15)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.themeState.brand as ResourceColor]);
        Text(`转入 ${this.getTargetAccountLabel()}`)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(34)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.themeState.backgroundPrimary)
    .borderRadius(17)
    .border({ width: 1, color: this.themeState.compDivider })
    .onClick(() => {
      this.cycleTargetAccount();
    })
  }

  /**
   * 构建账户选择区，支持在当前行原地展开候选项。
   */
  @Builder
  private AccountSelectorSection() {
    Stack({ alignContent: Alignment.Start }) {
      if (this.isAccountSelectorVisible) {
        List({ initialIndex: this.getSelectedAccountIndex(), scroller: this.accountScroller }) {
          ForEach(this.accountOptions, (account: string, index: number) => {
            ListItem() {
              this.AccountOptionPill(account, index, this.accountOptions.length);
            }
            .selectable(false)
            .focusable(false)
            .tabStop(false)
          }, (account: string) => account);
          }
        .listDirection(Axis.Horizontal)
        .width(this.getAccountViewportWidth())
        .height(ACCOUNT_PILL_HEIGHT)
        .scrollBar(BarState.Off)
        .fadingEdge(this.isAccountSelectorExpanded)
        .edgeEffect(EdgeEffect.None)
        .clip(this.isAccountSelectorExpanded)
        .scrollSnapAlign(ScrollSnapAlign.CENTER)
        .padding({ left: 0, right: 0 })
        .backgroundColor(this.themeState.compBackgroundPrimary)
        .borderRadius(20)
        .animation({ duration: ACCOUNT_ANIMATION_DURATION, curve: curves.cubicBezierCurve(0.34, 1.56, 0.64, 1) })
      }

      if (!this.isAccountSelectorVisible || this.isAccountSelectorClosing) {
        this.AccountCollapsedTrigger();
      }
    }
    .height(ACCOUNT_PILL_HEIGHT)
    .align(Alignment.Start)
  }

  /**
   * 构建收起态的当前支付方式按钮，避免未展开时出现横向滑动与渐隐。
   */
  @Builder
  private AccountCollapsedTrigger() {
    Button() {
      Row({ space: 6 }) {
        SymbolGlyph($r('sys.symbol.creditcard'))
          .fontSize(15)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.themeState.fontOnPrimary as ResourceColor]);
        Text(this.getSelectedAccountLabel())
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.fontOnPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width(this.getAccountExpandedWidth(this.getSelectedAccountLabel()))
    .height(ACCOUNT_PILL_HEIGHT)
    .padding(0)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.themeState.brand as ResourceColor)
    .borderRadius(17)
    .border({ width: 1, color: this.themeState.brand as ResourceColor })
    .stateEffect(false)
    .focusable(false)
    .tabStop(false)
    .defaultFocus(false)
    .groupDefaultFocus(false)
    .scale({
      x: this.isAccountSelectorClosing ? 1 : 1,
      y: this.isAccountSelectorClosing ? 1 : 1
    })
    .opacity(this.isAccountSelectorClosing ? 1 : 1)
    .animation({ duration: ACCOUNT_ANIMATION_DURATION, curve: curves.cubicBezierCurve(0.34, 1.56, 0.64, 1) })
    .enabled(this.accountOptions.length > 0)
    .onClick(() => {
      this.handleAccountPillClick(this.selectedAccount, 0);
    })
  }

  /**
   * 构建支付方式胶囊，按收起/展开两态切换宽度和可见性。
   */
  @Builder
  private AccountOptionPill(account: string, index: number, totalCount: number) {
    Button() {
      Row({ space: 6 }) {
        SymbolGlyph($r('sys.symbol.creditcard'))
          .fontSize(15)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.isActiveAccount(account) ? this.themeState.fontOnPrimary as ResourceColor :
            this.themeState.brand as ResourceColor]);
        Text(account)
          .fontSize(13)
          .fontWeight(this.isActiveAccount(account) ? FontWeight.Bold : FontWeight.Medium)
          .fontColor(this.isActiveAccount(account) ? this.themeState.fontOnPrimary : this.themeState.fontPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width(this.getAccountPillWidth(account))
    .height(ACCOUNT_PILL_HEIGHT)
    .padding(0)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.isActiveAccount(account) ? this.themeState.brand as ResourceColor :
      this.themeState.backgroundPrimary)
    .borderRadius(17)
    .border({
      width: 1,
      color: this.isActiveAccount(account) ? this.themeState.brand as ResourceColor : this.themeState.compDivider
    })
    .stateEffect(false)
    .focusable(false)
    .tabStop(false)
    .defaultFocus(false)
    .groupDefaultFocus(false)
    .margin({ right: this.getAccountPillMarginRight(index, totalCount) })
    .opacity(this.getAccountPillOpacity(account))
    .scale({ x: this.getAccountPillScale(account), y: this.getAccountPillScale(account) })
    .enabled(this.isAccountSelectorExpanded || this.isActiveAccount(account))
    .animation({ duration: ACCOUNT_ANIMATION_DURATION, curve: curves.cubicBezierCurve(0.34, 1.56, 0.64, 1) })
    .onClick(() => {
      this.handleAccountPillClick(account, index);
    })
  }

  /**
   * 构建账户、日期这类紧凑型信息按钮。
   */
  @Builder
  private MetaPill(text: string, icon: Resource, onClickAction: () => void) {
    Button() {
      Row({ space: 6 }) {
        SymbolGlyph(icon)
          .fontSize(15)
          .fontWeight(this.optionSystem.iconThickness)
          .fontColor([this.themeState.brand as ResourceColor]);
        Text(text)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
    }
    .height(34)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.themeState.backgroundPrimary)
    .borderRadius(17)
    .border({ width: 1, color: this.themeState.compDivider })
    .onClick(() => {
      onClickAction();
    })
  }

  /**
   * 构建备注胶囊，点击后在原位展开为输入态。
   */
  @Builder
  private RemarkTriggerPill() {
    Row({ space: 8 }) {
      SymbolGlyph($r('sys.symbol.square_and_pencil'))
        .fontSize(16)
        .fontWeight(this.optionSystem.iconThickness)
        .fontColor([this.isRemarkExpanded ? this.themeState.fontOnPrimary as ResourceColor :
          this.themeState.brand as ResourceColor]);

      if (this.isRemarkExpanded) {
        TextInput({ text: this.remarkText, placeholder: '写备注' })
          .id(REMARK_INPUT_ID)
          .layoutWeight(1)
          .fontSize(13)
          .fontWeight(this.optionSystem.fontThickness)
          .fontColor(this.themeState.fontOnPrimary)
          .placeholderColor(this.themeState.fontOnPrimary)
          .caretColor(this.themeState.fontOnPrimary)
          .backgroundColor('#00000000')
          .padding({ left: 2, right: 0, top: 0, bottom: 0 })
          .height(22)
          .onFocus(() => {
            this.updateRemarkPanel(true);
          })
          .onBlur(() => {
            this.updateRemarkPanel(false);
          })
          .onChange((value: string) => {
            this.remarkText = value;
          });
      } else {
        Text(this.remarkText.trim().length > 0 ? this.remarkText : '备注')
          .layoutWeight(1)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeState.fontPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .layoutWeight(1)
    .height(34)
    .constraintSize({ minWidth: this.isRemarkExpanded ? 140 : 72, maxWidth: '100%' })
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.isRemarkExpanded ? this.themeState.brand as ResourceColor :
      this.themeState.backgroundPrimary)
    .borderRadius(17)
    .border({
      width: 1,
      color: this.isRemarkExpanded ? this.themeState.brand as ResourceColor : this.themeState.compDivider
    })
    .onClick(() => {
      if (!this.isRemarkExpanded) {
        this.updateRemarkPanel(true);
        this.focusRemarkInput();
      }
    })
  }

  /**
   * 构建数字键盘单个按钮。
   */
  @Builder
  private KeyboardKey(keyItem: KeypadKey) {
    Button(keyItem.label)
      .width('23%')
      .height(72)
      .fontSize(keyItem.isPrimary ? 18 : 22)
      .fontWeight(keyItem.isPrimary ? FontWeight.Bold : FontWeight.Medium)
      .fontColor(this.getKeyboardKeyTextColor(keyItem))
      .backgroundColor(this.getKeyboardKeyBackgroundColor(keyItem))
      .borderRadius(KEYBOARD_CORNER_RADIUS)
      .enabled(!this.isSaving)
      .onClick(() => {
        this.handleKeyboardAction(keyItem.action);
      })
  }

  /**
   * 返回键盘按钮对应的文字颜色。
   */
  private getKeyboardKeyTextColor(keyItem: KeypadKey): ResourceColor {
    if (keyItem.isPrimary) {
      return this.themeState.fontOnPrimary as ResourceColor;
    }
    if (keyItem.isAccent) {
      return this.themeState.brand as ResourceColor;
    }
    return this.themeState.fontPrimary as ResourceColor;
  }

  /**
   * 返回键盘按钮对应的背景颜色。
   */
  private getKeyboardKeyBackgroundColor(keyItem: KeypadKey): ResourceColor {
    if (keyItem.isPrimary) {
      return this.themeState.brand as ResourceColor;
    }
    return this.themeState.compBackgroundPrimary;
  }

  /**
   * 构建分区标题。
   */
  @Builder
  private SectionHeader(title: string) {
    Text(title)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.themeState.fontSecondary)
      .width('100%')
  }
}
