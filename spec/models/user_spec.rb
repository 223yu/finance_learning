# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ユーザモデルに関するテスト', type: :model do

  describe 'バリデーションのテスト' do
    let(:user) { build(:user) }
    let!(:other_user) { create(:user) }
    subject { user.valid? }

    context 'テストデータが正しく保存されることのテスト' do
      it 'user' do
        user
        is_expected.to eq true
      end
      it 'other_user' do
        other_user
        is_expected.to eq true
      end
    end

    context '空白登録できないことのテスト' do

      it 'nameカラム' do
        user.name = ''
        is_expected.to eq false
      end
      it 'emailカラム' do
        user.email = ''
        is_expected.to eq false
      end
      it 'yearカラム' do
        user.year = ''
        is_expected.to eq false
      end
    end

    context '一意性のテスト' do
      it 'emailカラム' do
        user.email = other_user.email
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context '学習モデルとの関係' do
      it '1:Nとなっている' do
        expect(User.reflect_on_association(:learnings).macro).to eq :has_many
      end
    end

    context '仕訳モデルとの関係' do
      it '1:Nとなっている' do
        expect(User.reflect_on_association(:journals).macro).to eq :has_many
      end
    end

    context '勘定科目モデルとの関係' do
      it '1:Nとなっている' do
        expect(User.reflect_on_association(:accounts).macro).to eq :has_many
      end
    end

    context '仕訳取込モデルとの関係' do
      it '1:Nとなっている' do
        expect(User.reflect_on_association(:imports).macro).to eq :has_many
      end
    end
  end

  describe 'メソッドのテスト' do
    let(:user) { build(:user) }
    let!(:other_user) { create(:user) }

    context 'has_year?' do
      it '初期状態ではfalseが返る' do
        expect(user.has_year?).to eq false
      end
      it 'year != 0の時trueが返る' do
        user.year = 2021
        expect(user.has_year?).to eq true
      end
    end

    context 'has_years' do
      it 'ユーザが持つ全ての年度データを返す' do
        create(:account, user: other_user)
        create(:account, user: other_user, year: 2022)
        expect(other_user.has_years).to eq [2021,2022]
      end
    end

    context 'start_date' do
      it 'ユーザの持つ年度、入力月から月初日を返す' do
        user.year = 2021
        expect(user.start_date(1).to_s).to eq '2021-01-01 00:00:00 +0000'
      end
    end

    context 'end_date' do
      it 'ユーザの持つ年度、入力月から月末日を返す' do
        user.year = 2021
        expect(user.end_date(1).to_s).to eq '2021-01-31 23:59:59 +0000'
      end
    end

    context 'start_date_to_end_date' do
      it 'ユーザの持つ年度、開始月、終了月から期間を返す' do
        user.year = 2021
        expect(user.start_date_to_end_date(1,12).to_s).to eq '2021-01-01 00:00:00 +0000..2021-12-31 23:59:59 +0000'
      end
    end

    context 'accounts_index' do
      it '勘定科目の一覧を返す' do
        user = create(:user, year: 2021)
        create(:account, user: user, year: 2021)
        create(:account, user: user, year: 2021, code: 101)
        expect(user.accounts_index).to eq [['100 テスト', 100],['101 テスト', 101]]
      end
    end

    context 'accounts_setting' do
      before do
        user.accounts_setting(2021)
      end
      it '年度が変更されている' do
        expect(user.year).to eq 2021
      end
      it '初期勘定科目リストの勘定科目が作成されている' do
        expect(user.accounts_index.length).to eq 67
      end
    end

    describe 'update_year' do
      before do
        @user = create(:user, year: 2021)
        @user.accounts_setting(2021)
        Account.where(user: @user, year: 2021).update_all(opening_balance_12: 500)
        @user.year = 2022
      end

      context '科目設定に翌年のカラムが存在する場合' do
        before do
          # 初期設定にあるコードをサンプルとして作成
          @exist_account = create(:account, user: @user, year: 2022, code: 101)
          @exist_account.update(opening_balance_1: 1000)
          # 初期設定にないコードをサンプルとして作成
          @not_exist_account = create(:account, user: @user, year: 2022, code: 999)
          @not_exist_account.update(opening_balance_1: 1000)
          @user.update_year(2021)
        end

        it '翌年のカラム数が1つ増えている' do
          expect(@user.accounts_index.length).to eq 68
        end

        it '初期設定にあるコードの残高は引き継いでいる' do
          expect(Account.find(@exist_account.id).opening_balance_1).to eq 500
        end

        it '初期設定にないコードの残高は変わっていない' do
          expect(Account.find(@not_exist_account.id).opening_balance_1).to eq 1000
        end

        it '更新にて新たに作成したコードの残高は引き継いでいる' do
          expect(Account.find_by(user: @user, year: 2022, code: 111).opening_balance_1).to eq 500
        end

        it '損益科目の場合期首残高を引き継がない' do
          expect(Account.find_by(user: @user, year: 2022, code: 410).opening_balance_1).to eq 0
        end

      end
      context '科目設定に翌年のカラムが存在しない場合' do
        before do
          @user.update_year(2021)
        end

        it '翌年のカラム数が同じである' do
          expect(@user.accounts_index.length).to eq 67
        end

        it '貸借科目の場合期首残高を引き継いでいる' do
          expect(Account.find_by(user: @user, year: 2022, code: 101).opening_balance_1).to eq 500
        end

        it '損益科目の場合期首残高を引き継がない' do
          expect(Account.find_by(user: @user, year: 2022, code: 410).opening_balance_1).to eq 0
        end
      end
    end

    context 'code_id' do
      it '勘定科目コードから勘定科目idを返す' do
        user = create(:user, year: 2021)
        account = create(:account, user: user)
        expect(user.code_id(account.code)).to eq account.id
      end
    end

    context 'has_journal_in_this_year?' do
      before do
        @user = create(:user, year: 2021)
        @account = create(:account, user: @user)
        @other_account = create(:account, user: @user, code: 999)
        create(:journal, user: @user, debit: @account, credit: @account)
      end
      it '指定した科目の仕訳が今期中に存在しなければfalseを返す' do
        expect(@user.has_journal_in_this_year?(@other_account)).to eq false
      end
      it '指定した科目の仕訳が今期中に存在すればtrueを返す' do
        expect(@user.has_journal_in_this_year?(@account)).to eq true
      end
    end

    context 'accounts_index_from_total_account' do
      it '合計科目から勘定科目の一覧を返す' do
        user = create(:user, year: 2021)
        create(:account, user: user)
        create(:account, user: user, code: 101)
        create(:account, user: user, code: 999, total_account: '他流動資産')

        expect(user.accounts_index_from_total_account('現預金')).to eq [['100 テスト', 100],['101 テスト', 101]]
        expect(user.accounts_index_from_total_account('他流動資産')).to eq [['999 テスト', 999]]
      end
    end

    context 'journal_index_from_self_code' do
      before do
        @user = create(:user, year: 2021)
        account = create(:account, user: @user)
        other_account = create(:account, user: @user, code: 101)
        @journal1 = create(:journal, user: @user, debit: account, credit: account)
        @journal2 = create(:journal, user: @user, debit: account, credit: other_account)
        # 条件に合致しないレコードを検証用に2つ作成
        create(:journal, user: @user, debit: other_account, credit: other_account)
        create(:journal, user: @user, debit: account, credit: account, date: Date.new(2022,1,1))
        @range = @user.start_date_to_end_date(1,12)
      end
      it '科目に対する仕訳の一覧を返す' do
        array = []
        expect(@user.journal_index_from_self_code(100, @range, 0).map{ |j| j.reload.attributes }).to eq array.push(@journal1.reload.attributes).push(@journal2.reload.attributes)
      end

      it '総勘定元帳にて科目に対する仕訳の一覧を返す' do
        array = []
        expect(@user.journal_index_from_self_code_in_ledger(100, @range).map{ |j| j.reload.attributes }).to eq array.push(@journal1.reload.attributes).push(@journal2.reload.attributes)
      end
    end

    context 'return_balance_array' do
      it '選択した合計科目の期末残高の推移を返す' do
        user = create(:user, year: 2021)
        account = create(:account, user: user)
        other_account = create(:account, user: user, code: 101)
        (1..12).to_a.each do |mon|
          account.update("opening_balance_#{mon}".to_sym => (mon - 1))
          other_account.update("opening_balance_#{mon}".to_sym => (mon - 1))
        end
        account.update(debit_balance_12: 1)
        other_account.update(debit_balance_12: 1)

        expect(user.return_balance_array('現預金')).to eq [2,4,6,8,10,12,14,16,18,20,22,24]
      end
    end

    context 'return_profit_balance_array' do
      it '利益の発生残高の推移を返す' do
        user = create(:user, year: 2021)
        profit_account = create(:account, user: user, code: 101, total_account: '収入')
        other_profit_account = create(:account, user: user, code: 102, total_account: '収入')
        # 検証用に貸借の科目も一つ作成
        balance_account = create(:account, user: user)
        (1..12).to_a.each do |mon|
          profit_account.update("credit_balance_#{mon}".to_sym => (mon * 3))
          profit_account.update("debit_balance_#{mon}".to_sym => mon)
          other_profit_account.update("credit_balance_#{mon}".to_sym => (mon * 3))
          other_profit_account.update("debit_balance_#{mon}".to_sym => mon)
          balance_account.update("credit_balance_#{mon}".to_sym => (mon * 3))
          balance_account.update("debit_balance_#{mon}".to_sym => mon)
        end

        expect(user.return_profit_balance_array).to eq [4,8,12,16,20,24,28,32,36,40,44,48]
      end
    end

    context 'learned?' do
      before do
        @user = create(:user)
        @content = create(:content)
      end
      it '学習済みであればtrueを返す' do
        create(:learning, user: @user, content: @content)
        expect(@user.learned?(@content)).to eq true
      end

      it '学習済みでなければfalseを返す' do
        expect(@user.learned?(@content)).to eq false
      end
    end
  end
end
