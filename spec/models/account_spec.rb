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

end