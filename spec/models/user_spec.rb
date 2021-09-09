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

end
