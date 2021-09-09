# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '仕訳モデルに関するテスト', type: :model do

  describe 'バリデーションのテスト' do
    let(:user) { create(:user) }
    let(:account) { create(:account, user: user) }
    let(:journal) { build(:journal, user: user, debit: account, credit: account) }
    subject { journal.valid? }

    context 'テストデータが正しく保存されることのテスト' do
      it 'journal' do
        journal
        is_expected.to eq true
      end
    end

    context '空白登録できないことのテスト' do

      it 'dateカラム' do
        journal.date = ''
        is_expected.to eq false
      end
      it 'amountカラム' do
        journal.amount = ''
        is_expected.to eq false
      end
    end

    context '空白登録できることのテスト' do
      it 'descriptionカラム' do
        journal.description = ''
        is_expected.to eq true
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'ユーザモデルとの関係' do
      it 'N:1となっている' do
        expect(Journal.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end

    context '勘定科目モデルとの関係' do
      it '借方科目がN:1となっている' do
        expect(Journal.reflect_on_association(:debit).macro).to eq :belongs_to
      end
      it '貸方科目がN:1となっている' do
        expect(Journal.reflect_on_association(:credit).macro).to eq :belongs_to
      end
    end
  end

end