# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '勘定科目モデルに関するテスト', type: :model do

  describe 'バリデーションのテスト' do
    let(:user) { create(:user) }
    let(:account) { build(:account, user: user) }
    subject { account.valid? }

    context 'テストデータが正しく保存されることのテスト' do
      it 'account' do
        account
        is_expected.to eq true
      end
    end

    context '空白登録できないことのテスト' do

      it 'codeカラム' do
        account.code = ''
        is_expected.to eq false
      end
      it 'nameカラム' do
        account.name = ''
        is_expected.to eq false
      end
      it 'yearカラム' do
        account.year = ''
        is_expected.to eq false
      end
      it 'total_accountカラム' do
        account.total_account = ''
        is_expected.to eq false
      end
      it 'user_idカラム' do
        account.user_id = ''
        is_expected.to eq false
      end
    end

    context '一意性のテスト' do
      it 'user,year,codeの組み合わせは一意であることのテスト' do
        create(:account, user: user)
        account
        is_expected.to eq false
      end
    end
  end

  describe '初期値のテスト' do
    let!(:account) { create(:account) }

    it '残高の初期値' do
      expect(account.opening_balance_1).to eq 0
      expect(account.debit_balance_1).to eq 0
      expect(account.credit_balance_1).to eq 0
      expect(account.opening_balance_2).to eq 0
      expect(account.debit_balance_2).to eq 0
      expect(account.credit_balance_2).to eq 0
      expect(account.opening_balance_3).to eq 0
      expect(account.debit_balance_3).to eq 0
      expect(account.credit_balance_3).to eq 0
      expect(account.opening_balance_4).to eq 0
      expect(account.debit_balance_4).to eq 0
      expect(account.credit_balance_4).to eq 0
      expect(account.opening_balance_5).to eq 0
      expect(account.debit_balance_5).to eq 0
      expect(account.credit_balance_5).to eq 0
      expect(account.opening_balance_6).to eq 0
      expect(account.debit_balance_6).to eq 0
      expect(account.credit_balance_6).to eq 0
      expect(account.opening_balance_7).to eq 0
      expect(account.debit_balance_7).to eq 0
      expect(account.credit_balance_7).to eq 0
      expect(account.opening_balance_8).to eq 0
      expect(account.debit_balance_8).to eq 0
      expect(account.credit_balance_8).to eq 0
      expect(account.opening_balance_9).to eq 0
      expect(account.debit_balance_9).to eq 0
      expect(account.credit_balance_9).to eq 0
      expect(account.opening_balance_10).to eq 0
      expect(account.debit_balance_10).to eq 0
      expect(account.credit_balance_10).to eq 0
      expect(account.opening_balance_11).to eq 0
      expect(account.debit_balance_11).to eq 0
      expect(account.credit_balance_11).to eq 0
      expect(account.opening_balance_12).to eq 0
      expect(account.debit_balance_12).to eq 0
      expect(account.credit_balance_12).to eq 0
    end
  end

  describe 'アソシエーションのテスト' do
    context 'ユーザモデルとの関係' do
      it 'N:1となっている' do
        expect(Account.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end

    context '仕訳モデルとの関係' do
      it '借方科目が1:Nとなっている' do
        expect(Account.reflect_on_association(:debit_journals).macro).to eq :has_many
      end
      it '貸方科目が1:Nとなっている' do
        expect(Account.reflect_on_association(:credit_journals).macro).to eq :has_many
      end
    end

    context '仕訳取込モデルとの関係' do
      it '借方科目が1:Nとなっている' do
        expect(Account.reflect_on_association(:debit_imports).macro).to eq :has_many
      end
      it '貸方科目が1:Nとなっている' do
        expect(Account.reflect_on_association(:credit_imports).macro).to eq :has_many
      end
    end
  end

  describe 'メソッドのテスト' do
    describe 'update_balance' do
      before do
        user = create(:user, year: 2021)
        @account = create(:account, user: user)
        @other_account = create(:account, user: user, code: 101, total_account: 'カード')
        (1..12).to_a.each do |mon|
          @account.update("debit_balance_#{mon}".to_sym => 1000)
          @account.update("credit_balance_#{mon}".to_sym => 2000)
          @account.update("opening_balance_#{mon}".to_sym => 10000)
          @other_account.update("debit_balance_#{mon}".to_sym => 3000)
          @other_account.update("credit_balance_#{mon}".to_sym => 4000)
          @other_account.update("opening_balance_#{mon}".to_sym => 20000)
        end
      end

      context '借方の場合' do
        before do
          @account.update_balance(500, 2, 'debit')
          @other_account.update_balance(500, 2, 'debit')
        end
        it '指定月以前の期首残高、指定月以外の借方残高は変わっていない' do
          expect(@account.opening_balance_1).to eq 10000
          expect(@account.opening_balance_2).to eq 10000
          expect(@account.debit_balance_1).to eq 1000
          expect(@other_account.opening_balance_1).to eq 20000
          expect(@other_account.opening_balance_2).to eq 20000
          expect(@other_account.debit_balance_1).to eq 3000
          (3..12).to_a.each do |mon|
            expect(@account.send("debit_balance_#{mon}")).to eq 1000
            expect(@other_account.send("debit_balance_#{mon}")).to eq 3000
          end
        end
        it '貸方残高は変わっていない' do
          (1..12).to_a.each do |mon|
            expect(@account.send("credit_balance_#{mon}")).to eq 2000
            expect(@other_account.send("credit_balance_#{mon}")).to eq 4000
          end
        end
        it '指定月の借方残高が変わっている' do
          expect(@account.debit_balance_2).to eq 1500
          expect(@other_account.debit_balance_2).to eq 3500
        end
        it '指定月より後の期首残高が変わっている' do
          (3..12).to_a.each do |mon|
            expect(@account.send("opening_balance_#{mon}")).to eq 10500
            expect(@other_account.send("opening_balance_#{mon}")).to eq 19500
          end
        end
      end

      context '貸方の場合' do
        before do
          @account.update_balance(500, 2, 'credit')
          @other_account.update_balance(500, 2, 'credit')
        end
        it '指定月以前の期首残高、指定月以外の貸方残高は変わっていない' do
          expect(@account.opening_balance_1).to eq 10000
          expect(@account.opening_balance_2).to eq 10000
          expect(@account.credit_balance_1).to eq 2000
          expect(@other_account.opening_balance_1).to eq 20000
          expect(@other_account.opening_balance_2).to eq 20000
          expect(@other_account.credit_balance_1).to eq 4000
          (3..12).to_a.each do |mon|
            expect(@account.send("credit_balance_#{mon}")).to eq 2000
            expect(@other_account.send("credit_balance_#{mon}")).to eq 4000
          end
        end
        it '借方残高は変わっていない' do
          (1..12).to_a.each do |mon|
            expect(@account.send("debit_balance_#{mon}")).to eq 1000
            expect(@other_account.send("debit_balance_#{mon}")).to eq 3000
          end
        end
        it '指定月の貸方残高が変わっている' do
          expect(@account.credit_balance_2).to eq 2500
          expect(@other_account.credit_balance_2).to eq 4500
        end
        it '指定月より後の期首残高が変わっている' do
          (3..12).to_a.each do |mon|
            expect(@account.send("opening_balance_#{mon}")).to eq 9500
            expect(@other_account.send("opening_balance_#{mon}")).to eq 20500
          end
        end
      end
    end

    context 'update_opening_balance' do
      it '勘定科目の期首残高を更新すると2月以降も更新される' do
        user = create(:user, year: 2021)
        account = create(:account, user: user)
        (1..12).to_a.each do |mon|
          account.update("opening_balance_#{mon}".to_sym => (mon * 100))
        end
        prev_balance = account.opening_balance_1
        account.update(opening_balance_1: 101)
        account.update_opening_balance(prev_balance)

        (2..12).to_a.each do |mon|
          expect(account.send("opening_balance_#{mon}")).to eq (mon * 100 + 1)
        end
      end
    end

    context 'return_balances' do
      it '月から[期首残高, 借方残高, 貸方残高, 期末残高]を返す' do
        user = create(:user, year: 2021)
        account = create(:account, user: user)
        other_account = create(:account, user: user, code: 101, total_account: 'カード')
        (1..12).to_a.each do |mon|
          account.update("opening_balance_#{mon}".to_sym => 50 * (mon * mon - mon + 2))
          account.update("debit_balance_#{mon}".to_sym => (mon * 200))
          account.update("credit_balance_#{mon}".to_sym => (mon * 100))
          other_account.update("opening_balance_#{mon}".to_sym => 50 * (mon * mon - mon + 2))
          other_account.update("debit_balance_#{mon}".to_sym => (mon * 100))
          other_account.update("credit_balance_#{mon}".to_sym => (mon * 200))
        end

        expect(account.return_balances(2, 4)).to eq [200, 1800, 900, 1100]
        expect(other_account.return_balances(2, 4)).to eq [200, 900, 1800, 1100]
      end
    end

    context 'return_transition_balances' do
      it '月から[1月 .. 12月, 累計残高, 平均残高]を返す' do
        user = create(:user, year: 2021)
        account = create(:account, user: user)
        other_account = create(:account, user: user, code: 101, total_account: 'カード')
        (1..12).to_a.each do |mon|
          account.update("opening_balance_#{mon}".to_sym => 50 * (mon * mon - mon + 2))
          account.update("debit_balance_#{mon}".to_sym => (mon * 200))
          account.update("credit_balance_#{mon}".to_sym => (mon * 100))
          other_account.update("opening_balance_#{mon}".to_sym => 50 * (mon * mon - mon + 2))
          other_account.update("debit_balance_#{mon}".to_sym => (mon * 100))
          other_account.update("credit_balance_#{mon}".to_sym => (mon * 200))
        end

        expect(account.return_transition_balances(5)).to eq [100, 200, 300, 400, 500, 0, 0, 0, 0, 0, 0, 0, 1500, 300]
        expect(other_account.return_transition_balances(5)).to eq [100, 200, 300, 400, 500, 0, 0, 0, 0, 0, 0, 0, 1500, 300]
      end
    end

    context 'balance_array_from_1_to_12' do
      it '1月から12月までの残高を返す' do
        user = create(:user, year: 2021)
        account = create(:account, user: user)
        other_account = create(:account, user: user, code: 101, total_account: 'カード')
        (1..12).to_a.each do |mon|
          account.update("opening_balance_#{mon}".to_sym => 50 * (mon * mon - mon + 2))
          account.update("debit_balance_#{mon}".to_sym => (mon * 200))
          account.update("credit_balance_#{mon}".to_sym => (mon * 100))
          other_account.update("opening_balance_#{mon}".to_sym => 50 * (mon * mon - mon + 2))
          other_account.update("debit_balance_#{mon}".to_sym => (mon * 100))
          other_account.update("credit_balance_#{mon}".to_sym => (mon * 200))
        end

        expect(account.balance_array_from_1_to_12).to eq [200, 400, 700, 1100, 1600, 2200, 2900, 3700, 4600, 5600, 6700, 7900]
        expect(other_account.balance_array_from_1_to_12).to eq [200, 400, 700, 1100, 1600, 2200, 2900, 3700, 4600, 5600, 6700, 7900]
      end
    end
  end
end