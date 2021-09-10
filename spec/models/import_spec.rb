# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '仕訳取込モデルに関するテスト', type: :model do

  describe 'バリデーションのテスト' do
    let(:user) { create(:user) }
    let(:account) { create(:account, user: user) }
    let(:import) { build(:import, user: user, debit: account, credit: account) }
    subject { import.valid? }

    context 'テストデータが正しく保存されることのテスト' do
      it 'import' do
        import
        is_expected.to eq true
      end
    end

    context '空白登録できないことのテスト' do

      it 'dateカラム' do
        import.date = ''
        is_expected.to eq false
      end
      it 'amountカラム' do
        import.amount = ''
        is_expected.to eq false
      end
    end

    context '空白登録できることのテスト' do
      it 'descriptionカラム' do
        import.description = ''
        is_expected.to eq true
      end
    end

    context '金額には正の整数のみ登録できることのテスト' do
      it '負の数は登録することができない' do
        import.amount = -1
        is_expected.to eq false
      end
      it '0は登録することができない' do
        import.amount = 0
        is_expected.to eq false
      end
      it '正の整数は登録することができる' do
        import.amount = 1
        is_expected.to eq true
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'ユーザモデルとの関係' do
      it 'N:1となっている' do
        expect(Import.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end

    context '勘定科目モデルとの関係' do
      it '借方科目がN:1となっている' do
        expect(Import.reflect_on_association(:debit).macro).to eq :belongs_to
      end
      it '貸方科目がN:1となっている' do
        expect(Import.reflect_on_association(:credit).macro).to eq :belongs_to
      end
    end
  end

  describe 'メソッドのテスト' do
    context 'arrange_and_save' do
      before do
        @user = create(:user, year: 2021)
        account = create(:account, user: @user)
        @import = Import.new
        @import.month = 1
        @import.day = 1
        @import.debit_code = account.code
        @import.credit_code = account.code
        @import.amount = 500
        @import.description = 'テスト'
      end

      it '正しい値の時saveすることができる' do
        expect(@import.arrange_and_save(@user)).to be_truthy
      end
      it '月が誤っている時保存することができない' do
        @import.month = 13
        expect(@import.arrange_and_save(@user)).to be_falsey
      end
      it '日が誤っている時保存することができない' do
        @import.day = 32
        expect(@import.arrange_and_save(@user)).to be_falsey
      end
      it '借方科目コードが誤っている時保存することができない' do
        @import.debit_code = 999
        expect(@import.arrange_and_save(@user)).to be_falsey
      end
      it '貸方科目コードが誤っている時保存することができない' do
        @import.credit_code = 999
        expect(@import.arrange_and_save(@user)).to be_falsey
      end
      it '金額が誤っている時保存することができない' do
        @import.amount = 0
        expect(@import.arrange_and_save(@user)).to be_falsey
      end
    end

    context 'arrange_for_display' do
      before do
        @user = create(:user, year: 2021)
        @account = create(:account, user: @user)
        @other_account = create(:account, user: @user, code: 101, name: 'test')
        @import = create(:journal, user: @user, debit: @account, credit: @other_account)
        @import.arrange_for_display
      end

      it '月が正しい' do
        expect(@import.month).to eq 1
      end
      it '日が正しい' do
        expect(@import.day).to eq 1
      end
      it '借方コードが正しい' do
        expect(@import.debit_code).to eq 100
      end
      it '貸方コードが正しい' do
        expect(@import.credit_code).to eq 101
      end
      it '借方科目名が正しい' do
        expect(@import.debit_name).to eq 'テスト'
      end
      it '貸方科目名が正しい' do
        expect(@import.credit_name).to eq 'test'
      end
    end
  end
end