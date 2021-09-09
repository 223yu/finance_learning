# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '学習コンテンツモデルに関するテスト', type: :model do

  describe 'バリデーションのテスト' do
    let(:content) { build(:content) }
    subject { content.valid? }

    context 'テストデータが正しく保存されることのテスト' do
      it 'content' do
        content
        is_expected.to eq true
      end
    end

    context '空白登録できないことのテスト' do

      it 'titleカラム' do
        content.title = ''
        is_expected.to eq false
      end
      it 'bodyカラム' do
        content.body = ''
        is_expected.to eq false
      end
    end
  end

  describe '初期値のテスト' do
    let!(:content) { create(:content) }

    it 'ユーザ限定コンテンツの初期値' do
      expect(content.user_limited).to eq true
    end
  end

  describe 'アソシエーションのテスト' do
    context '学習モデルとの関係' do
      it '1:Nとなっている' do
        expect(Content.reflect_on_association(:learnings).macro).to eq :has_many
      end
    end
  end

end