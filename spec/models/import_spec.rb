# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '仕訳取込モデルに関するテスト', type: :model do

  describe 'バリデーションのテスト' do
    let(:user) { create(:user) }
    let(:account) { create(:account, user: user) }
    let(:import) { build(:import, user: user, debit: account, credit: account) }
    subject { import.valid? }

    describe 'テストデータが正しく保存されることのテスト' do
      it 'import' do
        import
        is_expected.to eq true
      end
    end

    describe '空白登録できないことのテスト' do

      it 'dateカラム' do
        import.date = ''
        is_expected.to eq false
      end
      it 'amountカラム' do
        import.amount = ''
        is_expected.to eq false
      end
    end

    describe '空白登録できることのテスト' do
      it 'descriptionカラム' do
        import.description = ''
        is_expected.to eq true
      end
    end

    describe '金額には正の整数のみ登録できることのテスト' do
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
    describe 'ユーザモデルとの関係' do
      it 'N:1となっている' do
        expect(Import.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end

    describe '勘定科目モデルとの関係' do
      it '借方科目がN:1となっている' do
        expect(Import.reflect_on_association(:debit).macro).to eq :belongs_to
      end
      it '貸方科目がN:1となっている' do
        expect(Import.reflect_on_association(:credit).macro).to eq :belongs_to
      end
    end
  end

  describe 'メソッドのテスト' do
    describe 'arrange_and_save' do
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

    describe 'arrange_for_display' do
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

    describe 'self_update' do
      before do
        @user = create(:user, year: 2021)
        account = create(:account, user: @user)
        other_account = create(:account, user: @user, code: 101, name: 'test')
        @import = create(:import, date: Date.new(2021,2,1), user: @user, debit: account, credit: other_account)
      end

      it 'テストデータが正常に更新されることのテスト' do
        import_params = { month:3, day: 1, debit_code: 100, credit_code: 101, amount: 1000, description: 'test' }
        @import.self_update(@user, import_params)
        @import = Import.find(1)
        expect(@import.date).to eq Date.new(2021,3,1)
        expect(@import.amount).to eq 1000
        expect(Import.all.length).to eq 1
      end

      it 'ロールバックが発生した場合、更新されていないことのテスト' do
        import_params = { month:'', day: 1, debit_code: 100, credit_code: 101, amount: 1000, description: 'test' }
        @import.self_update(@user, import_params)
        @import = Import.find(1)
        expect(@import.date).to eq Date.new(2021,2,1)
        expect(@import.amount).to eq 500
        expect(Import.all.length).to eq 1
      end
    end

    describe 'create_journal_from_import' do
      before do
        @user = create(:user, year: 2021)
        account = create(:account, user: @user)
        other_account = create(:account, user: @user, code: 101, name: 'test')
        hash = {}
        other_hash = {}
        (1..12).each do |mon|
          hash["debit_balance_#{mon}"] = 1000
          hash["credit_balance_#{mon}"] = 2000
          hash["opening_balance_#{mon}"] = 10000
          other_hash["debit_balance_#{mon}"] = 3000
          other_hash["credit_balance_#{mon}"] = 4000
          other_hash["opening_balance_#{mon}"] = 20000
        end
        account.update(hash)
        other_account.update(other_hash)
        @import = create(:import, date: Date.new(2021,2,1), user: @user, debit: account, credit: other_account)
      end

      context '正常に実行された場合' do
        before do
          @import.create_journal_from_import
          @account = Account.find(1)
          @other_account = Account.find(2)
        end

        it 'importのレコード数' do
          expect(Import.all.length).to eq 0
        end
        it 'journalのレコード数' do
          expect(Journal.all.length).to eq 1
        end
        it '借方科目の貸方残高は変わっていない' do
          (1..12).each do |mon|
            expect(@account.send("credit_balance_#{mon}")).to eq 2000
          end
        end
        it '貸方科目の借方残高は変わっていない' do
          (1..12).each do |mon|
            expect(@other_account.send("debit_balance_#{mon}")).to eq 3000
          end
        end
        it '借方科目の仕訳作成月以前の期首残高、仕訳作成月より前の借方残高は変わっていない' do
          expect(@account.opening_balance_1).to eq 10000
          expect(@account.opening_balance_2).to eq 10000
          expect(@account.debit_balance_1).to eq 1000
        end
        it '貸方科目の仕訳作成月以前の期首残高、仕訳作成月より前の貸方残高は変わっていない' do
          expect(@other_account.opening_balance_1).to eq 20000
          expect(@other_account.opening_balance_2).to eq 20000
          expect(@other_account.credit_balance_1).to eq 4000
        end
        it '借方科目の仕訳作成月の借方残高、仕訳作成月より後の期首残高は変わっている' do
          expect(@account.debit_balance_2).to eq 1500
          (3..12).each do |mon|
            expect(@account.send("opening_balance_#{mon}")).to eq 10500
          end
        end
        it '貸方科目の仕訳作成月の貸方残高、仕訳作成月より後の期首残高は変わっている' do
          expect(@other_account.credit_balance_2).to eq 4500
          (3..12).each do |mon|
            expect(@other_account.send("opening_balance_#{mon}")).to eq 19500
          end
        end
      end

      context 'ロールバックが発生した場合' do
        before do
          @import.update_attribute(:amount, 0)
          @import.create_journal_from_import
          @account = Account.find(1)
          @other_account = Account.find(2)
        end

        it 'importのレコード数' do
          expect(Import.all.length).to eq 1
        end
        it 'journalのレコード数' do
          expect(Journal.all.length).to eq 0
        end
        it '勘定科目の残高が変わっていない' do
          (1..12).each do |mon|
            expect(@account.send("debit_balance_#{mon}")).to eq 1000
            expect(@account.send("credit_balance_#{mon}")).to eq 2000
            expect(@account.send("opening_balance_#{mon}")).to eq 10000
            expect(@other_account.send("debit_balance_#{mon}")).to eq 3000
            expect(@other_account.send("credit_balance_#{mon}")).to eq 4000
            expect(@other_account.send("opening_balance_#{mon}")).to eq 20000
          end
        end
      end
    end

    describe 'all_destroy' do
      before do
        @user = create(:user, year: 2021)
        other_user = create(:user)
        account = create(:account, user: @user)
        other_account = create(:account, user: @user, code: 101, name: 'test')
        create(:import, user: @user, debit: account, credit: other_account)
        create(:import, user: @user, debit: account, credit: other_account)
        create(:import, user: other_user, debit: account, credit: other_account)
      end

      it '削除前のレコード数は正しい' do
        expect(Import.all.length).to eq 3
      end

      it '削除後のレコード数は正しい' do
        Import.all_destroy(@user)
        expect(Import.all.length).to eq 1
      end
    end
  end
end