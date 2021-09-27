# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '仕訳モデルに関するテスト', type: :model do

  describe 'バリデーションのテスト' do
    let(:user) { create(:user) }
    let(:account) { create(:account, user: user) }
    let(:journal) { build(:journal, user: user, debit: account, credit: account) }
    subject { journal.valid? }

    describe 'テストデータが正しく保存されることのテスト' do
      it 'journal' do
        journal
        is_expected.to eq true
      end
    end

    describe '空白登録できないことのテスト' do

      it 'dateカラム' do
        journal.date = ''
        is_expected.to eq false
      end
      it 'amountカラム' do
        journal.amount = ''
        is_expected.to eq false
      end
    end

    describe '空白登録できることのテスト' do
      it 'descriptionカラム' do
        journal.description = ''
        is_expected.to eq true
      end
    end

    describe '金額には正の整数のみ登録できることのテスト' do
      it '負の数は登録することができない' do
        journal.amount = -1
        is_expected.to eq false
      end
      it '0は登録することができない' do
        journal.amount = 0
        is_expected.to eq false
      end
      it '正の整数は登録することができる' do
        journal.amount = 1
        is_expected.to eq true
      end
    end
  end

  describe 'アソシエーションのテスト' do
    describe 'ユーザモデルとの関係' do
      it 'N:1となっている' do
        expect(Journal.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end

    describe '勘定科目モデルとの関係' do
      it '借方科目がN:1となっている' do
        expect(Journal.reflect_on_association(:debit).macro).to eq :belongs_to
      end
      it '貸方科目がN:1となっている' do
        expect(Journal.reflect_on_association(:credit).macro).to eq :belongs_to
      end
    end
  end

  describe 'メソッドのテスト' do
    describe 'arrange_and_save' do
      before do
        @user = create(:user, year: 2021)
        account = create(:account, user: @user)
        @journal = Journal.new
        @journal.month = 1
        @journal.day = 1
        @journal.debit_code = account.code
        @journal.credit_code = account.code
        @journal.amount = 500
        @journal.description = 'テスト'
      end

      it '正しい値の時saveすることができる' do
        expect(@journal.arrange_and_save(@user)).to be_truthy
      end
      it '月が誤っている時保存することができない' do
        @journal.month = 13
        expect(@journal.arrange_and_save(@user)).to be_falsey
      end
      it '日が誤っている時保存することができない' do
        @journal.day = 32
        expect(@journal.arrange_and_save(@user)).to be_falsey
      end
      it '借方科目コードが誤っている時保存することができない' do
        @journal.debit_code = 999
        expect(@journal.arrange_and_save(@user)).to be_falsey
      end
      it '貸方科目コードが誤っている時保存することができない' do
        @journal.credit_code = 999
        expect(@journal.arrange_and_save(@user)).to be_falsey
      end
      it '金額が誤っている時保存することができない' do
        @journal.amount = 0
        expect(@journal.arrange_and_save(@user)).to be_falsey
      end
    end

    describe 'arrange_and_save_in_simple_entry' do
      before do
        @user = create(:user, year: 2021)
        @account = create(:account, user: @user)
        @other_account = create(:account, user: @user, code: 101)
        @journal = Journal.new
        @journal.month = 1
        @journal.day = 1
        @journal.description = 'テスト'
        @journal.self_code = @account.code
        @journal.nonself_code = @other_account.code
        @journal.received_amount = 500
        @journal.invest_amount = ''
      end

      it '正しい値の時saveすることができる' do
        expect(@journal.arrange_and_save_in_simple_entry(@user)).to be_truthy
        expect(Journal.all.length).to eq 1
      end

      it '月が誤っている時、保存できずにfalseを返す' do
        @journal.month = 13
        expect(@journal.arrange_and_save_in_simple_entry(@user)).to be_falsey
        expect(Journal.all.length).to eq 0
      end

      it '日が誤っている時、保存できずにfalseを返す' do
        @journal.day = 32
        expect(@journal.arrange_and_save_in_simple_entry(@user)).to be_falsey
        expect(Journal.all.length).to eq 0
      end

      it '自身コードが誤っている時、保存できずにfalseを返す' do
        @journal.self_code = 999
        expect(@journal.arrange_and_save_in_simple_entry(@user)).to be_falsey
        expect(Journal.all.length).to eq 0
      end

       it '相手コードが誤っている時、保存できずにfalseを返す' do
        @journal.nonself_code = 999
        expect(@journal.arrange_and_save_in_simple_entry(@user)).to be_falsey
        expect(Journal.all.length).to eq 0
      end

      it '入金額、出金額共に''の時、保存できずにfalseを返す' do
        @journal.received_amount = ''
        expect(@journal.arrange_and_save_in_simple_entry(@user)).to be_falsey
        expect(Journal.all.length).to eq 0
      end

      it '入金額が''で、出金額が正しくない時、保存できずにfalseを返す' do
        @journal.received_amount = ''
        @journal.invest_amount = -1
        expect(@journal.arrange_and_save_in_simple_entry(@user)).to be_falsey
        expect(Journal.all.length).to eq 0
      end

      it '出金額が''で、入金額が正しくない時、保存できずにfalseを返す' do
        @journal.received_amount = -1
        expect(@journal.arrange_and_save_in_simple_entry(@user)).to be_falsey
        expect(Journal.all.length).to eq 0
      end

      it '入金額に入力がある場合、借方=自身になる' do
        @journal.arrange_and_save_in_simple_entry(@user)
        expect(@journal.debit).to eq @account
        expect(@journal.credit).to eq @other_account
        expect(Journal.all.length).to eq 1
      end
      it '出金額に入力がある場合、貸方=自身になる' do
        @journal.received_amount = ''
        @journal.invest_amount = 500
        @journal.arrange_and_save_in_simple_entry(@user)
        expect(@journal.debit).to eq @other_account
        expect(@journal.credit).to eq @account
        expect(Journal.all.length).to eq 1
      end
    end

    describe 'arrange_for_display' do
      before do
        @user = create(:user, year: 2021)
        @account = create(:account, user: @user)
        @other_account = create(:account, user: @user, code: 101, name: 'test')
        @journal = create(:journal, user: @user, debit: @account, credit: @other_account)
        @journal.arrange_for_display
      end

      it '月が正しい' do
        expect(@journal.month).to eq 1
      end
      it '日が正しい' do
        expect(@journal.day).to eq 1
      end
      it '借方コードが正しい' do
        expect(@journal.debit_code).to eq 100
      end
      it '貸方コードが正しい' do
        expect(@journal.credit_code).to eq 101
      end
      it '借方科目名が正しい' do
        expect(@journal.debit_name).to eq 'テスト'
      end
      it '貸方科目名が正しい' do
        expect(@journal.credit_name).to eq 'test'
      end
    end

    describe 'arrange_for_display_in_simple_entry' do
      before do
        @user = create(:user, year: 2021)
        @account = create(:account, user: @user)
        @other_account = create(:account, user: @user, code: 101, name: 'test')
        @journal = create(:journal, user: @user, debit: @account, credit: @other_account)
      end

      context '借方=自身の場合' do
        before do
          @journal.arrange_for_display_in_simple_entry(@account.id)
        end

        it '月が正しい' do
          expect(@journal.month).to eq 1
        end
        it '日が正しい' do
          expect(@journal.day).to eq 1
        end
        it '自科目のコードが正しい' do
          expect(@journal.self_code).to eq 100
        end
        it '相手科目のコードが正しい' do
          expect(@journal.nonself_code).to eq 101
        end
        it '相手科目の名前が正しい' do
          expect(@journal.nonself_name).to eq 'test'
        end
        it '入金額が正しい' do
          expect(@journal.received_amount).to eq 500
        end
      end

      context '貸方=自身の場合' do
        before do
          @journal.arrange_for_display_in_simple_entry(@other_account.id)
        end

        it '月が正しい' do
          expect(@journal.month).to eq 1
        end
        it '日が正しい' do
          expect(@journal.day).to eq 1
        end
        it '自科目のコードが正しい' do
          expect(@journal.self_code).to eq 101
        end
        it '相手科目のコードが正しい' do
          expect(@journal.nonself_code).to eq 100
        end
        it '相手科目の名前が正しい' do
          expect(@journal.nonself_name).to eq 'テスト'
        end
        it '出金額が正しい' do
          expect(@journal.invest_amount).to eq 500
        end
      end
    end

    describe 'update_debit_and_credit_balance' do
      before do
        @user = create(:user, year: 2021)
        account = create(:account, user: @user)
        other_account = create(:account, user: @user, code: 101, name: 'test')
        hash = {}
        other_hash = {}
        (1..12).to_a.each do |mon|
          hash["debit_balance_#{mon}"] = 1000
          hash["credit_balance_#{mon}"] = 2000
          hash["opening_balance_#{mon}"] = 10000
          other_hash["debit_balance_#{mon}"] = 3000
          other_hash["credit_balance_#{mon}"] = 4000
          other_hash["opening_balance_#{mon}"] = 20000
        end
        account.update(hash)
        other_account.update(other_hash)
        @journal = create(:journal, date: Date.new(2021,2,1), user: @user, debit: account, credit: other_account)
      end

      describe '正常に動いた場合、残高が更新されていることのテスト' do
        context 'reverse = falseの場合' do
          before do
            @journal.update_debit_and_credit_balance
            @account = Account.find(1)
            @other_account = Account.find(2)
          end

          it '借方コードの貸方残高、貸方コードの借方残高は更新されていない' do
            (1..12).to_a.each do |mon|
              expect(@account.send("credit_balance_#{mon}")).to eq 2000
              expect(@other_account.send("debit_balance_#{mon}")).to eq 3000
            end
          end
          it '借方コードの2月以外借方残高、貸方コードの2月以外貸方残高は更新されていない' do
            expect(@account.debit_balance_1).to eq 1000
            expect(@other_account.credit_balance_1).to eq 4000
            (3..12).to_a.each do |mon|
              expect(@account.send("debit_balance_#{mon}")).to eq 1000
              expect(@other_account.send("credit_balance_#{mon}")).to eq 4000
            end
          end
          it '借方コードの2月借方残高、貸方コードの2月貸方残高は正しく更新されている' do
            expect(@account.debit_balance_2).to eq 1500
            expect(@other_account.credit_balance_2).to eq 4500
          end
          it '1,2月の期首残高は変わっていない' do
            (1..2).to_a.each do |mon|
              expect(@account.send("opening_balance_#{mon}")).to eq 10000
              expect(@other_account.send("opening_balance_#{mon}")).to eq 20000
            end
          end
          it '3月以降の期首残高は正しく更新されている' do
            (3..12).to_a.each do |mon|
              expect(@account.send("opening_balance_#{mon}")).to eq 10500
              expect(@other_account.send("opening_balance_#{mon}")).to eq 19500
            end
          end
        end

        context 'reverse = trueの場合' do
          before do
            @journal.update_debit_and_credit_balance(true)
            @account = Account.find(1)
            @other_account = Account.find(2)
          end

          it '借方コードの貸方残高、貸方コードの借方残高は更新されていない' do
            (1..12).to_a.each do |mon|
              expect(@account.send("credit_balance_#{mon}")).to eq 2000
              expect(@other_account.send("debit_balance_#{mon}")).to eq 3000
            end
          end
          it '借方コードの2月以外借方残高、貸方コードの2月以外貸方残高は更新されていない' do
            expect(@account.debit_balance_1).to eq 1000
            expect(@other_account.credit_balance_1).to eq 4000
            (3..12).to_a.each do |mon|
              expect(@account.send("debit_balance_#{mon}")).to eq 1000
              expect(@other_account.send("credit_balance_#{mon}")).to eq 4000
            end
          end
          it '借方コードの2月借方残高、貸方コードの2月貸方残高は正しく更新されている' do
            expect(@account.debit_balance_2).to eq 500
            expect(@other_account.credit_balance_2).to eq 3500
          end
          it '1,2月の期首残高は変わっていない' do
            (1..2).to_a.each do |mon|
              expect(@account.send("opening_balance_#{mon}")).to eq 10000
              expect(@other_account.send("opening_balance_#{mon}")).to eq 20000
            end
          end
          it '3月以降の期首残高は正しく更新されている' do
            (3..12).to_a.each do |mon|
              expect(@account.send("opening_balance_#{mon}")).to eq 9500
              expect(@other_account.send("opening_balance_#{mon}")).to eq 20500
            end
          end
        end
      end
      context 'ロールバックが発生した場合、残高が更新されていないことのテスト' do
        before do
          @journal.debit = nil
          @journal.update_debit_and_credit_balance
          @account = Account.find(1)
          @other_account = Account.find(2)
        end

        it '全ての残高が変わっていない' do
          (1..12).to_a.each do |mon|
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

    describe 'self_create_and_update_account_balance_in_simple_entry' do
      before do
        @user = create(:user, year: 2021)
        account = create(:account, user: @user)
        other_account = create(:account, user: @user, code: 101, name: 'test')
        hash = {}
        other_hash = {}
        (1..12).to_a.each do |mon|
          hash["debit_balance_#{mon}"] = 1000
          hash["credit_balance_#{mon}"] = 2000
          hash["opening_balance_#{mon}"] = 10000
          other_hash["debit_balance_#{mon}"] = 3000
          other_hash["credit_balance_#{mon}"] = 4000
          other_hash["opening_balance_#{mon}"] = 20000
        end
        account.update(hash)
        other_account.update(other_hash)
        @journal = Journal.new(month: 2, day: 1, self_code: account.code,
                              nonself_code: other_account.code, received_amount: 500,
                              invest_amount: '', description: 'test')
      end

      describe 'テストデータが正常に保存されることのテスト' do
        before do
          @journal.self_create_and_update_account_balance_in_simple_entry(@user)
          @account = Account.find(1)
          @other_account = Account.find(2)
        end

        it '仕訳のレコードが一つ増えている' do
          expect(Journal.all.length).to eq 1
        end
        it '借方科目の貸方残高は変わっていない' do
        (1..12).to_a.each do |mon|
          expect(@account.send("credit_balance_#{mon}")).to eq 2000
        end
        end
        it '貸方科目の借方残高は変わっていない' do
          (1..12).to_a.each do |mon|
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
          (3..12).to_a.each do |mon|
            expect(@account.send("opening_balance_#{mon}")).to eq 10500
          end
        end
        it '貸方科目の仕訳作成月の貸方残高、仕訳作成月より後の期首残高は変わっている' do
          expect(@other_account.credit_balance_2).to eq 4500
          (3..12).to_a.each do |mon|
            expect(@other_account.send("opening_balance_#{mon}")).to eq 19500
          end
        end
      end

      describe 'ロールバックが発生した場合、残高が更新されていないことのテスト' do
        before do
          @journal.self_code = ''
          @journal.self_create_and_update_account_balance_in_simple_entry(@user)
          @account = Account.find(1)
          @other_account = Account.find(2)
        end

        it '仕訳のレコード数が変わっていない' do
          expect(Journal.all.length).to eq 0
        end
        it '勘定科目の残高が変わっていない' do
          (1..12).to_a.each do |mon|
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

    describe 'self_update_and_update_account_balance_in_simple_entry' do
      before do
        @user = create(:user, year: 2021)
        account = create(:account, user: @user)
        other_account = create(:account, user: @user, code: 101, name: 'test')
        hash = {}
        other_hash = {}
        (1..12).to_a.each do |mon|
          hash["debit_balance_#{mon}"] = 1000
          hash["credit_balance_#{mon}"] = 2000
          hash["opening_balance_#{mon}"] = 10000
          other_hash["debit_balance_#{mon}"] = 3000
          other_hash["credit_balance_#{mon}"] = 4000
          other_hash["opening_balance_#{mon}"] = 20000
        end
        account.update(hash)
        other_account.update(other_hash)
        @journal = create(:journal, date: Date.new(2021,2,1), user: @user, debit: account, credit: other_account)
      end

      describe 'テストデータが正常に保存されることのテスト' do
        before do
          journal_params = { month: 3, day: 1, self_code: 100, nonself_code: 101, received_amount: 1000, description: 'test'}
          @journal.self_update_and_update_account_balance_in_simple_entry(@user, journal_params)
          @account = Account.find(1)
          @other_account = Account.find(2)
        end

        it '仕訳のレコード数は変わっていない' do
          expect(Journal.all.length).to eq 1
        end
        it '以下の残高は変わっていない' do
          # 自身科目の貸方残高、相手科目の借方残高
          (1..12).to_a.each do |mon|
            expect(@account.send("credit_balance_#{mon}")).to eq 2000
            expect(@other_account.send("debit_balance_#{mon}")).to eq 3000
          end
          # 自身科目の1,2月期首残高、相手科目の1,2月期首残高
          expect(@account.opening_balance_1).to eq 10000
          expect(@account.opening_balance_2).to eq 10000
          expect(@other_account.opening_balance_1).to eq 20000
          expect(@other_account.opening_balance_2).to eq 20000
          # 自身科目の1月借方残高、相手科目の1月貸方残高
          expect(@account.debit_balance_1).to eq 1000
          expect(@other_account.credit_balance_1).to eq 4000
          # 自身科目の4月以降借方残高、相手科目の4月以降貸方残高
          (4..12).to_a.each do |mon|
            expect(@account.send("debit_balance_#{mon}")).to eq 1000
            expect(@other_account.send("credit_balance_#{mon}")).to eq 4000
          end
        end
        it '以下の残高は変わっている' do
          # 自身科目の2月借方残高、相手科目の2月貸方残高
          expect(@account.debit_balance_2).to eq 500
          expect(@other_account.credit_balance_2).to eq 3500
          # 自身科目の3月借方残高、相手科目の3月貸方残高
          expect(@account.debit_balance_3).to eq 2000
          expect(@other_account.credit_balance_3).to eq 5000
          # 自身科目の3月期首残高、相手科目の3月期首残高
          expect(@account.opening_balance_3).to eq 9500
          expect(@other_account.opening_balance_3).to eq 20500
          # 自身科目の4月以降期首残高、相手科目の4月以降期首残高
          (4..12).to_a.each do |mon|
            expect(@account.send("opening_balance_#{mon}")).to eq 10500
            expect(@other_account.send("opening_balance_#{mon}")).to eq 19500
          end
        end
      end

      describe 'ロールバックが発生した場合、残高が更新されていないことのテスト' do
        before do
          journal_params = { month: '', day: 1, self_code: 100, nonself_code: 101, received_amount: 1000, description: 'test'}
          @journal.self_update_and_update_account_balance_in_simple_entry(@user, journal_params)
          @account = Account.find(1)
          @other_account = Account.find(2)
        end

        it '仕訳のレコード数が変わっていない' do
          expect(Journal.all.length).to eq 1
        end
        it '勘定科目の残高が変わっていない' do
          (1..12).to_a.each do |mon|
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

    describe 'delete_after_updating_balance' do
      before do
        @user = create(:user, year: 2021)
        account = create(:account, user: @user)
        other_account = create(:account, user: @user, code: 101, name: 'test')
        hash = {}
        other_hash = {}
        (1..12).to_a.each do |mon|
          hash["debit_balance_#{mon}"] = 1000
          hash["credit_balance_#{mon}"] = 2000
          hash["opening_balance_#{mon}"] = 10000
          other_hash["debit_balance_#{mon}"] = 3000
          other_hash["credit_balance_#{mon}"] = 4000
          other_hash["opening_balance_#{mon}"] = 20000
        end
        account.update(hash)
        other_account.update(other_hash)
        journal = create(:journal, date: Date.new(2021,2,1), user: @user, debit: account, credit: other_account)
        journal.delete_after_updating_balance
        @account = Account.find(1)
        @other_account = Account.find(2)
      end

      it '借方科目の貸方残高は変わっていない' do
        (1..12).to_a.each do |mon|
          expect(@account.send("credit_balance_#{mon}")).to eq 2000
        end
      end
      it '貸方科目の借方残高は変わっていない' do
        (1..12).to_a.each do |mon|
          expect(@other_account.send("debit_balance_#{mon}")).to eq 3000
        end
      end
      it '借方科目の削除仕訳月以前の期首残高、削除仕訳月より前の借方残高は変わっていない' do
        expect(@account.opening_balance_1).to eq 10000
        expect(@account.opening_balance_2).to eq 10000
        expect(@account.debit_balance_1).to eq 1000
      end
      it '貸方科目の削除仕訳月以前の期首残高、削除仕訳月より前の貸方残高は変わっていない' do
        expect(@other_account.opening_balance_1).to eq 20000
        expect(@other_account.opening_balance_2).to eq 20000
        expect(@other_account.credit_balance_1).to eq 4000
      end
      it '借方科目の削除仕訳月の借方残高、削除仕訳月より後の期首残高は変わっている' do
        expect(@account.debit_balance_2).to eq 500
        (3..12).to_a.each do |mon|
          expect(@account.send("opening_balance_#{mon}")).to eq 9500
        end
      end
      it '貸方科目の削除仕訳月の貸方残高、削除仕訳月より後の期首残高は変わっている' do
        expect(@other_account.credit_balance_2).to eq 3500
        (3..12).to_a.each do |mon|
          expect(@other_account.send("opening_balance_#{mon}")).to eq 20500
        end
      end
      it '仕訳が削除されている' do
        expect(Journal.all.length).to eq 0
      end
    end
  end
end