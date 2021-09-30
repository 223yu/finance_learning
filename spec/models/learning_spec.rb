# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '学習モデルに関するテスト', type: :model do

  describe 'バリデーションのテスト' do
    let!(:user) { create(:user) }
    let!(:content) { create(:content) }
    let(:learning){ build(:learning, user: user, content: content) }
    subject { learning.valid? }

    context 'テストデータが正しく保存されることのテスト' do
      it 'import' do
        learning
        is_expected.to eq true
      end
    end

    context '空白登録できないことのテスト' do
      it 'user_idカラム' do
        learning.user_id = ''
        is_expected.to eq false
      end
      it 'content_idカラム' do
        learning.content_id = ''
        is_expected.to eq false
      end
    end

    context '一意性のテスト' do
      it 'user,contentの組み合わせは一意であることのテスト' do
        create(:learning, user: user, content: content)
        learning
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'ユーザモデルとの関係' do
      it 'N:1となっている' do
        expect(Learning.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end

    context '学習コンテンツモデルとの関係' do
      it '借方科目がN:1となっている' do
        expect(Learning.reflect_on_association(:content).macro).to eq :belongs_to
      end
    end
  end
end